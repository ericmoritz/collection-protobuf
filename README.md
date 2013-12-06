# collection+protobuf

> NOTE: The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
> NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
> in this document are to be interpreted as described in
> [RFC2119](http://tools.ietf.org/html/rfc2119).

`collection+protobuf` mimics the
[collection+json](http://amundsen.com/media-types/collection/format/)
specification using
[Protocol Buffers](https://developers.google.com/protocol-buffers/docs/overview)
to provide a structure for a language-neutral, extensible, hypermedia
RESTful service that should be easy to write automatic clients for.

## Profiles

Like `collection+json`, `collection+protobuf` supports the use of
sematic profiles to link to the .proto file that the resource is
defined in:

    application/vnd.collection+protobuf;profile=http://example.com/polling.proto#QuestionCollection

The profile information gives automatic clients enough information
to validate and decode a resource from an HTTP response.

## Collection messages

A `collection+protobuf` Collection message should be shaped like
this:

    message Collection {
	  optional string version;  // SHOULD
      optional string href;		// SHOULD
      repeated Link links;		// MAY
      repeated ____ items;		// MAY
      repeated Query queries;	// MAY
      optional _____ template;	// MAY
      optional Error error;		// MAY
    }


Obviously, for brevity, message declarations can omit any optional or
repeated fields that are not used by resource.  A client **MUST** support
missing fields.

### The Collection.template

The `Collection.template` field is a message that can be used to add
or edit members of the collection.

A `POST` of this object to the collection's `href` will create a new
resource if `POST` is allowed.

A `PUT` on an `Collection.items[].href` will edit/create a resource
if `PUT` is allowed on that resource.

### The Collection.items field

The `Collection.items` repeated message is shaped like an Item message
described below.

## Item messages

An Item message is shaped like this:

    message Item {
      optional string href;
      repeated _ data;
      repeated Link links;
    }

### Item.data

The `Item.data` field will be of the type of the subject of the
collection.
