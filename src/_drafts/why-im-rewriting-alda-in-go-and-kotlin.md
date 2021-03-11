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

# Alda and Clojure

In all honesty, the main reason that I ended up writing Alda in Clojure to begin
with is that Clojure is my favorite programming language. At the time in my life
when I wrote the first working version of Alda, I just felt like I wanted to
write everything in Clojure. And there is certainly something to be said for
writing your hobby project in the language that makes you the happiest or the
language that you're most familiar with.

Clojure did prove to be a good choice for me to write the first version of Alda
because:

1. The excellent [Instaparse][instaparse] library made it really easy for me to
   write a little EBNF grammar and generate a working parser.

2. One of Clojure's superpowers is making it easy to transform deeply nested
   data structures from one shape to another, which is basically what Alda does
   with the parser output to turn it into a score data structure ready to be
   performed.

3. Clojure is a JVM language, and the Java Virtual Machine comes with a built-in
   MIDI [synthesizer][jvm-synth] and [sequencer][jvm-sequencer] that I was able
   to use to make sound without requiring end users to install anything extra.

But implementing Alda in Clojure also ended up having another interesting
benefit. I made an early decision to include Lisp as a subset of the Alda
language. With Clojure itself being a Lisp, I was able to do this trivially by
parsing Clojure's syntax as a subset of Alda's syntax and then evaluating the
Clojure code within the context of the score. This didn't take much effort to
implement, but it unlocked tremendous possibilities for algorithmic music
composition with Alda.

To make it more clear what I'm talking about, consider this snippet of Alda
code where a piano is playing the notes C through G:

{% highlight text %}
piano:
  c d e f g
{% endhighlight %}

In Alda v1, you can also write your scores (either in part or completely) using
a Clojure DSL:

{% highlight clojure %}
piano:
  (note (pitch :c))
  (note (pitch :d))
  (note (pitch :e))
  (note (pitch :f))
  (note (pitch :g))
{% endhighlight %}

Because we're exposing the ability to `eval` arbitrary Clojure code, you can do
anything available in the Clojure language:

{% highlight clojure %}
piano:
  (for [letter [:c :d :e :f :g]]
    (note (pitch letter)))
{% endhighlight %}

And this is a lot of fun, because the Clojure standard library is chock full of
interesting and useful functions for operating on sequences:

{% highlight clojure %}
alto-saxophone:
  (->> [:c :e :g :a :d :b]
       shuffle
       cycle
       (map #(note (pitch %) (duration (note-length 8))))
       (take 16))
{% endhighlight %}

Even though it wasn't part of my original plans for the Alda language, this
feature of Alda became very important to me, as I grew to love writing music
programmatically by writing Clojure code within an Alda score.

So why, then, did I decide to do a total rewrite of Alda in Go?

# Alda v2

One of the major pain points of Alda v1 is that its architecture is rather
complex, and the burden of that complexity is pushed onto the user. [I wrote
about this in detail a few months ago][alda-v1-shortcomings], but the short
explanation is that Alda v1 does most of its work in background "worker"
processes, and you can't do anything unless you explicitly start an Alda server
first. Alda can't even tell you if you have a syntax error unless you first have
a server running, because even parsing is done in the worker process.

The only reason that I chose to do so much of the work in the worker process
(and so little in the client) is that [the Clojure runtime is infamously slow to
start][clojure-slow-start], which makes it unsuitable for writing command line
applications where fast start-up time is important. I still wanted to keep all
of the Clojure code that I'd written and continue to develop Alda in Clojure, so
as a compromise, I moved all of that code into a background process, and wrote a
lightweight Java client that delegates most of the work to that background
Clojure process.

TODO: continue explaining why the move to Go

> As an aside: I'm well aware that nowadays, [GraalVM][graalvm] can be used to
> compile Clojure code into fast, self-contained, native binaries. However, at
> the time when I was beginning the rewrite of Alda and I was deciding which
> language/runtime to use GraalVM either didn't exist yet, or it was brand
> new, so it wasn't really an option.
>
> Even now, in 2021, I would argue that GraalVM is probably still not mature
> enough for me to feel comfortable using it as the backbone of Alda. (Besides,
> I've just spent two years rewriting Alda in Go. I'm not in any hurry to
> rewrite it again!)

# Notes

* Maybe post a link to my Strange Loop 2019 video at the end.
  * https://www.youtube.com/watch?v=6hUihVWdgW0

* When I get to the part about talking about reimplementing Alda in Go, I might
  want to mention how I've preserved a couple of important things from Alda v1:
  * The ability to compose programmatically in Clojure.
    * (but now, in other languages too! and with arbitrary dependencies!)
  * The built-in Lisp. (except now I've implemented it myself in Go, and it's
    super duper limited, just the essentials)

## Copied from a Slack conversation

> TODO: convert these into organized blog post material

The move to Go was motivated by a desire to get closer to the metal and get really really fast startup time and performance. Go is by no means my favorite language, but it proved to be a good pragmatic choice because of the options that I tested (including Go, Rust, and Crystal), I found it to be the easiest way to create 100% static, cross-platform executables with minimal effort.
Kotlin is used for the "player process," a separate background process that listens for instructions sent by the Go client and plays audio using the JVM's MIDI sequencer and synthesizer. I could have gone with Clojure, but I wanted to get startup time as fast as possible, and Clojure is a non-starter in that area. IMO, Kotlin strikes a perfect balance between developer happiness (FP affordances, terseness, actual lambdas, etc.) and reasonable startup time and performance.

More context behind this decision is that my top goal for Alda v2 was to simplify the architecture, so that almost everything is happening right there in the client. The Alda v1 architecture is complicated and brittle in that you can't do hardly anything without having a server running, the server is a background process that, itself, has its own "worker" background processes, and I've seen end users run into trouble on certain OS's (looking at you, Windows!) where background processes can't start their own background processes, or something like that.
Because I had to move everything into the client, and startup time and performance are both super important, it became imperative that I rewrite the client in a systems programming language like Go.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda]: https://alda.io
[instaparse]: https://github.com/Engelberg/instaparse
[jvm-synth]: https://docs.oracle.com/javase/7/docs/api/javax/sound/midi/Synthesizer.html
[jvm-sequencer]: https://docs.oracle.com/javase/7/docs/api/javax/sound/midi/Sequencer.html
[alda-v1-shortcomings]: {% post_url 2020-12-14-alda-and-the-nrepl-protocol %}#shortcomings-of-alda-v1
[clojure-slow-start]: http://clojure-goes-fast.com/blog/clojures-slow-start/
[graalvm]: https://www.graalvm.org/
