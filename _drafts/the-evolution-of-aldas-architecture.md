---
layout: post
title: "The Evolution of Alda's Architecture"
category: alda
tags:
  - alda
  - music-programming
  - composition
  - zeromq
published: true
---

{% include JB/setup %}

In [my last blog post]({% post_url 2016-06-15-alda-for-clojurists %}), I talked about an important evolution in the implementation of [alda.lisp](https://github.com/alda-lang/alda/blob/master/doc/alda-lisp.md), a sort of DSL or "mini-language" that represents a musical score and compiles down to a data representation of the score that can be played by Alda's sound engine.

In this post, I'd like to talk about another way that Alda has evolved over the past year. At the time of writing, I consider Alda to be in "Stage 4" of an ongoing series of architectural improvements.

# Stage 1: Minimum Viable Product

* just a single clojure program that does everything

# Stage 2: HTTP Server/Client

* 12/25/15: break out client as a java program for better cli experience;
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc1-122515-christmas_tree
  server naiively implemented as an http server

# Stage 3: ZeroMQ Server/Client

* won't go into detail about ZeroMQ here -- it's something i've been playing around with a lot lately and i'm planning on writing another blog post soon about ZeroMQ
* if you're not familiar with ZeroMQ, you can think of it as an easy way to do networking between separate threads or processes
* in the case of alda, ZeroMQ proved to be a useful way to improve the previous client/server implementation
  * faster b/c less overhead
  * parsing/handling HTTP requests is more complicated than simple TCP requests, have to correctly consider methods, headers, and other parameters
* 8/18/16: translated client/server relationship into zeromq REQ/REP socket
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc32-81816
* use "lazy pirate" pattern to make the client more resilient to failure
  * more or less part of 1.0.0-rc32

# Stage 4: Load-Balanced Workers

* break server out into a broker and workers ("paranoid pirate" pattern)
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc35-9416
* the main impetus for this change was that users were starting to report performance/audio issues related to the server trying to parse, evaluate and play multiple scores at once
* i read somewhere that in performance-intensive audio applications, it is important to do all the audio "performance" on a separate thread, e.g. on a dedicated thread running on your sound card
* because zeromq makes it so easy, i decided to try giving each audio "performer" its own process, running on a separate jvm
* this solved a number of issues related to using multiple midi synthesizer instances in the same jvm
* the server is more responsive now that it doesn't have to compete for resources with an audio performance occurring in the same JVM
* worker processes do not exhibit the audio glitches that were observable before because they are mostly free to focus on performing audio, in between polling for messages

# Stage 5 (WIP): Modular Components

> NB: is this actually multiple steps?
>
> maybe step 5 is organizing the repos as separate projects and (TODO) setting
> up a system where it's easy to replace the existing components (client, server
> and worker) with alternate implementations, and the client (or maybe a new,
> separate program?) keeps track of managing and updating these components,
> which can now be separate programs
>
> right now, we have only a single program, which is created by bundling the
> (java) client, (clojure) server and (clojure) worker into an executable
> uberjar, but i'm thinking it may be better to organize it so that the
> components can be implemented in non-JVM languages, e.g. a rust client
>
> so then step 6 would be breaking the worker out into services w/ something
> like the majordomo or titanic pattern

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
