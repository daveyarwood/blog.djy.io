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
why I made the somewhat surprising decision to rewrite it in Go and Kotlin,
given that Alda v1 is mostly written in Clojure.

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

In Alda v1, you can also write your scores (either partially or completely)
using a Clojure DSL:

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

Even though it wasn't part of my original plan for the Alda language, this
feature of Alda became very important to me, as I grew to love writing music
programmatically by writing Clojure code within an Alda score.

So why, then, did I decide to do a total rewrite of Alda in Go?

# Alda v2

One of the major pain points of Alda v1 is that its architecture is rather
complex, and the burden of that complexity is foisted onto the user. [I wrote
about this in detail a few months ago][alda-v1-shortcomings], but the short
version is that Alda v1 does most of its work in background "worker" processes,
and you can't do anything useful unless you explicitly start an Alda server
first. Alda can't even tell you if you have a _syntax error_ unless you first
have a server running, because even parsing is done in the worker process.

The only reason that I chose to do so much of the work in the worker process
(and so little in the client) is that [the Clojure runtime is infamously slow to
start][clojure-slow-start], which makes it unsuitable for writing command line
applications where fast start-up time is important. I still wanted to keep all
of the Clojure code that I'd written and continue to develop Alda in Clojure, so
as a compromise, I moved all of that code into a background process, and wrote a
lightweight Java client that delegates most of the work to that background
Clojure process.

In short, I chose to make the architecture more complicated and the user
experience worse just so that I could continue to develop Alda in Clojure! But
as time went by, I grew increasingly dissatisfied with the complex
client/server/worker architecture and the fact that users need to start a server
before they can do anything useful with Alda. After mulling it over for a while,
I finally decided that it would be worth simplifying the architecture so that
most of the work is being done in the client, even if that meant that I had to
rewrite Alda in a different language.

## Why Go?

> As an aside: I'm well aware that nowadays, [GraalVM][graalvm] can be used to
> compile Clojure programs into fast, self-contained, native binaries. However,
> at the time when I was beginning the rewrite of Alda and I was deciding which
> language/runtime to use, GraalVM either didn't exist yet, or it was brand
> new, so it wasn't really an option.
>
> Even now, in 2021, GraalVM is probably still not mature enough for me to feel
> comfortable using it as the backbone of Alda. (Besides, I've just spent two
> years rewriting Alda in Go. I'm not in any hurry to rewrite it again!)

I wanted to move most of the work into the client, and startup time and
performance were both super important. It became imperative that I rewrite the
client in a low(-ish) level programming language, one that could produce native
executables on every platform (at least Windows, macOS and Linux) that start up
instantly and run fast.

Go is by no means my favorite language (I could say more about what I don't like
about Go, but that's a topic for another time!), but it proved to be a good
pragmatic choice because out of the options that I tested, which also included
Rust and Crystal, Go was the only language that made it easy for me to create
100% static, cross-platform executables.

## Why Kotlin?

I also ended up using Kotlin to write the Alda v2 "player" process, a new
background process that listens for low-level instructions sent by the Go client
and plays audio using the JVM's MIDI sequencer and synthesizer. I could have
stuck with Clojure to write this new player process, but I wanted to cut down on
startup time as much as possible, and Clojure is simply a non-starter (no pun
intended!) in that area. When it comes to JVM languages, I'm a big fan of
Kotlin, because it does a lot in the way of developer happiness (FP affordances,
null safety, terseness, actual lambdas, etc.), and it has reasonably good
startup time to boot, which makes it well suited for writing command line
applications.

# alda-clj

When I rewrote Alda in Go, I was careful to preserve the ability to compose
music programmatically in Clojure. I achieved this by writing a Clojure library
([alda-clj]) that provides a Clojure DSL on top of the Alda language. What the
library does under the hood is dirt simple. A Clojure expression like...

{% highlight clojure %}
(note
  (pitch :c)
  (note-length 4))
{% endhighlight %}

...evaluates to a record that implements a `Stringify` protocol. For example,
the value of the expression above is a `Note` record that knows how to represent
itself as a string of Alda code. And alda-clj provides a `->str` function that
returns the string of Alda code:

{% highlight clojure %}
(->str
  (note
    (pitch :c)
    (note-length 4)))

;; evaluates to "c4"
{% endhighlight %}

These "domain objects" (part declarations, notes, chords, etc.) compose together
easily, allowing Clojure programmers to construct an Alda score in pure Clojure.
Then, playing the score is simply a matter of wrapping the objects in a call to
the `play!` function:

{% highlight clojure %}

(play!
  (part "piano")
  (note (pitch :c))
  (note (pitch :d))
  (note (pitch :e)))
{% endhighlight %}

Under the hood, all that's doing is stringifying the domain objects into a
single string of Alda code (e.g. `c d e `) and piping it into the `alda play`
command to play it, just like any other Alda score.

There are two wonderful things about this.

First, it means that I get to have my cake and eat it too. I can write Alda in
the language that it needs to be written in for performance reasons, but I can
still use Alda as a vehicle for programmatic Clojure music, the same way that I
always have. (Actually, it's even better now!)

The other thing is that the general pattern that I've come up with here can be
used to create an Alda DSL in practically _any_ programming language.
Contributors have created Alda libraries in Ruby ([alda-rb]) and Julia
([Alda.jl][alda-jl]), and I've even written [a guide][alda-library-guide] to
help programmers roll their own Alda library for their favorite language. I
can't wait to see what other libraries people will come up with!

# Alda v2: coming soon!

Hopefully I've made it clear enough why I chose to reimplement Alda in Go and
Kotlin. I also gave you a little taste of what's to come with the next version
of Alda, which I'm very excited about. I'll be writing more soon about the
upcoming release of Alda 2.0, so stay tuned!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1376511357261086721

[alda]: https://alda.io
[instaparse]: https://github.com/Engelberg/instaparse
[jvm-synth]: https://docs.oracle.com/javase/7/docs/api/javax/sound/midi/Synthesizer.html
[jvm-sequencer]: https://docs.oracle.com/javase/7/docs/api/javax/sound/midi/Sequencer.html
[alda-v1-shortcomings]: {% post_url 2020-12-14-alda-and-the-nrepl-protocol %}#shortcomings-of-alda-v1
[clojure-slow-start]: http://clojure-goes-fast.com/blog/clojures-slow-start/
[graalvm]: https://www.graalvm.org/
[alda-clj]: https://github.com/daveyarwood/alda-clj
[alda-rb]: https://github.com/UlyssesZh/alda-rb
[alda-jl]: https://github.com/SalchiPapa/Alda.jl
[alda-library-guide]: https://github.com/alda-lang/alda/blob/master/doc/implementing-an-alda-library.md
