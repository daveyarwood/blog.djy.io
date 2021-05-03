---
layout: post
title: "Announcing Alda 2"
category: alda
tags:
  - alda
published: true
---

{% include JB/setup %}

I'm excited to announce the release of Alda 2.0.0! This new version of
[Alda][alda] is a from-the-ground-up rewrite that I've been working on since
late 2018, and I couldn't be happier to finally share it with the world!

Despite the shiny new version number, at a language level, Alda 2 is almost
exactly the same as the Alda that you're used to. I have sampled scores from the
wild and taken great care to ensure that they are treated the same way by Alda 1
and Alda 2. I even wrote [a comparison tool][comparer] and ran it on a number of
Alda scores that I found on GitHub, and it helped me to find and fix some bugs
and inconsistencies. As a result, I can say with confidence that your Alda
scores should still parse successfully and sound exactly the same as they did
with Alda 1.

One notable breaking change is that, because Alda is no longer written in
Clojure, Alda no longer supports inline Clojure code, and the attribute syntax
is different in a couple of places. I've written an [Alda 2 migration
guide][migration-guide] with details about what has changed and what to expect.

Here's a quick summary:

# What's new?

* `alda` is now a native application written in Go. Releases are available for
  Linux, Mac and Windows.

* There is also a small background `alda-player` process, written in Kotlin.
  Alda starts these processes in the background to play your scores.

* Because of the move to native and most of the work now being done in the
  `alda` client process (instead of in a worker process), Alda 2 is noticeably
  faster than Alda 1. Scores are now parsed and evaluated in **microseconds**!

* You no longer have to start a server in order to use Alda. No more running
  `alda up`! After installing Alda 2, you're just an `alda play` command away
  from hearing your text-based musical creations.

* The new `alda doctor` command runs some basic health checks and looks for
  signs that your system might not be set up for Alda to work properly. If you
  run into any unexpected problems, `alda doctor` can help you troubleshoot.

* The Alda REPL (**R**ead-**E**val-**P**lay **L**oop) has been upgraded to work
  across a network connection. You can run `alda repl` in either `--client` or
  `--server` mode, or run `alda repl` with no flags for the experience that
  you're used to from Alda 1.

  This new, network-enabled REPL has promising potential as a foundation for
  tooling and a platform for collaborative score-writing in the future!

# What's changed?

* As I mentioned above, inline Clojure code is no longer supported. But if
  you're a Clojure programmer and you're still interested in writing Alda scores
  programmatically (e.g. to create algorithmic music compositions), have no
  fear! The [alda-clj] library can do everything that you were able to do with
  inline Clojure code in Alda 1, and much more.

* Whereas Alda 1 had inline Clojure code, Alda 2 has a tiny, built-in Lisp
  implementation called "alda-lisp". alda-lisp lacks a lot of Clojure's syntax
  and features, but it provides just enough to support Alda's attributes. Most
  attributes (e.g. `(volume 50)`) will work the same way they did before. Two of
  them have changed slightly:

  * `(key-signature! [:a :major])` is now `(key-signature! '(a major))`

  * `(octave :up)` and `(octave :down)` are now `(octave 'up)` and `(octave
    'down)`.

    (Although you'd usually just write `>` and `<`, and those still work the
    same way.)

* The `alda parse` output in Alda 2 is different from that of Alda 1 in a number
  of ways. If you happen to have built any tooling or workflows that rely on the
  Alda 1 `alda parse` output, you will likely need to make adjustments after
  upgrading to Alda 2.

# Try it out!

If you haven't installed Alda yet, you can get the latest version by following
the [instructions on the Alda website][alda-install].

If you have Alda 1 installed, you can upgrade to Alda 2 by running `alda
update` **twice**. (The first time will install the last release in the
1.x series, and the second time will install the latest 2.x release.)

After installing Alda 2, give these commands a try:

{% highlight text %}
alda version
alda --help
alda doctor
alda play -c "piano: c8 d e f | d+2/f+/b32 > c+16. < b8 a+ g+ | c+2/e+/f+"
{% endhighlight %}


I hope you enjoy the next generation of Alda, and that you're as excited about
the future of Alda as I am! If you'd like, you can join our [Slack
group][alda-slack] and let us know what you think of Alda 2. I'd love to hear
your thoughts.

Finally, I should mention that if you enjoy my work on Alda, you can support me
and sustain the ongoing development of Alda by [becoming a sponsor][gh-sponsor].

Have fun!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda]: https://alda.io
[comparer]: https://github.com/daveyarwood/alda-v1-v2-comparer
[migration-guide]: https://github.com/alda-lang/alda/blob/master/doc/alda-2-migration-guide.md
[alda-clj]: https://github.com/daveyarwood/alda-clj
[alda-install]: https://alda.io/install
[alda-slack]: https://slack.alda.io
[gh-sponsor]: https://github.com/sponsors/daveyarwood
