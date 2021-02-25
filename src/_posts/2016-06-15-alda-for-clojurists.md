---
layout: post
title: "Alda for Clojurists"
category: alda
tags:
  - alda
  - music programming
  - composition
published: true
---

{% include JB/setup %}

# A more FP-friendly Alda

Just recently, I rewrote a big chunk of the [Alda](https://github.com/alda-lang/alda) codebase; the result is something I'm a lot happier with, as a [Clojure](http://clojure.org) programmer. Clojure is a language that encourages programming in a [functional](https://en.wikipedia.org/wiki/Functional_programming) style, minimizing the need to keep track of the state of variables and reliance upon unpredictable side effects.

My first pass at writing the core library of Alda was admittedly not very faithful to the tenets of functional programming. This wasn't a conscious decision; it just ended up being the quickest way to write the code and have it work reasonably well.

This first cut of Alda used to work like this:

* There were a bunch of dynamic [vars](http://clojure.org/reference/vars) defined in the `alda.lisp` namespace, each of which represented the current state of some aspect of the Alda score being evaluated.
* As an Alda score file was parsed and evaluated, each "event" would modify one or more of the top-level vars. For example, a `note` event would add some note data to `*events*` and make a note of the updated position in the score of the instrument that played the note by updating `*instruments*`. To keep track of which instrument(s) were currently active, the score evaluation process would access and modify the `*current-instruments*` var.
* Each time a new score was evaluated, the `score` event would re-initialize all of the dynamic vars, losing any state that had been accumulated by the previous score.

Here is a Clojure REPL session demonstrating how this worked before:

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

# FP in a nutshell

When working with a functional programming language like Clojure, the programmer avoids redefining variables that have already been defined.

For example, consider this imperative code written in JavaScript:

{% highlight javascript %}
var sum = 5; // sum is 5

for (var i = 0; i < 10; i++) {
  sum = sum + i; // sum gets changed a bunch of times
}

return sum;  // sum is 50
{% endhighlight %}

In Clojure, we wouldn't define something and then redefine it. Instead, we would express the sum as a single expression, like this:

{% highlight clojure %}
(reduce + 5 (range 10)) ; sum is 50
{% endhighlight %}

In the JavaScript example, we constructed an imperative `for` loop where we change the value of `sum` on each iteration, then we returned the final value.

In the Clojure example, we represented this more concisely as a mathematical calculation:

* Take the range of numbers from 0 until 10. (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
* Perform a reducing operation over this range:
  * adding the next number to the accumulated result
  * starting with the number 5 as an initial value

If you're new to functional programming, you may not be familiar with `reduce`. `reduce` works sort of like a constrained `for` loop, but we usually don't perform any "side effects" like changing the values of variables. Instead, we define a sort of "formula" for what the result should be in each iteration of the loop, then each result is fed into the next iteration of the loop until we're out of things to loop over and we have our result.

The "formula" is a function that takes two arguments: the "accumulator" (the result that gets fed back into the loop each time) and the next value.

In the case of the example above, the formula is `accumulator + next-value`, so we can conveniently just use `+` as our reducing function.

So, given the initial accumulator value of 5, and the range 0-9 to reduce over, the reducing process looks something like this:

{% highlight shell %}
# accumulator' = accumulator + value
5 + 0 = 5
5 + 1 = 6
6 + 2 = 8
8 + 3 = 11
11 + 4 = 15
15 + 5 = 20
20 + 6 = 26
26 + 7 = 33
33 + 8 = 41
41 + 9 = 50
{% endhighlight %}

The key thing about representing this calculation as `(reduce + 5 (range 10))` is that it is anonymous and completely self-contained. Notice that we did not have to define any variables to calculate this sum. That means we don't have to worry about accidentally forgetting to set the initial value of a variable, and we don't have to worry about some other process altering the state of the variable before we get the value we want. This is the power and simplicity of functional programming, in a nutshell.

# A formula for calculating a musical score

To reiterate the problem we were having with Alda: we were storing all of our
"working state" in top-level variables like `*events*` and
`*current-instruments*`, and those variables could be modified by any process
that was trying to create a score. The scores were *not* anonymous and
self-contained, so if you had two or more processes that were both trying to
create or modify a score using the same Alda server, then they could potentially
conflict with one another.

The solution I came up with was to make creating or updating a score a **reducing operation**. The reducing function was basically this:

{% highlight javascript %}
// JavaScript pseudocode
function(score, event) {
  return updatedScore(score, event);
}
{% endhighlight %}

An "event" could be any number of things: a note, a rest, a chord, a change in the value of an instrument's "attributes" like octave or volume, etc. I implemented `update-score` as a Clojure [multimethod](http://clojure.org/reference/multimethods), a special kind of function that has different behavior depending on arbitrary properties of its arguments. The `update-score` multimethod examines the type of event and updates the score accordingly. For example, when it encounters a "new part" event, it finds or creates the appropriate instrument and stores that context on the anonymous "score" that is being accumulated.

**At no point during this score-updating process does the original score get modified.** Each iteration of the score-updating reducing function is returning a modified copy of the score, rather than modifying the score and returning it. This is an essential thing to understand about functional programming. In our case, it is beneficial because it means we can safely process multiple scores at the same time without having to worry about one score clobbering the state of another.

# Using Alda in a Clojure REPL

To better illustrate how this works, I can show you a few examples of different events and what the `update-score` multimethod does when it encounters them.

## Events: what do they look like?

Alda has a convenient Clojure DSL that allows you to express a musical score in the form of a Lisp S-expression.

For example, consider the following sheet music:

<center>
  <img src="{{site.url}}/assets/2015-08-23-sheet-music-01.png"
       alt="sheet music generated by www.tunefl.com"
       title="sheet music generated by www.tunefl.com"
       style="margin-bottom: 20px" />
</center>

This is a simple musical score containing four notes: C, D, E, F.

Assuming you wanted these notes played by a French horn, the corresponding Alda score would look like this:

{% highlight shell %}
french-horn:
  c d e f
{% endhighlight %}

When the Alda compiler parses this code, the result is a single S-expression of Clojure code:

{% highlight clojure %}
boot.user=> (require '[alda.parser :refer (parse-input)])
nil
boot.user=> (parse-input "french-horn:\n  c d e f")
(alda.lisp/score (alda.lisp/part {:names ["french-horn"]} (alda.lisp/note (alda.lisp/pitch :c)) (alda.lisp/note (alda.lisp/pitch :d)) (alda.lisp/note (alda.lisp/pitch :e)) (alda.lisp/note (alda.lisp/pitch :f))))
boot.user=> (pp) ; pretty-print the previous result
(alda.lisp/score
 (alda.lisp/part
  {:names ["french-horn"]}
  (alda.lisp/note (alda.lisp/pitch :c))
  (alda.lisp/note (alda.lisp/pitch :d))
  (alda.lisp/note (alda.lisp/pitch :e))
  (alda.lisp/note (alda.lisp/pitch :f))))
nil
{% endhighlight %}

The resulting Clojure code makes use of several functions defined in the `alda.lisp` namespace provided by Alda. Each of these functions has different semantics, but all of the functions that are considered "events" work in the same basic way: they return a Clojure map representing an event.

Take `alda.lisp/part`, for example:

{% highlight clojure %}
; NOTE: using :refer :all here allows us to leave off the "alda.lisp" when using
; these functions
boot.user=> (require '[alda.lisp :refer :all])
nil
boot.user=> (part {:names ["french-horn"]})
{:event-type :part, :instrument-call {:names ["french-horn"]}, :events nil}
{% endhighlight %}

The result of evaluating a `part` form is a Clojure map containing an `:event-type`, which tells the `update-score` multimethod what kind of event this is, and any number of other fields used by Alda to update the score appropriately.

In the case of the "part" event, Alda adds an instance of the appropriate type of instrument to the score (declared via the `:instrument-call`) and then reduces through all of the part's `:events` to add them to the score. A part's "events" are things like attribute changes, notes, and chords.

A "note" event looks like this:

{% highlight clojure %}
boot.user=> (note (pitch :c) (duration (note-length 1)))
{:event-type :note, :pitch-fn #object[alda.lisp.model.pitch$pitch$fn__15521 0x6f6ffd31 "alda.lisp.model.pitch$pitch$fn__15521@6f6ffd31"], :beats 4.0, :ms 0, :slur? false}
boot.user=> (pp)
{:event-type :note,
 :pitch-fn
 #object[alda.lisp.model.pitch$pitch$fn__15521 0x6f6ffd31 "alda.lisp.model.pitch$pitch$fn__15521@6f6ffd31"],
 :beats 4.0,
 :ms 0,
 :slur? false}
{% endhighlight %}

Just like we saw before with `part`, the `note` event returns a map containing one required field `:event-type`, which tells the score evaluation process what type of event it is so it knows what to do with the other information in the map.

The REPL representation of `:pitch-fn` looks kind of funky, but all it is is a function that is applied to the current instruments' octave and key signature in order to get the actual pitch of the note. For example, if an instrument is in octave 4 and has no key signature, then the note "C" corresponds to MIDI note number 60, and has a frequency of about 262 Hz:

{% highlight clojure %}
boot.user=> ((pitch :c) 4 {})
261.6255653005986
boot.user=> ((pitch :c) 4 {} :midi true)
60
{% endhighlight %}

The remaining fields have values when a duration is assigned to the note. In the example above, the note has the duration of a whole (1) note, which means it lasts for 4 beats. The `:ms` field has a non-zero value if the note's duration is expressed in milliseconds instead of as a note length.

## Events: what do they do?

To see the effect of updating a score with an event, we can define a score using `alda.lisp/score`, update the score using `alda.lisp/continue`, and then use [clojure.data/diff](https://clojuredocs.org/clojure.data/diff) to show what's different about the updated score:

{% highlight clojure %}
boot.user=> (require '[clojure.data :refer (diff)])
nil
boot.user=> (def s1 (score))
#'boot.user/s1
boot.user=> (def s2 (continue s1 (part "bassoon")))
#'boot.user/s2
boot.user=> (diff s1 s2)
({:instruments nil, :current-instruments nil, :voice-instruments nil, :current-voice nil} {:instruments {"bassoon-L1iSp" {:octave 4, :current-offset #alda.lisp.model.records.AbsoluteOffset{:offset 0}, :key-signature {}, :config {:type :midi, :patch 71}, :duration 1, :volume 1.0, :last-offset #alda.lisp.model.records.AbsoluteOffset{:offset -1}, :id "bassoon-L1iSp", :quantization 0.9, :tempo 120, :panning 0.5, :current-marker :start, :time-scaling 1, :stock "midi-bassoon", :track-volume 0.7874015748031497}}, :current-instruments #{"bassoon-L1iSp"}} {:beats-tally-default nil, :nicknames {}, :global-attributes {}, :cram-level 0, :markers {:start 0}, :beats-tally nil, :events #{}, :chord-mode false})
boot.user=> (pp)
 ; things that are unique about the score before
({:instruments nil,
  :current-instruments nil,
  :voice-instruments nil,
  :current-voice nil}
 ; things that are unique about the score after
 {:instruments
  {"bassoon-L1iSp"
   {:octave 4,
    :current-offset {:offset 0},
    :key-signature {},
    :config {:type :midi, :patch 71},
    :duration 1,
    :volume 1.0,
    :last-offset {:offset -1},
    :id "bassoon-L1iSp",
    :quantization 0.9,
    :tempo 120,
    :panning 0.5,
    :current-marker :start,
    :time-scaling 1,
    :stock "midi-bassoon",
    :track-volume 0.7874015748031497}},
  :current-instruments #{"bassoon-L1iSp"}}
 ; things that didn't change
 {:beats-tally-default nil,
  :nicknames {},
  :global-attributes {},
  :cram-level 0,
  :markers {:start 0},
  :beats-tally nil,
  :events #{},
  :chord-mode false})
nil
{% endhighlight %}

Things worth noting:

- Continuing a score with `alda.lisp/continue` does not modify the original score; it produces a new one. In the REPL session above, we defined the original (empty) score as `s1`, then continued it and defined the resulting score (with bassoon part added) as `s2`. `s1` was not modified in the process of creating `s2`.

- Adding a "part" event to an Alda score changes a handful of things in the score map, namely `:instruments`, `:current-instruments`, `:voice-instruments`, and `:current-voice`. You may not need to understand the subtle differences between these fields; sufficeth to say that using `alda.lisp/part` in a score has an impact on the instruments in the score and which ones are active at that moment in the score.

Let's continue, and see what the `note` event does:

{% highlight clojure %}
boot.user=> (def s3 (continue s2 (note (pitch :c))))
#'boot.user/s3
boot.user=> (diff s2 s3)
({:instruments {"bassoon-L1iSp" {:last-offset {:offset -1}, :current-offset {:offset 0}}}, :events nil} {:instruments {"bassoon-L1iSp" {:last-offset {:offset 0}, :current-offset {:offset 500.0}, :min-duration nil, :duration-inside-cram nil}}, :events #{#alda.lisp.model.records.Note{:offset 0, :instrument "bassoon-L1iSp", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 60, :pitch 261.6255653005986, :duration 450.0, :voice nil}}} {:beats-tally-default nil, :nicknames {}, :global-attributes {}, :cram-level 0, :markers {:start 0}, :instruments {"bassoon-L1iSp" {:octave 4, :key-signature {}, :config {:type :midi, :patch 71}, :duration 1, :volume 1.0, :id "bassoon-L1iSp", :quantization 0.9, :tempo 120, :panning 0.5, :current-marker :start, :time-scaling 1, :stock "midi-bassoon", :track-volume 0.7874015748031497}}, :beats-tally nil, :current-instruments #{"bassoon-L1iSp"}, :chord-mode false})
boot.user=> (pp)
 ; things unique about s2
({:instruments
  {"bassoon-L1iSp"
   {:last-offset {:offset -1}, :current-offset {:offset 0}}},
  :events nil}
 ; things unique about s3
 {:instruments
  {"bassoon-L1iSp"
   {:last-offset {:offset 0},
    :current-offset {:offset 500.0},
    :min-duration nil,
    :duration-inside-cram nil}},
  :events
  #{
    {:offset 0,
     :instrument "bassoon-L1iSp",
     :volume 1.0,
     :track-volume 0.7874015748031497,
     :panning 0.5,
     :midi-note 60,
     :pitch 261.6255653005986,
     :duration 450.0,
     :voice nil}
    }}
 ; things that stayed the same
 {:beats-tally-default nil,
  :nicknames {},
  :global-attributes {},
  :cram-level 0,
  :markers {:start 0},
  :instruments
  {"bassoon-L1iSp"
   {:octave 4,
    :key-signature {},
    :config {:type :midi, :patch 71},
    :duration 1,
    :volume 1.0,
    :id "bassoon-L1iSp",
    :quantization 0.9,
    :tempo 120,
    :panning 0.5,
    :current-marker :start,
    :time-scaling 1,
    :stock "midi-bassoon",
    :track-volume 0.7874015748031497}},
  :beats-tally nil,
  :current-instruments #{"bassoon-L1iSp"},
  :chord-mode false})
nil
{% endhighlight %}

As you can see, the note event changed a couple things:

- The bassoon instrument's "last offset" and "current offset" changed to reflect how far into the score (in milliseconds) that instrument is after having played the note. These new values will be used to determine where in the score the next note the bassoon plays will be placed.

- `:events`, which was an empty set `#{}` before, now contains a single note event, which is represented as a map containing information like the volume, panning, pitch, and duration of the note.

## Putting it all together

At this point, you may be wondering: How is it practical to write a score this way? Do I have to define a new var like `s1`, `s2` and `s3` each time I add something to the score?

A more practical way to use `alda.lisp` is to define a score as an [atom](http://clojure.org/reference/atoms):

{% highlight clojure %}
boot.user=> (def s (atom (score)))
#'boot.user/s
boot.user=> @s
{:chord-mode false, :current-instruments #{}, :voice-instruments nil, :events #{}, :beats-tally nil, :instruments {}, :markers {:start 0}, :cram-level 0, :global-attributes {}, :current-voice nil, :nicknames {}, :beats-tally-default nil}
{% endhighlight %}

Now your score can be continued in-place using `swap!` with `alda.lisp/continue`:

{% highlight clojure %}
boot.user=> (swap! s continue (part "marimba"))
{:chord-mode false, :current-instruments #{"marimba-Gdk86"}, :events #{}, :beats-tally nil, :instruments {"marimba-Gdk86" {:octave 4, :current-offset #alda.lisp.model.records.AbsoluteOffset{:offset 0}, :key-signature {}, :config {:type :midi, :patch 13}, :duration 1, :volume 1.0, :last-offset #alda.lisp.model.records.AbsoluteOffset{:offset -1}, :id "marimba-Gdk86", :quantization 0.9, :tempo 120, :panning 0.5, :current-marker :start, :time-scaling 1, :stock "midi-marimba", :track-volume 0.7874015748031497}}, :markers {:start 0}, :cram-level 0, :global-attributes {}, :nicknames {}, :beats-tally-default nil}
{% endhighlight %}

To make this slightly more convenient, you can use `alda.lisp/continue!` which is a shortcut for the above:

{% highlight clojure %}
boot.user=> (continue! s (note (pitch :c))
       #_=>              (note (pitch :d))
       #_=>              (note (pitch :e)))
{:chord-mode false, :current-instruments #{"marimba-Gdk86"}, :events #{#alda.lisp.model.records.Note{:offset 1000.0, :instrument "marimba-Gdk86", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 64, :pitch 329.6275569128699, :duration 450.0, :voice nil} #alda.lisp.model.records.Note{:offset 0, :instrument "marimba-Gdk86", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 60, :pitch 261.6255653005986, :duration 450.0, :voice nil} #alda.lisp.model.records.Note{:offset 500.0, :instrument "marimba-Gdk86", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 62, :pitch 293.6647679174076, :duration 450.0, :voice nil}}, :beats-tally nil, :instruments {"marimba-Gdk86" {:octave 4, :current-offset #alda.lisp.model.records.AbsoluteOffset{:offset 1500.0}, :key-signature {}, :config {:type :midi, :patch 13}, :duration 1, :min-duration nil, :volume 1.0, :last-offset #alda.lisp.model.records.AbsoluteOffset{:offset 1000.0}, :id "marimba-Gdk86", :quantization 0.9, :duration-inside-cram nil, :tempo 120, :panning 0.5, :current-marker :start, :time-scaling 1, :stock "midi-marimba", :track-volume 0.7874015748031497}}, :markers {:start 0}, :cram-level 0, :global-attributes {}, :nicknames {}, :beats-tally-default nil}
boot.user=> (:events @s)
#{#alda.lisp.model.records.Note{:offset 1000.0, :instrument "marimba-Gdk86", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 64, :pitch 329.6275569128699, :duration 450.0, :voice nil} #alda.lisp.model.records.Note{:offset 0, :instrument "marimba-Gdk86", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 60, :pitch 261.6255653005986, :duration 450.0, :voice nil} #alda.lisp.model.records.Note{:offset 500.0, :instrument "marimba-Gdk86", :volume 1.0, :track-volume 0.7874015748031497, :panning 0.5, :midi-note 62, :pitch 293.6647679174076, :duration 450.0, :voice nil}}
boot.user=> (pp)
#{
  {:offset 1000.0,
   :instrument "marimba-Gdk86",
   :volume 1.0,
   :track-volume 0.7874015748031497,
   :panning 0.5,
   :midi-note 64,
   :pitch 329.6275569128699,
   :duration 450.0,
   :voice nil}
  {:offset 0,
   :instrument "marimba-Gdk86",
   :volume 1.0,
   :track-volume 0.7874015748031497,
   :panning 0.5,
   :midi-note 60,
   :pitch 261.6255653005986,
   :duration 450.0,
   :voice nil}
  {:offset 500.0,
   :instrument "marimba-Gdk86",
   :volume 1.0,
   :track-volume 0.7874015748031497,
   :panning 0.5,
   :midi-note 62,
   :pitch 293.6647679174076,
   :duration 450.0,
   :voice nil}}
nil
{% endhighlight %}

## Playing your score

`alda.now` provides a quick and easy way to create and play Alda scores in a Clojure application or REPL. You can [read the documentation](https://github.com/alda-lang/alda/blob/master/doc/alda-now.md) for more information on the kinds of things it allows you to do, but for a quick demo, we can use `alda.now/play-score!` to play the score we created above.

{% highlight clojure %}
boot.user=> (require '[alda.now :refer :all])
nil
boot.user=> (play-score! s)
Jun 15, 2016 7:52:27 AM com.jsyn.engine.SynthesisEngine start
INFO: Pure Java JSyn from www.softsynth.com, rate = 44100, RT, V16.7.3 (build 457, 2014-12-25)
#object[alda.sound$play_BANG_$fn__16145 0x301ea9a9 "alda.sound$play_BANG_$fn__16145@301ea9a9"]
{% endhighlight %}

There will be a delay\* as the MIDI synthesizer is initialized, and then you should hear a marimba playing three notes: C, D, E.

> \**This delay only happens the first time you play something in a session; playback will be immediate each time after that.*

For playing one-off snippets of music instead of pre-defined scores, you can use `alda.now/play!`:

{% highlight clojure %}
boot.user=> (play!
       #_=>   (part "accordion"
       #_=>     (note (pitch :c) (duration (note-length 8)))
       #_=>     (note (pitch :d))
       #_=>     (note (pitch :e :flat))
       #_=>     (note (pitch :f))
       #_=>     (note (pitch :g))
       #_=>     (note (pitch :a :flat))
       #_=>     (note (pitch :b))
       #_=>     (octave :up)
       #_=>     (note (pitch :c))))
Jun 15, 2016 8:02:05 AM com.jsyn.engine.SynthesisEngine start
INFO: Pure Java JSyn from www.softsynth.com, rate = 44100, RT, V16.7.3 (build 457, 2014-12-25)
nil
{% endhighlight %}

# That's it

If you're a Clojure programmer, hopefully this gives you enough background on how Alda works as a Clojure library that you can use it as a tool to create music or sound effects in your Clojure programs.

Each time we release a new version of Alda, in addition to releasing the command-line executable on GitHub, [I also upload the package to Clojars](https://clojars.org/alda). So, if any of this stuff interests you, I encourage you to set `alda` as a dependency with your favorite [Clojure
build tool](http://boot-clj.com) and play around with it. Have fun!
