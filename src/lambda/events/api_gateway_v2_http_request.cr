require "json"

module Lambda::Events
  class APIGatewayV2HTTPRequest
    include JSON::Serializable

    @[JSON::Field(key: "version")]
    property version : String

    @[JSON::Field(key: "routeKey")]
    property route_key : String

    @[JSON::Field(key: "rawPath")]
    property raw_path : String

    @[JSON::Field(key: "rawQueryString")]
    property raw_query_string : String

    @[JSON::Field(key: "cookies")]
    property cookies : Array(String)?

    @[JSON::Field(key: "headers")]
    property headers : Hash(String, String)

    @[JSON::Field(key: "queryStringParameters")]
    property query_string_parameters : Hash(String, String)?

    @[JSON::Field(key: "pathParameters")]
    property path_parameters : Hash(String, String)?

    @[JSON::Field(key: "requestContext")]
    property request_context : APIGatewayV2HTTPRequestContext?

    @[JSON::Field(key: "stageVariables")]
    property stage_variables : Hash(String, String)?

    @[JSON::Field(key: "body")]
    property body : String?

    @[JSON::Field(key: "isBase64Encoded")]
    property is_base64_encoded : Bool
  end

  class APIGatewayV2HTTPRequestContext
    include JSON::Serializable

    @[JSON::Field(key: "routeKey")]
    property route_key : String

    @[JSON::Field(key: "accountId")]
    property account_id : String

    @[JSON::Field(key: "stage")]
    property stage : String

    @[JSON::Field(key: "requestId")]
    property request_id : String

    @[JSON::Field(key: "authorizer")]
    property authorizer : APIGatewayV2HTTPRequestContextAuthorizerDescription?

    @[JSON::Field(key: "apiId")]
    property api_id : String

    @[JSON::Field(key: "domainName")]
    property domain_name : String

    @[JSON::Field(key: "domainPrefix")]
    property domain_prefix : String

    @[JSON::Field(key: "time")]
    property time : String

    @[JSON::Field(key: "timeEpoch")]
    property time_epoch : Int64

    @[JSON::Field(key: "http")]
    property http : APIGatewayV2HTTPRequestContextHTTPDescription
  end

  class APIGatewayV2HTTPRequestContextAuthorizerDescription
    include JSON::Serializable

    @[JSON::Field(key: "jwt")]
    property jwt : APIGatewayV2HTTPRequestContextAuthorizerJWTDescription?

    @[JSON::Field(key: "lambda")]
    property lambda : Hash(String, JSON::Any)?

    @[JSON::Field(key: "iam")]
    property iam : APIGatewayV2HTTPRequestContextAuthorizerIAMDescription?
  end

  class APIGatewayV2HTTPRequestContextAuthorizerJWTDescription
    include JSON::Serializable

    @[JSON::Field(key: "claims")]
    property claims : Hash(String, String)

    @[JSON::Field(key: "scopes")]
    property scopes : Array(String)?
  end

  class APIGatewayV2HTTPRequestContextAuthorizerIAMDescription
    include JSON::Serializable

    @[JSON::Field(key: "access_key")]
    property access_key : String

    @[JSON::Field(key: "account_id")]
    property account_id : String

    @[JSON::Field(key: "callerId")]
    property caller_id : String

    @[JSON::Field(key: "cognitoIdentity")]
    property cognito_identity : APIGatewayV2HTTPRequestContextAuthorizerCognitoIdentity?

    @[JSON::Field(key: "principalOrgId")]
    property principal_org_id : String

    @[JSON::Field(key: "userArn")]
    property user_arn : String

    @[JSON::Field(key: "userId")]
    property user_id : String
  end

  class APIGatewayV2HTTPRequestContextAuthorizerCognitoIdentity
    include JSON::Serializable

    @[JSON::Field(key: "amr")]
    property amr : Array(String)

    @[JSON::Field(key: "identityId")]
    property identity_id : String

    @[JSON::Field(key: "identityPoolId")]
    property identity_pool_id : String
  end

  class APIGatewayV2HTTPRequestContextHTTPDescription
    include JSON::Serializable

    @[JSON::Field(key: "method")]
    property method : String

    @[JSON::Field(key: "path")]
    property path : String

    @[JSON::Field(key: "protocol")]
    property protocol : String

    @[JSON::Field(key: "sourceIp")]
    property sourceIp : String

    @[JSON::Field(key: "userAgent")]
    property user_agent : String
  end
end
