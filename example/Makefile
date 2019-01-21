CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)

ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

build: docker
	[ -d bin ] || mkdir bin
ifeq ($(uname_S), Darwin)
	docker run --rm -it -v $(CURDIR):/app -w /app crystal-static-compile:latest crystal build src/bootstrap.cr -o bin/bootstrap --release --static --no-debug
else
	$(SHARDS_BIN) build --release --static --no-debug $(CRFLAGS)
endif
	zip -j bootstrap.zip bin/bootstrap

docker:
	docker build . -t crystal-static-compile

clean:
	rm -f ./bin/bootstrap* bootstrap.zip

test: build
	$(CRYSTAL_BIN) spec
