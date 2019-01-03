CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)

ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

build:
ifeq ($(uname_S), Darwin)
	docker run --rm -it -v $(CURDIR):/app -w /app crystallang/crystal:latest crystal build src/bootstrap.cr -o bin/bootstrap --release --static --no-debug
else
	$(SHARDS_BIN) build --release --static --no-debug $(CRFLAGS)
endif
	zip -j bootstrap.zip bin/bootstrap

clean:
	rm -f ./bin/bootstrap*

test: build
	$(CRYSTAL_BIN) spec

