require "http"
require "json"

module Lambda::Builder
  class HTTPResponse
    property body : String | JSON::Any | Nil
    getter headers : HTTP::Headers
    getter status_code

    def initialize(@status_code = 200, @body = nil)
      @headers = HTTP::Headers.new
    end

    # Returns a `JSON::Any` object for passing on to AWS
    def as_json : JSON::Any
      json = Hash(String, JSON::Any).new

      json["statusCode"] = JSON::Any.new status_code

      if !body.nil?
        json["body"] = JSON::Any.new body
      end

      json["headers"] = headers.to_h

      JSON::Any.new(json)
    end

    def to_json(json : JSON::Builder)
      json.object do
        json.field "statusCode", @status_code

        if !@body.nil?
          json.field "body", @body
        end

        json.field "headers" do
          json.start_object
          headers.each do |key, value|
            json.field key, value.first
          end
          json.end_object
        end
      end
    end
  end
end
