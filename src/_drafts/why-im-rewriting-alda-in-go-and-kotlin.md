---
layout: post
title: "Why I'm rewriting Alda in Go and Kotlin"
category: alda
tags:
  - clojure
  - go
  - kotlin
published: true
---

{% include JB/setup %}

Over the last 2 years or so, I've been working on a ground-up rewrite of
[Alda][alda], the music composition programming language that has been my
passion project since 2012. Now that I'm finally almost done(!) with the rewrite
and just about ready to release Alda v2 to the world, I figured I should explain
why, exactly, I made the somewhat surprising decision to rewrite it in Go and
Kotlin, given that Alda v1 is mostly written in Clojure.

# Notes

## Copied from a Slack conversation

> TODO: convert these into organized blog post material

The move to Go was motivated by a desire to get closer to the metal and get really really fast startup time and performance. GraalVM wasn't really an option at the time that I made that decision, and I would argue is probably still not an option given the relative immaturity of GraalVM. Go is by no means my favorite language, but it proved to be a good pragmatic choice because of the options that I tested (including Go, Rust, and Crystal), I found it to be the easiest way to create 100% static, cross-platform executables with minimal effort.
Kotlin is used for the "player process," a separate background process that listens for instructions sent by the Go client and plays audio using the JVM's MIDI sequencer and synthesizer. I could have gone with Clojure, but I wanted to get startup time as fast as possible, and Clojure is a non-starter in that area. IMO, Kotlin strikes a perfect balance between developer happiness (FP affordances, terseness, actual lambdas, etc.) and reasonable startup time and performance.

More context behind this decision is that my top goal for Alda v2 was to simplify the architecture, so that almost everything is happening right there in the client. The Alda v1 architecture is complicated and brittle in that you can't do hardly anything without having a server running, the server is a background process that, itself, has its own "worker" background processes, and I've seen end users run into trouble on certain OS's (looking at you, Windows!) where background processes can't start their own background processes, or something like that.
Because I had to move everything into the client, and startup time and performance are both super important, it became imperative that I rewrite the client in a systems programming language like Go.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda]: https://alda.io
