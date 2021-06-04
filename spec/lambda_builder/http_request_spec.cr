require "../spec_helper"

describe Lambda::Builder::HTTPRequest do
  it "parses properly" do
    ENV["_HANDLER"] = "foo"
    input = JSON.parse(request_body)
    req = Lambda::Builder::HTTPRequest.new(input)
    req.method.should eq "POST"
    req.path.should eq "/hello"
    req.headers["User-Agent"].should eq "curl/7.54.0"
    req.headers.size.should eq 16
    req.body.to_s.should eq %q({"foo":"bar"})
    req.request_context["path"].should eq "/dev/hello"
    req.handler.should eq "foo"
    req.query_params.size.should eq 1
    req.query_params["test"].should eq "bar"
  end

  it "parses api gateway v2 (HTTP gateway)" do
    ENV["_HANDLER"] = "foo"
    input = JSON.parse(request_body_v2)
    req = Lambda::Builder::HTTPRequest.new(input)
    req.method.should eq "OPTIONS"
    req.path.should eq "/hi"
  end

  it "works with empty body and query string" do
    body = %q({ "path" : "/test", "httpMethod" : "GET", "headers" : { "key": "value" }, "requestContext" : {} })
    response = HTTP::Client::Response.new(200, body, HTTP::Headers.new)
    input = JSON.parse response.body
    req = Lambda::Builder::HTTPRequest.new(input)

    req.headers.size.should eq 1
    req.headers["key"].should eq "value"
    req.body.should eq nil
  end

  it "supports JSON serialization/deserialization" do
    body = %q({ "path" : "/test", "httpMethod" : "GET", "headers" : { "key": "value" }, "requestContext" : {} })
    ENV["_HANDLER"] = "my_handler"
    input = JSON.parse body
    req = Lambda::Builder::HTTPRequest.new(input)
    json = req.to_json
    parsed_req = Lambda::Builder::HTTPRequest.from_json json.to_s
    req.headers.should eq parsed_req.headers
    req.to_json.should eq parsed_req.to_json
    req.method.should eq parsed_req.method
    req.method.should eq "GET"
    req.path.should eq parsed_req.path
    req.path.should eq "/test"
  end
end
