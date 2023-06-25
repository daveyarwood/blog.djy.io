---
layout: post
title: "MusicXML import and other new Alda features"
category: alda
tags:
  - alda
  - musicxml
published: true
---

{% include JB/setup %}

Hey everyone! It's been quite a while since I've posted an update about
[Alda][alda-website]. First of all, rest assured that I'm still here, and I'm as
interested as ever in taking Alda in fun, new directions. I wanted to share a
little update about what I've been up to lately with Alda. Moreover, I want to
highlight an amazing new feature that has been contributed recently and tell you
about why I'm so excited about it. We'll get to that shortly, but first:

# A few quick updates

The last time that I had much to say about Alda was when I announced in June
2021 that I had [completely rewritten it in Go and Kotlin][alda-2-announcement]
and released this newer, better version as Alda 2. I'm very happy with how
that's turned out. I've been enjoying using Alda 2 myself, and I've been finding
that it's easier to maintain than Alda 1 was.

I haven't had as much time as I'd like to work on Alda recently, but we have
managed to do a few things, nonetheless:

* In December 2021, I refactored the Alda parser to include a first-class AST.
  Alda 2.1.0 added `--output ast` and `--output ast-human` options to the `alda
  parse` command to [show the AST of an Alda score][show-ast], which can be
  useful for debugging potential parser errors, as well as for building Alda
  tooling (e.g. for text editors).

* In January 2022, I finished an experimental WebAssembly build of the Alda
  client. My goal is to eventually [run Alda in browsers][run-in-browsers], as
  it would be convenient to be able to play around with Alda without needing to
  install anything to your computer.

* In April 2022, a `:parts` command was added to the Alda REPL. It prints
  information about the parts in the current score.

* I also fixed a bunch of bugs and made some general usability improvements from
  time to time.

# MusicXML import

In May 2023, we released Alda 2.2.5, which features a new command called `alda
import`. You can use this command to import a MusicXML file and produce a
working Alda score.

[MusicXML][music-xml] is a W3C standard open format for exchanging digital sheet
music. A lot of popular sheet music applications, including Sibelius and Finale,
support exporting your scores to this format. Starting from this release, Alda
can now work with these files too. Here is a simple example workflow.

[This MusicXML file][parts.musicxml] represents the following score:

<center>
<img src="{{ site.url }}/assets/2023-06-25-parts.png"
     title="A short sheet music example featuring 5 instrumental parts"
     width="75%">
</center>

We can use Alda to translate a score like this into an Alda score that is
roughly equivalent:

{% highlight text %}
$ alda import -i musicxml -f /tmp/parts.musicxml
midi-flute:
  (key-signature "") c4 d e f | g4 a b > c | < b4 a g f | e4 d c2

midi-oboe:
  (key-signature "") c4 e g > c | < g4 e c2 | g1 | c1

midi-clarinet:
  (key-signature "c+ f+") (transpose -2) d4 d d d | r1 | d4 d d d | r1

midi-bassoon:
  (key-signature "") o3 c1 | g1 | c1 | c1

midi-french-horn:
  (key-signature "f+") (transpose -7) g4 b g b | > d4 < b g2 | r1 | g1
{% endhighlight %}

Because the Alda CLI can accept input from stdin, we can pipe that Alda code
directly into the `alda play` command to hear the score:

{% highlight text %}
$ alda import -i musicxml -f /tmp/parts.musicxml | alda play
Playing...
{% endhighlight %}

Or we can write the Alda code to a file for further experimentation:

{% highlight text %}
# You can either redirect the output into a file:
$ alda import -i musicxml -f /tmp/parts.musicxml > /tmp/parts.alda

# Or use the -o / --output flag:
$ alda import -i musicxml -f /tmp/parts.musicxml -o /tmp/parts.alda
{% endhighlight %}

As a fun experiment, let's "round-trip" this score back to MusicXML and see how
it compares to the original.

First, we'll use `alda export` to export the Alda file as a MIDI file:

{% highlight text %}
$ alda export -f /tmp/parts.alda -o /tmp/parts.mid
Exporting...
Exported score to /tmp/parts.mid
{% endhighlight %}

The MIDI file can be played by a variety of different programs, such as
[TiMidity][timidity]:

{% highlight text %}
$ timidity -A100 --verbose /tmp/parts.mid
Playing /tmp/parts.mid
MIDI file: /tmp/parts.mid
Format: 0  Tracks: 1  Divisions: 128
126 supported events, 348321 samples, time 0:07
Init soundfonts `FluidR3_GM.sf2'
Loading SF Tonebank 0 60: French Horns
Loading SF Tonebank 0 68: Oboe
Loading SF Tonebank 0 70: Bassoon
Loading SF Tonebank 0 71: Clarinet
Loading SF Tonebank 0 73: Flute
Resample cache: Key 17/18(94.4%) Sample 1.3M/1.3M(98.5%)
Playing time: ~11 seconds
Notes cut: 0
Notes lost totally: 0
{% endhighlight %}

Now that we have a MIDI file, we can import it into another sheet music program,
such as MuseScore:

<center>
<img src="{{ site.url }}/assets/2023-06-25-musescore.png"
     title="Screenshot of the aforementioned MIDI file imported into MuseScore"
     width="75%">
</center>

And we can then export the score back to MusicXML:

<center>
<img src="{{ site.url }}/assets/2023-06-25-musescore-export.png"
     title="Screenshot of the MuseScore exporting the score to MusicXML"
     width="75%">
</center>

There are some minor differences between this [round-tripped MusicXML
file][parts-roundtripped] and the original MusicXML file. Notice, for example,
that the instruments are presented in a different order, and we've lost the
grouping bracket around four of the five parts. But apart from the minor
differences, it is, for all intents and purposes, the same score!

I'm excited about this feature because now, it is possible for Alda to
participate in the ecosystem of music notation software. Now, you can take
a MusicXML file (or even a MIDI file) that was written via some other software,
and edit it using Alda. And you can go the other way, too: you can take a score
that you wrote in Alda, export it to MIDI, and import it into other software.

MusicXML import is a brand new feature for Alda, and it's bound to be a little
rough around the edges, but I'm confident that it will become more robust over
time. Please give it a try (you can [download the latest version of
Alda][install-alda], or run `alda update` if you already have an older version
installed) and let us know what you think! If you notice any problems with `alda
import`, it'll help us out if you [open an issue][open-an-issue] on GitHub.

# Thanks to our contributors!

I'd like to give a huge thanks to David Lu and Alan Ma for their hard work on
contributions to this feature. Being able to import Alda scores from MIDI files
is a feature that was [requested early on][import-midi-discussion], and I'm
really happy that thanks to the help of our contributors, we were finally able
to make this intriguing idea a reality.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda-website]: https://alda.io
[alda-2-announcement]: {% post_url 2021-06-30-announcing-alda-2 %}
[show-ast]: https://github.com/alda-lang/alda/blob/master/CHANGELOG.md#210-2021-12-29
[run-in-browsers]: https://github.com/alda-lang/alda/discussions/455
[music-xml]: https://w3c.github.io/musicxml/
[parts.musicxml]: https://github.com/alda-lang/alda/blob/fb14a138ebe91084503cd962a0ddcb6f7bcc1fb8/client/interop/musicxml/examples/parts.musicxml
[timidity]: https://timidity.sourceforge.net/
[install-alda]: https://alda.io/install/
[open-an-issue]: https://github.com/alda-lang/alda/issues/new/choose
[import-midi-discussion]: https://github.com/alda-lang/alda/discussions/438
[parts-roundtripped]: https://gist.github.com/daveyarwood/6e0a573735ca95908015382cb39a7f2b
