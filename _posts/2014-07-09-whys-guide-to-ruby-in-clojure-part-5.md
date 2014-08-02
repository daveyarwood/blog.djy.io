---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 5"  
category: 
tags: [clojure, ruby]
---
{% include JB/setup %}

*Parts 1 through 4 of this series can be found [here][part1], [here][part2], [here][part3] and [here][part4].*

[part1]: {% post_url 2014-01-06-whys-guide-to-ruby-in-clojure-part-1 %}
[part2]: {% post_url 2014-02-20-whys-guide-to-ruby-in-clojure-part-2 %}
[part3]: {% post_url 2014-03-05-whys-guide-to-ruby-in-clojure-part-3 %}
[part4]: {% post_url 2014-03-19-whys-guide-to-ruby-in-clojure-part-4 %}

At long last, here is part 5 of my series translating the code examples from w(p)gtr into Clojure! I meant to post this like, 4 months ago, but I've been super busy, mostly with music stuff (see [my last post][theremin] for the most recent cool thing I've done), and I didn't get a chance to test this code to make sure it works until just a few days ago. If anyone was really looking forward to this installment, sorry!

[theremin]: {% post_url 2014-07-05-saint-saens-the-swan-on-theremin %}

Here's where things really get interesting. \_why decides to throw some metaprogramming at us, showcasing an area where Ruby truly shines. Dwemthy's Array is without a doubt the coolest part of the entire guide. The fact that you can mold and shape the syntax of Ruby to make your own custom DSLs is flat-out inspiring. As it turns out, this is another area in which Clojure (actually, Lisp in general) excels, with its macro system. If I wanted to write an idiomatic implementation of Dwemthy's Array in Clojure, I would probably actually avoid using metaprogramming and instead use a more functional style and ordinary maps instead of records. But that wouldn't address the burning question I had going into this translation project, which is essentially, "Can Clojure do everything Ruby can?" So, I took this as an opportunity to compare metaprogramming and classes in Ruby to metaprogramming and records in Clojure. 

Also of note, the beginning of this chapter reminded me of how ugly Clojure's (really Java's) lower-level methods for dealing with website are, when compared to Ruby's `File` class and `open-uri` library. This is something I noticed back in [part 2][part2] when dealing specifically with file I/O. Clojure's `spit` and `slurp` methods are nice, but in order to read a file (or website content) in line by line, we still have to resort to Java inter-op and deal with explicit reader and writer objects. You'd think there'd be some higher-level construct available in Clojure's core libraries by now...

It also occurred to me in this chapter that in Clojure, the equivalent of a Ruby block is essentially writing the `~@body` part of a macro. Strictly speaking, you could consider an ordinary function to be the equivalent of a Ruby block (and you'd be right), but in terms of writing a function that *takes* a block, I think the closest syntactic match would be to write a macro that takes arguments like `[foo bar & body]`, where `body` is the "block" of code to be executed in some context. I find it interesting the difference in simplicity between Clojure's (first-class) functions, and the existence of three different things in Ruby (lambdas, blocks and procs, oh my!) that essentially all cover the same territory.

Chapter 6 (Sections 1-3)
========================

{% highlight clojure %}

; ex. 1:
(slurp "http://preeventualist.org/lost")

; ex. 2:
(slurp "http://preeventualist.org/lost/searchfound?q=truck")

; ex. 3:
(slurp "folder/idea-about-hiding-lettuce-in-the-church-chairs.txt")

; ex. 4:
(slurp "http://your.com/idea-about-hiding-lettuce-in-the-church-chairs.txt")

; ex. 5:
(let [address "http://preeventualist.org/lost/searchfound?q=truck"]
  (with-open [rdr (clojure.java.io/reader address)]
    (filter #(re-find #"pickup" %) (line-seq rdr))))

; not as pretty as Ruby's syntax with open-uri, I'm afraid...

; ex. 6:
; macros can be used to emulate block-like behavior in Clojure

(defmacro each-line [rdr [line] & body]
  `(doseq [~line (line-seq ~rdr)] ~@body))

; ex. 7:
(defmacro yield-thrice [& body]
  `(dotimes [_# 3] ~@body))

; ex. 8:
; demonstration of Ruby block syntax -- not relevant to Clojure

; ex. 9:
(defmacro double-open [[a filename1, b filename2] & body]
  (letfn [(filename->reader [filename] 
            (-> filename io/resource io/file io/reader))]
  `(with-open [~a (~filename->reader ~filename1)]
     (with-open [~b (~filename->reader ~filename2)]
       ~@body))))

(double-open [x "idea1.txt", y "idea2.txt"]
  (str (first (line-seq x)) " | " (first (line-seq y))))

; the Ruby example uses the "readline" function, which returns one line and 
; essentially "keeps track" of where you are in the file/URL/whatever object so
; that a subsequent call to "readline" will return the next line. Clojure has a
; similar function called "read-line" that works on stream objects, however it's
; not idiomatic to the functional programming style that Clojure promotes. The
; "line-seq" function returns a lazy sequence of all lines in a reader object, so
; it's more idiomatic to perform sequence operations on a "line-seq." Because the
; sequence is lazy, it's no less performant than using "read-line" because you
; still aren't consuming the entire sequence at once unless you need to do so.

; ex. 10:
(ns ex.preeventualist
  (:require [clojure.java.io :as io]
            [clojure.string :as str])
  (:import (java.net URLEncoder)))

(defn open [page query]
  (let [qs
        (str/join "&" 
                  (map (fn [[k v]] (java.net.URLEncoder/encode (str k "=" v)))
                       query))
        address
        (str "http://preeventualist.org/lost/" page "?" qs)]
    (str/split (slurp address) #"--\n")))

(defn search [word] (open "search" {"q" word}))
(defn searchlost [word] (open "searchlost" {"q" word}))
(defn searchfound [word] (open "searchfound" {"q" word}))

(defn addfound [your-name item-lost found-at description]
  (open "addfound" {"name" your-name, "item" item-lost, 
                    "at" found-at, "desc" description}))

(defn addlost [your-name item-found last-seen description]
  (open "addlost" {"name" your-name, "item" item-found,
                   "seen" last-seen, "desc" description}))

; exs. 11-13:
; okay, and we've finally reached the infamous Dwemthy's Array!

; This is a great example of the strength of metaprogramming in Ruby. 
; _why concocts a Creature class that contains some sorcery that allows
; you to, when inheriting the class from another, more specific class 
; such as a Dragon class, utilize a more concise and fun format for 
; representing RPG-style attributes.

; Clojure also supports metaprogramming, but goes about it in a different
; way than Ruby does. In Clojure, you can utilize macros to essentially 
; create any kind of syntax you can imagine.

; this example is just the desired syntax, so we could do something like:

(defcreature Dragon
  life 1340
  strength 451
  charisma 1020
  weapon 939)

; of course, in _why's words, "This is not metaprogramming yet. Only the pill.
; The /product/ of metaprogramming." See the next example for the implementation...

; ex. 14:
(defmacro defcreature [name & attributes]
  (let [fields (mapv first (partition 2 attributes))
        values (map second (partition 2 attributes))
        record-name (symbol (str name "Record"))]

    `(do
       (defrecord ~record-name ~fields)
       (defn ~name [] (new ~record-name ~@values)))))

; ex. 15:
; (Ruby-specific example about attr_reader)

; ex. 16:
; come to think of it, our Clojure version of _why's Creature class
; is actually better in that it's more flexible! _why's class is set
; up such that every class that inherits from Creature has 4 traits:
; life, strength, charisma and weapon. Our defcreature macro lets you
; choose what attributes each creature has. If we wanted to, we could
; redefine our macro to only allow those 4 specific attributes, and
; that would even simplify our code a bit. This is a good example of
; the flexibility, power and (relative) simplicity of Clojure's macros.

; ex. 17:
; in this example, _why shows us what Ruby does "behind the scenes"
; with his Creature class. So, here is what our defcreature macro does
; behind the scenes when we call (defcreature Dragon ... etc.):

(do 
  (defrecord DragonRecord [life strength charisma weapon])
  (defn Dragon [] (new DragonRecord 1340 451 1020 939)))

; this template isn't exactly like that of _why's Creature class. 
; The main difference is that _why's Creature template defines all
; creature "subclasses" to have the same 4 traits -- life, strength,
; charisma and weapon. In contrast, our defcreature macro lets each
; creature have its own custom traits, making for more custom creature
; creation. This is certainly possible in Ruby, as well, but would 
; perhaps make for a more complicated example in this introduction to
; metaprogramming in Ruby.

; ex. 18:
; same as exs. 11-13

; ex. 19:
; Clojure has an "eval" method too, but it operates on a data structure
; instead of a string:

(def drgn (Dragon))
; is identical to...
(def drgn (eval '(Dragon)))
; or, alternatively...
(eval '(def drgn (Dragon)))

; ex. 20:
(print "What monster class have you come to battle? ")
(def monster-class (read-line))
(eval (read-string (format "(def monster (%s))" monster-class)))
(pr monster)

; ex. 20-1/2:
; irb example demonstrating instance_eval and class_eval in Ruby.
; Clojure has no equivalent to these methods, as there are no
; instances or classes in Clojure. In Ruby, instance_eval and
; class_eval are useful for adding functionality to instances and
; classes "on the fly," e.g. within an irb session, or perhaps 
; even conditionally within a program -- allowing you to do things
; like modify a character class in a certain way *if* a player 
; reaches a certain point or does a certain thing. As _why puts it,
; this "can be useful and ... can be dangerous as well."

; ex. 21:
; At this point, we could try to implement the "hit" and "fight" methods,
; in a functional style, as part of a "Battle" protocol that would be a
; part of the defrecord generated by our defcreature macro. However,
; records don't work too well with mutable state in Clojure, since a
; record is supposed to be an immutable representation of the state of
; an "object" at any given time.

; While it would certainly be possible to re-do Dwemthy's Array from
; scratch in a functional style, this would change the dynamic of the
; original game in Ruby. Dwemthy's Array is interesting in that _why
; designed it to be played in an "open" fashion from irb -- you could
; even call it a "metagame." The player is the programmer. You create
; an instance of a creature like the Rabbit, define a "Dwemthy's Array"
; of enemy creatures, and then have your creature make the first move
; on the Array, which starts a chain reaction of battling each creature
; of the Array in succession.

; So, to make a translation of this game in Clojure, we would want it 
; to be playable in a REPL environment. While it is possible to implement
; the necessary methods in a functional style, the object-oriented 
; nature of this kind of game makes it more convenient to implement 
; using mutable state via Clojure's reference types.

; Whereas the original Dwemthy's Array relies on monkey-patching (via
; method_missing to allow the Rabbit to attack the Array directly,
; to make things cleaner we are implementing this as an ordinary 
; function called "attack," which takes a challenger (e.g. the Rabbit),
; an attack function, and a Dwemthy's Array as arguments. It's a little
; more to type, but it makes for safer and tidier code. (You can chalk
; this one up as a victory for Ruby if you value aesthetics over safety!)

(defn creature-name [creature]
  (-> (str (type creature))
      (clojure.string/split #"\.")
      (last)))

(defn hit [^clojure.lang.Atom creature, damage]
  (let [p-up (rand-int (:charisma @creature))
        recovery (if (= 7 (rem p-up 9))
                   (/ p-up 4)
                   0)]
    (when (pos? recovery)
      (printf "[%s magick powers up %d!]\n" (creature-name @creature) recovery)
      (swap! creature update-in [:life] + recovery)))
  (swap! creature update-in [:life] - damage)
  (when (not (pos? (:life @creature)))
    (printf "[%s has died.]\n" (creature-name @creature))))

(defn fight [^clojure.lang.Atom creature, ^clojure.lang.Atom enemy, weapon]
  (if (not (pos? (:life @creature)))
    (printf "[%s is too dead to fight!]\n" (creature-name @creature))
    (do 
      (let [your-hit (rand-int (+ (:strength @creature) (:weapon @creature)))]
        (println "[You hit with" your-hit "points of damage!]")
        (hit enemy your-hit))
      (prn @enemy)
      (when (pos? (:life @enemy))
        (let [enemy-hit (rand-int (+ (:strength @enemy) (:weapon @enemy)))]
          (println "[Your enemy hit with" enemy-hit "points of damage!]")
          (hit creature enemy-hit))))))

(defn attack [^clojure.lang.Atom challenger, move, ^clojure.lang.Atom dwary]
  (if (pos? (:life @(first @dwary)))
    (move challenger (first @dwary))
    (do 
      (swap! dwary next)
      (if-not @dwary
        (println "[Whoa. You decimated Dwemthy's Array!]")
        (printf "[Get ready. %s has emerged.]\n" 
                (creature-name @(first @dwary)))))))

; ex. 22:
(defcreature Rabbit
  life 10
  strength 2
  charisma 44
  weapon 4
  bombs 3)

; can't redefine ^
; (Clojure needs it for metadata)
; using "v" instead for the boomerang

(defn v [rabbit enemy]
  "little boomerang"
  (fight rabbit enemy 13))

(def divide /)
(defmulti / (fn [& args] (some number? args)))
(defmethod / true [& args] (apply divide args))
(defmethod / nil [rabbit enemy]
  "the hero's sword is unlimited!!"
  (let [elm10 (rem (:life @enemy) 10)
        damage (rand-int (+ 4 (* elm10 elm10)))] 
    (fight rabbit enemy damage)))

(defn % [rabbit enemy]
  "lettuce will build your strength and extra ruffage
   will fly in the face of your opponent!!"
  (let [recovery (rand-int (:charisma @rabbit))]
    (println "[Healthy lettuce gives you" recovery "life points!!]")
    (swap! rabbit update-in [:life] + recovery)
    (fight rabbit enemy 0)))

(def multiply *)
(defmulti * (fn [& args] (some number? args)))
(defmethod * true [& args] (apply multiply args))
(defmethod * nil [rabbit enemy]
  "bombs, but you only have three!!"
  (if (zero? (:bombs @rabbit))
    (println "[UHN!! You're out of bombs!!]")
    (do 
      (swap! rabbit update-in [:bombs] - 1)
      (fight rabbit enemy 86))))

; ex. 22-1/2:
(def r (atom (Rabbit)))
(:life @r)
(:strength @r)

; ex. 23:
(defcreature ScubaArgentine
  life 46
  strength 35
  charisma 91
  weapon 2)

; ex. 23-1/2 (several irb snippets):
(def r (atom (Rabbit)))
(def s (atom (ScubaArgentine)))

(v r s)
(/ r s)
(% r s)
(* r s)

; Ruby example of overloading math operators to do useful 
; array functions... Clojure doesn't do this, but here are
; the equivalent functions for doing these things:

; "array + array"
(concat ["D" "W" "E"] ["M" "T" "H" "Y"])

; "array - array" (removes all instances of items from the
; 2nd array from the 1st array; order is flipped in Clojure)
(remove #(some (set %) [\W \T])
        ["D" "W" "E" "M" "T" "H" "Y"])

; "array * times" (repeats array "times" times)
(flatten (repeat 3 ["D" "W"]))

; ex. 24:
(defcreature IndustrialRaverMonkey
  life 46
  strength 35
  charisma 91
  weapon 2)

(defcreature DwarvenAngel
  life 540
  strength 6
  charisma 144
  weapon 50)

(defcreature AssistantViceTentacleAndOmbudsman
  life 320
  strength 6
  charisma 144
  weapon 50)

(defcreature TeethDeer
  life 655
  strength 192
  charisma 19
  weapon 109)

(defcreature IntrepidDecomposedCyclist
  life 901
  strength 560
  charisma 422
  weapon 105)

(defcreature Dragon
  life 1340 
  strength 451 
  charisma 1020
  weapon 939)
 
; ex. 25:
(def dwary
  (atom (mapv atom [(IndustrialRaverMonkey)
                    (DwarvenAngel)
                    (AssistantViceTentacleAndOmbudsman)
                    (TeethDeer)
                    (IntrepidDecomposedCyclist)
                    (Dragon)])))

; ex. 26 ("Start here"):
(attack r % dwary)

; ex. 27:
(loop []
  (print ">> ")
  (flush)
  (println "=>" (eval (read-string (read-line))))
  (recur))
  
{% endhighlight %}

How would you have done Dwemthy's Array differently? Comments welcome!
