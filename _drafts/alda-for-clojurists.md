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

# A more FP-friendly Alda

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

# Nutshell

When working with a functional programming language like Clojure, the programmer avoids redefining variables that have already been defined.

For example, consider this imperative code written in JavaScript:

{% highlight javascript %}
var sum = 5; // sum is 5

for (var i = 0; i < 10; i++) {
  sum = sum + i; // sum gets changed a bunch of times
}

return sum;  // sum is 50
{% endhighlight %}

In Clojure, we wouldn't define something and then redefine it. Instead, we would do something like this:

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

To reiterate the problem we were having with Alda: we were storing all of our "working state" in top-level variables like `*events*` and `*current-instruments*`, and those variables could be modified by any process that was trying to create a score. The scores were *not* anonymous and self-contained, so if you had two or more processes that were both trying to create or modify a score using the same Alda server, then they could potentially conflict with each other and cause conflicts.

The solution I came up with was to make creating or updating a score a **reducing operation**. The reducing function was basically this:

{% highlight javascript %}
# JavaScripty pseudocode
function(score, event) {
  return updateScore(score, event); }
{% endhighlight %}

An "event" could be any number of things: a note, a rest, a chord, a change in the value of an instrument's "attributes" like octave, volume, etc. I implemented `update-score` as a Clojure [multimethod](http://clojure.org/reference/multimethods), a special kind of function that has different behavior based on arbitrary properties of its arguments. The `update-score` multimethod examines the type of event and updates the score accordingly. For example, when it encounters a "new part" event, it finds or creates the appropriate instrument and stores that context on the anonymous "score" that is being accumulated.

**At no point during this score-updating process does the original score get modified.** Each iteration of the score-updating reducing function is returning a modified copy of the score, rather than modifying the score and returning it. This is an essential thing to understand about functional programming. In our case, it is beneficial because it means we can safely process multiple scores at the same time without having to worry about one score clobbering the state of another.

# Using Alda in a Clojure REPL

To better illustrate how this works, I can show you a few examples of different events and what the `update-score` multimethod does when it encounters them.

## Events

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
; NOTE: using :refer :all here allows us to leave off the "alda.lisp" when calling 
; these functions
boot.user=> (require '[alda.lisp :refer :all])
nil
boot.user=> (part {:names ["french-horn"]})
{:event-type :part, :instrument-call {:names ["french-horn"]}, :events nil}
{% endhighlight %}

The result of evaluating a `part` form is a Clojure map containing an `:event-type`, which tells the `update-score` multimethod what kind of event this is, and any number of other fields used by Alda to update the score appropriately.

In the case of the "part" event, Alda adds an instance of the appropriate type of instrument to the score (declared via the `:instrument-call`) and then reduces through all of the part's `:events` to add them to the score. A part's "events" are things like attribute changes, notes, and chords.

...

{% highlight clojure %}
boot.user=> (note (pitch :c))
{:event-type :note, :pitch-fn #object[alda.lisp.model.pitch$pitch$fn__15527 0x5bdfc7db "alda.lisp.model.pitch$pitch$fn__15527@5bdfc7db"], :beats nil, :ms nil, :slur? nil}
boot.user=> (part {:names ["french-horn"]} (note (pitch :c)))
{:event-type :part, :instrument-call {:names ["french-horn"]}, :events ({:event-type :note, :pitch-fn #object[alda.lisp.model.pitch$pitch$fn__15527 0xc52e5cd "alda.lisp.model.pitch$pitch$fn__15527@c52e5cd"], :beats nil, :ms nil, :slur? nil})}
{% endhighlight %}
