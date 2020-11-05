---
layout: post
title: "Alda and the nREPL protocol"
category: alda
tags:
  - alda
  - nrepl
  - repl
  - clojure
published: true
---

{% include JB/setup %}

As you may have heard, I have been busy, working on Alda v2, a ground-up rewrite
of [Alda][alda-website]. As part of this project, I have re-thought the Alda
REPL experience to make it closer in spirit to the [nREPL][nrepl] experience
that I've been enjoying as a Clojure programmer.

The big idea about nREPL is that it is a [REPL][repl] that operates over a
network connection. After starting an nREPL **server**, any number of nREPL
**clients** can connect to the server and send over code to be evaluated. The
server treats each client connection in a separate context, and sends evaluation
results back to the client in response.

> TODO: More about how I found this to be a good foundation for building the
> Alda v2 REPL. Mention how I read that nREPL isn't Clojure-specific, and the
> protocol has been used successfully to implement REPLs for other languages as
> well. So, I decided to try my hand at using the nREPL protocol to implement
> the new-and-improved REPL for Alda v2.

# The way things are now

The current version of Alda (v1) actually has a client/server architecture
already. To start the server, you run `alda up`, and to start a REPL client
session, you run `alda repl`.

I realized, however, that the Alda v1 client/server idea extends a little too
far into user-land. The user is _forced_ to worry about whether or not a server
is running, even when you just want to perform basic evaluations outside of the
context of a REPL session.

For example, if you don't have a server running, any attempt to play an Alda
score from the command line will fail:

{% highlight text %}
$ alda play -c 'cello: o2 a'
# ... after an awkward pause ...
[27713] ERROR Alda server is down. To start the server, run `alda up`.
{% endhighlight %}

> TODO: continue discussing how Alda v2 is better, etc.

# Notes

* Alda and the nREPL protocol
  * An experience report about implementing the Alda v2 REPL and using the nREPL
    protocol for the communication between the REPL client and REPL server.
  * Brief technical overview / what I gleaned from the nREPL documentation as
    the most relevant / salient parts.
  * The most fun part was testing my implementation of the client and server
    against the corresponding Clojure nREPL thing, i.e. having an Alda REPL
    client talk to a Clojure nREPL server, and vice versa.
  * The big finish: a code block copy-pasted from a terminal session where a
    Clojure nREPL client is sending `eval` requests to an Alda REPL server,
    the Alda REPL server is sending back `¯\_(ツ)_/¯`, and the Clojure nREPL
    client is printing it out, lolol
  * Final conclusions
    * I had read that the nREPL protocol was simple enough to be easily
      implemented from scratch, and I really did find that to be the case. I
      found implementing both an nREPL client and server in Go to be fun and
      satisfying. The nREPL documentation is very good and easy to follow.
    * If you are a Clojure programmer, I would encourage you to try the
      exercise of implementing an nREPL client or server from scratch. In the
      process, you will discover how the nREPL protocol works, and you might be
      surprised to learn just how simple it is.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda-website]: https://alda.io
[nrepl]: https://nrepl.org
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
