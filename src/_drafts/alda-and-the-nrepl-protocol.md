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

As I was designing the next major version of Alda, I came to the conclusion that
the Alda REPL should function in the same way. The exciting idea that I have in
mind is that multiple Alda composers can connect to the same Alda REPL server
and compose music together by interacting with the server in real time.

With this idea in mind, I started thinking about what the protocol should be for
these interactions between REPL clients and REPL servers. I had read that nREPL
is a language-agnostic protocol (i.e. not specific to Clojure) and that it has
been used to successfully implement [nREPL servers for other
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

For years, I have been wishing that most of the Alda experience were more
"self-contained" in the way that you typically see with most programming
languages. Alda does need to start background processes to play your score in an
asynchronous manner, but I have always wished that Alda would start these
background processes _for_ me, instead of expecting me to run `alda up` and wait
for the server to come up before I can do anything. I've also wished that Alda
could do more of the work that it does without needing to talk to a server at
all. For example, if my score has a syntax error, the `alda` CLI should be able
to tell me that immediately without needing to talk to a background process.

So I implemented it that way for Alda v2, and just as I'd hoped, the basic,
everyday usage of the Alda CLI feels a lot more comfortable and satisfying now.
When Alda v2 is released, users will no longer need to know about Alda's
background processes at all. After downloading and installing Alda, users can
run `alda play -c 'some code'` or `alda play -f some-file.alda` whenever the
inspiration strikes them and Alda will play their score.  There are still
background processes out of necessity (an important goal of Alda is that
playback is asynchronous), but now, the processes are entirely managed "behind
the scenes" by Alda.

# The Alda v2 REPL

Whereas the Alda v1 REPL requires you to start an Alda server first, the Alda v2
REPL seamlessly starts a REPL server for you. When you run `alda repl` at the
command line, you immediately end up in an interactive REPL session that feels
a lot like the command line `alda play -c '...'` experience, except that the
REPL remembers the context of your previous evaluations. For example, if you
evaluate the following line of code:

{% highlight text %}
accordion: o5 c d e f
{% endhighlight %}

You will hear an accordion playing the notes C, D, E, and F in the fifth octave.
Then, if you evaluate the following line of code:

{% highlight text %}
g
{% endhighlight %}

You will hear the note G, still on an accordion, still in the fifth octave.

> TODO: talk about how this doesn't _feel_ like a client/server setup, but under
> the hood, it is. Then, talk about what we can do with that.

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
[nrepl-beyond-clojure]: https://nrepl.org/nrepl/0.8/beyond_clojure.html
