# crystal-lambda

A small example of running lambdas written in [crystallang](https://crystal-lang.org/)

## Installation

Clone this repo, runs the `shards` command to install dependencies, run `crystal spec` to ensure passing tests and you should be ready for deployment.

The `lambda.cr` provides some glue code to run own events. The `request.cr` file contains some helper classes to create a request class, that enhances a regular crystallang HTTP request and some response helper class.

The interesting class to tinker around with would be the `bootstrap.cr` file, which contains the definitions of the three sample lambdas.

## Deployment

Make sure the [serverless framework](https://serverless.com/) is set up properly.

If you are using osx, make sure you are building your app using docker, as an AWS lambda runtime environment is based on Linux. You can create a linux binary using docker like this

```
docker run --rm -it -v $PWD:/app -w /app crystallang/crystal:latest crystal build src/bootstrap.cr -o bin/bootstrap --release --static --no-debug
```

Now package the zip file required for deployment and deploy

```
zip -j bootstrap.zip bin/bootstrap
sls deploy
```

Now you will have one HTTP endpoint deployed, one scheduled event running every 10 minutes and one lambda listening on an SQS queue - which can be triggered by sending a message to it. You can also run `sls info` to get the exact HTTP endpoint.

The configuration of the above can be found in the `serverless.yml` file.

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

## Contributing

1. Fork it (<https://github.com/spinscale/crystal-aws-lambda/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`), also run `bin/ameba`
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Don't forget to add proper tests, if possible

## Contributors

- [Alexander Reelsen](https://github.com/spinscale) - creator and maintainer
