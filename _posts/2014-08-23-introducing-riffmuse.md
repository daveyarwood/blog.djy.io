---
published: true
layout: post
title: Introducing Riffmuse
category: music
tags: 
  - composition
  - clojure
---

{% include JB/setup %}

I've written a simple command line app in Clojure that will take a musical scale as a command line argument and algorithmically generate a short musical idea or "riff" using the notes in that scale. I call it [Riffmuse](https://github.com/daveyarwood/riffmuse).

Here's how Riffmuse works in a nutshell: it takes the command line argument(s), figures out what scale you want (For this, I used the awesome parser generator library [Instaparse](https://github.com/Engelberg/instaparse) to create a parser that allows a flexible syntax in specifying scales. C major can be represented as, e.g., "C major," "CMAJ" or even just "c"), determines what notes are in that scale, comes up with a rhythmic pattern for the notes (represented as 16 "slots" that can either have a note or no note), and then fills the slots with notes from the scale you've specified.

Here's an example:

{% highlight clojure %}
> riffmuse c-sharp minor
    
Riffmuse v1.0.0
---------------
    
Scale:
    
    C# minor

Notes:
    
    1                2                 3                4
    | A |   | C# |   |   | C# | C# |   | F# |   |   |   | E | G# | E | A |
    
Guitar:
    
         1               2               3               4
     A|----------4---------------------------------------7-------7--12-
     E|--5-------------------9---9-------2-------------------4---------
{% endhighlight %}

That's not the best-sounding riff, but if you run Riffmuse a handful of times, you're bound to end up with a musical idea that inspires you in some way, and you can then tweak it and play around with it to your liking. 

The idea for this program was inspired by some of the music that I wrote in college for Composition classes. I became interested in [algorithmic composition](http://en.wikipedia.org/wiki/Algorithmic_composition), the idea of leaving some portion of the composition process up to chance by using some sort of algorithm to generate musical material. I wrote a few interesting pieces of music whose pitch content was derived from a list of [randomly generated numbers](http://www.random.org). You can use Riffmuse as a tool for writing algorithmic music, but you can also use it more generally as a source of inspiration, a muse that can help you think outside of the box and come up with some interesting musical ideas.

Riffmuse currently supports the following scales: major, minor, major pentatonic, minor pentatonic, blues, octatonic (there are only two possible octatonic scales -- both are available as "octatonic 1" and "octatonic 2") and chromatic. I may implement more in the future; I didn't want to over-complicate things for this initial release.

Some ideas I have for the future of Riffmuse:

* Optimize guitar fingerings -- currently it's just a 50/50 chance what string a note will be on, which can lead to some wonky position changes. Above, for example, no sane guitarist would play a C# on the A string (4th fret), and then move up to the 9th fret just to play the same note on the A string...
* Build a GUI interface with drop-down selectors for the pitches and scale types
* Make it into a web app
* ... and/or an Android app?
* Find some way for Riffmuse to synthesize the riff into sound so that you can hear what it sounds like. This will take more work... I could potentially use Overtone for this. 
* Expand this idea to generating chord progressions. This might end up spinning off as a new project.

I'm pretty excited about Riffmuse as the first step toward more interesting algorithmic music compositional tools. I can already see myself using it to come up with interesting riffs and progressions. I'll be sure to post updates as I add new features.