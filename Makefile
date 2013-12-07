.PHONY: all clean sw

all: test README.md collection.proto

test: collection.proto
	@echo "Syntax checking collection.proto"
	protoc --python_out=./examples/ collection.proto
	protoc --python_out=./ examples/friends.proto
	PYTHONPATH=examples/ python bin/make_friends.py
	@echo "ok."

sw:
	ispell -p ./.ispell_english src/collection+proto.sw
	# use my fork: https://github.com/ericmoritz/spiralweb
	spiralweb src/collection+proto.sw

README.md:

	@make sw
collection.proto:
	@make sw

clean:
	rm -f README.md collection.proto examples/friends/*

