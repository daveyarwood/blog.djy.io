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
server treats each client connection as a separate context, and sends evaluation
results back to the client in response.

As I was designing the next major version of Alda, I came to the conclusion that
the Alda REPL should function in the same way. The exciting idea that I have in
mind is that multiple Alda composers could connect to the same Alda REPL server
and compose music together by interacting with the server in real time.

With this idea in mind, I started thinking about the protocol for these
interactions between REPL clients and REPL servers. I had read that nREPL is a
language-agnostic protocol (i.e. not specific to Clojure) and that it has been
used to successfully implement [nREPL servers for other
languages][nrepl-beyond-clojure]. So, I decided to try my hand at using the
nREPL protocol as the basis for a new, improved Alda v2 REPL experience.

# Shortcomings of Alda v1

The current version of Alda (v1) actually has a client/server architecture
already. To start the server, you run `alda up`, and to start a REPL client
session, you run `alda repl`.

I realized, however, that the Alda v1 client/server idea extends a little too
far into user-land. The user is _forced_ to worry about whether or not a server
is running, even outside of the context of a REPL session when they just want to
perform basic evaluations at the command line.

For example, if you don't have a server running, any attempt to play an Alda
score from the command line will fail:

{% highlight text %}
$ alda play -c 'cello: o2 a'
# ... after an awkward pause ...
[27713] ERROR Alda server is down. To start the server, run `alda up`.
{% endhighlight %}

I have often wished that most of the Alda experience were more "self-contained"
in the way that you typically see with most programming languages' command line
tools. Alda does need to start background processes to play your score in an
asynchronous manner, but it would be nice if Alda could start these background
processes _for_ me, instead of expecting me to run `alda up` and wait for the
server to come up before I can do anything. It would also be nice if Alda could
do more of the work that it does without needing to talk to a server at all. For
example, the `alda` CLI should be able to tell me if my score has a syntax error
without needing to talk to a background process.

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
architecture unlocks new and exciting possibilities for Alda composers to
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

> TODO: overview of the transport and messages

## Client/server interactions

> TODO: high level description of an interaction between a client and a server

# Notes

* Alda and the nREPL protocol
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
[nrepl-beyond-clojure]: https://nrepl.org/nrepl/0.8/beyond_clojure.html
