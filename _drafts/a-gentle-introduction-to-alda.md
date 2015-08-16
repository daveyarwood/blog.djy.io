---
layout: post
title: "A Gentle Introduction to Alda"
category: alda
tags: 
  - alda
  - music-programming
  - composition
published: true
---

{% include JB/setup %}

# UNC / MML

(some sort of screenshot would be nice here)

I can trace the origins of Alda back to 2004. At the time, I was studying Music Composition at UNC and exploring ways to make electronic music. I mucked around in [FruityLoops][fruityloops] a bit without much success. Eventually, I stumbled upon an entire world of [music programming][musicprog]. My gateway drug was [MML][mml], which was (and perhaps still is) the most legit way for [chiptune][chiptune] musicians to make NES music.
After reading through [Nullsleep][nullsleep]'s excellent [MML tutorial][mmltut] and learning how to make [some rudimentary NES music][pixelrain], I started to become more involved in making music with human beings and took a hiatus from MML. But the seed had been planted for a lifelong obsession with the idea of programming music.

[fruityloops]: https://en.wikipedia.org/wiki/FL_Studio
[musicprog]: https://en.wikipedia.org/wiki/List_of_audio_programming_languages
[mml]: https://en.wikipedia.org/wiki/Music_Macro_Language#Modern_MML
[chiptune]: https://en.wikipedia.org/wiki/Chiptune
[nullsleep]: http://www.nullsleep.com/
[mmltut]: http://www.nullsleep.com/treasure/mck_guide/
[pixelrain]: {% post_url 2015-01-24-pixel-rain %}

(maybe another screenshot here)

MML ended up becoming a major influence on Alda. I really enjoyed the workflow of creating NES music by writing code in a text editor. But what I wanted was a more general-purpose music programming language. I wanted to take MML's approach to generating NES music and extend it to other realms of digital music creation: additive/subtractive synthesis, electroacoustic music, and even classical music.

# Classical music?

(screenshot of sibelius or something?)

I was a classically trained musician long before I was a competent programmer. My music education led to a particular interest in composing music in a variety of styles. Growing up around computers, I discovered an ever-expanding class of GUI applications designed to help musicians compose music. 
I wrote guitar tablature with [Guitar Pro][guitarpro], and for traditional music notation I have tried, at various times in my life, [Cakewalk][cakewalk], [Noteworthy Composer][noteworthy], [Finale][finale], [Sibelius][sibelius], and [Musescore][musescore], among others. 

[guitarpro]: http://guitar-pro.com
[cakewalk]: https://en.wikipedia.org/wiki/Cakewalk_(sequencer)
[noteworthy]: https://noteworthycomposer.com
[finale]: http://finalemusic.com
[sibelius]: http://sibelius.com
[musescore]: https://musescore.org

When I was studying music composition, I got a lot of mileage out of Sibelius, in particular. I used Sibelius extensively to transcribe pieces of music as I composed them. It allowed me to have a digital record of my compositions, and it was essential (practically a requirement) as a way to print out individual instrument parts to distribute to the musicians who performed my pieces.

Music notation applications like Sibelius are clearly a very important tool for people who are serious about composing music. However, as a programmer and as a composer, I feel that there are a couple of fundamental problems with GUI music notation software:

* **It's distracting.**  When pre-digital age composers used to write music, they would sit at a piano and write it out by hand on staff paper. All of the notation techniques, the layout of their scores, everything, came directly from their minds and through their pens. 
When you notate music using a GUI application, you have menus upon menus in front of you from which to select whatever elements of music notation you wish to use in your score. This is distracting in two ways:

    1. It's not always easy to find what you're looking for. By the time you find it, you may have lost your train of thought.

    2. Having all of these music elements in front of you is visually distracting. When I used Sibelius, I would sometimes end up distracting myself for long stretches of time as I perused all of the different music notation elements it was possible to place, or browsed through all the project templates available. 

    In contrast to working with these complex GUI applications, I have found that programming pieces of music in a text editor is a pleasantly distraction-free experience.

* **It's limiting.** I think for a composer to have an ideal environment in which to compose, he needs to get back to the basics. He needs a blank canvas and a way to notate music. And because this is the 21st century, his scores need a way to be interpreted by a computer and turned into audio. It would also be nice if his scores could be easily converted to and from standard notation format that human musicians are trained to read. 

    The GUI programs available today do an excellent job of handling these 21st century requirements, but they do so by taking a shortcut -- they skip the "blank canvas" part. Of course, when you create a new score in Sibelius (for example), you do have what looks like some empty lines of staff paper, but in fact, this blank staff paper carries a very different connotation than does a physical page of manuscript paper. You can't just grab a pencil and start writing whatever your heart desires. 
    
    There are a number of hidden restraints that the GUI application forces upon you. This is an inherent shortcoming of any GUI music notation editor; in order to be able to represent your musical score visually in a sane and comprehensible way, it has to impose some restrictions. 
    Audio programming languages must also impose restrictions (in the same sense that any piece of software does), but because they are not tied to visually representing your score and maintaining a user-friendly GUI interface, audio programming environments are able to get away with imposing substantially less restrictions on the composer. As a composer, I find this fascinating and inspiring.

# What is Alda?

TODO

- primary influences: MML, LilyPond, etc.

# Setup

- git clone alda-lang/alda
- get boot
- You can now use a handful of built-in tasks. 
  - You can parse and/or play Alda code from a file or a string of Alda code provided as a command-line argument.
  - You can build a score incrementally using the Alda REPL.

# Basic Alda syntax

- show examples of notated music and their corresponding representation in Alda

# Organizing a score

- again, show examples of notated music

# Contributing

plz help, PRs welcome, send me an email, etc.
