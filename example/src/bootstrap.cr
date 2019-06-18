require "lambda_builder"

runtime = Lambda::Builder::Runtime.new

runtime.register_handler("httpevent") do |input|
  req = Lambda::Builder::HTTPRequest.new(input)
  user = req.query_params.fetch("hello", "World")
  response = Lambda::Builder::HTTPResponse.new(200, "Hello #{user} from Crystal")
  response.as_json
end

runtime.register_handler("scheduledevent") do |input|
  runtime.logger.debug("Hello from scheduled event, input: #{input}")
  JSON.parse "{}"
end

runtime.register_handler("snsevent") do |input|
  runtime.logger.info("SNSEvent input: #{input}")
  JSON.parse "{}"
end

runtime.run
