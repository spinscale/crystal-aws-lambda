require "spec"
require "../src/lambda"
require "webmock"
require "http"
require "json"

def mock_next_invocation(body : String)
  WebMock.stub(:get, "http://localhost/2018-06-01/runtime/invocation/next").
    to_return(status: 200, body: body, headers: {"Lambda-Runtime-Aws-Request-Id" => "54321", "Lambda-Runtime-Trace-Id" => "TRACE-ID", "Content-Type": "application/json"})
end

describe Lambda do

  io = IO::Memory.new()
  logger = Logger.new(io, level: Logger::INFO)

  Spec.before_each do
    WebMock.reset
    ENV["AWS_LAMBDA_RUNTIME_API"] = "localhost:80"
    ENV["_HANDLER"] = "handler"
    io.clear
  end

  it "can read the runtime API from the environment" do
    ENV["AWS_LAMBDA_RUNTIME_API"] = "my-host:12345"
    lambda = Lambda.new(logger)
    lambda.host.should eq "my-host"
    lambda.port.should eq 12345
  end

  it "should be able to register a handler as proc" do
    lambda = Lambda.new(logger)
    handler = ->(_input: JSON::Any) {
      JSON.parse LambdaHttpResponse.new(200).to_json
    }
    lambda.register_handler("test", handler)
    lambda.handlers["test"].should eq handler
  end

  it "should be able to register a scheduled event" do
    lambda = Lambda.new(logger)
    lambda.register_handler("test", -> (_input: JSON::Any) {
      return JSON.parse(%q({ "foo" : "bar"}))
    })
    lambda.handlers["test"].should_not be_nil
  end

  it "can run with a scheduled event" do
    body = %Q({ "input" : { "test" : "test" }})
    mock_next_invocation body

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |request|
      req = JSON.parse request.body.to_s
      req.as(JSON::Any)["foo"].as_s.should eq "bar"
      HTTP::Client::Response.new(202)
    end

    lambda = Lambda.new(logger)
    lambda.process_request(Proc(JSON::Any, JSON::Any).new { |_input|
      return JSON.parse(%q({ "foo" : "bar" }))
    })

  end

  it "can return text responses including header" do
    body = %Q({ "body" : "This is my body", "headers" : { "foo": "bar" }, "path" : "/my-test-path", "httpMethod": "POST", "requestContext" : {}})

    mock_next_invocation body

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |request|
      req = JSON.parse request.body.to_s
      req.as(JSON::Any)["statusCode"].as_i.should eq 200
      req.as(JSON::Any)["body"].as_s.should eq "text body"
      req.as(JSON::Any)["headers"]["Content-Type"].as_s.should eq "application/text"

      HTTP::Client::Response.new(202)
    end

    lambda = Lambda.new(logger)
    lambda.process_request(
      ->(_input: JSON::Any) {
        response = LambdaHttpResponse.new(200, "text body")
        response.headers["Content-Type"] = "application/text"
        JSON.parse response.to_json
      }
    )
  end

  it "can handle exceptions" do
    body = %Q({ "body" : "This is my body", "headers" : { "foo": "bar" }, "path" : "/my-test-path", "httpMethod": "POST", "requestContext" : {}})

    mock_next_invocation body

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/error").to_return do |request|
      req = JSON.parse request.body.to_s
      req.as(JSON::Any)["statusCode"].as_i.should eq 500
      req.as(JSON::Any)["body"].as_s.should eq "anything"
      HTTP::Client::Response.new(202)
    end

    lambda = Lambda.new(logger)
    lambda.process_request(
      ->(_input: JSON::Any) {
        raise "anything"
        JSON.parse "{}"
      }
    )
  end

  it "sets the environment x-ray trace id" do
    body = %Q({ "body" : "This is my body", "headers" : { "foo": "bar" }, "path" : "/my-test-path", "httpMethod": "POST", "requestContext" : {}})

    mock_next_invocation body

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |_request|
      HTTP::Client::Response.new(202)
    end

    lambda = Lambda.new(logger)
    lambda.process_request(
      ->(_input: JSON::Any) {
        JSON.parse "{}"
      }
    )

    ENV["_X_AMZN_TRACE_ID"].should eq "TRACE-ID"
  end

end
