---
layout: post
title: "Alda: A Manifesto and Gentle Introduction"
category: alda
tags: 
  - alda
  - music-programming
  - composition
published: true
---

{% include JB/setup %}

# What is Alda?

<img src="{{site.url}}/assets/2015-08-18-alda.png"
     alt="alda"
     title="alda"
     width="600"
     height="300" />

Alda's ambition is to be a powerful and flexible music programming language that can be used to create music in a variety of genres by typing some code into a text editor and running a program that compiles the code and turns it into sound. I've put a lot of thought into making the syntax as intuitive and beginner-friendly as possible. In fact, one of the goals of Alda is to be simple for someone with little-to-no programming experience to pick up and start using. Alda's tagline, *a music programming language for musicians*, conveys its goal of being useful to non-programmers.

But while its syntax aims to be as simple as possible, Alda will also be extensive in scope, offering composers a canvas with creative possibilities as close to unlimited as it can muster. I've already rambled at length about the inspiring creative potential that audio programming languages can bring to the table. It is my hope that Alda will embody much of this potential. 

At the time of writing, Alda can be used to create MIDI scores, using any instrument available in the [General MIDI sound set](http://www.midi.org/techspecs/gm1sound.php). In the near future, Alda's scope will be expanded to include sounds synthesized from basic waveforms, samples loaded from sound files, and perhaps other forms of synthesis.

In this blog post, I will walk you through the steps of setting up Alda and writing some basic scores. 

But first, a little history.

# UNC and MML

<img src="{{ site.url }}/assets/2015-08-18-imml.png"
     alt="MML code sample"
     title="MML code sample. (source: http://midr2.under.jp/mck/imml.html)" />

I can trace the origins of Alda back to 2004. At the time, I was studying Music Composition at UNC and exploring ways to make electronic music. I mucked around in [FruityLoops][fruityloops] a bit without much success. Eventually, I stumbled upon an entire world of [music programming][musicprog]. My gateway drug was [MML][mml], which was (and perhaps still is) the most legit way for [chiptune][chiptune] musicians to make NES music.
After reading through [Nullsleep][nullsleep]'s excellent [MML tutorial][mmltut] and learning how to make [some rudimentary NES music][pixelrain], I started to become more involved in making music with human beings and took a hiatus from MML. But the seed had been planted for a lifelong obsession with the idea of programming music.

[fruityloops]: https://en.wikipedia.org/wiki/FL_Studio
[musicprog]: https://en.wikipedia.org/wiki/List_of_audio_programming_languages
[mml]: https://en.wikipedia.org/wiki/Music_Macro_Language#Modern_MML
[chiptune]: https://en.wikipedia.org/wiki/Chiptune
[nullsleep]: http://www.nullsleep.com/
[mmltut]: http://www.nullsleep.com/treasure/mck_guide/
[pixelrain]: {% post_url 2015-01-24-pixel-rain %}

MML ended up becoming a major influence on Alda. I really enjoyed the workflow of creating NES music by writing code in a text editor. But what I wanted was a more general-purpose music programming language. I wanted to take MML's approach to generating NES music and extend it to other realms of digital music creation: additive/subtractive synthesis, electroacoustic music, and even classical music.

# Classical music?

<img src="{{site.url}}/assets/2015-08-18-sibelius.png" 
     alt="Sibelius (the music notation software)"
     title="Sibelius (source: https://en.wikipedia.org/wiki/Sibelius_(software))">

I was a classically trained musician long before I was a competent programmer. My music education led to a particular interest in composing music in a variety of styles. Growing up around computers, I discovered an ever-expanding class of GUI applications designed to help musicians compose music. 
I wrote guitar tablature with [Guitar Pro][guitarpro], and for traditional music notation I have tried, at various times in my life, [Cakewalk][cakewalk], [Noteworthy Composer][noteworthy], [Finale][finale], [Sibelius][sibelius], and [MuseScore][musescore], among others. 

[guitarpro]: http://guitar-pro.com
[cakewalk]: https://en.wikipedia.org/wiki/Cakewalk_(sequencer)
[noteworthy]: https://noteworthycomposer.com
[finale]: http://finalemusic.com
[sibelius]: http://sibelius.com
[musescore]: https://musescore.org

When I was studying music composition, I got a lot of mileage out of Sibelius, in particular. I used Sibelius extensively to transcribe pieces of music as I composed them. It allowed me to have a digital record of my compositions, and it was essential (practically a requirement) as a way to print out individual instrument parts to distribute to the musicians who performed my pieces.

Music notation applications like Sibelius are clearly a very important tool for people who are serious about composing music. However, as a programmer and as a composer, I feel that there are a couple of fundamental problems with GUI music notation software:

<center>
  <img src="{{site.url}}/assets/2015-08-19-ravel.jpg"
       alt="Maurice Ravel"
       title="Maurice Ravel at work (source: http://www.gettyimages.com/detail/news-photo/maurice-ravel-french-composer-1875-1937-pictured-here-at-news-photo/79054097)" 
       width="300"
       height="371"/>
</center>

* **It's distracting.**  When pre-digital age composers used to write music, they would sit at a piano and write it out by hand on staff paper. All of the notation techniques, the layout of their scores, everything, came directly from their minds and through their pens. 
When you notate music using a GUI application, you have menus upon menus in front of you from which to select whatever elements of music notation you wish to use in your score. This is distracting in two ways:

    1. It's not always easy to find what you're looking for. By the time you find it, you may have lost your train of thought.

    2. Having all of these music elements in front of you is visually distracting. When I used Sibelius, I would sometimes end up distracting myself for long stretches of time as I perused all of the different music notation elements it was possible to place, or browsed through all the project templates available. 

    In contrast to working with these complex GUI applications, I have found that programming pieces of music in a text editor is a pleasantly distraction-free experience.

<center>
  <img src="{{site.url}}/assets/2015-08-19-limitations.png"
       alt="an error message in Sibelius"
       title="An error message in Sibelius (source: http://www.sibeliusblog.com/tutorials/stretching-the-limits)" 
       width="500"
       height="350"/>
</center>

* **It's limiting.** I think for a composer to have an ideal environment in which to compose, he needs to get back to the basics. He needs a blank canvas and a way to notate music. And because this is the 21st century, his scores need a way to be interpreted by a computer and turned into audio. It would also be nice if his scores could be easily converted to and from the standard notation format that human musicians are trained to read. 

    The GUI programs available today do an excellent job of handling these 21st century requirements, but they do so by taking a shortcut -- they skip the "blank canvas" part. Of course, when you create a new score in Sibelius (for example), you do have what looks like some empty lines of staff paper, but in fact, this blank staff paper carries a very different connotation than does a physical page of manuscript paper. You can't just grab a pencil and start writing whatever your heart desires. There are a number of hidden restraints that the GUI application forces upon you. 

    This is an inherent shortcoming of any GUI music notation editor; in order to be able to represent your musical score visually in a sane and comprehensible way, it has to impose some restrictions. Audio programming languages must also impose restrictions (in the same sense that any piece of software does), but because they are not tied to visually representing your score and maintaining a user-friendly GUI interface, they are able to get away with imposing substantially less restrictions on the composer. As a composer, I find this fascinating and inspiring.

# Setup

> Note: As Alda is currently still under development, you will need to follow the process below to run it. Hopefully the process is pretty intuitive, and certainly feel free to [e-mail me](mailto:dave.yarwood@gmail.com?subject=alda) if you run into any issues. In the future, the process will be much simpler, e.g. downloading and running a standalone executable program.

To get started with Alda, you will need to do two things:

<ol>
  <li>
  Clone the <a href="http://github.com/alda-lang/alda">GitHub repository</a> by running this command:<br>
  <br>
  {% highlight text %}
  git clone git@github.com:alda-lang/alda.git
  {% endhighlight %}
  </li>
  <br>
  <li>
  Install the Clojure build tool <a href="http://boot-clj.com">Boot</a>.
  </li>
</ol>

Open a terminal in the directory where you cloned the Alda repo, and you will now be able to use a handful of built-in tasks. You can parse and/or play Alda code from a file or a string of Alda code provided as a command-line argument. Or, you can build a score incrementally by using the Alda REPL.

# Basic Alda syntax

We will use the Alda REPL at first, to experiment a little with Alda syntax. To start the REPL, type: 

{% highlight text %}
boot alda-repl
{% endhighlight %}

> Note: Alda uses a [soundfont](https://en.wikipedia.org/wiki/SoundFont) called FluidR3 to make MIDI sound a lot nicer. This is a one-time 125 MB download that will kick off when you run the above command. This may take a few minutes, depending on your network connection. 
To pass the time while you wait, you may want to watch [some](https://www.youtube.com/watch?v=NhjSzjoU7OQ) [music](https://www.youtube.com/watch?v=7F5TZ7z7tJs) [videos](https://www.youtube.com/watch?v=gzoEK545j64) on YouTube or something.

> If you'd prefer to skip this step and use the Java Virtual Machine's built-in MIDI synthesizer (which sounds terrible) instead, you can type `boot alda-repl --stock`.

Once FluidR3 has downloaded and the REPL is ready, you should see something like this:

<center>
  <img src="{{site.url}}/assets/2015-08-20-alda-repl.png"
       alt="the Alda REPL"
       title="the Alda REPL" 
       width="500"
       height="225">
</center>

You can type snippets of Alda code into the REPL, press Enter, and hear the results instantly.

As I mentioned, MML ended up being a primary influence on Alda. The great thing about MML, in particular, is the simplicity of its syntax. I would describe it as being similar to [Markdown](http://daringfireball.net/projects/markdown); essentially, what you see is what you get.

## Notes

Let's start with a simple example. Let's translate this measure of sheet music into Alda:

**(insert sheet music here: C D E F quarter notes)**

Here we have four quarter notes: C, D, E and F. The Alda version of this is:

{% highlight text %}
c d e f
{% endhighlight %}

Try typing this into the REPL... nothing happens. Why? Well, we haven't told Alda what kind of instrument we want. Let's go with a piano:

{% highlight text %}
piano: c d e f
{% endhighlight %}

You should hear a piano playing those four notes. You will also notice that the prompt has now changed from `>` to `p>`. `p` is short for `piano`, and it signifies that the piano is the only currently active instrument. Until you change instruments, any notes that you enter into the REPL will continue to be played by the piano.

## Octaves

Let's add some more notes.

**(insert sheet music here: G A B > C quarter notes)**

{% highlight text %}
g a b > c
{% endhighlight %}

You should hear the piano continuing upwards in the C major scale. An interesting thing to note here is the `>`. This is Alda syntax for "go up to the next octave." An octave, in [scientific pitch notation](https://en.wikipedia.org/wiki/Scientific_pitch_notation), starts on a C and goes up to a B. Once you go above that B, the notes start over from C and you are in a new octave. 
In Alda, each instrument starts in octave 4, and remains in that octave until you tell it to change octaves. You can do that in one of two ways: you can use `<` and `>` to go down or up by one octave; or, you can jump to a specific octave using `o` followed by a number. For example:

**(sheet music: 10 C's in SPN -- maybe just re-use the sheet music from the SPN wikipedia page?)**

{% highlight text %}
o0 c > c > c > c > c > c > c > c > c > c o4
{% endhighlight %}

## Accidentals

Sharps and flats can be added to a note by adding `+` or `-`. 

**sheet music**

{% highlight text %}
c < b- a g f+ 
{% endhighlight %}

You can even have double flats/sharps:

**sheet music**

{% highlight text %}
f+ e d+ c+ < b++
{% endhighlight %}

As a matter of fact, a note in Alda can have any combination of flats/sharps. It usually isn't useful to use more than 2 sharps or flats (tops), but there's nothing stopping you from doing things like this:

**sheet music?**

{% highlight text %}
o4 c++++-+-+-+
{% endhighlight %}

## Note lengths

By default, notes in Alda are quarter notes. You can set the length of a note by adding a number after it. The number represents the note type, e.g. 4 for a quarter note, 8 for an eighth, 16 for a sixteenth, etc. When you specify a note length, this becomes the "new default" for all subsequent notes.

**sheet music**

{% highlight text %}
c4 c8 c c16 c c c c32 c c c c c c c | c1
{% endhighlight %}

You may have noticed the pipe `|` character before the last note in the example above. This represents a bar line separating two measures of music. Bar lines are optional in Alda; they are ignored by the compiler, and serve no purpose apart from making your score more readable.

Rests work just like notes; they're kind of like notes that you can't hear. A rest is represented as the letter `r`.

**sheet music**

{% highlight text %}
r2 c | r4 c r8 c r4
{% endhighlight %}

You can use [dotted notes](https://en.wikipedia.org/wiki/Dotted_note), too. Simply add one or more `.`s onto the end of a note length.

**sheet music**

{% highlight text %}
trombone: o2 c4.. d16 e-8 r c r
{% endhighlight %}

# Organizing a score

- introduce writing alda scores to files in this section. apologize for Clojure's startup time :)
  - can reference this article:
    - http://blog.ndk.io/2014/02/11/jvm-slow-startup.html
  - also note that Alda will eventually be an AOT-compiled, standalone executable, which will speed things up a bit

- again, show examples of notated music

# Contributing

plz help, PRs welcome, send me an email, etc.
