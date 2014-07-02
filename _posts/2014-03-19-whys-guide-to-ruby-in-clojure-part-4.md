---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 4"
category:
tags: [clojure, ruby]
---
{% include JB/setup %}

*Parts 1, 2 and 3 of this series can be found [here][part1], [here][part2] and [here][part3].*

[part1]: {% post_url 2014-01-06-whys-guide-to-ruby-in-clojure-part-1 %}
[part2]: {% post_url 2014-02-20-whys-guide-to-ruby-in-clojure-part-2 %}
[part3]: {% post_url 2014-03-05-whys-guide-to-ruby-in-clojure-part-3 %}

So here's where \_why starts getting into monkey-patching, which I would consider to be kind of a key feature of Ruby... sure, it's dangerous in that it has the potential to seriously break your code, but Ruby lives on the edge! Monkey-patching in Ruby is kind of interesting in that Rubyists always warn you not to do it, while at the same time showing off how cool and powerful it is. Clojure, on the other hand, is set up in such a way that it's really difficult to majorly screw things up. Everything is namespaced, so functions can't really override each other, and while technically it *is* possible to override core functions by either redefining them or extending protocols, the temptation to do that really isn't there, thanks to Clojure providing easier ways to go about solving the problem. Namely, multimethods provide an easy and surprisingly flexible avenue for polymorphism. In fact, multimethods actually *one-up* polymorphism in that you can dispatch based not just on the type of the arguments, but on *any* function! In this chapter I decided to translate the monkey-patching examples mostly just by defining ordinary functions that assume the argument you're passing in is of a particular type. When we get to Dwemthy's Array (which is in the next chapter, I think?), you'll see me take the multimethod approach to do that crazy thing where \_why monkey-patched a handful of math operators to make them double as weapons used by a rabbit. (If you haven't read *\_why's (Poignant) Guide to Ruby*, you probably have *no* idea what I'm talking about!)

OK, enough yammering. Onward!

Chapter 5 (Sections 4-7)
========================

{% highlight clojure %}

; exs. 32-34:
; not applicable to Clojure (Ruby class inheritance)
; although this is somewhat similar to implementing protocols in records
 
; ex. 35:
(defn mail-them-a-kit [address]
  (when-not (instance? address ex.Address)
    (throw (IllegalArgumentException. "No Address object found.")))
  (print (formatted address)))
 
; ex. 36:
; this kind of monkey-patching isn't really available in Clojure...
; the way to do it would be to create a new protocol/record that takes
; an ordinary array as an argument and implements this modified "join"
; function on the array instead of e.g. clojure.string/join
 
(defprotocol ArrayPlus
  (join [a] [a sep] [a sep frmt] 
        "Joins strings together into a formatted string."))
 
(defrecord ArrayMine [a]
  ArrayPlus
    (join [am] (join am ""))
    (join [am sep] (join am sep "%s"))
    (join [am sep frmt]
      (clojure.string/join sep (map #(format frmt %) a))))
 
; ex. 37:
(def rooms (ArrayMine. [3 4 6]))
(str "We have " (join rooms ", " "%d bed") " rooms available.")
 
; ex. 38:
; Ruby modules are analagous to Clojure namespaces
 
(ns ex.watchful-saint-agnes)
 
(def ToothlessManWithFork ["man" "fork" "exposed gums"])
 
(defrecord FatWaxyChild [])
 
(def timid-foxfaced-girl {"please" "i want an acorn please"})
 
; ex. 39:
; this is another thing in Ruby that you can't really do in Clojure,
; or at least it's not idiomatic. You can access all of the above objects
; from a different namespace as ex.watchful-saint-agnes/FatWaxyChild, 
; ex.watchful-saint-agnes/timid-foxfaced-girl, etc. The idea of "copying" them
; over into a new "class" doesn't really make sense in Clojure's functional
; style.
 
; ex. 40:
(defrecord LotteryTicket [picks purchased])
 
(defn new-lottery-ticket [& picks]
  (cond
    (not= (count picks) 3) 
    (throw (IllegalArgumentException. "three numbers must be picked"))
 
    (not= (count (distinct picks)) 3)
    (throw (IllegalArgumentException. 
            "the three picks must be different numbers"))
 
    (not-every? #(some #{%} (range 1 26)) picks)
    (throw (IllegalArgumentException. 
            "the three picks must be numbers between 1 and 25")))
  (LotteryTicket. picks (java.util.Date.)))
 
; ex. 41:
; no need to do this in Clojure. Records automatically give you a standard
; way to "get" fields. Records function just like maps, which makes getting
; the fields as easy as getting a value from a map (see next example)
 
; ex. 42:
(def ticket (apply new-lottery-ticket (repeatedly 3 #(rand-nth (range 1 26)))))
(:picks ticket)
 
; ex. 43:
; unlike in Ruby, this works by default
 
(assoc ticket :picks [2 6 19])
 
; ex. 44:
; in Clojure it would make more sense for this to be an ordinary function,
; not a class method belonging to the LotteryTicket "class"
 
(defn random-lottery-ticket []
  (apply new-lottery-ticket (repeatedly 3 #(rand-nth (range 1 26)))))
 
; results in an IllegalArgumentException if not all 3 numbers are unique
 
; ex. 45:
(defn random-lottery-ticket []
  (try (apply new-lottery-ticket (repeatedly 3 #(rand-nth (range 1 26))))
       (catch IllegalArgumentException e (random-lottery-ticket))))
 
; recursively calls itself until it returns a valid lottery ticket (3 unique #'s)
 
; ex. 46:
; rather than making this all part of a "LotteryDraw class," it would be more
; idiomatic in Clojure to include all of these as top-level objects and functions
; in a namespace called, say, (ns ex.lottery-draw)
 
(def tickets (atom {}))
 
(defn buy [customer & tickets]
  (swap! tickets #(merge-with concat % {customer tickets})))
 
; ex. 47:
(buy "Yal-dal-rip-sip" 
     (new-lottery-ticket 12 6 19)
     (new-lottery-ticket 5 1 3)
     (new-lottery-ticket 24 6 8))
 
; ex. 48:
(defprotocol Scoring
  (score [ticket final] "Counts the number of correct numbers on the ticket."))
 
(extend-type LotteryTicket
  Scoring
    (score [ticket final]
      (count (clojure.set/intersection (set (:picks ticket)) (set (:picks final))))))
 
; ex. 49: 
(defn play []
  "Returns a hash of each winner to a list of their winning tickets, in the
   form {winner ([ticket1 score1] [ticket2 score2])}."
  (let [winning-numbers (random-lottery-ticket)]
    (into {}
      (for [[plyr tkts] @tickets
            :when (some #(> (score % winning-numbers) 0) tkts)]
        [plyr (for [tkt tkts
                    :let [score (score tkt winning-numbers)]
                    :when (> score 0)]
                [tkt score])]))))
 
 
; ex. 50:
; not relevant to our Clojure translation of ex. 48.
; the "||=" syntax here is a Ruby trick used to "initialize" an entry
; in a map to an empty array [] if there is not already a key with a certain
; name in said map. This is not needed in Clojure, as you can just do, e.g.,
; (merge-with f map {key val}) and if the map already contains the key, it will 
; "update" it by calling the function on the existing value, otherwise it will 
; "create" the {key val} entry you are merging in
 
; ex. 51:
; see above. Re: this particular example of conditional assignment
; (winners[buyer] = winners[buyer] || []), Clojure essentially has this 
; "built into" its implentation of hashmaps. If you try to look up a key 
; in a map that doesn't contain said key, you conveniently get nil.
 
; ex. 51-1/2:
; (this is an irb example that could just as easily be a standalone script)
 
(doseq [[winner tickets] (play)]
  (println winner "won on" (count tickets) "ticket(s)!")
  (doseq [[ticket score] tickets]
    (println (str "\t" (clojure.string/join ", " (:picks ticket)) ": " score))))
 
; exs. 52-53:
; not applicable to Clojure, wherein records work just like hash-maps
 
; ex. 54:
(defprotocol Judging
  (the-winner [contest name]))
 
(defrecord SkatingContest [winner]
  Judging
    (the-winner [_ name]
      (when-not (string? name)
        (throw (IllegalArgumentException. "The winner's name must be a String,
                not a math problem or a list of names or any of that business.")))
      (SkatingContest. name)))
 
; example usage:
(def contest (SkatingContest. nil))
(the-winner contest "Dave")  ;=> (SkatingContest. "Dave")
 
; not exactly something you would do in Clojure, but it's possible!
 
; ex. 55:
(def NOTES [:Ab :A :Bb :B :C :Db :D :Eb :E :F :Gb :G])
 
(defrecord AnimalLottoTicket [picks purchased])
 
(defn new-ticket [note1 note2 note3 :as notes]
  (when-not (distinct? notes)
    (throw (IllegalArgumentException. "the three picks must be different notes")))
  (letfn [(valid-note? [x] (some #{x} NOTES))]
    (when-not (every? valid-note? notes)
      (throw (IllegalArgumentException. 
              "the three picks must be notes in the chromatic scale."))))
  (AnimalLottoTicket. notes (java.util.Date.)))
 
(defn random-ticket []
  (try (apply new-ticket (repeatedly 3 #(rand-nth NOTES)))
       (catch IllegalArgumentException e (random-ticket))))
 
(defprotocol Scoring
  (score [ticket final] "Counts the number of correct numbers on the ticket."))
 
(extend-type AnimalLotteryTicket
  Scoring
    (score [ticket final]
      (count (clojure.set/intersection (set (:picks ticket)) (set (:picks final))))))
 
; ex. 56:
; references the MindReader "read" method from ex. 13. In this Ruby example, 
; _why refers to "self.read" within a module, with the intent of mixing the
; module into an existing class that contains a "read" method, such as the 
; MindReader class from before. To emulate this in Clojure, we can create an
; ordinary function that takes a "this" argument (a record). See the next 
; example for how to "mix in" this function to our existing MindReader record.
 
(require '[endertromb.core :as endertromb])
 
(defn scan-for-a-wish [this]
  (when-let [wish ((comp first filter) #(= (subs % 0 6) "wish: ") (read this))]
    (clojure.string/replace wish "wish: " "")))
 
; ex. 57:
; there is actually no need to "mix in" our scan-for-a-wish method. As an ordinary
; method, it can be used by (or rather, on) any record that implements a protocol
; that has a "read" method. If you pass in a (MindReader.) record to the 
; scan-for-a-wish method, it will replace the "this" in (read this), and the
; correct "read" method will be dispatched.
 
; ex. 58:
(def reader (MindReader. (endertromb/scan-for-sentience)))
(def wisher (WishMaker. (rand-int 6)))
 
; this example doesn't really work within Clojure's functional programming 
; paradigm. To be fair, it isn't properly explained how the Ruby example's 
; infinite loop goes on to the next wish after the last one has been granted. I 
; assume the WishMaker's "grant" method would destructively delete the wishful 
; thought from the queue of thoughts read by the MindReader, so that on the next 
; iteration of the loop, the "scan_for_a_wish" method will find a new wish. If 
; this were an actual program in Clojure, scanning thoughts for wishes in 
; real-time, we would probably want to use a ref or an atom to represent a (lazy?) 
; sequence of thoughts, and have an infinite loop that checks the first thought
; and either grants it (if it starts with "wish: ") or discards it, updating the 
; ref or atom's state with each iteration of the loop

{% endhighlight %}