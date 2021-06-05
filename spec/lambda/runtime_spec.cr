require "spec"
require "../spec_helper"

def mock_next_invocation(body : String)
  WebMock.stub(:get, "http://localhost/2018-06-01/runtime/invocation/next")
    .to_return(status: 200, body: body, headers: {"Lambda-Runtime-Aws-Request-Id" => "54321", "Lambda-Runtime-Trace-Id" => "TRACE-ID", "Content-Type": "application/json"})
end

describe Lambda::Runtime do
  io = IO::Memory.new

  Spec.before_each do
    WebMock.reset
    ENV["AWS_LAMBDA_RUNTIME_API"] = "localhost:80"
    ENV["_HANDLER"] = "my_handler"
    io.clear
  end

  it "can read the runtime API from the environment" do
    ENV["AWS_LAMBDA_RUNTIME_API"] = "my-host:12345"
    runtime = Lambda::Runtime.new
    runtime.host.should eq "my-host"
    runtime.port.should eq 12345
  end

  it "should be able to register a handler" do
    runtime = Lambda::Runtime.new
    # handler = do |_input| JSON.parse Lambda::Builder::HTTPResponse.new(200).to_json end
    runtime.register_handler("my_handler") do |_input|
      JSON.parse(%q({ "foo" : "bar"}))
    end
    runtime.handlers["my_handler"].should_not be_nil
  end

  it "can run with a JSON::Any handler" do
    body = %Q({ "input" : { "test" : "test" }})
    mock_next_invocation body

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |request|
      req = JSON.parse request.body.to_s
      req.as(JSON::Any)["foo"].as_s.should eq "bar"
      HTTP::Client::Response.new(202)
    end

    runtime = Lambda::Runtime.new
    runtime.register_handler("my_handler") do
      JSON.parse(%q({ "foo" : "bar" }))
    end
    runtime.process_handler
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

    runtime = Lambda::Runtime.new
    runtime.register_handler("my_handler") do
      response = Lambda::Builder::HTTPResponse.new(200, "text body")
      response.headers["Content-Type"] = "application/text"
      JSON.parse response.to_json
    end
    runtime.process_handler
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

    runtime = Lambda::Runtime.new
    runtime.register_handler("my_handler") do
      raise "anything"
    end
    runtime.process_handler
  end

  it "sets the environment x-ray trace id" do
    body = %Q({ "body" : "This is my body", "headers" : { "foo": "bar" }, "path" : "/my-test-path", "httpMethod": "POST", "requestContext" : {}})

    mock_next_invocation body

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |_request|
      HTTP::Client::Response.new(202)
    end

    runtime = Lambda::Runtime.new
    runtime.register_handler("my_handler") do
      JSON.parse "{}"
    end
    runtime.process_handler

    ENV["_X_AMZN_TRACE_ID"].should eq "TRACE-ID"
  end

  it "can run with a (String -> String) handler" do
    mock_next_invocation request_body_v2

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |request|
      request.body.to_s.should eq "Hi I'm a string"
      HTTP::Client::Response.new(202)
    end

    runtime = Lambda::Runtime.new
    runtime.register_handler("my_handler", String, String) do
      "Hi I'm a string"
    end
    runtime.process_handler
  end

  it "can run with a (HTTPRequest -> HTTPResponse) handler" do
    mock_next_invocation request_body

    expected = Lambda::Builder::HTTPResponse.new(200, "Hello from Crystal").as_json.to_json

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |request|
      request.body.to_s.should eq expected
      HTTP::Client::Response.new(202)
    end

    runtime = Lambda::Runtime.new
    runtime.register_handler("my_handler", Lambda::Builder::HTTPRequest, Lambda::Builder::HTTPResponse) do
      Lambda::Builder::HTTPResponse.new(200, "Hello from Crystal")
    end
    runtime.process_handler
  end

  it "can run with a (APIGatewayV2HTTPRequest -> APIGatewayV2HTTPResponse) handler" do
    mock_next_invocation request_body_v2

    expected = Lambda::Events::APIGatewayV2HTTPResponse.new(200, "yolo").to_json

    WebMock.stub(:post, "http://localhost/2018-06-01/runtime/invocation/54321/response").to_return do |request|
      request.body.to_s.should eq expected
      HTTP::Client::Response.new(202)
    end

    runtime = Lambda::Runtime.new

    runtime.register_handler("my_handler", Lambda::Events::APIGatewayV2HTTPRequest, Lambda::Events::APIGatewayV2HTTPResponse) do |input|
      response = Lambda::Events::APIGatewayV2HTTPResponse.new(200, "yolo")
      response
    end

    runtime.process_handler
  end
end
