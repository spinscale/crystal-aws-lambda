CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)

ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

build:
	[ -d bin ] || mkdir bin
	docker run --rm -it -v $(CURDIR):/app -w /app durosoft/crystal-alpine:0.30.1 /bin/sh -c "crystal build src/bootstrap.cr -o bin/bootstrap --release --static --no-debug ; strip bin/bootstrap"
	zip -j bootstrap.zip bin/bootstrap

dependencies:
	(SHARDS_BIN)

clean:
	rm -fr ./bin bootstrap.zip

test: build
	$(CRYSTAL_BIN) spec
