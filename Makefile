.PHONY: all clean sw

all: README.md collection.proto

sw:
	spiralweb tangle src/collection+proto.sw
	spiralweb weave src/collection+proto.sw


README.md:

	@make sw
collection.proto:
	@make sw

clean:
	rm -f README.md collection.proto

