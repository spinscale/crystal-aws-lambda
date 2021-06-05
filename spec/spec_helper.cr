require "spec"
require "webmock"

require "../src/lambda"

Log.setup(:trace)

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

def request_body_v2
  <<-END
  {
      "version": "2.0",
      "routeKey": "OPTIONS /{proxy+}",
      "rawPath": "/hi",
      "rawQueryString": "",
      "headers": {
          "accept": "*/*",
          "accept-encoding": "gzip, deflate, br",
          "accept-language": "en-US,en;q=0.9",
          "access-control-request-headers": "authorization,content-type",
          "access-control-request-method": "POST",
          "content-length": "0",
          "content-type": "application/x-www-form-urlencoded",
          "forwarded": "by=4.235.36.19;for=108.29.59.253;host=local.dev;proto=https",
          "host": "local.dev",
          "origin": "https://local.dev",
          "referer": "https://local.dev/",
          "sec-fetch-dest": "empty",
          "sec-fetch-mode": "cors",
          "sec-fetch-site": "same-site",
          "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
          "via": "HTTP/1.1 AmazonAPIGateway",
          "x-amzn-trace-id": "Self=1-60ad1af6-6041ce5d35bd44ad26b42c70;Root=1-60ad1af6-7bbc041f64b16ac44ad97952",
          "x-forwarded-for": "3.235.36.19",
          "x-forwarded-port": "443",
          "x-forwarded-proto": "https"
      },
      "pathParameters": {
          "proxy": "score"
      },
      "requestContext": {
          "routeKey": "OPTIONS /{proxy+}",
          "accountId": "333957572119",
          "stage": "$default",
          "requestId": "f5Emhi3LIAMEM7A=",
          "apiId": "07lpms4hxh",
          "domainName": "local.dev",
          "domainPrefix": "local",
          "time": "25/May/2021:15:42:46 +0000",
          "timeEpoch": 1621957366418,
          "http": {
              "method": "OPTIONS",
              "path": "/hi",
              "protocol": "HTTP/1.1",
              "sourceIp": "3.235.36.19",
              "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"
          }
      },
      "isBase64Encoded": false
  }
END
end
