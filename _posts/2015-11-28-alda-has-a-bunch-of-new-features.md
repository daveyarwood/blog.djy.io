---
layout: post
title: "Alda Has a Bunch of New Features"
category: alda
tags:
  - alda
  - music-programming
  - composition
published: true
---

{% include JB/setup %}

Three months ago, I wrote [a blog post][og-blog-post] introducing the music programming language [Alda][alda] and walking through the basics of using it to write a musical score.

To my amazement and delight, my blog post went mildly viral on Reddit and Hacker News, bringing about a spike in activity on GitHub. I'm thankful for this not only because it brought a handful of new [contributors][contributors] to the project, but also because it pushed me to work extra hard on making improvements and adding new features.

A lot has changed in the last three months. Here's a run-down of some of the new features that have been added to Alda since then.

# Key Signatures

There is now a `key-signature` attribute which, when set, provides default flats and sharps for the appropriate notes depending on the key. This makes it easier to write an Alda score when you're in a key that has a lot of flats or sharps.

The key of B major, for example, has five sharps: F#, C#, G#, D# and A#. Before key signatures in Alda, if you wanted to express a B major scale, you would have to remember to include sharps on all of the right notes:

{% highlight text %}
vibraphone: b8 > c+ d+ e f+ g+ a+ b
{% endhighlight %}

Now you can express a B major scale this way:

{% highlight text %}
vibraphone:
  (key-signature [:b :major])
  b8 > c d e f g a b
{% endhighlight %}

# Advanced Rhythms

There are two new ways to represent rhythms in Alda.

## Seconds/Milliseconds

As an alternative to representing the length of a note in terms of standard music notation (e.g. half, quarter, eighth), the length of the note can be expressed in terms of seconds or milliseconds:

{% highlight text %}
piano:
  # 2 seconds
  c2s

  # 400 milliseconds
  e400ms
{% endhighlight %}

## CRAM

Notes can also be "crammed" evenly into exact note lengths.

For example, you can cram five notes into the duration of a half note:

{% highlight text %}
{ c d e f g }2
{% endhighlight %}

You can also include note-lengths on the notes *inside* of a cram, which will have the effect of giving the longer notes more time relative to the others. The duration of the entire cram expression does not change.

{% highlight text %}
{c d e}2 {c2 d4 e} {c1 d4 e}
{% endhighlight %}

See the Alda docs for [more information about CRAM][cram].

# Repeats

Notes, chords and other Alda "events" can be repeated by appending `* <number-of-repeats>`:

{% highlight text %}
guitar:
  c *4
  c/e *4
{% endhighlight %}

Events can also be grouped together inside of square brackets and repeated:

{% highlight text %}
[c16 d e f g]*4
{% endhighlight %}

# Inline Clojure Code

Alda now supports writing [Clojure][clojure] code alongside Alda code in a score. Any code placed between parentheses in an Alda score is read and evaluated as a Clojure S-expression. Here's a simple example:

{% highlight text %}
(print "Your name, please: ")
(flush)
(def your-name-here (read-line))
(println (format "Hi, %s!" your-name-here))

piano: c12 e g > c4
{% endhighlight %}

This feature opens the door for Clojure programmers to do all kinds of interesting things when writing scores. It's possible to define your own functions and values and use them programmatically in an Alda score. This allows you to do things in your score that a computer can do but a human composer can't, such as choosing notes to play at random:

{% highlight text %}
(def REST-RATE 0.15)
(def MS-LOWER 30)
(def MS-UPPER 3000)
(def MAX-OCTAVE 8)

(defn random-note
  "Plays a random note in a random octave, for a random number of
  milliseconds.

  May randomly decide to rest, instead, for a random number of milliseconds."
  []
  (let [ms (ms (rand-nth (range MS-LOWER MS-UPPER)))]
    (if (< (rand) REST-RATE)
      (pause (duration ms))
      (let [o (rand-int (inc MAX-OCTAVE))
            n [(keyword (str (rand-nth "abcdefg")))
               (rand-nth [:sharp :flat :natural])]]
       (octave o)
       (note (apply pitch n) (duration ms))))))

midi-electric-piano-1:
  (panning 25)
  (random-note) * 50

midi-timpani:
  (panning 50)
  (random-note) * 50

midi-celesta:
  (panning 75)
  (random-note) * 50
{% endhighlight %}

# Improvements to the Alda REPL

We've added a number of useful commands to the Alda REPL.

`:help` displays a list of the available commands. Additional information about commands and their options is available by typing `:help` and the name of the command, e.g. `:help play`:

{% highlight text %}
> :help play
:play

Plays the current score.

   Can take optional `from` and `to` arguments, in the form of markers or mm:ss times.

   Without arguments, will play the entire score from beginning to end.

   Example usage:

     :play
     :play from 0:05
     :play to 0:10
     :play from 0:05 to 0:10
     :play from guitarIn
     :play to verse
     :play from verse to bridge

{% endhighlight %}

The `:new`, `:load`, `:map` and `:score` commands are the start of a [robust system][robust-repl] we are developing that will make it easy to write scores interactively in the Alda REPL.

# The Future

The most exciting features are [yet to come][todo] -- stay tuned for more updates in the coming months. If you're a developer and you're interested in helping, please consider [contributing][contributing]!

[og-blog-post]: {% post_url 2015-09-05-alda-a-manifesto-and-gentle-introduction %}
[alda]: https://github.com/alda-lang/alda
[contributors]: https://github.com/alda-lang/alda/graphs/contributors
[cram]: https://github.com/alda-lang/alda/blob/master/doc/cram.md
[clojure]: http://clojure.org
[robust-repl]: https://github.com/alda-lang/alda/issues/54
[todo]: https://github.com/alda-lang/alda#todo
[contributing]: https://github.com/alda-lang/alda/blob/master/CONTRIBUTING.md
