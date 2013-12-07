% -*- markdown -*-
@doc collection+proto [out=README.md]

<!--

@code collection.proto [out=collection.proto]
package collection;
///===================================================================
/// Collection+Protobuf messages
///===================================================================

// Documentation can be found at
// <https://github.com/ericmoritz/collection-protobuf/>

@=

-->

# collection+protobuf - Document format

> NOTE: The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
> NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
> in this document are to be interpreted as described in
> [RFC2119](http://tools.ietf.org/html/rfc2119).

`collection+protobuf` follows the
[collection+json](http://amundsen.com/media-types/collection/format/)
specification but uses
[Protocol Buffers](https://developers.google.com/protocol-buffers/docs/overview)
to provide a structure for a language-neutral, extensible, hypermedia
RESTful service that avoids the ambiguity of a schema-less format
such as JSON.

Unless specified, this specification follows the `collection+json`
specification and protocol exactly. 

## Goals of `collection+protobuf`

1. Avoid ambiguity by using structured protobuf messages
2. Provide a universal interface to enable automatic clients
3. Maintain the same [H Factor](http://amundsen.com/hypermedia/hfactor/) as
   `collection+json`
4. Maintain structural compatibility with `collection+json` by avoiding to
   redefine any `collection+json` fields. This will aid automatic conversion.

## Compatibility with `collection+json`

`collection+protobuf` tries to maintain structural compatibility with
`collection+json` but favors complex strongly typed data for the
payload.

`collection+protobuf` uses a `pb` field to prevent conflicts with
services that want to provide a simpler `collection+json` `data`
field.

Services that want to maintain compatibility with `collection+json`
are free use repeated `DataField` messages in `Template.data` and
`Item.data` messages.

This `data` field is assumed ignored by services accepting
`collection+protobuf` request bodies.  Services that use content
negotiation to allow `collection+json` request bodies, *MUST* follow
the `collection+json` specification and use the `template.data` and
`item.data` fields when using JSON.

If your service does convert a `collection+protobuf` message to `JSON`
don't call the resource `application/vnd.collection+json` unless it
meets their
[spec](http://amundsen.com/media-types/collection/format/).

We strongly encourage that messages converted to JSON adhere to the
`collection+json` spec.  The world does not need one more ad-hoc
format.

## Profiles

Like `collection+json`, `collection+protobuf` supports the use of
semantic profiles to link to the `.proto` file that the resource is
defined in:

    application/vnd.collection+protobuf;profile=http://example.com/polling.proto#polling.QuestionCollection

The profile information gives automatic clients enough information to
validate and decode a resource from an HTTP response.

## Resource messages

A Resource message wraps a collection message.  The resource
message type is used to aid extensibility if additional fields need
to be bundled with the collection. 

```protobuf
message {Subject}Resource {
    optional Collection collection; 
}
```

## Collection messages

A `collection+protobuf` Collection message should be shaped like
this:

```protobuf
message {Subject}Collection {
  optional string version;				// SHOULD
  optional string href;					// SHOULD
  repeated Link links;					// MAY
  repeated {Subject}Item items;			// MAY
  repeated Query queries;	            // MAY
  optional {Subject}Template template;	// MAY
  optional Error error;					// MAY
}
```

Obviously, for brevity, message declarations can omit any optional or
repeated fields that are not used by resource.  A client **MUST** support
missing fields.

### The Collection.template

The `Collection.template` field is a message that can be used to add
or edit members of the collection.

The template message is shaped like:

```protobuf
message {Subject}Template {
  optional{Subject}TemplatePB pb;
}
```

To match `collection+json` The template should be wrapped in
a the subject's Collection message:

```protobuf
template {
  pb {
    full_name: "J. Doe"
    email: "joe@example.org"
    blog: "http://examples.org/blogs/jdoe"
    avatar: "http://examples.org/images/jdoe"
  }
}
```

A `collection+protobuf` services **MUST** follow protocol established
by `collection+json` [§ 2.1 read/write](http://amundsen.com/media-types/collection/format/#read-write)

### The Collection.items field

The `Collection.items` repeated message is shaped like an Item message
described below.


## Item messages

An Item message is shaped like this:

```protobuf
message {Subject}Item {
  optional string href;
  optional {Subject} pb;
  repeated Link links;
}
```

### Item.pb

The `Item.pb` field will be of the type of the subject of the
collection.



## Error message

The error message is used to express that an error that occurred
processing the request.

<!-- 
@code collection.proto

///-------------------------------------------------------------------
/// An Error message used to convey the latest error condition
/// produced by a fault
///-------------------------------------------------------------------
@=
-->

```protobuf
@code collection.proto
message Error {
  optional string title = 1;
  optional string code = 2;
  optional string message = 3;
}
@=
```

## Link message

The link message is used by Collection messages and Item messages to
get all hyper on.

Link relations are thoughtfully described at
http://amundsen.com/media-types/linkrelations/

The render field MUST be "link" or "image".

<!--
@code collection.proto


///-------------------------------------------------------------------
/// A Link message for Collection.links & Item.links
///
/// To get all hyper on.
/// List of official link relations:
/// http://www.iana.org/assignments/link-relations/link-relations.xhtml
///-------------------------------------------------------------------
@=
-->

```protobuf
@code collection.proto
message Link {
  required string rel = 1;
  required string href = 2;
  optional string name = 3;
  optional string render = 4 [default="link"];
  optional string prompt = 5;
}
@=
```

> NOTE: It is up for debate if we should use an enum for the render
> field; I chose a string to make conversion to JSON easier.

## Query template message

A Query message for describing how to make queries

The name/value pairs of the `data` messages can be combined with the
`href` field to make GET requests.

<!--
@code collection.proto


///-------------------------------------------------------------------
/// A Query message for describing how to make queries
///
/// The name/value pairs of the `data` messages can be combined with the
/// `href` field to make GET requests.
///-------------------------------------------------------------------
@=

-->

```protobuf
@code collection.proto
message Query {
  required string href = 1;
  required string rel = 2;
  optional string name = 3;
  optional string prompt = 4;
  repeated DataField data = 5;
}
@=
```

## DataField message
    
The DataField message is used by the Query message to describe a query template

<!--
@code collection.proto

///-------------------------------------------------------------------
/// The DataField message is used by the Query message to describe a
/// query template
///-------------------------------------------------------------------

@=

-->

```protobuf
@code collection.proto

message DataField {
  required string name = 1;
  optional string value = 2;
  optional string prompt = 3;
}
@=
```

The DataField message MAY be used with `Template.data` and `Item.data`
to maintain compatibility with `collection+json` without sacrifice of
explicit typing.

The `Template.data` and `Item.data` field MUST be ignored by
`collection+protobuf` services.

## Examples and Utilities

In the `examples/` directory is a `friends.proto` that demostrates
conversion of the `collection+json`
[example](http://amundsen.com/media-types/collection/examples/) into
`collection+protobuf`

In the `examples/friends/` are text protobuf messages and binary
protobuf messages for the converted examples.
