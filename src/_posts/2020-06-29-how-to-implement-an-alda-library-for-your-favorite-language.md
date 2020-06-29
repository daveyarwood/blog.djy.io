---
layout: post
title: "How to implement an Alda library for your favorite language"
category: alda
tags:
  - alda
  - music programming
  - composition
  - generative art
published: true
---

{% include JB/setup %}

An important design goal of [Alda][alda] is that the language should not be a
Turing-complete programming environment. This keeps Alda simple and focused on
doing what it does best: being an easy-to-learn, markup-like text language for
music composition.

At the same time, I really enjoy being able to compose algorithmic music by
writing programs that generate Alda scores. This was what led me to make the
Clojure library [alda-clj].

Here are a couple of basic examples showing how you can use alda-clj in a
Clojure program or REPL session:

{% highlight clojure %}
;; Import all of the functions from alda.core into the current context
(require '[alda.core :refer :all])

;; Play a whole note G2 on a trombone
(play!
  (part "trombone")
  (octave 2)
  (note (pitch :g) (note-length 1)))

;; Play "C D E F G" 4 times at random tempos in the range of 60-260 BPM
(play!
  (part "piano")
  (for [bpm (repeatedly 4 #(+ 60 (rand-int 200)))]
    [(tempo bpm)
     (for [letter [:c :d :e :f :g]]
       (note (pitch letter) (note-length 8)))]))
{% endhighlight %}

alda-clj is old news, though. I wrote alda-clj back in December 2018. An idea
that I find much more compelling is that anybody can come along and create their
own library for generative music or live-coding that uses Alda as a platform,
not just for Clojure, but for _any_ language.

I've been excited about this concept for a long time, now. Every now and then, a
conversation pops up somewhere about writing programs in `<insert language
here>` to make music with Alda. I was surprised to see how quickly I could write
my own library that does this in Clojure. It only took me a couple of days to
write! ...Granted, I _am_ the creator of Alda, so it was probably a little bit
easier for me to do it than it would be for anyone else. But even if that
weren't the case, I still think that most people who've been programming for at
least a couple of years could write a library like alda-clj for their language
of choice within a matter of days.

The other day, somebody in the [Alda Slack group][alda-slack] asked me if there
was a reference for implementing a library for Alda in another language. This
made me realize that, despite having [written in the
past][writing-music-programmatically] about it being _easy_ to implement an Alda
library in your language of choice, I haven't provided any specific guidance
about how somebody might go about doing that.

**Until now.**

I just finished writing a step-by-step guide for any programmer who wants to
write their own Alda library for their language of choice. At the time of
writing, I'm aware of only two such libraries: [alda-clj][alda-clj] (Clojure)
and [alda-rb][alda-rb] (Ruby). Maybe your favorite language will be next! :)

[The guide is here][alda-library-guide]. Feedback welcome! I hope you find it
helpful and that some of you might get the itch to try your hand at writing an
Alda library for `<insert language here>`.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda]: https://alda.io
[alda-clj]: https://github.com/daveyarwood/alda-clj
[alda-library-guide]: https://github.com/alda-lang/alda/blob/master/doc/implementing-an-alda-library.md
[alda-rb]: https://github.com/UlyssesZh/alda-rb
[alda-slack]: https://slack.alda.io
[writing-music-programmatically]: https://github.com/alda-lang/alda/blob/master/doc/writing-music-programmatically.md
