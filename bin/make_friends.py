#!/usr/bin/env python
from friends_pb2 import FriendResource
from itertools import imap

def friend(msg, 
           href="",
           full_name="", 
           email="", 
           blog_href="",
           avatar_href=""):

    msg.href=href
    msg.pb.full_name = full_name
    msg.pb.email = email

    if blog_href:
        link(msg.links.add(),
             rel="blog",
             href=blog_href,
             prompt="Blog")

    if avatar_href:
        link(msg.links.add(),
             rel="avatar",
             href=avatar_href,
             prompt="Avatar")

    return msg


def link(msg,
         rel="",
         href="",
         prompt=""):
    msg.rel = rel
    msg.href = href
    msg.prompt = prompt
    

def data(msg,
         name="",
         value="",
         prompt=""):
    msg.name = name
    msg.value = value
    msg.prompt = prompt


def query(msg, 
          rel="",
          href="",
          prompt=""):
    msg.rel = rel
    msg.href = href
    msg.prompt = prompt
    return msg         


def template(msg):
    msg.pb.full_name = ""
    msg.pb.email = ""
    msg.pb.blog = ""
    msg.pb.avatar = ""


def skel_resource():
    resource = FriendResource()
    template(resource.collection.template)

    resource.collection.version = "1.0"
    resource.collection.href = "http://example.org/friends/"
    link(resource.collection.links.add(),
         rel="feed",
         href="http://example.org/friends/rss")

    q = query(
        resource.collection.queries.add(),
        href="http://example.org",
        rel="search",
        prompt="Enter search string",
    )
    data(q.data.add(),
         name="search")


    return resource


def resource():
    resource = skel_resource()

    friend(resource.collection.items.add(),
           href="http://example.org/friends/jdoe",
           full_name="J. Doe",
           email="joe@example.org",
           blog_href="http://examples.org/blogs/jdoe",
           avatar_href="http://examples.org/images/jdoe")

    friend(resource.collection.items.add(),
           href="http://example.org/friends/msmith",
           full_name="M. Smith",
           email="msmith@example.org",
           blog_href="http://examples.org/blogs/msmith",
           avatar_href="http://examples.org/images/msmith")

    friend(resource.collection.items.add(),
           href="http://example.org/friends/rwilliams",
           full_name="R. Williams",
           email="rwilliams@example.org",
           blog_href="http://examples.org/blogs/rwilliams",
           avatar_href="http://examples.org/images/rwilliams")

    return resource

def member_resource(skel, item):
    item_resource = FriendResource()
    item_resource.CopyFrom(skel)
    item_resource.collection.items.add().CopyFrom(item)
    template = item_resource.collection.template
    template.pb.full_name = item.pb.full_name
    template.pb.email = item.pb.email

    for link in item.links:
        if link.rel == "blog":
            template.pb.blog = link.href
        elif link.rel == "avatar":
            template.pb.avatar = link.href

    return item_resource

def save(key, msg):
    basename = "examples/friends/{key}".format(**locals())
    with open(basename + ".pbf", "wb") as fh:
        fh.write(msg.SerializeToString())

    with open(basename + ".txt", "wb") as fh:
        fh.write(str(msg))

def key(item):
    return item.href.split("/")[-1]


def main():
    resource_msg = resource()
    skel = skel_resource()
    members = imap(lambda item: member_resource(skel, item), 
                   resource_msg.collection.items)

    save("index", resource_msg)

    for member in members:
        save(key(member.collection.items[0]),
             member)

if __name__ == '__main__':
    main()
    
