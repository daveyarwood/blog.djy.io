---
published: true
layout: post
title: "Out of the Blue"
category: music
tags:
  - alda
  - composition
  - generative art
---

{% include JB/setup %}

In January 2019, I collaborated with the choreographer [Renay
Aumiller](https://www.instagram.com/renay.aumiller.dances) to create a modern
dance piece called _Out of the Blue_. I wrote a program that prompted the
audience to contribute a list of body parts and dance qualities, and then fed
that creative input into an algorithm to randomly generate a series of short
dance vignettes.

Each vignette featured a body part and a movement idea contributed by the
audience, as well as a short piece of music to accompany the music.  Renay
improvised modern dance movement on top of this, to sometimes poignant or
comedic effect.

I composed the musical backdrops in [Alda](https://alda.io) and my program
cross-faded them dynamically based on the randomly generated length of each
vignette (30-90 seconds). For this recorded version, each backdrop is played for
30 seconds before cross-fading into the next.

<br>
<center>
<iframe width="75%" height="166" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/651060473&amp;color=ff5500&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false"></iframe>
</center>
<br>

---

Here is the Alda source code for each backdrop, accompanied by some notes about
my creative process. Hopefully you'll find it interesting!

I employed a little trick to inspire myself as I was composing most of these
musical scenes. I wrote a program that picked 2 or 3 instruments at random and
played randomly chosen notes on those instruments. The results weren't usable
out-of-the-box, but every few runs of the program, an interesting combination of
instruments would occur by accident, and that inspired me to see what
interesting musical ideas I could come up with using those instruments.

# 01

Backdrop #1 is super simple, just a long, low G on strings, punctuated regularly
with timpani hits. I think it has on overall feeling of "medieval suspense". I
thought this was interesting enough as-is, and moved onto the next backdrop.

{% highlight text %}
(tempo! 85)

md = (vol 80)
lg = (vol 100)

midi-timpani:
  (panning 90)
  o2 md g8 %downbeat [ lg g2.. o1 md g8 lg g2.. o2 md g8 ]*99

midi-string-ensemble-2:
  (panning 10)
  (volume 60)
  (quant 99)
  o1 @downbeat g1~1~1~1 *99
{% endhighlight %}

# 02

For Backdrop #2, I took the output of one of the runs of my score generator
program and I used it almost as-is.

The generator emitted two instrument parts, a kalimba and a music box. I played
up the percussive sound of the kalimba by creating an artificial delay effect; I
added three more kalimbas and had them play the same notes, spaced apart from
one another in 250ms intervals, and added progressive levels of panning and
volume decay. I think it kind of sounds like a ping-pong ball falling down the
stairs into the basement.

{% highlight text %}
(key-sig! [:e :flat :locrian])

kphrase = o2 f2397ms o3 d2598ms o3 d2638ms o3 g1949ms
mbphrase = o2 e875ms o2 e1044ms o2 c2667ms o3 e2939ms o1 e659ms

midi-kalimba "mk1":
  (panning 50)
  kphrase * 100

midi-kalimba "mk2":
  (panning 60) (vol 75)
  r250ms
  kphrase * 100

midi-kalimba "mk3":
  (panning 70) (vol 50)
  r500ms
  kphrase * 100

midi-kalimba "mk4":
  (panning 80) (vol 25)
  r750ms
  kphrase * 100

midi-music-box:
  (panning 6)
  mbphrase * 100
{% endhighlight %}

# 03

My generator happened to pick a MIDI ocean wave sound (the [General MIDI
spec](https://www.midi.org/specifications-old/item/gm-level-1-sound-set)
includes a number of other goofy sounds like a gunshot, a telephone ringing,
etc.), so I composed something simple and relaxing to accompany the sound of the
waves.

A celeste outlining an A minor pentatonic cluster (A - C - D - E - G) seemed to
do the trick. I had the celeste wait 10 seconds, then play the same thing,
shifted down a note within the context of A minor (G - B - C - D - F). Then I
just kept doing that, working my way down the scale. Boom, backdrop done.
Next!

{% highlight text %}
midi-seashore:
  (vol 70) (pan 20)
  o0 c150s

midi-celesta:
  (tempo 100)
  (vol 50) (pan 95)
  [
    r10s o4 a8 > c   d   e   g2.
    r10s o4 g8   b > c   d   f2.
    r10s o4 f8   a   b > c   e2.
    r10s o4 e8   g   a   b > d2.
    r10s o4 d8   f   g   a > c2.
    r10s o4 c8   e   f   g   b2.
  ]*99
{% endhighlight %}

# 04

The inspiration generator gave me a helicopter sound and pizzicato strings next.
Challenge accepted! I wrote some inline Clojure code to generate sequences of D
notes moving up in octaves (D1, D2, D3, D4, D5), separated by random-length
pauses. I think the result sounds like the score to a movie scene where a spy is
infiltrating a military base or something.

{% highlight text %}
(defn random-pause
  []
  (pause (duration (ms (rand-nth (range 300 4000))))))

(defn pizz-sequence
  []
  (for [octave-number (range 1 5)]
    [(octave octave-number)
     (note (pitch :d) (duration (ms 1000)))
     (random-pause)]))

(defn heli-sequence
  []
  [(random-pause)
   (note (pitch :c) (duration (ms (rand-nth (range 3000 10000)))))])

midi-pizzicato-strings:
  (pan 30)
  (repeatedly 99 pizz-sequence)

midi-helicopter:
  (pan 100) (vol 50)
  o0 (repeatedly 99 heli-sequence)
{% endhighlight %}

# 05

For Backdrop #5, I imagined that I was playing some simple arpeggios on a clean
electric guitar. I think GM instrument #101 ("FX 5 (brightness)") is intended to
be played in a higher register, but it ended up sounding pretty neat as a bass,
sort of like a more electronic-sounding bowed upright bass.

{% highlight text %}
(tempo! 90)

midi-electric-guitar-jazz:
  (quant 400)
  (pan 0)
  (vol 75)
  [
    o3 [ c8   e g   b > e < b   g e ]*4
    o2 [ a8 > e g   b > e < b   g e < ]*4
    o3 [ c8   f g > c   e   c < g f ]*4
  ]*99

midi-fx-brightness:
  [
    o2 c1~1~1~1
    o1 a1~1~1~1
    o1 f1~1~1~1
  ]*99
{% endhighlight %}

# 06

I think I must have been channeling VGM composer [Nobuo
Uematsu](https://en.wikipedia.org/wiki/Nobuo_Uematsu) when I wrote Backdrop #6.

It's always fun to play with changing chords while keeping the bass note the
same. In this case, the bass guitar plays a steady stream of B quarter notes,
while the electric piano plays a different chord every 4 measures (Bm7 - G7 -
Cmaj7 - Bm7).

{% highlight text %}
midi-pizzicato-strings:
  (pan 10) (vol 70)

  [
    r1 *4

    [ o6 g16 d < b g f+ d < b   g   f+2 | r1 ]*2
    [ o6 g16 d < b g f  d < b   g   f2  | r1 ]*2
    [ o6 e16 c < b g e  d   c < b   g2  | r1 ]*2
    [ o6 d16 c < b g f+ d < b   f+  d2  | r1 ]*2
  ]*99

midi-electric-piano-2:
  (pan 90) (vol 60)
  (quant 150)

  [
    r1 *4

    [ r1 o3 b1/>d/f+/a ]*2
    [ r1 o3 b1/>d/f/g ]*2
    [ r1 o3 b1/>c/e/g ]*2
    [ r1 o3 a1/b/>d/f+ ]*2
  ]*99

electric-bass:
  o1 b4 *999

midi-percussion:
  o2 c4 *999
{% endhighlight %}

# 07

This backdrop starts with a piano alternating between Gmaj7 and Dmaj7. I added a
second piano that plays exactly the same thing, but softer and panned
differently, creating a nice echo effect, as if you're standing in a cathedral
and the sound from the piano is bouncing off of the back of the room.

The chord voicings I chose happened to have 5 notes in them, so I thought it
would be interesting to arpeggiate the chords from top to bottom in quintuplets.
This has an especially dreamy effect with the artificial echo.

{% highlight text %}
(tempo! 150)

pianoPart1 = [
  (quant 90)
  [
    [ o2 g4/>d/g/b/>f+ ] *16
    [ o2 d4/a/>d/f+/>c+ ] *16
  ]*4
]

pianoPart2 = [
  (quant 400)
  [
    {o4 f+ < b g d < g}2 *8
    {o4 c+ < f+ d < a d}2 *8
  ]*2
]

pianoPart = [ pianoPart1 pianoPart2 ]*20

midi-electric-grand-piano "echo":
  (vol 80) (pan 25)
  pianoPart

midi-bright-acoustic-piano "main":
  (vol 50) (pan 100)
  r8 pianoPart

midi-synth-bass-2:
  (quant 100)
  [
    # pianoPart1 unaccompanied
    r1~1~1~1 *4

    # pianoPart1 with this accompaniment
    [
      [ o1 g2.. > d8 a1 ]*2
      [ o1 d2.. > f+8 > c+1 ]*2
    ]*2

    # pianoPart2 unaccompanied
    r1~1~1~1 *4
  ]* 20
{% endhighlight %}

# 08

Backdrop #8 is conceptually simple, but fun to listen to. There are 8 voices,
each playing a randomly generated sequence of pizzicato notes with random-length
pauses. It starts with only one voice doing this, and then every 10 seconds a
new voice enters. The result is that over time, the music becomes progressively
more dense and chaotic, like the sound of popcorn popping in the microwave.

{% highlight text %}
(key-sig! [:e :major])

(defn random-notes
  []
  (for [n (range 1000)]
    [(pause (duration (ms (rand-int 500))))
     (octave (rand-nth (range 2 6)))
     (note (pitch (rand-nth [:e :g :b :d]))
           (duration (ms (rand-int 2000))))]))

midi-pizzicato-strings:
  V1: (pan 15) (random-notes)
  V2: (pan 90) r10s (random-notes)
  V3: (pan 30) r20s (random-notes)
  V4: (pan 75) r30s (random-notes)
  V5: (pan 45) r40s (random-notes)
  V6: (pan 60) r50s (random-notes)
  V7: (pan 25) r60s (random-notes)
  V8: (pan 80) r70s (random-notes)
  V9: (pan 50) r80s (random-notes)
{% endhighlight %}

