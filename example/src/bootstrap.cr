require "lambda_builder"

runtime = LambdaBuilder::Runtime.new

runtime.register_handler("httpevent",
  ->(input : JSON::Any) {
    req = LambdaBuilder::Util::LambdaHttpRequest.new(input)
    user = req.query_params.fetch("hello", "World")
    response = LambdaBuilder::Util::LambdaHttpResponse.new(200, "Hello #{user} from Crystal")
    # not super efficient, serializing to JSON string and then parsing, simplify this
    return JSON.parse response.to_json
  }
)

runtime.register_handler("scheduledevent",
  ->(input : JSON::Any) {
    runtime.logger.debug("Hello from scheduled event, input: #{input}")
    return JSON.parse "{}"
  }
)

runtime.register_handler("snsevent",
  ->(input : JSON::Any) {
    runtime.logger.info("SNSEvent input: #{input}")
    return JSON.parse "{}"
  }
)

runtime.run
