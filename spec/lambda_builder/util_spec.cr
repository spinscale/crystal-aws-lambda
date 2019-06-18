require "spec"
require "../../src/lambda_builder"

describe Lambda::Builder::Util do
  body = %q({"resource":"/hello","path":"/hello","httpMethod":"POST","headers":{"Accept":"*/*","CloudFront-Forwarded-Proto":"https","CloudFront-Is-Desktop-Viewer":"true","CloudFront-Is-Mobile-Viewer":"false","CloudFront-Is-SmartTV-Viewer":"false","CloudFront-Is-Tablet-Viewer":"false","CloudFront-Viewer-Country":"DE","content-type":"application/x-www-form-urlencoded","Host":"my-host.execute-api.us-east-1.amazonaws.com","User-Agent":"curl/7.54.0","Via":"2.0 my-id.cloudfront.net (CloudFront)","X-Amzn-Trace-Id":"Root=1-11-111","X-Forwarded-For":"1.143.1.124, 216.1.60.1","X-Forwarded-Port":"443","X-Forwarded-Proto":"https"},"multiValueHeaders":{"Accept":["*/*"],"CloudFront-Forwarded-Proto":["https"],"CloudFront-Is-Desktop-Viewer":["true"],"CloudFront-Is-Mobile-Viewer":["false"],"CloudFront-Is-SmartTV-Viewer":["false"],"CloudFront-Is-Tablet-Viewer":["false"],"CloudFront-Viewer-Country":["DE"],"content-type":["application/x-www-form-urlencoded"],"Host":["my-host.execute-api.us-east-1.amazonaws.com"],"User-Agent":["curl/7.54.0"],"Via":["2.0 my-id.cloudfront.net (CloudFront)"],"X-Amzn-Trace-Id":["Root=TRACE-ID"],"X-Forwarded-For":["1.143.1.124, 216.1.60.1"],"X-Forwarded-Port":["443"],"X-Forwarded-Proto":["https"]},"queryStringParameters":{"test":"bar"},"multiValueQueryStringParameters":{"test":["bar"]},"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"i70nco","resourcePath":"/hello","httpMethod":"POST","extendedRequestId":"extendedRequestID","requestTime":"14/Dec/2018:20:56:07 +0000","path":"/dev/hello","protocol":"HTTP/1.1","stage":"dev","domainPrefix":"my-hsot","requestTimeEpoch":1544820967605,"requestId":"abcdefg-ffe2-11e8-a78f-1111","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"1.1.1.1","accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"curl/7.54.0","user":null},"domainName":"my-host.execute-api.us-east-1.amazonaws.com","apiId":"my-host"},"body":"{\"foo\":\"bar\"}","isBase64Encoded":false})

  describe "LambdaHTTPRequest" do
    it "parses properly" do
      ENV["_HANDLER"] = "foo"
      input = JSON.parse body
      req = Lambda::Builder::Util::LambdaHttpRequest.new(input)
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

    it "works with empty body and query string" do
      body = %q({ "path" : "/test", "httpMethod" : "GET", "headers" : { "key": "value" }, "requestContext" : {} })
      response = HTTP::Client::Response.new(200, body, HTTP::Headers.new)
      input = JSON.parse response.body
      req = Lambda::Builder::Util::LambdaHttpRequest.new(input)

      req.headers.size.should eq 1
      req.headers["key"].should eq "value"
      req.body.should eq nil
    end

    it "supports JSON serialization/deserialization" do
      body = %q({ "path" : "/test", "httpMethod" : "GET", "headers" : { "key": "value" }, "requestContext" : {} })
      ENV["_HANDLER"] = "my_handler"
      input = JSON.parse body
      req = Lambda::Builder::Util::LambdaHttpRequest.new(input)
      json = req.to_json
      parsed_req = Lambda::Builder::Util::LambdaHttpRequest.from_json json.to_s
      req.headers.should eq parsed_req.headers
      req.to_json.should eq parsed_req.to_json
      req.method.should eq parsed_req.method
      req.method.should eq "GET"
      req.path.should eq parsed_req.path
      req.path.should eq "/test"
    end
  end

  describe "LambdaHTTPResponse" do
    it "always returns status code" do
      json = JSON.parse Lambda::Builder::Util::LambdaHttpResponse.new(123).to_json
      json["statusCode"].as_i.should eq 123
      json["body"]?.should be_nil
    end

    it "can contain a body as text" do
      text = "my text"
      json = JSON.parse Lambda::Builder::Util::LambdaHttpResponse.new(200, text).to_json
      json["body"]?.should eq text
    end

    it "can contain a body as json" do
      input = JSON.parse "{ \"foo\" : \"bar\" }"
      json = JSON.parse Lambda::Builder::Util::LambdaHttpResponse.new(200, input).to_json
      json["body"]["foo"]?.should eq "bar"
    end

    it "can contain additional headers" do
      response = Lambda::Builder::Util::LambdaHttpResponse.new(200, "body")
      response.headers["Content-Type"] = "application/text"
      json = JSON.parse response.to_json
      json["headers"]["Content-Type"]?.should eq "application/text"
    end
  end
end
