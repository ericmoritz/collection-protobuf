.PHONY: all clean sw

all: test README.md collection.proto

test: collection.proto
	@echo "Syntax checking collection.proto"
	protoc --python_out=/tmp/ collection.proto
	@echo "ok."

sw:
	ispell src/collection+proto.sw
	spiralweb tangle src/collection+proto.sw
	spiralweb weave src/collection+proto.sw


README.md:

	@make sw
collection.proto:
	@make sw

clean:
	rm -f README.md collection.proto

