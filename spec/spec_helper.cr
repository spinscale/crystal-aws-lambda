require "spec"
require "webmock"

require "../src/lambda_builder"

def request_body
  <<-END
  {
    "resource": "/hello",
    "path": "/hello",
    "httpMethod": "POST",
    "headers": {
      "Accept": "*/*",
      "CloudFront-Forwarded-Proto": "https",
      "CloudFront-Is-Desktop-Viewer": "true",
      "CloudFront-Is-Mobile-Viewer": "false",
      "CloudFront-Is-SmartTV-Viewer": "false",
      "CloudFront-Is-Tablet-Viewer": "false",
      "CloudFront-Viewer-Country": "DE",
      "content-type": "application/x-www-form-urlencoded",
      "Host": "my-host.execute-api.us-east-1.amazonaws.com",
      "User-Agent": "curl/7.54.0",
      "Via": "2.0 my-id.cloudfront.net (CloudFront)",
      "X-Amzn-Trace-Id": "Root=1-11-111",
      "X-Forwarded-For": "1.143.1.124, 216.1.60.1",
      "X-Forwarded-Port": "443",
      "X-Forwarded-Proto": "https"
    },
    "multiValueHeaders": {
      "Accept": [
        "*/*"
      ],
      "CloudFront-Forwarded-Proto": [
        "https"
      ],
      "CloudFront-Is-Desktop-Viewer": [
        "true"
      ],
      "CloudFront-Is-Mobile-Viewer": [
        "false"
      ],
      "CloudFront-Is-SmartTV-Viewer": [
        "false"
      ],
      "CloudFront-Is-Tablet-Viewer": [
        "false"
      ],
      "CloudFront-Viewer-Country": [
        "DE"
      ],
      "content-type": [
        "application/x-www-form-urlencoded"
      ],
      "Host": [
        "my-host.execute-api.us-east-1.amazonaws.com"
      ],
      "User-Agent": [
        "curl/7.54.0"
      ],
      "Via": [
        "2.0 my-id.cloudfront.net (CloudFront)"
      ],
      "X-Amzn-Trace-Id": [
        "Root=TRACE-ID"
      ],
      "X-Forwarded-For": [
        "1.143.1.124, 216.1.60.1"
      ],
      "X-Forwarded-Port": [
        "443"
      ],
      "X-Forwarded-Proto": [
        "https"
      ]
    },
    "queryStringParameters": {
      "test": "bar"
    },
    "multiValueQueryStringParameters": {
      "test": [
        "bar"
      ]
    },
    "pathParameters": null,
    "stageVariables": null,
    "requestContext": {
      "resourceId": "i70nco",
      "resourcePath": "/hello",
      "httpMethod": "POST",
      "extendedRequestId": "extendedRequestID",
      "requestTime": "14/Dec/2018:20:56:07 +0000",
      "path": "/dev/hello",
      "protocol": "HTTP/1.1",
      "stage": "dev",
      "domainPrefix": "my-hsot",
      "requestTimeEpoch": 1544820967605,
      "requestId": "abcdefg-ffe2-11e8-a78f-1111",
      "identity": {
        "cognitoIdentityPoolId": null,
        "accountId": null,
        "cognitoIdentityId": null,
        "caller": null,
        "sourceIp": "1.1.1.1",
        "accessKey": null,
        "cognitoAuthenticationType": null,
        "cognitoAuthenticationProvider": null,
        "userArn": null,
        "userAgent": "curl/7.54.0",
        "user": null
      },
      "domainName": "my-host.execute-api.us-east-1.amazonaws.com",
      "apiId": "my-host"
    },
    "body": "{\\"foo\\":\\"bar\\"}",
    "isBase64Encoded": false
  }
END
end
