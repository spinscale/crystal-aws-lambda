require "http"
require "json"

module Lambda::Builder
  class HTTPRequest < HTTP::Request
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

      super(body["httpMethod"].as_s, path, headers, request_body, internal: nil)

      @request_context = body["requestContext"].as_h
      @original_body = body
    end

    def to_json(json : JSON::Builder)
      json.object do
        json.field "request", @original_body
        json.field "handler", @handler
      end
    end

    def self.from_json(value : String) : HTTPRequest
      HTTPRequest.from_json JSON::PullParser.new(value)
    end

    def self.from_json(value : JSON::PullParser) : HTTPRequest
      value.read_begin_object
      value.read_object_key
      body = JSON::Any.new value
      value.read_object_key
      handler = value.read_string
      value.read_end_object
      HTTPRequest.new body, handler
    end
  end
end
