require "http"
require "log"
require "./http_request"
require "./http_response"

module Lambda::Builder
  class Runtime
    getter host : String
    getter port : Int16
    getter handlers : Hash(String, (String -> String)) = Hash(String, (String -> String)).new
    Log = ::Log.for(self)

    def initialize
      api = ENV["AWS_LAMBDA_RUNTIME_API"].split(":", 2)

      @host = api[0]
      @port = api[1].to_i16
    end

    # Associate the block/proc to the function name
    def register_handler(name : String, &handler : String -> String)
      self.handlers[name] = handler
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

    def _process_request(proc : Proc(String, String))
      client = HTTP::Client.new(host: @host, port: @port)

      begin
        response = client.get "/2018-06-01/runtime/invocation/next"
        ENV["_X_AMZN_TRACE_ID"] = response.headers["Lambda-Runtime-Trace-Id"] || ""

        aws_request_id = response.headers["Lambda-Runtime-Aws-Request-Id"]
        base_url = "/2018-06-01/runtime/invocation/#{aws_request_id}"

        # input = JSON.parse response.body
        # body = proc.call input
        body = proc.call response.body

        Log.info { "preparing body #{body}" }
        response = client.post("#{base_url}/response", body: body)
        Log.debug { "response invocation response #{response.status_code} #{response.body}" }
      rescue ex
        body = %Q({ "statusCode": 500, "body" : "#{ex.message}" })
        response = client.post("#{base_url}/error", body: body)
        Log.error { "response error invocation response from exception " \
                    "#{ex.message} #{response.status_code} #{response.body}" }
      ensure
        client.close
      end
    end
  end
end
