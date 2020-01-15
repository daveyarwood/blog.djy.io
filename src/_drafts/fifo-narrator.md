---
layout: post
title: "The FIFO-controlled, text-to-speech narrator"
tags:
  - unix
  - text to speech
  - sox
  - audio
  - i3
  - command line
published: true
---

{% include JB/setup %}

* Explain premise of _By Chance_
  * Originally called _Out of the Blue_ because we performed it in a blue room
  * Link back to previous blog post 2019-07-15-out-of-the-blue.md

* Text-to-speech narrator
  * Renay wanted a text to speech narrator that I could cue from my laptop as
    she performed and had conversations with the narrator
  * I tried the built-in `say` command on Ubuntu (TODO: find the package), and
    it's cool, but it doesn't sound natural enough, sounds robotic and corny; in
    this day and age we are all used to more natural sounding robot voices like
    Siri and Alexa
    * For entertainment value, see if I can record a wav of `/usr/bin/say 'I am
      a terrible speech synthesizer'` and embed an audio player into the page
      * could use HTML5 `<audio src="..."></audio>` element
  * The best solution I found was the Google Text-to-Speech service
    * To use the Google Text-to-Speech service directly requires a Google Cloud
      Services account, but it turns out that you can use it with less ceremony
      by hitting the free Google Translate API
    * There are multiple command-line tools that do this out of the box with no
      setup
    * The one I use is https://github.com/desbma/GoogleSpeech
      * demo audio player playing the output of `google_speech -l en-uk "i'm a
        good speech synthesizer"`
  * Code example of looping through all the files in a directory, reading line
    by line, and piping each line to `google_speech`:

{% highlight bash %}
find "$narration_dir" | sort | tail -n+2 | while read filename; do
  cat $filename | while read line; do
    google_speech $gs_opts "$line"
  done
done
{% endhighlight %}

* FIFO (mkfifo, etc.)
  * Demo gif using `file example-fifo`, `cat example-fifo`
  * `fifo-narrator` script
    * creates the FIFO
    * waits for "bangs" to arrive on the FIFO, and those "bangs" trigger one
      script file to be narrated
      * timing depends on live performance, so this allows me to control when to
        proceed to the next script
    * i3 keybinding that puts a "bang" onto the FIFO

* Performance #1 (January 2019) was a smash success

* Performance #2 (November 2019) was, unfortunately, ruined by technical
  difficulties
  * Partway through the narration, the narration just stopped working. I
    switched over to my terminal and was presented with a long Python
    stacktrace. Someone in the crowd went "hey, that's Python!" We had to
    stumble onward without the narrator. Renay was furious with me.
  * I hadn't thought about the fact that you need to have access to the Internet
    in order to use the Google Text-to-Speech.
  * Incidentally, it turns out that the google_speech CLI tool works offline by
    caching the audio synthesized from text input that you've handed to it
    before.
    * Performance #1 had (luckily) gone off without a hitch despite my laptop
      not being connected to the internet at the time. The text-to-speech audio
      was being played back from the cache from when we had rehearsed at home.
    * Somehow, during performance #2, I think the cache failed. (Maybe it was
      a TTL cache and it just happened to expire at the worst possible time?
      Who knows?)
  * It became clear that our performance should not depend on the reliability of
    a network connection or the availability of the Google Text-to-Speech
    service.
  * A better approach would be to pre-record the text-to-speech narration and
    simply play it back during the performance. I could use the same FIFO setup
    to cue moving from each audio file to the next.

* Rough calculation of the pauses between utterances in each script file, based
  on the number of consecutive blank lines.

* SoX
  * man page: "Sound eXchange, the Swiss Army knife of audio manipulation"
  * reads and writes audio files
  * actually does a lot more than that, and I've barely scratched the surface of
    what it can do
    * maybe use some of the examples in the man page, which look interesting
  * I'm using it for two things:
    * generate wav files for specific durations of silence
      * `sox -n -r 24k -c 1 "$part_filename" trim 0.0 "$duration"`
    * stitch together TTS mp3s padded by the silent wav files to add pauses
      * `sox $(ls $parts_dir/*) "$mp3_filename"`

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME
