require "./lambda"

lambda = Lambda.new()

lambda.register_handler("httpevent",
  ->(input: JSON::Any) {
    req = LambdaHttpRequest.new(input)
    user = req.query_params.fetch("hello", "World")
    response = LambdaHttpResponse.new(200, "Hello #{user} from Crystal")
    # not super efficient, serializing to JSON string and then parsing, simplify this
    return JSON.parse response.to_json
  }
)

lambda.register_handler("scheduledevent",
  ->(input: JSON::Any) {
    lambda.logger.debug("Hello from scheduled event, input: #{input}")
    return JSON.parse "{}"
  }
)

lambda.register_handler("snsevent",
  ->(input: JSON::Any) {
    lambda.logger.info("SNSEvent input: #{input}")
    return JSON.parse "{}"
  }
)

lambda.run()
