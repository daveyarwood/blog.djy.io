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

I was a classically trained musician long before I was a competent programmer. My music education led to a particular interest in composing music in a variety of styles. Growing up around computers, I discovered an ever-expanding class of GUI applications designed to help musicians compose music. I wrote guitar tablature with [Guitar Pro][guitarpro]

[guitarpro]: 

- there are text-based music/audio programming languages, as well as visual ones (e.g. puredata)
- there is also a separate class of music GUI applications, which are much more popular
- in fact, I had been using applications like Guitar Pro, Finale and Sibelius for years
- when I discovered music programming languages, I made a connection between what these GUI programs are doing and what you can do with MPLs
- but MPLs resonated with me more -- these music programming languages tend to allow you to do more things in a less restrictive way than the GUI programs. 
- perhaps more importantly, I have found that programming pieces of music in a text editor is a pleasantly distraction-free experience, when compared to putting together a piece of music in a complex GUI application like Sibelius. 
- I used Sibelius extensively during my music education to transcribe pieces of music as I composed them
  - it allowed me to have a digital record of my compositions, and was essential (practically a requirement) as a way to print out individual instrument parts to distribute to the musicians who performed my pieces
  - Sibelius is great - there is a reason it is considered an industry leader in the field of music notation software
  - as a programmer, however, I feel that there are some fundamental problems with GUI music notation software:
    - it's distracting. 
      - When pre-digital age composers used to write music, they would sit at a piano and write it out by hand. All of the notation techniques, the layout of their scores, everything came directly from their minds through their pens. 
      - When you notate music using a GUI application, you have menus upon menus in front of you from which to select whatever elements of music notation you wish to use in your score. 
      - This is distracting in two ways:
        1. it's not always easy to find what you're looking for. By the time you find it, you may have lost your train of thought.
        2. having all of these music elements in front of you is visually distracting. When I used Sibelius, I would sometimes end up distracting myself for long stretches of time as I perused all of the different music notation elements it was possible to place, or browsed through all the project templates available. 
    - it's limiting.
      - I think for a composer to have an ideal environment in which to compose, he needs to get back to the basics. He needs a blank canvas and a way to notate music. Because this is the 21st century, his scores need a way to be interpreted by a computer and turned into audio. It would also be nice if his scores could be easily converted to and from standard notation format that human musicians are trained to read.
      - The GUI programs available today do an excellent job of handling these 21st century requirements. However, they do so by taking a shortcut -- they skip the "blank canvas" part. 
      - Yes, when you create a new Sibelius score, you have what looks like some empty lines of staff paper, but this blank staff paper carries a much different connotation than a physical page of manuscript paper. You can't just grab a pencil and start writing whatever your heart desires. There are a number of hidden restraints than Sibelius forces upon you.
      - I can't blame Sibelius for this. It is a shortcoming that every GUI music notation editor has to deal with. In order to be able to represent your musical score visually in a sane way, it has to impose some restrictions. 
      - Audio programming languages must also impose restrictions out of necessity, but because they are not tied to visually representing your score and maintaining a user-friendly GUI interface, they can get away with imposing substantially less restrictions on the composer. (example: loops, tempo phasing between instruments) As a composer, I find this fascinating and inspiring.
- primary influences: MML, LilyPond, etc.

# What is Alda?

TODO

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
