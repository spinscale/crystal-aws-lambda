require "lambda_builder"

runtime = Lambda::Builder::Runtime.new

Log.define_formatter(
  LambdaFormatter,
  "#{severity} [#{string(ENV["_HANDLER"])}] - #{source(after: ": ")}#{message}#{data(before: " -- ")}#{context(before: " -- ")}#{exception}"
)

Log.setup(:debug, Log::IOBackend.new(formatter: LambdaFormatter))

runtime.register_handler("httpevent") do |input|
  req = Lambda::Builder::HTTPRequest.new(input)
  user = req.query_params.fetch("hello", "World")
  response = Lambda::Builder::HTTPResponse.new(200, "Hello #{user} from Crystal")
  response.as_json
end

runtime.register_handler("scheduledevent") do |input|
  Log.debug { "Hello from scheduled event, input: #{input}" }
  JSON.parse "{}"
end

runtime.register_handler("snsevent") do |input|
  Log.info { "SNSEvent input: #{input}" }
  JSON.parse "{}"
end

runtime.run
