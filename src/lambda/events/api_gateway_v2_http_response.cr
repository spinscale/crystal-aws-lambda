require "json"

module Lambda::Events
  class APIGatewayV2HTTPResponse
    include JSON::Serializable

    @[JSON::Field(key: "statusCode")]
    property status_code : Int32

    @[JSON::Field(key: "headers")]
    property headers : Hash(String, String)

    @[JSON::Field(key: "multiValueHeaders")]
    property multi_value_headers : Hash(String, Array(String))

    @[JSON::Field(key: "body")]
    property body : String

    @[JSON::Field(key: "isBase64Encoded")]
    property is_base64_encoded : Bool?

    @[JSON::Field(key: "cookies")]
    property cookies : Array(String)

    def initialize(status_code, body)
      @status_code = status_code
      @body = body
      @headers = Hash(String, String).new
      @multi_value_headers = Hash(String, Array(String)).new
      @cookies = Array(String).new
    end
  end
end
