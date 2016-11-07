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

* break out client as a java program for better cli experience;
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc1-122515-christmas_tree
  server naiively implemented as an http server

# Stage 3: ZeroMQ Server/Client

* translate client/server relationship into zeromq REQ/REP socket
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc32-81816
* use "lazy pirate" pattern to make the client more resilient to failure
  * more or less part of 1.0.0-rc32

# Stage 4: Load-Balanced Workers

* break server out into a broker and workers ("paranoid pirate" pattern)
  * https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#100-rc35-9416

# Stage 5 (TODO): Modular Components

* already heading in a modular direction with the current progression
  * program
  * client + server
  * client + server + worker

* the worker could be further broken up into modules:
  * alda.parser (parser)
  * alda.lisp   (score construction DSL)
  * alda.sound  (sound engine)

* this modularity is great for at least a couple reasons
  * each module can become a separate project with its own github repo in the alda-lang org
    * each project becomes conceptually simpler to understand
    * contributors can explore and discover the alda projects to which they are most interested in contributing
    * less issues per repo + more specialized issues
      * issues become more visible, can get the attention they need
  * more exciting: isolating alda components into external modules paves the way for a "plug 'n play" architecture where developers could experiment with writing their own implementations of modules they want to improve, in any programming language they want to use
    * arbitrary examples:
      * an alda client written in rust
      * an alda server written in ruby
      * an alda parser/score construction component written in node.js
      * an alternate sound engine using the Web Audio API via a headless browser

* thoughts welcome on this: https://github.com/alda-lang/alda/issues/186
