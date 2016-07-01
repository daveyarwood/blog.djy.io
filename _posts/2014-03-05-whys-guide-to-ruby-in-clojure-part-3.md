---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 3"
category: null
tags:
  - clojure
  - ruby
published: true

redirect_from: '/2014/03/05/whys-guide-to-ruby-in-clojure-part-3/'
---

{% include JB/setup %}

*Parts 1 and 2 of this series can be found [here][part1] and [here][part2].*

[part1]: {% post_url 2014-01-06-whys-guide-to-ruby-in-clojure-part-1 %}
[part2]: {% post_url 2014-02-20-whys-guide-to-ruby-in-clojure-part-2 %}

Okay, is it me, or is Chapter 5 absurdly long compared to the other chapters in this book!? Holy moley. I'm going to have to split this one up into a couple of blog entries. This entry will cover roughly half of Chapter 5.

Things start getting super fun in this chapter. I think I may have had even more fun translating these examples than I did reading/exploring them back when I was learning Ruby for the first time. These examples continue to highlight some interesting differences between Ruby and Clojure. For one thing, Ruby has the advantage when it comes to convenient "case statement" syntax. Clojure does have a `case` function that matches based on the identity of a given object, but Ruby's `case` statements are more flexible in that they allow matching based on whether a number falls within a given range. We could mirror that syntax in Clojure fairly easily by using a macro, but it's easy enough to just use a `cond` statement instead, like I did below.

I chose to use Clojure records and protocols as I translated the WishMaker and MindReader examples, however a true Clojurian might prefer to use ordinary functions rather than complicate things with records and protocols. For the purposes of this translation exercise, though, I thought it would be interesting to use records and protocols in order to show how they can duplicate some of the functionality of Ruby's classes. By the way, "endertromb.core" is an imaginary library analogous to \_why's imaginary Endertromb module. As with some of the examples in the last chapter, the "Endertromb" examples here are more an illustration of syntax than anything.


Chapter 5 (Sections 1-3)
========================

{% highlight clojure %}
; ex. 1:
(defn dr-chams-timeline [year]
  (cond
    (= year 1894)
    "Born."
    (<= 1895 year 1913)
    "Childhood in Louisville, Winston Co., Mississippi."
    (<= 1914 year 1919)
    "Worked at a pecan nursery; punched a Quaker."
    (<= 1920 year 1928)
    (str "Sailed in the Brotherhood of River Wisdomming, which journeyed the Mississippi "
         "River and engaged in thoughtful self-improvement, where he finished 140 credit "
         "hours from their Oarniversity.")
    (= year 1929)
    "Returned to Louisville to pen a novel about time-travelling pheasant hunters."
    (<= 1930 year 1933)
    (str "Took up a respectable career insuring pecan nurseries. Financially stable, he "
         "spent time in Brazil and New Mexico, buying up rare paper-shell pecan trees. "
         "Just as his notoriety came to a crescendo: gosh, he tried to bury himself "
         "alive.")
    (= year 1934)
    (str "Went back to writing his novel. Changed the hunters to insurance tycoons and "
         "the pheasants to Quakers.")
    (<= 1935 year 1940)
    (str "Took Arthur Cone, the Headmaster of the Brotherhood of River Wisdomming, as a "
         "houseguest. Together for five years, engineering and inventing.")
    (= year 1941)
    "And this is where things got interesting."))

; ex. 2:
(dr-chams-timeline 1941)

; ex. 3:
(cond
  (= year 1894) "Born."
  (<= 1895 year 1913) "Childhood in Louisville, Winston-Co., Mississippi."
  :else "No information about this year.")

; ex. 4:
(if (= 1894 year)
  "Born."
  (if (<= 1895 year 1913)
    "Childhood in Louisville, Winston Co., Mississippi."
    "No information about this year."))

; ex. 5:
(def opus-magnum true)
(defn save-hannah [] (let [success opus-magnum] nil))
; this doesn't really make sense, but then, the original Ruby example was just to
; demonstrate the lack of closures in Ruby

; ex. 6:
(def verb "rescued")
(doseq [verb ["sedated" "sprinkled" "electrocuted"]]
  (println "Dr. Cham" verb "his niece Hannah."))
(println "Finally, Dr. Cham" verb "his niece Hannah.")

; ex. 7:
(doseq [verb ["sedated" "sprinkled" "electrocuted"]]
  (println "Dr. Cham" verb "his niece Hannah."))
(println "Finally, Dr. Cham" verb "his niece Hannah.")
; results in an error, just like the Ruby example

; ex. 8:
(require '[endertromb.core :as endertromb])

(defprotocol WishMaking
  (grant [wm wish] "Grants a wish."))

(defrecord WishMaker [energy]
  WishMaking
    (grant [_ wish]
      (cond
        (or
          (> (count wish) 10)
          (re-find #" " wish))
        (throw (IllegalArgumentException. "Bad wish."))

        (zero? energy)
        (throw (Exception. "No energy left."))

        :else
        (do
          (endertromb/make wish)
          (WishMaker. (dec energy))))))

; ex. 9:
(def todays-wishes (WishMaker. (rand-int 6)))

; ex. 10:
(def todays-wishes (WishMaker. (rand-int 6)))
(grant todays-wishes "antlers")

; ex. 11:
(def number 5)
(print (inc number))

(def phrase "wishing for antlers")
(print (count phrase))

(def today-wishes (WishMaker. (rand-int 6)))
(grant todays-wishes "antlers")

; ex. 12:
(print (type 5))
(print (type "wishing for antlers"))
(print (type (WishMaker. (rand-int 6))))

; ex. 13:
(require '[endertromb.core :as endertromb])

(defprotocol MindReading
  (read [mr] "Reads minds."))

(defrecord MindReader [minds]
  MindReading
    (read [_] (map endertromb/read minds)))

; Ruby initialize method pulled out into the object instantiation:
(MindReader. (endertromb/scan-for-sentience))

; skipping all the irb stuff... (it's not relevant to Clojure)

; ex. 14:
(defprotocal Elevation
  (maintenance-password [this] "Maintenance password.")
  (authenticate [this password] "Checks password before operating."))

(defrecord Elevator [password]
  Elevation
    (maintenance-password [_] "stairs_are_history!")
    (authenticate [_ password]
      (when-not (= password maintenance-password)
        (throw (Exception. "bad password")))))

; Other Elevator methods would call (authenticate [_ password]) before executing
; their functions. If the password checks out, it returns nil and the rest of the
; method will happily execute. Otherwise, an exception is thrown.

; ex. 15:
(defn wipe-mutterings-from [sentence]
  (clojure.string/replace sentence #"\([^)]*\)" ""))

; ex. 16:
(def what-he-said
  (str "But, strangely (em-pithy-dah), I learned upon, played upon (pon-shoo) "
       "the organs on my home (oth-rea) planet."))

(wipe-mutterings-from what-he-said)

; ex. 17:
(defn wipe-mutterings-from [sentence]
  (when-not (string? sentence)
    (throw (IllegalArgumentException.
             (str "cannot wipe mutterings from a " (type sentence)))))
  (clojure.string/replace sentence #"\([^)]*\)" ""))

; ex. 18:
(def something-said "A (gith) spaceship.")
(wipe-mutterings-from something-said)

; ex. 19:
; (the "sentence = sentence.dup" example)
; there is no need to do this in Clojure, thanks to functional programming!

; ex. 20:
; (ditto)

; ex. 21:
(def s "A string is a long shelf of letters and spaces.")
(subs s 0 1)  ; A
(subs s 0)    ; A string is a long shelf of letters and spaces.
(apply str (drop 1 (drop-last 1 s)))   ; (drops first and last character)
(subs s 0 3)  ; A s
(re-find #"shelf" s)  ; shelf

; ex. 22:
; (same as ex. 17)

; ex. 23:
(def muddy-stick "Here's a ( curve.")
(wipe-mutterings-from muddy-stick)

; not a problem for our functional implementation using clojure.string/replace!

; ex. 24:
; Bingo! Here, _why uses gsub/regexp to improve this method. This is practically the
; same thing as our clojure.string/replace solution; _why just used a slightly
; different regexp, \([-\w]+\) than I did. Mine's better, though ;)

; ex. 25:
; Clojure doesn't encourage monkey-patching, but implementing this is still trivial
; and quite readable using ordinary functions:

(defn name-significance [name]
  (let [legend
        {"Paij" "Personal", "Gonk" "Business",
          "Blon" "Slave", "Stro" "Master",
          "Wert" "Father", "Onnn" "Mother",
          "ree" "AM", "plo" "PM"}
        syllables (clojure.string/split name #"-")]
    (clojure.string/join " " (map legend syllables))))

; BTW, you could technically "monkey-patch" the String type to add a
; "name-significance" method, extended from a protocol you create via Clojure's
; "extend-type" function, but the usage would be exactly the same:
; (name-significance "name"). So in this case, there isn't much point to using
; anything more complicated than an ordinary function.

; ex. 26:
(name-significance "Paij-ree")

; ex. 27:
; rather than monkey-patching, you could just do this:
(defn dash-split [s] (clojure.string/split s #"-"))

; if polymorphism is needed, you can use multimethods

; ex. 28:
(dash-split "Gonk-plo")

; ex. 29:
; (class String; def dash_split; split('-'); end; end)
; The equivalent to this in Clojure would involve using extend-type on Java's String
; class. It's not really necessary, though :)

; ex. 30:
; the equivalent part of our name-significance method is:
(map legend syllables)

; ex. 31:
(def cats-and-tips (map #(+ % (* % 0.20)) [0.12 0.63 0.09]))
{% endhighlight %}

Hope you enjoyed this as much as I enjoyed translating it! Comment below if I missed anything or if you think you might have a better translation for any of these examples. The rest of Chapter 5 is coming soon -- get ready for the Animal Lottery!
