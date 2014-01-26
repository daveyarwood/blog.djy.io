---
layout: post
title: "Happy New Year!"
description: "first post; status of yggdrasil"
category: yggdrasil
tags: [yggdrasil clojure python ruby]
---
{% include JB/setup %}

I have the day off work, so I figured I'd set up this blog on github. Maybe I don't really *need* a blog just yet, but I figure at least I'll have one at the ready whenever I end up having something noteworthy to blog about.

A little over a year ago, in October 2012, I started working on my first big programming project -- a music programming language. The language is called Yggdrasil, and it's still young, but developing nicely, I think. I've been working on it in my spare time between my full-time (non-programming) job and playing in bands, so development has been slow, but steady. I've been finding that the more I learn about programming, the quicker this project has been coming along.

Yggdrasil's journey thus far has spanned 3 attempts in different programming languages. I started in Python (my first programming language, unless you count dicking around with Visual Basic when I was a kid, or the one introductory Java class I took in college), building a parser using the PLY (Python Lex-Yacc) library. I knew nothing about building a parser, and very little about good programming practices, so that initial attempt was a little messy. I somehow managed to build a parser that could successfully parse a simple .yg file and tell you the pitch, duration and octave of every note.

I then discovered Ruby, fell in love with the language and got majorly sidetracked. After diving in for a few months and learning a ton of Ruby, I decided to start over (or at least translate what Python code I'd written already) in Ruby. I found a couple of decent MIDI libraries and an excellent parsing library called Treetop, and was on my way again.

But I didn't get far before I ended up on another large tangent, teaching myself a great deal about programming in general by exploring a small variety of programming languages. I'd already read [Learn Python the Hard Way][lpthw] and [_why's (Poignant) Guide to Ruby][wpgtr] and done various exercises on [Project Euler][euler], etc. My partially-scratched itch for fun programming texts was scratched further by [Learn You a Haskell][lyah] and [Seven Languages in Seven Weeks][7li7w]. I learned a ton about general programming concepts and language-agnostic best practices, and came to appreciate functional programming. 

I somehow (possibly through reading Seven Languages in Seven Weeks, although I seem to recall already knowing some when I read it) discovered Clojure, and was immediately wowed by its aesthetic, grace, power and simplicity. I was hooked from the start, and I think I'm falling even more in love with it the more time I spend using and learning it. The way things are structured in Clojure simply resonates with me in away that none of the other languages I've dabbled in so far have done (although Ruby gets an honorable mention for its own unique blend of flexibility, simplicity and fun). Best of all, there is already a quite impressive library in Clojure that I think will get me halfway to what I want to do. It's a fantastic project called [Overtone][overtone]. So at this stage in the development of Yggdrasil, my goal is to build a music programming language on top of Overtone -- a language that can leverage many of the cool things you can do in Overtone, but with a syntax that makes more sense to a music composer with little to no background in programming. My primary influences in the world of already-existent music programming languages are [MCK MML][mml] and [LilyPond][lilypond]. 

As of this post, I have a great deal of syntax invented, and I'm working on the parser side of things. I'm trying to get to the point where Yggdrasil can parse a .yg score and create a detailed parse tree of all of the music "events" in the score -- notes, chords, volume/panning/tempo changes, and so on. Once I have that under my belt, I'll work on implementing the actual synthesis of the music using Overtone.

Things might keep progressing slowly, but hopefully 2014 will be the year that sees an alpha release of Yggdrasil!

[lpthw]: http://learnpythonthehardway.org
[wpgtr]: http://mislav.uniqpath.com/poignant-guide
[euler]: http://www.projecteuler.net
[lyah]: http://learnyouahaskell.com
[7li7w]: http://pragprog.com/book/btlang/seven-languages-in-seven-weeks
[overtone]: http://overtone.github.io
[mml]: http://www.nullsleep.com/treasure/mck_guide
[lilypond]: http://www.lilypond.org
