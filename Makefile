.PHONY: all clean sw

all: test README.md collection.proto

test: collection.proto
	@echo "Syntax checking collection.proto"
	protoc --python_out=/tmp/ collection.proto
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
	rm -f README.md collection.proto

