require "../../spec_helper"

describe Lambda::Builder::HTTPResponse do
  it "always returns status code" do
    json = JSON.parse Lambda::Builder::HTTPResponse.new(123).to_json
    json["statusCode"].as_i.should eq 123
    json["body"]?.should be_nil
  end

  it "can contain a body as text" do
    text = "my text"
    json = JSON.parse Lambda::Builder::HTTPResponse.new(200, text).to_json
    json["body"]?.should eq text
  end

  it "can contain a body as json" do
    input = JSON.parse "{ \"foo\" : \"bar\" }"
    json = JSON.parse Lambda::Builder::HTTPResponse.new(200, input).to_json
    json["body"]["foo"]?.should eq "bar"
  end

  it "can contain additional headers" do
    response = Lambda::Builder::HTTPResponse.new(200, "body")
    response.headers["Content-Type"] = "application/text"
    json = JSON.parse response.to_json
    json["headers"]["Content-Type"]?.should eq "application/text"
  end

  it "can return a JSON::Any object" do
    response = Lambda::Builder::HTTPResponse.new(200, "body")
    response.headers["Content-Type"] = "application/text"
    json = response.as_json
    json.should be_a(JSON::Any)
    json.as_h["headers"]["Content-Type"]?.should eq "application/text"
  end
end
