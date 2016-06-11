---
layout: post
title: "Alda for Clojurists"
category: alda
tags:
  - alda
  - music-programming
  - composition
published: true
---

{% include JB/setup %}

Just recently, I rewrote a big chunk of the [Alda](https://github.com/alda-lang/alda) codebase; the result is something I'm a lot happier with, as a [Clojure](http://clojure.org) programmer. Clojure is a language that encourages programming in a [functional](https://en.wikipedia.org/wiki/Functional_programming) style, minimizing the need to keep track of the state of variables and reliance upon unpredictable side effects.

My first pass at writing the core library of Alda was admittedly not very faithful to the tenets of functional programming. This wasn't a conscious decision; it just ended up being the quickest way to write the code and have it work reasonably well.

This first cut of Alda used to work like this:

* There were a bunch of dynamic [vars](http://clojure.org/reference/vars) defined in the `alda.lisp` namespace, each of which represented the current state of some aspect of the Alda score being evaluated.
* As an Alda score file was parsed and evaluated, each "event" would modify one or more of the top-level vars. For example, a `note` event would add some note data to `*events*` and make a note of the updated position in the score of the instrument that played the note by updating `*instruments*`. To keep track of which instrument(s) were currently active, the score evaluation process would access and modify the `*current-instruments*` var.
* Each time a new score was evaluated, the `score` event would re-initialize all of the dynamic vars, losing any state that had been accumulated by the previous score.

Here is a Clojure REPL session demonstrating how this worked:

{% highlight clojure %}
; alda v1.0.0-rc14

boot.user=> (require '[alda.lisp :refer :all])
nil
boot.user=> (score*) ; start a new score
{}
boot.user=> *instruments*
{}
boot.user=> *current-instruments*
#{}
boot.user=> (part* "bassoon") ; add a bassoon part
nil
boot.user=> *current-instruments*
#{"bassoon-x5BWg"}
boot.user=> *instruments*
{"bassoon-x5BWg" {:octave 4,
                  :current-offset #alda.lisp.AbsoluteOffset{:offset 0},
                  :key-signature {},
                  :config {:type :midi, :patch 71},
                  :duration 1,
                  :volume 1.0,
                  :last-offset #alda.lisp.AbsoluteOffset{:offset 0},
                  :id "bassoon-x5BWg",
                  :quantization 0.9,
                  :tempo 120,
                  :panning 0.5,
                  :current-marker :start,
                  :stock "midi-bassoon",
                  :track-volume 0.7874015748031497}}
boot.user=> (note (pitch :c) (duration (note-length 2 {:dots 1}))) ; add a note
(#alda.lisp.Note{:offset #alda.lisp.AbsoluteOffset{:offset 0},
                 :instrument "bassoon-x5BWg",
                 :volume 1.0,
                 :track-volume 0.7874015748031497,
                 :panning 0.5,
                 :midi-note 60,
                 :pitch 261.6255653005986,
                 :duration 1350.0})
boot.user=> *events*
{:start {:offset #alda.lisp.AbsoluteOffset{:offset 0},
         :events [#alda.lisp.Note{:offset #alda.lisp.AbsoluteOffset{:offset 0},
                                  :instrument "bassoon-x5BWg",
                                  :volume 1.0,
                                  :track-volume 0.7874015748031497,
                                  :panning 0.5,
                                  :midi-note 60,
                                  :pitch 261.6255653005986,
                                  :duration 1350.0}]}}
boot.user=> *instruments*
{"bassoon-x5BWg" {:octave 4,
                  :current-offset #alda.lisp.AbsoluteOffset{:offset 1500.0},
                  :key-signature {},
                  :config {:type :midi, :patch 71},
                  :duration 3.0,
                  :volume 1.0,
                  :last-offset #alda.lisp.AbsoluteOffset{:offset 0},
                  :id "bassoon-x5BWg",
                  :quantization 0.9,
                  :tempo 120,
                  :panning 0.5,
                  :current-marker :start,
                  :stock "midi-bassoon",
                  :track-volume 0.7874015748031497}}
boot.user=> (score*) ; start a new score
{}
boot.user=> *events*
{:start {:offset #alda.lisp.AbsoluteOffset{:offset 0},
         :events []}}
boot.user=> *instruments*
{}
boot.user=> *current-instruments*
#{}
{% endhighlight %}

This was our immediate problem: an Alda process could only handle one score at a time. This worked OK for experimenting in a Clojure REPL, but in practice, it became evident that we needed an Alda process to be able to manage multiple scores. For example, a user might want to play one score, and then parse or play another score while the first score is still playing. The top-level var-based system was simply not able to accommodate this use case; this was my catalyst for rewriting Alda in a more functional style.

TODO: explain how it works now, example REPL session, explain benefits
TODO: show examples of how each event type changes a score
