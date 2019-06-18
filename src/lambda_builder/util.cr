require "http"
require "json"

module Lambda::Builder::Util
  class LambdaHttpRequest < HTTP::Request
    getter request_context : Hash(String, JSON::Any)
    getter handler : String

    def initialize(body : JSON::Any, @handler = ENV["_HANDLER"])
      headers = HTTP::Headers.new
      body["headers"].as_h.each { |k, v| {headers.add(k, v.as_s)} }
      request_body = nil
      if (body["body"]? && body["body"].as_s?)
        request_body = body["body"].as_s
      end

      path = body["path"].as_s
      if (body["queryStringParameters"]? && body["queryStringParameters"].as_h?)
        qs = Hash(String, String).new
        body["queryStringParameters"].as_h.each do |key, value|
          qs[key] = value.to_s
        end
        path += "?" + HTTP::Params.encode qs
      end
      super(body["httpMethod"].as_s, path, headers, request_body)
      @request_context = body["requestContext"].as_h
      @original_body = body
    end

    def to_json(json : JSON::Builder)
      json.object do
        json.field "request", @original_body
        json.field "handler", @handler
      end
    end

    def self.from_json(value : String) : LambdaHttpRequest
      LambdaHttpRequest.from_json JSON::PullParser.new(value)
    end

    def self.from_json(value : JSON::PullParser) : LambdaHttpRequest
      value.read_begin_object
      value.read_object_key
      body = JSON::Any.new value
      value.read_object_key
      handler = value.read_string
      value.read_end_object
      LambdaHttpRequest.new body, handler
    end
  end

  class LambdaHttpResponse
    property body : String | JSON::Any | Nil
    getter headers : HTTP::Headers
    getter status_code

    def initialize(@status_code = 200, @body = nil)
      @headers = HTTP::Headers.new
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
