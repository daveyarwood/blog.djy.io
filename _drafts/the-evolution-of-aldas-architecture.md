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

In [my last blog post]({% post_url 2016-06-15-alda-for-clojurists %}), I talked
about an important evolution in the implementation of [alda.lisp][aldalisp], a
sort of [DSL][dsl] or "mini-language" that represents a musical score and
compiles down to a data that can be played by Alda's sound engine.

[aldalisp]: https://github.com/alda-lang/alda/blob/master/doc/alda-lisp.md
[dsl]: https://en.wikipedia.org/wiki/Domain-specific_language

In this post, I'd like to talk about another way in which Alda has evolved over
the past year and a half. On the way there, I will give you a brief history of
how I've architected Alda since I started working on it in 2012.

At the time of writing, I consider Alda to be in "Phase 5" of an ongoing series
of architectural improvements.

# Phase 1 (2012-2015): Minimum Viable Product

_diagram here: CLI interface -> parse code -> evaluate score -> play score_

When I wrote the "first cut" of Alda, I started with the simplest thing that got
the job done: a single program that does everything.

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

I found that Clojure offered all of the same perks, but also some significant
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

_diagram here: client request -> server response -> back to client_

At this point, the basic functionality was all there, and it was working pretty
nicely, as I recall. But there was one thing that kept bugging me, each time I
ran `alda play -f some-score.alda`: the startup time was atrocious. On my
Macbook Pro, I would have to wait for something like 5-10 seconds before `alda`
would respond. I can only imagine that it was insanely slow to run on older
hardware. Something had to be done about this.

Slow startup time has long been a [known issue for Clojure][cljstartuptime], and
it remains a problem in 2017. It's usually a non-issue when you use Clojure to
make long-running processes like servers and web services. The process may take
a while to start, but once it's up, it stays up and it runs fast. But the slow
startup time starts to become problematic when you want to write a program that
you have to run a lot and you always want it to respond quickly; in other words,
a command-line utility like Alda.

[cljstartuptime]: http://blog.ndk.io/jvm-slow-startup.html

On Christmas Day 2015, I released [the first Alda 1.0.0 release
candidate][100rc1changelog], which featured a new server/client architecture.
The server was a Clojure program that took just as long to start, but then it
stayed running in the background and was quick to respond when you ran the
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
fine, although it was a little bit clunky and unnecessary.

[j2b]: https://github.com/adzerk-oss/boot-jar2bin
[aldagithub]: https://github.com/alda-lang

# Phase 3: ZeroMQ Server/Client

_diagram here: ZMQ server/client with REQ/REP sockets_

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

* break server out into a broker and workers ("paranoid pirate" pattern)
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc35-9416
* the main impetus for this change was that users were starting to report performance/audio issues related to the server trying to parse, evaluate and play multiple scores at once
* i read somewhere that in performance-intensive audio applications, it is important to do all the audio "performance" on a separate thread, e.g. on a dedicated thread running on your sound card
* because zeromq makes it so easy, i decided to try giving each audio "performer" its own process, running on a separate jvm
* this solved a number of issues related to using multiple midi synthesizer instances in the same jvm
* the server is more responsive now that it doesn't have to compete for resources with an audio performance occurring in the same JVM
* worker processes do not exhibit the audio glitches that were observable before because they are mostly free to focus on performing audio, in between polling for messages

# Phase 5 (WIP): Modular Components

* right now, we have only a single program, which is created by bundling the
  (java) client, (clojure) server and (clojure) worker into an executable
  uberjar, but i'm thinking it may be better to organize it so that the
  components can be implemented in non-JVM languages, e.g. a rust client

* already heading in a modular direction with the current progression
  * program
  * client + server
  * client + server + worker

* the worker could be further broken up into separate services:
  * compiler (parses alda code and turns it into a playable score)
  * performer (plays the compiled score)

* this modularity is great for at least a couple reasons
  * each module can be a separate project with its own github repo in the alda-lang org
    * already doing this, enjoying it so far
    * each project is conceptually simpler to understand
    * contributors can explore and discover the alda projects to which they are most interested in contributing
    * less issues per repo, more specialized issues
      * issues become more visible, can get the attention they need
  * more exciting: isolating alda components into external modules paves the way for a "plug 'n play" architecture where developers could feasibly write their own implementations of modules they want to improve, in any programming language they want to use
    * arbitrary examples:
      * an alda client written in rust
      * an alda server written in ruby
      * an alda parser/score construction component written in node.js
      * an alternate sound engine using the Web Audio API via a headless browser

* already done: organized the repos as separate projects/codebases

* (TODO) set up a system where it's easy to replace the existing components
  (client, server and worker) with alternate implementations, and the client (or
  maybe a new, separate program?) keeps track of managing and updating these
  components, which can now be separate programs

* (TODO) break the worker out into services
  * from ZMQ standpoint, considering using elements of the majordomo and titanic patterns
    * services registered with server
    * client still only interacts with the server
    * workers are idempotent
    * server maintains the state of requests and responses
    * request/response is asynchronous:
      * client makes a request, immediately gets a response ("your request is in the queue")
      * workers take jobs off the queue and write the results to disk
      * client periodically checks back with server for status
      * server immediately knows whether the response has arrived, because it can
        see the response on disk
      * server delivers response to client
    * the queue is persistent, which is nice; servers and workers can go down and
      then come back online and pick right up where they left off
    * might modify this pattern a little to allow for multi-step transactions
      * client makes a multi-part request (e.g. parse, build, and play a score)
      * worker A does part 1 of the request (e.g. compile alda code into score
        events), writes result to somewhere temporary
      * server getting status request in the meantime will not see a final result
        and tell the client it's still pending
      * worker B takes temporary result as its job and does part 2 of the request
        (e.g. build score from score events), writes result to somewhere temporary
      * server still sees request as pending, can even tell the client the latest
        step that has been completed
      * worker C takes temporary result of worker B as its job and does part 3 of
        the request (e.g. play the compiled score), writes final result to disk
      * server can now tell client the job is complete and send client the final
        result
      * the appeal of this is that specialized workers can be written in different
        languages that might be better suited to the task at hand
