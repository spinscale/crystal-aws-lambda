# crystal-aws-lambda

A small library to simplify running lambdas written in [crystallang](https://crystal-lang.org/). Not production ready, just an evening hack!

## Installation

You can include this as a dependency in your project in `shards.yml` file

```
dependencies:
  lambda:
    github: spinscale/crystal-aws-lambda
    branch: main
```

Now run the the `shards` command to download the dependency. You can now create your own lambda handlers like this

```crystal
require "lambda"

runtime = Lambda::Runtime.new

runtime.register_handler("httpevent") do |input|
  req = Lambda::Builder::HTTPRequest.new(input)
  user = req.query_params.fetch("hello", "World")
  response = Lambda::Builder::HTTPResponse.new(200, "Hello #{user} from Crystal")
  # not super efficient, serializing to JSON string and then parsing, simplify this
  JSON.parse response.to_json
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
```

The `input` variable is of type `JSON::Any` and represents the JSON handed over by the lambda event.

There is a helper class to create a HTTP request from the input, no need to do that manually.

## Deployment

Make sure the [serverless framework](https://serverless.com/) is set up properly. The next step is to create a proper serverless configuration file like this

```yml
service: crystal-hello-world

provider:
  name: aws
  runtime: provided

package:
  artifact: ./bootstrap.zip

functions:
  httpevent:
    handler: httpevent
    events:
      - http:
          memorySize: 128
          path: hello
          method: get

  snsevent:
    handler: snsevent
    memorySize: 128
    events:
      - sns: my-sns-topic

  scheduledevent:
    handler: scheduledevent
    memorySize: 128
    events:
      - schedule:
          rate: rate(10 minutes)
          input:
            hello: world
```

If you are using osx, make sure you are building your app using docker, as an AWS lambda runtime environment is based on Linux. You can create a linux binary using docker like this

```
docker run --rm -it -v $PWD:/app -w /app crystallang/crystal:latest crystal build src/bootstrap.cr -o bin/bootstrap --release --static --no-debug
```

Now package the zip file required for deployment and deploy

```
zip -j bootstrap.zip bin/bootstrap
sls deploy
```

In order to monitor executions you can check the corresponding function logs like this

```
sls logs -f httpevent -t
sls logs -f snsevent -t
sls logs -f scheduledevent -t
```

you can also get some very simple metrics per functions (this might require additional permissions)

```
sls metrics -f httpevent
sls metrics -f snsevent
sls metrics -f scheduledevent
```

## Example

If you want to get up and running with an example, run the following commands

```
git clone https://github.com/spinscale/crystal-aws-lambda
cd crystal-aws-lambda/example
# download dependencies
shards
# built binary (using docker under osx) and creates the zip file
make
# deploy to AWS, requires the serverless tool to be properly set up
sls deploy
```

This will start a sample runtime, that includes a HTTP endpoint, a scheduled event and an SQS listening event.

## Contributing

1. Fork it (<https://github.com/spinscale/crystal-aws-lambda/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`), also run `bin/ameba`
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Don't forget to add proper tests, if possible

## Contributors

- [Alexander Reelsen](https://github.com/spinscale) - creator and maintainer
