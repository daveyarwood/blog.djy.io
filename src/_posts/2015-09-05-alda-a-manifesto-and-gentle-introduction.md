---
layout: post
title: "Alda: A Manifesto and Gentle Introduction"
category: alda
tags:
  - alda
  - music programming
  - composition
published: true

redirect_from: '/alda/2015/09/05/alda-a-manifesto-and-gentle-introduction/'
---

{% include JB/setup %}

# What is Alda?

<img src="{{site.url}}/assets/2015-08-18-alda.png"
     alt="alda"
     title="alda"
     width="600"
     height="300" />

Alda's ambition is to be a powerful and flexible music programming language that can be used to create music in a variety of genres by typing some code into a text editor and running a program that compiles the code and turns it into sound. I've put a lot of thought into making the syntax as intuitive and beginner-friendly as possible. In fact, one of the goals of Alda is to be simple for someone with little-to-no programming experience to pick up and start using. Alda's tagline, *a music programming language for musicians*, conveys its goal of being useful to non-programmers.

But while its syntax aims to be as simple as possible, Alda will also be extensive in scope, offering composers a canvas with creative possibilities as close to unlimited as it can muster. I'm about to ramble a little about the inspiring creative potential that audio programming languages can bring to the table; it is my hope that Alda will embody much of this potential.

At the time of writing, Alda can be used to create MIDI scores, using any instrument available in the [General MIDI sound set](http://www.midi.org/techspecs/gm1sound.php). In the near future, Alda's scope will be expanded to include sounds synthesized from basic waveforms, samples loaded from sound files, and perhaps other forms of synthesis.
I'm envisioning a world where programmers and non-programmers alike can create all sorts of music, from classical to chiptune to experimental soundscapes, using only a text editor and the Alda executable.

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
[mmltut]: http://tilde.club/~nullsleep/#6.1.2
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

    This is an inherent shortcoming of any GUI music notation editor; in order to be able to represent your musical score visually in a sane and comprehensible way, it has to impose some restrictions. Audio programming languages must also impose restrictions (in the same sense that any piece of software does), but because they are not tied to visually representing your score and maintaining a user-friendly GUI interface, they are able to get away with imposing substantially less restrictions on the composer. As a composer myself, I find this fascinating and inspiring.

# Setup

[Follow the instructions here](https://github.com/alda-lang/alda#installation) to install the latest version of Alda.

Once you've installed Alda, run `alda up` to start an Alda server in the
background. This will take a minute, but then after that, you can leave the
server running and you won't need to start it again (at least, not until the
next time you restart your computer).

You should now be able to use a handful of built-in commands that start with `alda`. You can parse and/or play Alda code from a file or a string of Alda code provided as a command-line argument. Or, you can build a score incrementally by using the Alda REPL (Read-Evaluate-Play Loop).

# Alda 101

We will use the Alda REPL at first, to experiment a little with Alda syntax. To start the REPL, type:

{% highlight text %}
alda repl
{% endhighlight %}

You can type snippets of Alda code into the REPL, press Enter, and hear the results instantly.

As I mentioned, MML ended up being a primary influence on Alda, along with [LilyPond](http://lilypond.org). The great thing about both MML and LilyPond is the simplicity of their syntax. I would describe the syntax of both languages as being similar to [Markdown](http://daringfireball.net/projects/markdown); essentially, what you see is what you get.

## Notes

Let's start with a simple example. Let's translate this measure of sheet music into Alda code:

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-01.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px" />
</center>

Here we have four quarter notes: C, D, E and F. The Alda version of this is:

{% highlight text %}
c d e f
{% endhighlight %}

Try typing this into the REPL and pressing Enter... nothing happens. Why? Well, we haven't told Alda what instrument we want to play these notes. Let's go with a piano:

{% highlight text %}
piano: c d e f
{% endhighlight %}

Now you should hear a piano playing those four notes. You will also notice that the prompt has changed from `>` to `p>`. `p` is short for `piano`, and it signifies that the piano is the only currently active instrument. Until you change instruments, any notes that you enter into the REPL will continue to be played by the piano.

## Octaves

Let's add some more notes.

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-02.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
g a b > c
{% endhighlight %}

You should hear the piano continuing upwards in the C major scale. An interesting thing to note here is the `>`. This is Alda syntax for "go up to the next octave." An octave, in [scientific pitch notation](https://en.wikipedia.org/wiki/Scientific_pitch_notation), starts on a C and goes up to a B. Once you go above that B, the notes start over from C and you are in a new octave.
In Alda, each instrument starts in octave 4, and remains in that octave until you tell it to change octaves. You can do that in one of two ways: you can use `<` and `>` to go down or up by one octave; or, you can jump to a specific octave using `o` followed by a number. For example:

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-03.png"
       alt="octaves, C0 - C9"
       title="octaves, C0 - C9 (source: https://en.wikipedia.org/wiki/Scientific_pitch_notation)"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
o0 c > c > c > c > c > c > c > c > c > c
{% endhighlight %}

## Accidentals

Sharps and flats can be added to a note by appending `+` or `-`.

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-04.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
o4 c < b- a g f+
{% endhighlight %}

You can even have double flats/sharps:

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-05.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
g+ f+ e+ d+ c++
{% endhighlight %}

As a matter of fact, a note in Alda can have any combination of flats/sharps. It usually isn't useful to use more than 2 sharps or flats (tops), but there's nothing stopping you from doing things like this:

{% highlight text %}
o4 c++++-+-+-+
{% endhighlight %}

The above is a really obtuse and unnecessary way to represent an E (a.k.a. a C-sharp-sharp-sharp-sharp-flat-sharp-flat-sharp-flat-sharp) in Alda.

## Note lengths

By default, notes in Alda are quarter notes. You can set the length of a note by adding a number after it. The number represents the note type, e.g. 4 for a quarter note, 8 for an eighth, 16 for a sixteenth, etc. When you specify a note length, this becomes the "new default" for all subsequent notes.

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-06.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
o4 c4 c8 c c16 c c c c32 c c c c c c c | c1
{% endhighlight %}

You may have noticed the pipe `|` character before the last note in the example above. This represents a bar line separating two measures of music. Bar lines are optional in Alda; they are ignored by the compiler, and serve no purpose apart from making your score more readable.

### Rests

Rests in Alda work just like notes; they're kind of like notes that you can't hear. A rest is represented as the letter `r`.

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-07.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
r2 c | r4 c r8 c r4
{% endhighlight %}

### Dotted notes

You can use [dotted notes](https://en.wikipedia.org/wiki/Dotted_note), too. Simply add one or more `.`s onto the end of a note length.

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-08.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
trombone: o2 c4.. d16 e-8 r c r
{% endhighlight %}

### Ties

You can add note durations together using a [tie][tie], which in Alda is represented as a tilde `~`.

[tie]: https://en.wikipedia.org/wiki/Tie_(music)

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-09.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
piano: o2 g+1~1
{% endhighlight %}

## Chords

When you play multiple notes at the same time on a single instrument, that's a chord! In Alda, a chord is multiple notes separated by slashes `/`.

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-10.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
o4 c1/e-/g/b
{% endhighlight %}

Notice that, just like with a sequence of consecutive notes, specifying a note length on one note of a chord will make that the default note length for all subsequent notes.

A convenient feature of Alda is that the notes in a chord do not need to be the same length. This can be convenient when writing pieces of music that feature melodies weaving in and out of chords:

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-11.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
o4 c1/e/g/>c4 < b a g | < g+1/b/>e
{% endhighlight %}

Also note that it is possible to change octaves mid-chord using `<` and `>`. This makes it convenient to describe chords from the bottom up or top down.

## Voices

Another way to represent notes played at the same time in Alda is with voices. The same example we just wrote with chords could also be written like this using a combination of chords and voices:

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-11.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px"/>
</center>

{% highlight text %}
V1: o5 c4 < b a g | e1     V2: o4 c1/e/g | < g+/b
{% endhighlight %}

To exit the Alda REPL, type `bye` and press Enter.

# Writing a score

So far, we have been feeding Alda some code, line by line, and hearing the result each time. This is a good way to test the waters and see how small pieces of code sound before you commit to them. When you're ready to set some music down in stone, it's time to write a score.

To Alda, a score is just a text file. You can use any text editor you'd like to
create this text file. By convention, the file's name should end in `.alda`.
Create a blank text file in whatever directory you're currently in in your
terminal, and name it `test.alda`.

Type the following into `test.alda`:

{% highlight text %}
bassoon: o2 d8 e (quant 30) f+ g (quant 99) a2
{% endhighlight %}

Then, run `alda play --file test.alda`. You should hear a nimble bassoon melody.

## Attributes

You may have noticed that I snuck in a new syntax here. I was going to get to that, I promise! `(quant XX)` (where `XX` is a number from 0-99) essentially changes the *length* of a note, without changing its *duration*. The number argument represents the percentage of the note's full length that is heard. Notice, when you play back the bassoon melody above, how the F# and G notes (quantized at 30%) are short and *staccato*, whereas the final A note
(quantized at 99%) is long and *legato*.

`quant` (short for `quantization`) is one example of an attribute that you can set within an Alda score. `volume` is another example; it lets you set the volume of the notes to come. Like most attributes, `volume` (which can be abbreviated as `vol`) is also expressed as a number between 0 and 100.

Try editing `test.alda` to look like this:

{% highlight text %}
bassoon: o2 d8 e (quant 30) (vol 65) f+ g (quant 99) a2
{% endhighlight %}

Run `alda play --file test.alda` again to hear the difference in volume between the first two and last three notes.

## Multiple instruments

Finally, we come to the meat of writing a score: writing for multiple instruments.

An Alda score can contain any number of instrument parts, which are all played simultaneously when the score is performed. Try this out in your `test.alda` file:

{% highlight text %}
trumpet:  o4 c8 d e f g a b > c4.
trombone: o3 e8 f g a b > c d e4.
{% endhighlight %}

The key thing to notice here is that we have written out individual parts for two instruments, a trumpet and a trombone -- one after the other -- and when you play the score, you will hear both instruments playing at the same time, in harmony.

You can also write out the parts a little at a time, like this:

{% highlight text %}
trumpet:  o4 c8 d e f g
trombone: o3 e8 f g a b

trumpet:  a b > c4.
trombone: > c d e4.
{% endhighlight %}

Notice that this example sounds exactly the same as the last example. This demonstrates another important thing about writing scores in Alda: when you switch to another instrument part, the instrument part you were working on still exists, in sort of a "paused" state, ready to pick it back up where you left off once you switch back to that instrument.

## Global attributes

Recall that you can change things like an instrument's `volume` by setting attributes.`tempo` is another thing you can change by setting an attribute. Let's try it:

{% highlight text %}
trumpet:  (tempo 200) o4 c8 d e f g a b > c4.
trombone: o3 e8 f g a b > c d e4.
{% endhighlight %}

Wait a minute... did you hear that? The trumpet took off at 200 bpm like we told it to, but the trombone remained steady at the default tempo, 120 bpm! This is actually not a bug, but a feature. In Alda, tempo (along with every other attribute) is set on a per-instrument basis, making it entirely possible for two instruments to be playing at two totally different tempos.

Global attributes are written just like regular attributes, but with an exclamation point on the end. Try this on for size:

{% highlight text %}
trumpet:  (tempo! 200) o4 c8 d e f g a b > c4.
trombone: o3 e8 f g a b > c d e4.
{% endhighlight %}

`tempo!` sets the tempo for all instruments, at the specific time in the score where you place it. Try playing around with this bit of Alda code, moving the `(tempo! 200)` to different places in the score. Try out some different tempos other than 200 bpm.

## Markers

We've already gone over a lot, but I'd like to show you how to do just one more thing in Alda -- it's an important one because it helps you keep your instruments synchronized in perfect time.

The concept behind markers is *assigning a name to a moment in time*. A name can contain letters, numbers, apostrophes, dashes, pluses, and parentheses, and the first two characters must be letters. The following are all examples of valid marker names:

- `chorus`
- `voiceIn`
- `last-note`
- `verse(2)`
- `bass+drums`

Using markers is a two-step process. *Place* a marker by sticking a `%` before the name, and then *jump to it* by sticking a `@` before the name. To demonstrate, let's go back to our trumpet and trombone example. Let's have a tuba come in right on the last note. We can do that by placing a marker in either the trumpet or trombone part, right before the last note, and then jump to that marker in the tuba part that we'll create:

{% highlight text %}
trumpet:  o4 c8 d e f g a b > %last-note c4.~2
trombone: o3 e8 f g a b > c d e4.~2
tuba: @last-note o2 c4.~2
{% endhighlight %}

So, that's Alda in a nutshell. Please don't hesitate to [e-mail me](mailto:dave.yarwood@gmail.com?subject=alda) if you have any questions about how to do something in Alda. Or, better yet, if you're a Clojure programmer and you like open-source software, [consider contributing](https://github.com/alda-lang/alda/blob/master/CONTRIBUTING.md)! Pull requests are warmly accepted.

