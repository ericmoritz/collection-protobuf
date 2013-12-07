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

`collection+protobuf` mimics the
[collection+json](http://amundsen.com/media-types/collection/format/)
specification using
[Protocol Buffers](https://developers.google.com/protocol-buffers/docs/overview)
to provide a structure for a language-neutral, extensible, hypermedia
RESTful service that avoids the ambiguity of a schema-less format
such as JSON.

## Goals of `collection+protobuf`

1. Avoid ambiguity via structured protobuf messages
2. Provide a common structure to enable automatic client
3. Maintain the same [H Factor](http://amundsen.com/hypermedia/hfactor/) as
   `collection+json`
4. Maintain structural compatibility with `collection+json` by avoiding to
   redefine any `collection+json` fields. This will aid automatic conversion.

## Compatibility with `collection+json`

`collection+protobuf` tries to maintain structural compatibility with
`collection+json` but favors stronger typing for the data.

While `collection+json` uses an anonymous objects for `data` fields that are
shaped like:

```JSON
{"prompt" : STRING, "name" : STRING, "value" : VALUE}
```

`collection+protobuf` uses the field `pb` for structured protobuf messages.

The schema-less format of `collection+json`'s `data` field leads to the
kind of ambiguity that `collection+protobuf` is trying to avoid. This is
why `collection+protobuf` uses `pb` for its payload.

Services that want to maintain strict compatibility with
`collection+json` are free use repeated `DataField` messages 
in `Template.data` and `Item.data` messages.

This `data` field is assumed ignored by `collection+protobuf` services.

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
message Resource {
    optional Collection collection; 
}
```

## Collection messages

A `collection+protobuf` Collection message should be shaped like
this:

```protobuf
message Collection {
  optional string version;  // SHOULD
  optional string href;		// SHOULD
  repeated Link links;		// MAY
  repeated ____ items;		// MAY
  repeated Query queries;	// MAY
  optional ____ template;	// MAY
  optional Error error;		// MAY
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
message Template {
  optional ____ pb;
}
```
    
A `POST` of this object to the collection's `href` will create a new
resource if `POST` is allowed.

A `PUT` on an `Collection.items[].href` will edit/create a resource
if `PUT` is allowed on that resource.

### The Collection.items field

The `Collection.items` repeated message is shaped like an Item message
described below.


## Item messages

An Item message is shaped like this:

```protobuf

message Item {
  optional string href;
  optional _ pb;
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

