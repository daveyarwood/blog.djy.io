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
of [Alda][alda-website] using Go and Kotlin. As part of this project, I have
re-thought the Alda REPL experience to make it closer in spirit to the
[nREPL][nrepl] experience that I've been enjoying as a Clojure programmer.

The big idea about nREPL is that it is a [REPL][repl] that operates over a
network connection. After starting an nREPL **server**, any number of nREPL
**clients** can connect to the server and send over code to be evaluated. The
server treats each client connection as a separate context, and sends evaluation
results back to the client in response.

As I was designing the next major version of Alda, I came to the conclusion that
the Alda REPL should function in the same way. The exciting idea that I have in
mind is that multiple Alda composers could connect to the same Alda REPL server
and compose music together by interacting with the server in real time.

So, I started thinking about the protocol for these interactions between REPL
clients and REPL servers. I had read that nREPL is a language-agnostic protocol
(i.e. not specific to Clojure) and that it has been used to successfully
implement [nREPL servers for other languages][nrepl-beyond-clojure]. So, I
decided to try my hand at using the nREPL protocol as the basis for a new,
improved Alda v2 REPL experience.

# Shortcomings of Alda v1

The current version of Alda (v1) actually has a client/server architecture
already. To start the server, you run `alda up`, and to start a REPL client
session, you run `alda repl`.

I realized, however, that the Alda v1 client/server idea extends a little too
far into user-land. The end user is forced to worry about whether or not a
server is running, even outside of the context of a REPL session when they just
want to perform basic evaluations at the command line.

For example, if you don't have a server running, any attempt to play an Alda
score from the command line will fail:

{% highlight text %}
$ alda play -c 'cello: o2 a'
# ... after an awkward pause ...
[27713] ERROR Alda server is down. To start the server, run `alda up`.
{% endhighlight %}

I have often wished that Alda had a better out-of-the-box experience. Alda does
need to start background processes to play your score in an asynchronous manner,
but it would be nice if Alda could start these background processes _for_ me,
instead of expecting me to run `alda up` and wait for the server to come up
before I can do anything. It would also be nice if Alda could do more of the
work that it does without needing to talk to a server at all. For example, the
`alda` CLI should be able to tell me if my score has a syntax error without
needing to talk to a background process.

So, I've implemented it that way for Alda v2, and now I feel like the basic,
everyday usage of the Alda CLI is much more comfortable and satisfying! When
Alda v2 is released, users will no longer need to know about Alda's background
processes at all. After downloading and installing Alda, users can run `alda
play -c 'some code'` or `alda play -f some-file.alda` whenever the inspiration
strikes them and Alda will play their score, even though they never ran `alda
up` (a command that no longer exists in Alda v2). There are still background
processes out of necessity (an important goal of Alda is that playback is
asynchronous), but now, the processes are entirely managed "behind the scenes"
by Alda.

# The Alda v2 REPL

Whereas the Alda v1 REPL requires you to start an Alda server first (`alda up`),
the Alda v2 REPL automatically starts a REPL server for you when you run `alda
repl`. The interactive REPL session feels a lot like the command line `alda play
-c '...'` experience, except that the REPL remembers the context of your
previous evaluations. For example, if you evaluate the following line of code:

{% highlight text %}
accordion: o5 c d e f
{% endhighlight %}

You will hear an accordion playing the notes C, D, E, and F in the fifth octave.
Then, if you evaluate the following line of code:

{% highlight text %}
g
{% endhighlight %}

You will hear the note G, still on an accordion, still in the fifth octave.

The Alda v2 REPL loads instantaneously, and you can immediately start entering
lines of input into your REPL session after you run `alda repl`. It doesn't
_feel_ like a client/server setup, but under the hood, it is.

It might not look like much now, but this improved client/server REPL
architecture will unlock new and exciting possibilities for Alda composers to
collaborate in real time.

Imagine a scenario where one composer is sharing their system's audio with
others. Maybe they are performing live on a stage, and their audio is being
projected over a sound system. Maybe it's a virtual event with an audience.  Or
maybe it's just a small group of friends on a Zoom call. In any of these
scenarios, the composer who's sharing their audio can start an Alda REPL server
(`alda repl --server --port 12345`) and the other composers can participate by
connecting to the REPL server (`alda repl --client --host 1.2.3.4 --port
12345`). Now, all of the composers have access to the same audio programming
environment, and they can interact with the same score, writing their own
contributions and hearing them played together.

Just talking about this is giving me goosebumps! I hope that someday, I can make
this dream of live, collaborative Alda programming a reality. But for now, I'd
like to talk a little more about the nREPL protocol and the fun that I had
implementing it for Alda v2.

# The nREPL protocol

## Messages and transport

nREPL messages are typically sent [bencoded][bencode] over sockets. Bencode is a
simple encoding format developed by BitTorrent with existing library support in
a number of languages. I tried several bencode libraries for Go, and I ended up
choosing [this one][bencode-go] because it has a simple, intuitive API and it
worked out of the box.

Every nREPL message represents either a request from a client or a response from
a server. In either case, the message is an associative data structure (think
Clojure maps, Ruby hashes, Go maps, JSON objects, etc.). Every request message
contains at least an operation (`op`), and often other entries whose names vary
depending on the operation.

Here's an example request from a client to evaluate a string of code:

{% highlight json %}
{
  "op": "eval",
  "code": "(+ 1 2 3)"
}
{% endhighlight %}

Strictly speaking, this is all that's required in a request. However, there are
a couple of other things that it is standard for a client request to include:

* `id`: a unique identifier (e.g. a UUID) representing the request. The server
  parrots the `id` value back in the response so that the client can be sure
  that the response it's supposed to receive wasn't mixed up with the response
  for another request.

* `session`: another unique identifier that represents the _session_ that the
  client and server are currently participating in. I'll talk more about
  sessions below.

Response messages also include `id` and `session` entries, and they also may
include a `status` entry, which is actually a _list_ of strings that describe
the status of the request. If a request was handled successfully, the status
will be `["done"]`. If there was an error, the status will be `["done",
"error"]`. If a response is missing status information altogether, it means that
the request is still being processed, and the client should continue to receive
responses from the server until it receives one where the `status` entry
includes `"done"`.

Here's an example response from a server with an evaluation result:

{% highlight json %}
{
  "id": "d2fa0626-58a3-4abc-b0af-a8afd8b818ad",
  "session": "bb05e357-d9c0-49d2-b206-067c88913e68",
  "status": ["done"],
  "value": "6"
}
{% endhighlight %}

## Client/server interactions

The official nREPL documentation about [building servers][building-servers] and
[building clients][building-clients] is concise and super informative. I was
basically able to read and implement all of it over the course of a few days,
and I had a lot of fun doing it!

When an nREPL client starts, it first sends a `clone` request to the server to
create a new session:

{% highlight json %}
{
  "id": "dc0a4fb1-0a30-483c-8384-de166cb9bf4d",
  "op": "clone"
}
{% endhighlight %}

The server sends a response that indicates the session was created successfully
and includes the ID of the new session:

{% highlight json %}
{
  "id": "dc0a4fb1-0a30-483c-8384-de166cb9bf4d",
  "new-session": "b08f4313-7f8a-46a0-8a40-5b8424681dbf",
  "status": ["done"]
}
{% endhighlight %}

Next, the client sends a `describe` request to verify that the server supports
all of the operations it needs to perform:

{% highlight json %}
{
  "id": "0014c5ec-69bd-4fa1-ad78-1aabde04cc4f",
  "op": "describe",
  "session": "b08f4313-7f8a-46a0-8a40-5b8424681dbf"
}
{% endhighlight %}

The server responds with information about what operations it can perform, as
well as what versions of things (e.g. Alda) it is running:

{% highlight json %}
{
  "id": "0014c5ec-69bd-4fa1-ad78-1aabde04cc4f",
  "ops": {
    "clone": {},
    "describe": {},
    "eval": {},
    "eval-and-play": {},
    "export": {},
    "instruments": {},
    "load": {},
    "new-score": {},
    "replay": {},
    "score-data": {},
    "score-events": {},
    "score-text": {},
    "stop": {}
  },
  "session": "b08f4313-7f8a-46a0-8a40-5b8424681dbf",
  "status": ["done"],
  "versions": {
    "alda": {
      "version-string": "1.99.2"
    }
  }
}
{% endhighlight %}

This is useful because it means the client can fail gracefully if it
inadvertently connects to an nREPL server that can't perform the operations that
the client needs. In particular, `eval-and-play` is an operation that I
implemented for the Alda nREPL server, but a different kind of nREPL server
(like a Clojure nREPL server) would not support that operation, so the Alda
client can easily detect that situation and let the user know.

## Trying it out

The most fun part was that I was able to test my implementations of the Alda
nREPL client and server by pointing them at a Clojure nREPL server and client.
This taught me a lot about what an nREPL client or server written "to spec"
should do.

The cool thing is that I was able to make my Alda nREPL server functional enough
to participate in a Clojure nREPL client session. The Alda nREPL server doesn't
really support `eval` (at least, not yet?), so it just responds with a shrug
emoji, but it's still fun to see the communication happening:

<center>
<img src="{{ site.url }}/assets/2020-12-12-alda-clojure-nrepl.gif"
     title="A dysfunctional nREPL session between a Clojure client and an Alda server"
     width="75%">
</center>

# Conclusions

I had read that the nREPL protocol was simple enough to be easily implemented
from scratch, and I really did find that to be the case. I found implementing an
nREPL client and server in Go to be a fun little project. The nREPL
documentation is very good and easy to follow.

If you are a Clojure programmer, I would encourage you to try the exercise of
implementing an nREPL client or server from scratch. In the process, you will
discover how the nREPL protocol works, you'll be surprised to learn just how
simple it is, and maybe you'll build something interesting!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1338490530666340352

[alda-website]: https://alda.io
[nrepl]: https://nrepl.org
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[nrepl-beyond-clojure]: https://nrepl.org/nrepl/0.8/beyond_clojure.html
[bencode]: https://wiki.theory.org/index.php/BitTorrentSpecification#Bencoding
[bencode-go]: https://github.com/jackpal/bencode-go
[building-servers]: https://nrepl.org/nrepl/0.8/building_servers.html
[building-clients]: https://nrepl.org/nrepl/0.8/building_clients.html
