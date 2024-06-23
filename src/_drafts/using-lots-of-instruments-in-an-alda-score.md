---
layout: post
title: "Using lots of instruments in an Alda score"
category: alda
tags:
  - alda
  - midi
published: true
---

{% include JB/setup %}

Hello again. Another year gone by, another new feature for [Alda][alda]!

I just released [Alda 2.3.0][alda-2.3.0] yesterday, and it features some
improvements to the way that Alda determines which MIDI channel to use for each
instrument part, and even for individual notes. This is something that I'd been
meaning to do for quite a while, and I'm excited that I finally got around to
it.

With this new release, it is now possible to use more than 16 instruments in the
same Alda score. As long as there aren't 16 instruments trying to play _at the
same time_, Alda can figure out how to use the 16 available MIDI channels to
play your score -- even if it uses all 128 instruments in the General MIDI spec!

Here's a fun little demo of The Lick™ played on all 128 instruments:

<center>
  <p>
    <figure>
      <figcaption>
      all-instruments.alda
      </figcaption>
      <audio controls src="{{ site.url }}/assets/2024-06-23-all-instruments.mp3"></audio>
    </figure>
  </p>
</center>

[The score][all-instruments] looks like this:

{% highlight alda %}
(tempo! 200)

theLick = d8 e f g {d+16 e4}4 c8 d8~1

midi-acoustic-grand-piano: (panning 43) o3 theLick
midi-bright-acoustic-piano: (panning 0) o4 r1*1 theLick
midi-electric-grand-piano: (panning 98) o5 r1*2 theLick
midi-honky-tonk-piano: (panning 9) o5 r1*3 theLick
# ... 120 more lines ...
midi-helicopter: (panning 96) o3 r1*125 theLick
midi-applause: (panning 56) o6 r1*126 theLick
midi-gunshot: (panning 83) o4 r1*127 theLick
midi-percussion: (panning 84) o5 r1*128 theLick
{% endhighlight %}

Fun fact: Writing all 128 lines by hand would have been tedious, so I wrote a
little Clojure program to generate the basic skeleton for me:

{% highlight clojure %}
(ns the-lick
  (:require [clojure.java.process :as proc]
            [clojure.string       :as str]))

(def instruments
  (->> (proc/exec "alda" "instruments")
       str/split-lines))

(doseq [[instrument rests] (map vector instruments (range))]
  (println (format "%s: (panning %d) o%d r1*%d theLick"
                   instrument
                   (rand-int 100)
                   (+ (rand-int 5) 2)
                   rests)))
{% endhighlight %}

Then I tweaked the output a little bit to get the final version. The skeleton
included random octave and panning values for each of the 128 instruments. I
left the random panning values the way they were -- the desired effect was
already there, with each instrument popping up in a random location within the
stereo spectrum. The only thing I needed to adjust was the octave values. Many
of the random octave values already sounded good, but I ended up changing some
to make the instrument sound more like what you would expect; bass instruments
are in lower octaves, high-pitched instruments like the piccolo are in higher
octaves, etc.

This was a fun project, and I'm excited to share the results. [Give the new
version of Alda a try][install-alda] and let me know if you come up with
anything interesting!

> If you like what I'm doing with [Alda][alda], please consider [sponsoring
> me][sponsor-me] to support future development!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[alda]: https://alda.io
[alda-2.3.0]: https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#230-2024-06-22
[all-instruments]: https://github.com/alda-lang/alda/blob/master/examples/all-instruments.alda
[install-alda]: https://alda.io/install
[sponsor-me]: https://github.com/sponsors/daveyarwood

[tweet]: https://twitter.com/dave_yarwood/status/FIXME
