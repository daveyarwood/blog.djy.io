---
layout: post
title: "Making MIDI Sound Awesome in Your JVM"
category: alda
tags: [alda, java, jvm, midi]

redirect_from: '/alda/2015/04/17/making-midi-sound-awesome-in-your-jvm/'
---
{% include JB/setup %}

You might be surprised to learn that your Java Virtual Machine is a capable musician. A MIDI soft synthesizer has actually been built into the JVM for years and years, and starting with Java 7, it's gotten a whole lot more awesome.

# MIDI: A Primer

Quoth [Wikipedia](http://en.wikipedia.org/wiki/MIDI):

> **MIDI** (/ˈmɪdi/; short for **Musical Instrument Digital Interface**) is a technical standard that describes a protocol, digital interface and connectors and allows a wide variety of electronic musical instruments, computers and other related devices to connect and communicate with one another.[1] A single MIDI link can carry up to sixteen channels of information, each of which can be routed to a separate device.

If you started computing in the 90's like I did, the word "MIDI" probably makes you think of [canyon.mid](https://www.youtube.com/watch?v=OIW4F285QjA) and the handful of other amazing MIDI files that came bundled with Windows 95. This was amazing at the time because *your computer was synthesizing music!* (I still find this pretty amazing, to be honest.)

We tend to think of those cheesy SoundBlaster sound card sounds when we think of MIDI, but technically, MIDI doesn't really have a sound of its own. Really, all it is is a standard for a set of 128 named instruments and a bunch of instructions that you can give them to get them to make music. What the instruments will actually sound like is up to the synthesizer that interprets these instructions. Professional keyboardists use expensive MIDI controllers all the time to drive powerful (and even more expensive) hardware synthesizers, which can sound breathtakingly realistic. Personal computers have had software synthesizers built into their sound cards ever since the inception of the MIDI standard in the early 80's, and every sound card's interpretation of MIDI is different. I used to create MIDI files a lot in my adolescence, and part of the fun was comparing the way they sounded on my computer, vs. the ones in the computer lab at school, vs. my friends' computers, etc. What does your computer's MIDI sound like? If you're curious, you might want to try downloading a few of the `.mid` files on [this site](https://sites.google.com/site/musiccurios/downloads), opening them and seeing what happens. If you're on a Mac, GarageBand will probably open and you'll hear the gorgeous sounds of its built-in soft synth. If you're running Linux, good luck! (j/k; actually, I hear that some modern Linux distributions can handle MIDI pretty well out of the box nowadays. In the past, I've had to spend quite a bit of time tinkering with [FluidSynth](http://www.fluidsynth.org) or [Timidity](http://sourceforge.net/projects/timidity) to get MIDI working in Linux. If you're in this boat, you have my utmost sympathy.)

# MIDI on the JVM

There's a MIDI soft synth actually baked into the JVM. You can interact with it using the code that lives in `javax.sound.midi.MidiSystem`, and it's actually not so hard to work with. There's a little tutorial [here](https://docs.oracle.com/javase/tutorial/sound/MIDI-synth.html) on working with MIDI in Java, or you can poke around in [the docs](https://docs.oracle.com/javase/8/docs/api/javax/sound/midi/MidiSystem.html) and play around with it. If you're writing Clojure code, you of course have access to all of `javax.sound.midi`, and making use of it in a Clojure program is almost trivial -- [this guy wrote a pretty good tutorial](https://taylodl.wordpress.com/2014/01/21/making-music-with-clojure-an-introduction-to-midi) on the subject.

# Better-sounding MIDI on the JVM

Since Java 7, [Gervill](https://java.net/projects/gervill/pages/Home) has been the JVM's built-in soft synth. The most awesome thing about Gervill, IMHO, is that it allows you to load [SoundFont](http://en.wikipedia.org/wiki/SoundFont) files, which change the way the MIDI sounds on your computer. If you do some quick googling, it's not hard to find some really beautiful-sounding soundfonts, distributed as freeware. There's a nice collection of them [here](https://musescore.org/en/handbook/soundfont); my favorite (and by many accounts, the most popular soundfont) is [FluidR3](http://www.musescore.org/download/fluid-soundfont.tar.gz). Because the default MIDI synth on your computer probably sounds pretty bad, I heartily recommend taking a few minutes to install a great-sounding soundfont to your JVM. Your ears will thank you!

You wouldn't believe how hard it was to find out how to load a soundfont into your JVM. Luckily, [this guy on minecraftforum.net](http://www.minecraftforum.net/forums/mapping-and-modding/mapping-and-modding-tutorials/1571330-better-java-midi-instrument-sounds-for-linux) was nice enough to share how to do it. Essentially, there are two things you can do:

1. **Load soundfonts on a program-by-program basis** -- if you're writing a Java program, you tell it to load a specific soundfont file.

2. **Replace the default soundfont (referred to as the "emergency soundbank file")** -- that way, when executing Java code that utilizes the MIDI soft synth but does not provide or specify a soundfont, your default soundfont will be used. On my Macbook, this was located in `~/.gervill/` as `soundbank-emg.sf2`.

As I see it, there's really not much benefit to using the emergency soundfont that comes with your JVM. So, I downloaded FluidR3 and replaced my default soundfont with it:

{% highlight text %}
$ cp ~/.gervill/soundbank-emg.sf2 ~/.gervill/soundbank-emg.sf2.bak
$ mv ~/Downloads/fluid-soundfont/FluidR3\ GM2-2.SF2 ~/.gervill/soundbank-emg.sf2
{% endhighlight %}

To take my JVM's new soundfont for a test drive, I wrote [a little Clojure script to demo instruments in the General MIDI soundbank](https://raw.githubusercontent.com/alda-lang/alda/master/bin/midi-patch-demo). If you have [Boot](http://www.boot-clj.com) installed, you can download the script and try it out -- you give it a number from 1-128 and it prints out the name of the instrument and plays a three-octave ascending G-major arpeggio, so you can hear what the instrument sounds like across a few different octaves. (To get an idea of how much better FluidR3 is than the default soundfont, try doing the following before and after installing it!)

{% highlight text %}
$ curl https://raw.githubusercontent.com/alda-lang/alda/master/bin/midi-patch-demo -o midi-patch-demo
$ chmod +x midi-patch-demo
$ ./midi-patch-demo 50
Patch 50: Slow Strings
$ ./midi-patch-demo 47
Patch 47: Harp
$ ./midi-patch-demo 30
Patch 30: Overdrive Guitar
$ ./midi-patch-demo 81
Patch 81: Square Lead
{% endhighlight %}

Enjoy!
