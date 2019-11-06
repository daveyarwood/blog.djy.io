---
layout: post
title: "Writing music with Alda #2: rhythm and meter"
category: alda
tags:
  - alda
  - music programming
  - composition
published: true
---

{% include JB/setup %}

This is the second installment in a series where I guide you through learning
how to write music using [Alda][alda]. So far, we've covered:

[#1: Setup and first notes]({% post_url 2019-10-11-writing-music-with-alda-1 %})

# Note lengths

Now that we know how to make different notes, we can start to play around with
making the notes longer or shorter.

Listen to this example, where we're playing the note C a bunch of times, with
descending note lengths tacked on after each `c`:

{% highlight text %}
piano: c10 c9 c8 c7 c6 c5 c4 c3 c2 c1
{% endhighlight %}

What do you notice about how long each note lasts?

**The higher the number is, the shorter the note is.**

Why is that? Well, in standard music notation, we express note lengths as
fractions. We talk about half notes (1/2), quarter notes (1/4), eighth notes
(1/8), and so on. In Alda, we recognize that we only care about the
_denominator_ in the fraction, so to keep things concise, we leave the "1/" part
off and we just use the denominator. A quarter note is 4, a half note is 2, etc.
So, for example, a C quarter note is represented as `c4`.

In the example above, we start with `c10`, a "tenth note" (1/10). Then, we
gradually decrease the note length (the denominator in the fraction) until we
end up at `c1`, which is called a "whole note" (1/1). As the denominators get
smaller, the quantities (of time) get larger, so the notes sound longer.

## Alda note lengths vs. standard music notation

Now, if you walk up to a classically trained musician and you start talking
about "fifth notes" and "tenth notes," they'll probably look at you funny
because those particular note lengths don't actually exist in standard notation!
For whatever reason, the symbols that we have available to us only cover the
powers of 2:

<center>
<img src="{{ site.url }}/assets/2019-10-21-note-hierarchy.gif"
     title="Standard music notation works in powers of 2 (source: https://www.schoolofcomposition.com/music-rhythm/)">
</center>

Mathematically, other fractions make perfect sense. Four quarter notes last the
same amount of time as two half notes or one whole note. Five "fifth notes"
would also last the same amount of time, so we know how long a "fifth note"
should be. It's a little faster than a quarter note, fast enough so that if you
play five of them back to back, it lasts as long as a whole note.

{% highlight text %}
piano:
  # 4 quarter notes = 1 whole note
  c4 c c c c1

  # 5 "fifth" notes = 1 whole note
  c5 c c c c c1
{% endhighlight %}


Standard music notation doesn't have symbols for note lengths that aren't powers
of 2, but Alda is a text format; we can easily support any denominator note
length, so we do! As you're composing music with Alda, remember that you can
experiment with note lengths that aren't powers of 2. As a result, you're bound
to come up with some uncommon and very interesting rhythms.

# Meter

Western music (classical, pop, whatever) is firmly rooted in the number 4. When
people use the word _beat_ (as in: "play this note for 2 beats"), they're
usually talking about quarter notes. Four quarter notes lasts as long as a whole
note, and that length of time is often called a **measure**.

Strictly speaking, **a measure is just a way to group beats**, and it doesn't
have to be 4 beats. It can be a group of 2 beats, 3 beats, 3-1/2 beats, 12
beats, or any other number of beats. Regardless of the number of beats, the
default "beat" is a quarter note, so we're almost always defining the length of
a measure by comparing it to a whole note (which lasts 4 beats)!

## Drumming in 4/4

To make this a little more concrete, let's talk about rock drums for a bit.

Here is a minimal drum pattern:

{% highlight text %}
percussion:
  o2 c4 d c d
{% endhighlight %}

In octave 2, C is a kick drum and D is a snare drum.

The general pattern for rock drumming is to go back and forth between kick and
snare, like this:

> Beat 1: KICK
>
> Beat 2: SNARE
>
> Beat 3: KICK
>
> Beat 4: SNARE

We tend to be in **4/4** most of the time. 4/4 is a **time signature** where
there are four beats in a measure (that's the first "4"), and a "beat" is
defined as a quarter note (that's the second "4").

Now, let's take the example above and repeat it several times. **In 4/4, each
group of four beats is one measure**, so we'll put each measure on a separate
line so that we can easily see where the measures are:

{% highlight text %}
percussion:
  o2
  c4 d c d
  c d c d
  c d c d
  c d c d
{% endhighlight %}

So, the drum pattern is:

> Measure 1: KICK SNARE KICK SNARE
>
> Measure 2: KICK SNARE KICK SNARE
>
> Measure 3: KICK SNARE KICK SNARE
>
> Measure 4: KICK SNARE KICK SNARE

Here's a slightly more complex example:

{% highlight text %}
percussion:
  o2
  c4 d c8 c d4
  c4 d c8 c d4
  c4 d c8 c d4
  c4 d c8 c d4
{% endhighlight %}

Now, we have a mix of quarter and eighth notes. The pattern is:

> KICK SNARE KICK-KICK SNARE

The overall idea is still to alternate between the kick drum and the snare drum,
but we're adding in an extra kick during beat 3 (so that it's "kick-kick" eighth
notes instead of just a "kick" quarter note) for the sake of variety. Having
beats 1 and 2 (KICK SNARE) be different from beats 3 and 4 (KICK-KICK SNARE)
makes it easier for us to "feel" that a measure is 4 beats long, i.e. we're in
4/4.

Classically trained musicians have a mini-language that we use to describe a
rhythm verbally. In this case, the "KICK SNARE KICK-KICK SNARE" rhythm above is
pronounced: "1 2 3-and 4." Listen to the rhythm and count along; notice that
there is a note (the "and") that is positioned exactly between beats 3 and 4.

# Exercises

1. Play a measure of 4/4 consisting of 4 quarter notes.

2. Play a measure of 4/4 consisting of 8 eighth notes.

3. Play a measure of 4/4 consisting of 7 "seventh" notes.

4. Write a measure of 4/4 that is a mix of quarter and eighth notes.

5. Write a [C major scale][c-major-scale] in quarter notes.

  - Change it so that they're all eighth notes.

  - Make some of them eighth notes and some of them quarter notes.

  - See what interesting rhythms you can make using just quarter and eighth
    notes.

  - Now try user other note lengths besides quarter and eighth.

    (Remember that any number works in Alda! Try both odd and even numbers.)

[c-major-scale]: {% post_url 2019-10-11-writing-music-with-alda-1
%}#notes-besides-c


# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1186969469962334208

[alda]: https://alda.io
