---
layout: post
title: "Writing music with Alda #1: your first notes"
category: alda
tags:
  - alda
  - music programming
  - composition
published: true
---

{% include JB/setup %}

Every now and then, somebody tells me that they just installed [Alda][alda] and
they're enjoying it, but that they aren't quite sure where to start when it
comes to writing a piece of music. The trouble is that Alda is significantly
more useful to those of us who already have some knowledge of songwriting or
music theory.  If you don't have that kind of background, you might feel like
you could use some direction.

For a long while now, I've been meaning to create a series of blog posts that
will bring the rest of us up to speed so that we can _all_ use Alda to write
music. I think Alda can be a great tool for computer-savvy people to learn the
basics of music theory and start writing music.

So, let's get started!

# Setup

If you haven't already, [install Alda][install-alda]. If you already have Alda
installed, make sure you're using the latest version by running `alda update`.

If you've done this properly, you should be able to run `alda version` in your
terminal and see output like the following:

{% highlight shell %}
$ alda version
Client version: 1.3.3
Server version: [27713] 1.3.3

# If you see an error message about the server being down...
$ alda version
Client version: 1.3.3
Server version: [27713] ERROR Alda server is down. To start the server, run `alda up`.

# ...start the server by running `alda up`, and you'll be good to go.
$ alda up
[27713] Starting Alda server...
[27713] Server up ✓
[27713] Starting worker processes...
[27713] Ready ✓

$ alda version
Client version: 1.3.3
Server version: [27713] 1.3.3
{% endhighlight %}

I recommend installing a good, free MIDI soundfont, [as described here in the
Alda README][midi-soundfont]. The sound quality will be noticeably better, and
so will the music that you write!

# Following along

As you read through the examples in this blog series, type them yourself and use
Alda to play them back. Don't just copy and paste them into your REPL or text
editor; type them out yourself! The process of typing the code yourself will get
you more familiar with the syntax and help you learn faster.

There are a few different ways that you can follow along:

## The Alda REPL

Alda has an interactive mode called the **R**ead-**E**val-**P**lay **L**oop. To
start a REPL session, run `alda repl`:

{% highlight text %}
$ alda repl
 █████╗ ██╗     ██████╗  █████╗
██╔══██╗██║     ██╔══██╗██╔══██╗
███████║██║     ██║  ██║███████║
██╔══██║██║     ██║  ██║██╔══██║
██║  ██║███████╗██████╔╝██║  ██║
╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝

             1.3.3
         repl session

Type :help for a list of available commands.

>
{% endhighlight %}

You can now enter Alda code, line by line, and each time you press Enter, the
line of code that you entered is played back.

{% highlight text %}
> piano: c
{% endhighlight %}

## Text editor + terminal

You can edit your Alda code in a text file, using whatever text editor you like
best, and then, in a separate terminal, use the `alda play` command to play the
contents of the file.

{% highlight shell %}
# After creating a file called `test.alda` in your home directory...
$ cat ~/test.alda
piano: c

# Play the file
$ alda play -f ~/test.alda
{% endhighlight %}

## Text editor plugin

There are [Alda plugins available for a handful of text editors][alda-plugins].
The Vim and Emacs plugins, in particular, give you the ability to play back the
contents of your file (or just parts of it, e.g. what you have currently
selected) just by pressing a couple of keys.

# Your first notes

## Middle C

When you're learning to play the piano, one of the first things you learn is
where to find "middle C" on the keyboard.

<img src="{{ site.url }}/assets/2019-10-10-middle-c-on-keyboard.png"
     title="Middle C on the piano keyboard (source: https://music.stackexchange.com/questions/9987/on-a-piano-scale-what-is-considered-middle-c)">

<img src="{{ site.url }}/assets/2019-10-10-middle-c-between-staves.jpg"
     title="Middle C between the treble and bass staves (source: https://music.stackexchange.com/questions/9987/on-a-piano-scale-what-is-considered-middle-c)">

To play middle C in Alda, switch to the fourth octave (`o4`) and play `c`:

{% highlight text %}
# Middle C
piano: o4 c
{% endhighlight %}

## C in other octaves

This is only one instance of the note "C." There are other C's on the piano;
they sound just like middle C, but they are in a lower or higher octave.

{% highlight text %}
# C3 (one octave below middle C)
piano: o3 c

# C4 (middle C)
piano: o4 c

# C5 (one octave above middle C)
piano: o5 c
{% endhighlight %}

## Notes besides C

Remember this: **C is where the octave starts**. The note letters are A through
G, so it's a little weird that the first note is C instead of A, but that's just
the way it is. (I'm not actually sure why it works that way. If you're reading
this and you know, please enlighten me!)

If you start at C and make your way up the keyboard (C, D, E, F...), you're
playing a **C major scale**.

{% highlight text %}
piano: c d e f g a b
{% endhighlight %}

Hear how the notes keep getting slightly higher in pitch. Notice how after G
comes A; A is _higher_ than G.

At this point, we've just played a B, and the next note up is a C. So, if we
started in octave 4, then this next C is the start of octave 5.

{% highlight text %}
piano: o4 c d e f g a b o5 c
{% endhighlight %}

Alda has a "next octave up" operator (`>`) that lets you say the same thing in a
different way:

{% highlight text %}
# start in octave 4 (o4), switch to octave 5 (o5)
piano: o4 c d e f g a b o5 c

# start in octave 4 (o4), move up (>) to octave 5
piano: o4 c d e f g a b > c
{% endhighlight %}

# Exercises

1. Experiment with changing the octave in the example above from `o4` to a
different octave number and see how that sounds.

2. Start in octave 0, play a C, go up an octave using `>`, play a C, go up an
octave, play a C, etc.

3. Start in octave 8, play a C, go _down_ an octave using `<`, play a C, go down
an octave, play a C, etc.

4. Play an **A minor scale**. An A minor scale has the same notes as the C major
scale, but you start on A instead of C.

5. Find a list of all of the instruments available in Alda. Try some of them out and find a few in particular that you like.

# *~ fin ~*

That's all for now. Stay tuned for more of these in the near future!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1182625166414798848

[alda]: https://alda.io
[install-alda]: https://github.com/alda-lang/alda#installation
[midi-soundfont]: https://github.com/alda-lang/alda#midi-soundfonts
[alda-plugins]: https://github.com/alda-lang/alda#editor-plugins
