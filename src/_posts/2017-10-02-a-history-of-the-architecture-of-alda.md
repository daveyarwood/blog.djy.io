---
layout: post
title: "A History of the Architecture of Alda"
category: alda
tags:
  - alda
  - music-programming
  - composition
  - zeromq
published: true
---

{% include JB/setup %}

<p align="center">
  <img src="{{site.url}}/assets/2017-10-01-blueprint.jpg"
       alt="Electronics circuit sketch with pen, pencil and ruler"
       title="Sketching a blueprint (source: https://ak6.picdn.net/shutterstock/videos/10822091/thumb/1.jpg)"
       width="639"
       height="360"/>
</p>

In [my last blog post]({% post_url 2016-06-15-alda-for-clojurists %}), I talked
about an important evolution in the implementation of [alda.lisp][aldalisp], a
sort of [DSL][dsl] or "mini-language" that represents a musical score and
compiles down to data that can be interpreted and performed by Alda's sound
engine.

[aldalisp]: https://github.com/alda-lang/alda/blob/master/doc/alda-lisp.md
[dsl]: https://en.wikipedia.org/wiki/Domain-specific_language

In this post, I'll discuss another way in which Alda has evolved over the past
couple years. On the way there, I will tell you the tale of how I've architected
Alda since I started working on it in 2012.

At the time of writing, I consider Alda to be in "Phase 5" of an ongoing series
of architectural improvements:

* Table of Contents
{:toc}

# Phase 1: Minimum Viable Product

<p align="center">
  <img src="{{site.url}}/assets/2017-10-01-single-program.svg"
       alt="diagram: alda code entered at command line -> parse code, evaluate score, play score"
       title="alda, phase 1: a single program that does everything"
       />
</p>

When I wrote the "first cut" of Alda, I set out to make the simplest thing that
got the job done: a single program that does everything.

The diagram above summarizes the work that this program needed to do. It needed to provide:

1. A command-line interface, exposing a handful of tasks and options.

2. A parser, which translates user input (i.e. Alda code) into data: a sequence
   of events occurring in a musical score.

3. A score-building DSL, which can be thought of as a sort of "compiler" that
   iterates through the score events and produces a single value, a data
   structure representing the score.

4. A sound engine that can perform the score.

It took me a few attempts using different programming languages (Python, Ruby)
before I settled upon [Clojure][clj] as my language of choice. To their credit,
Python and Ruby both have [great][click] [libraries][slop] available for
building command-line programs, good [parser-generator][ply]
[libraries][treetop], and support for playing MIDI music (although this requires
the user to install a synthesizer like [FluidSynth][fluidsynth]).

[clj]: https://clojure.org
[click]: http://click.pocoo.org
[slop]: https://github.com/leejarvis/slop
[ply]: http://www.dabeaz.com/ply
[treetop]: https://github.com/nathansobo/treetop
[fluidsynth]: http://www.fluidsynth.org

I found that Clojure offered the same perks, but also had some significant
advantages:

* As a [Lisp][lisp] tailor-made for [functional programming][fp], it allowed me
  to develop faster and produce saner, more concise code.

* Also thanks to the power of Lisp, it was trivial to implement the
  score-building DSL. A score could be represented elegantly as an
  [S-expression][sexp].

* Because Clojure is a JVM (Java Virtual Machine) language, I could leverage the
  [JVM's built-in MIDI synthesizer][jvmsynth] to provide sound for Alda users
  without requiring them to have anything installed besides Java.

* Java (and by extension, JVM languages like Clojure) makes it very easy to
  distribute cross-platform executable programs. It's nice not having to worry
  about the low-level details of different operating systems.

[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[fp]: https://en.wikipedia.org/wiki/Functional_programming
[sexp]: https://en.wikipedia.org/wiki/S-expression
[jvmsynth]: http://blog.djy.io/making-midi-sound-awesome-in-your-jvm/

The first, "single Clojure program" version of Alda was run directly via the
build tool [Boot][boot] and leveraged Boot's elegant [`defclifn`][defclifn]
macro to parse command-line arguments.

The parser proved to be very easy to write, thanks to the excellent
[Instaparse][instaparse] parser-generator library.

We used [at-at][atat] for note scheduling at first, and then switched to the
more robust [JSyn][jsyn], which offers better precision by scheduling events in
realtime on a dedicated audio thread.

[instaparse]: https://github.com/Engelberg/instaparse
[atat]: https://github.com/overtone/at-at
[jsyn]: http://www.softsynth.com/jsyn

At first, `alda` was distributed as a Boot script, which meant that you had to
have Boot installed in order to use Alda. Later, we began to distribute the
program as an executable uberjar, which only requires that you have Java
installed.

[boot]: http://boot-clj.com
[defclifn]: https://github.com/boot-clj/boot/wiki/Scripts#command-line-args

# Phase 2: HTTP Server/Client

<p align="center">
  <img src="{{site.url}}/assets/2017-10-01-http-server.svg"
       alt="diagram: alda code entered at command line -> sent to server -> server parses code, evaluates score, plays score"
       title="alda, phase 2: http server and client"
       />
</p>

At this point, the basic functionality was all there, and it was working pretty
nicely, if I recall correctly. But there was one thing that kept bugging me.
Each time I ran `alda play -f some-score.alda`, the startup time was atrocious.
On my new-ish Macbook Pro, I would have to wait for something like 5-10 seconds
before `alda` would respond. I can only imagine that it was insanely slow to run
on older hardware. Something had to be done about this.

Slow startup time has long been a [known issue for Clojure][cljstartuptime], and
it remains a problem in 2017. It's usually a non-issue when you use Clojure to
make long-running processes like servers and web services. The process may take
a while to start, but once it's up, it stays up and it runs fast. But the slow
startup time starts to become problematic when you want to write a program that
you have to run a lot and you always want it to respond quickly: a command line
utility, for example.

[cljstartuptime]: http://blog.ndk.io/jvm-slow-startup.html

On Christmas Day 2015, I released [the first Alda 1.0.0 release
candidate][100rc1changelog], which featured a new server/client architecture.
The server was a Clojure program that took just as long to start, but then it
stayed running in the background and it was quick to respond when you ran the
`alda` client program.

The client was written in a language better suited for command-line programs. I
could have chosen any number of languages that let you write fast,
cross-platform command-line programs ([Rust][rust] and [Go][go] were on my radar, and I even made [an attempt in Go][goattempt]), but I ended up going with Java.

[100rc1changelog]: https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc1-2015-12-25-christmas_tree
[rust]: https://www.rust-lang.org
[go]: https://golang.org
[goattempt]: https://github.com/alda-lang/alda/commit/1bdd04e5595a70468298fff0dd80b4961775c313

I'm not a huge fan of Java as a language (the JVM platform, on the other hand,
is excellent). It's verbose, not well-suited to functional programming, and it
encourages you to use crazy OOP patterns that obfuscate your code. But in this
case, I saw a couple of advantages to writing the Alda client in Java:

* Because both the client and server compile down to Java bytecode, we can
  package both of them together in the same uberjar, and then produce a single
  executable program (`alda`, or `alda.exe` for Windows users) via a Boot task I
  wrote called [jar2bin][j2b]. This greatly simplifies releases and makes Alda
  easy to install.

* It's nice to have a project in the [Alda organization][aldagithub] that's
  written in a language as ubiquitous as Java. Lots of people know Java, so when
  newcomers want to contribute to Alda, there is at least one project that they
  can contribute to without having to learn a new programming language.

My first stab at the client/server architecture was one in which the client and
server communicated over HTTP. The server was an HTTP server that accepted JSON
requests, and different commands were mapped to different routes.  This worked
out fine, although it turned out to be a little bit clunky and unnecessary.

[j2b]: https://github.com/adzerk-oss/boot-jar2bin
[aldagithub]: https://github.com/alda-lang

# Phase 3: ZeroMQ Server/Client

<p align="center">
  <img src="{{site.url}}/assets/2017-10-01-zmq-server.svg"
       alt="diagram: alda code entered at command line -> sent to server -> server parses code, evaluates score, plays score"
       title="alda, phase 3: zeromq server and client"
       />
</p>

Some time went by, and a contributor pointed out that HTTP is not an ideal
transport protocol to use between the Alda server and client. What we need is
actually very simple: we need to send small strings of data between the server
and client (typically running both on the same machine) so that the client can
make requests to the server and the server can send responses. HTTP can do that
and much more, but there is a lot of overhead. For a program as
performance-sensitive as Alda, I was interested in exploring better ways to do
[inter-process communication][ipc].

As recommended by the same contributor, I looked into [ZeroMQ][zmq] and I was
immediately hooked. I won't go into too much depth here about ZeroMQ, but
sufficeth to say, it's opened the door to a world where Alda consists of
multiple, specialized programs that talk to each other in interesting ways. With
ZeroMQ, I can build arbitrarily complex, multi-process programs out of smaller,
composable parts.

ZeroMQ proved to be a better way to implement the client/server architecture I
had slapped together previously. It turns out that parsing and handling HTTP
requests is a great deal more complicated than dealing with simple TCP requests;
you have to correctly consider a plethora of HTTP methods, headers, and other
parameters. With ZeroMQ, you're just sending byte arrays, which can be broken up
into frames for convenience. In the other process, you can interpret the byte
arrays as strings and handle them however you'd like. This is both simpler and
faster than HTTP.

On August 8, 2016, we released [Alda 1.0.0-rc32][alda100rc32], which replaced
the HTTP client/server implementation with one built from ZeroMQ REQ/REP
(request/response) sockets. I used the [Lazy Pirate pattern][lazypirate] to make
the client more resilient to failure and handle scenarios like network
connectivity issues or the server being down.

[ipc]: https://en.wikipedia.org/wiki/Inter-process_communication
[zmq]: http://zeromq.org/
[alda100rc32]: https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc32-2016-08-18
[lazypirate]: http://zguide.zeromq.org/page:all#Client-Side-Reliability-Lazy-Pirate-Pattern

# Phase 4: Load-Balanced Workers

<p align="center">
  <img src="{{site.url}}/assets/2017-10-01-load-balanced-workers.svg"
       alt="diagram: alda code entered at command line -> sent to server -> server forwards to available worker -> worker parses code, evaluates score, plays score"
       title="alda, phase 4: zeromq client/server with load-balanced workers"
       />
</p>

One of ZeroMQ's greatest assets is its excellent [zguide][zguide], a friendly
and comprehensive walkthrough of not only ZeroMQ, but IPC in general. The zguide
shows you how to use ZeroMQ starting with the very basics, illustrating the
concepts with code examples along the way. Along with each example, there is a
brief discussion of the strengths and weaknesses of that particular approach or
pattern, segueing into another example that is slightly stronger than the
previous.

After reading far enough to implement a simple client/server architecture, I
realized that we needed to [break the server up into separate "worker"
processes][alda100rc35] (Alda 1.0.0-rc35, September 4, 2016). This allows requests to be handled asynchronously,
with newer requests being handled promptly even while older requests are still
in progress.

(If you're curious, the ZeroMQ pattern I adapted is called the [Paranoid Pirate
Pattern][ppp].)

The main impetus for this change was that users were starting to report
performance/audio issues related to the server trying to parse, evaluate and
play multiple scores at once. I read somewhere that in performance-intensive
audio applications, it is important to do all of the audio "performance" on a
separate thread, e.g. on a dedicated thread running on your sound card. So,
after some experimentation, I ended up giving each audio "performer" (a.k.a.
worker) its own process, running in a separate JVM. This solved a number of
issues caused by using multiple MIDI synthesizer instances in the same JVM.

After making this change, Alda's audio performance improved noticeably. The
worker processes did not exhibit the audio glitches that were observable before
because they were mostly free to focus on performing audio, in between polling
for messages. Similarly, the server became more responsive now that it didn't
have to compete for resources with an audio performance occurring in the same
JVM.

[zguide]: http://zguide.zeromq.org
[ppp]: http://zguide.zeromq.org/page:all#Robust-Reliable-Queuing-Paranoid-Pirate-Pattern
[alda100rc35]: https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc35-2016-09-04

# Phase 5 (WIP): Modular Components

<p align="center">
  <img src="{{site.url}}/assets/2017-10-01-modular-components.png"
       alt="lots of modular synthesizer components connected with wires"
       title="modular components (source: http://www.self-titledmag.com/2013/02/10/trent-reznor-factory-floor-carl-craig-and-more-set-to-appear-in-modular-synth-documentary-i-dream-of-wires/)"
       width="657"
       height="399"
       />
</p>


At the moment, Alda is still packaged and released as a single program, which we
create by bundling the (Java) client, (Clojure) server and (Clojure) worker into
an executable uberjar. But, I've been thinking a lot about setting things up so
that the components could be implemented in non-JVM languages. I think it might
be compelling to explore alternative languages and runtimes for some of the
difficult work that Alda needs to do. For example, it might be compelling to
write a faster compiler in C (or perhaps something slightly higher-level like
[Rust][rust]), or an alternative, [Web Audio API][webaudio]-based audio
generator that can run in the browser.

We are already heading in a "modular" direction with the progression of Phases 1
through 4 that I described above. We have gone from a single program, to a
client/server architecture, to a load-balanced server/worker architecture.

This modularity we've been exploring is also great for a couple of other
reasons:

* We have restructured the projects in the [alda-lang GitHub
  organization][aldalang] so that each module is maintained in a separate
  repository where relevant issues are filed and code is contributed. I like
  this because each individual project is smaller and conceptually simpler to
  understand than Alda as a whole. New contributors can explore and discover the
  Alda projects to which they are most interested in contributing. There are
  less issues per repo, and the issues are more specialized, and more visible,
  so they can get the attention they need.

* Isolating Alda components into external modules that aren't tied to the JVM
  could pave the way for an ecosystem of "plug 'n play" modules. Developers in
  the open-source community could feasibly write their own implementations of
  the modules that they want to improve, using whichever programming language
  they prefer.

Going forward, I believe the worker can be broken up further into at least two
discrete services:

  1. The compiler, which parses Alda code and turns it into a playable score.
  2. The performer, which plays the compiled score.

I haven't dived too deep into this idea yet, but from what I've read in the
ZeroMQ zguide, there are some patterns like [Majordomo][majordomo] and
[Titanic][titanic] that look to be able to provide the type of service-oriented
architecture that I'm imagining. In the case of the Titanic pattern, work that
needs to be done is stored on disk, a specialized service does the work and
writes the result to disk, and a server (or "broker") manages the services and
coordinates the process of a client making a request, the work happening, and
the client getting a response.

At the moment, this is just a pipe dream, but I'm very interested in discussing
and/or experimenting with this kind of architecture. If you have thoughts about
this, [please share them
here](https://github.com/alda-lang/alda-server-clj/issues/10)!

[aldalang]: https://github.com/alda-lang
[rust]: https://www.rust-lang.org
[webaudio]: https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API
[majordomo]: http://zguide.zeromq.org/page:all#Service-Oriented-Reliable-Queuing-Majordomo-Pattern
[titanic]: http://zguide.zeromq.org/page:all#Disconnected-Reliability-Titanic-Pattern

