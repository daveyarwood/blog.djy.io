---
layout: post
title: "Making MIDI Sound Awesome in a Clojure Program"
category: alda
tags: 
  - clojure
  - java
  - jvm
  - midi
  - alda
published: true

redirect_from: '/alda/2015/06/25/making-midi-sound-awesome-in-a-clojure-program'
---

{% include JB/setup %}

I wrote a couple months ago about [MIDI and the JVM][midi-jvm]. I explained that [Gervill][gervill] has been the JVM's built-in soft synth since Java 7, and I mentioned that there are two ways that Gervill allows you to load [SoundFont][soundfont] files, changing the way the General MIDI instruments sound on your computer.
You can replace your default ("emergency") soundfont by replacing `~/.gervill/soundbank-emg.ef2` (so that, when executing Java code that utilizes the MIDI soft synth, but does not provide or specify a soundfont, your default soundfont will be used) -- or -- if you're the one writing the program, you can tell it to load a specific soundfont from a file or input stream.

I do the majority of my coding in Clojure, because it's amazing in general, and one thing about Clojure that's especially great is the way it handles dependencies, via Maven repositories. Having your Clojure project pull in a third-party library is as easy as adding its group/artifact ID and version number to the list of dependencies in your `project.clj` (if you're using [Leiningen][lein]) or `build.boot` (if you're using [Boot][boot]). The build tool does all the heavy lifting.

One of my original goals with [Alda][alda] (my music programming language) was to have it produce General MIDI music with instruments that sound realistic enough to not sound cheesy. The stock MIDI soundfont on most computers is definitely not capable of sounding cheese-free, so I determined early on that I would need to have Alda load a soundfont into the JVM.

Combining these three concepts led me to this idea: packaging a good soundfont as a Maven dependency, and having Alda pull it down and load it into the JVM for you.
This is awesome because the user shouldn't have to worry about making his/her MIDI sound good. This is a notorious problem with General MIDI -- it sounds different on every computer, and it rarely sounds acceptable out-of-the-box. Packaging and loading a soundfont programmatically ended up being a refreshingly easy solution.

[FluidR3][fluid-r3] is the best-sounding freeware MIDI soundfont that I'm aware of (if you know of a better one, let me know!), so it's the one I went with. I packaged it as a Maven repository and deployed it to Maven Central\*. I also created [a tiny Clojure library for loading a MIDI soundfont into the JVM][midi.soundfont], deployed as a Clojar. 
All that was left at that point was to include both dependencies in Alda and use them to load FluidR3's instruments into the MIDI synthesizers it uses.

<small>\* which ended up being quite the ordeal! I'm working on writing a separate blog post about that whole process. </small>

For a quick demo, follow the instructions [here][alda-demo]:

{% highlight text %}
git clone git@github.com:alda-lang/alda.git
cd alda
boot play --file test/examples/awobmolg.alda 
{% endhighlight %}

(It will take a minute before you hear anything -- all 125 MB of the FluidR3 dependency jar have to download into your local Maven repository first.)

Then, for the sake of comparison, try:

{% highlight text %}
boot play --stock --file test/examples/awobmolg.alda
{% endhighlight %}

The `--stock` flag bypasses FluidR3 and plays the Alda score with your JVM's default soundfont. Notice how much better the FluidR3 one sounds!

[midi-jvm]: {% post_url 2015-04-17-making-midi-sound-awesome-in-your-jvm %}
[gervill]: https://java.net/projects/gervill/pages/Home
[soundfont]: http://en.wikipedia.org/wiki/SoundFont
[lein]: http://leiningen.org
[boot]: http://boot-clj.com
[alda]: https://github.com/alda-lang/alda
[fluid-r3]: http://www.musescore.org/download/fluid-soundfont.tar.gz
[midi.soundfont]: https://github.com/daveyarwood/midi.soundfont
[alda-demo]: https://github.com/alda-lang/alda#quick-demo
