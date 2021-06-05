require "http"
require "log"
require "./events"

module Lambda
  alias Handler = (String -> String) |
                   (JSON::Any -> JSON::Any) |
                   (Lambda::Builder::HTTPRequest -> Lambda::Builder::HTTPResponse) |
                   (Lambda::Events::APIGatewayV2HTTPRequest -> Lambda::Events::APIGatewayV2HTTPResponse)

  class Runtime
    getter host : String
    getter port : Int16
    getter handlers : Hash(String, Handler) = Hash(String, Handler).new
    Log = ::Log.for(self)

    def initialize
      api = ENV["AWS_LAMBDA_RUNTIME_API"].split(":", 2)

      @host = api[0]
      @port = api[1].to_i16
    end

    def register_handler(name : String, input : T.class, output : U.class, &block : T -> U) forall T, U
      handler = Proc(T, U).new &block
      raise "unsupported handler '#{typeof(handler)}'' must be typeof '#{typeof(Handler)}'" unless handler.is_a?(Handler)

      self.handlers[name] = handler
    end

    def register_handler(input : T.class, output : U.class, &block : T -> U) forall T, U
      register_handler("default", input, output, &block)
    end

    def register_handler(name : String, &block : JSON::Any -> JSON::Any)
      register_handler(name, JSON::Any, JSON::Any, &block)
    end

    def register_handler(&block : JSON::Any -> JSON::Any)
      register_handler("default", JSON::Any, JSON::Any, &block)
    end

    def run
      loop do
        process_handler
      end
    end

    def process_handler
      handler_name = ENV["_HANDLER"]

      if handlers.has_key?(handler_name)
        _process_request handlers[handler_name]
      else
        Log.error { "unknown handler: #{handler_name}, available handlers: #{handlers.keys.join(", ")}" }
      end
    end

    def execute_handler(handler : Handler, body)
      case handler
      in Proc(String, String)
        handler.call(body)
      in Proc(Lambda::Builder::HTTPRequest, Lambda::Builder::HTTPResponse)
        req = Lambda::Builder::HTTPRequest.new(JSON.parse(body))
        handler.call(req).as_json.to_json
      in Proc(Lambda::Events::APIGatewayV2HTTPRequest, Lambda::Events::APIGatewayV2HTTPResponse)
        request = Lambda::Events::APIGatewayV2HTTPRequest.from_json(body)
        handler.call(request).to_json
      in Proc(JSON::Any, JSON::Any)
        handler.call(JSON.parse(body)).to_json
      end
    end

    def _process_request(handler : Handler)
      client = HTTP::Client.new(host: @host, port: @port)

      begin
        invocation_response = client.get "/2018-06-01/runtime/invocation/next"
        ENV["_X_AMZN_TRACE_ID"] = invocation_response.headers["Lambda-Runtime-Trace-Id"] || ""

        aws_request_id = invocation_response.headers["Lambda-Runtime-Aws-Request-Id"]
        invocation_base_url = "/2018-06-01/runtime/invocation/#{aws_request_id}"

        handler_result = execute_handler(handler, invocation_response.body)

        Log.info { "preparing result response #{handler_result}" }

        result_response = client.post("#{invocation_base_url}/response", body: handler_result)

        Log.debug { "result_response #{result_response.status_code} #{result_response.body}" }
      rescue ex
        body = %Q({ "statusCode": 500, "body" : "#{ex.message}" })
        response = client.post("#{invocation_base_url}/error", body: body)
        Log.error { "response error invocation response from exception " \
                    "#{ex.message} #{response.status_code} #{response.body}" }
      ensure
        client.close
      end
    end
  end
end
