---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 2"
category: null
tags: 
  - clojure
  - ruby
published: true
---

{% include JB/setup %}

*Part 1 of this series can be found [here][part1].*

[part1]: {% post_url 2014-01-06-whys-guide-to-ruby-in-clojure-part-1 %}

In this chapter, we start to see more of \_why's use of Ruby code to do metaphysical things like catch stars and use them to construct star-monkeys. Of course, there is no earthly way to test this code, but I'm including these examples in order to demonstrate Clojure's syntax as it compares to Ruby's. 

As we get into these more involved examples, it becomes easier to see how Clojure stacks up against Ruby in terms of the simplicity and readibility of the code. Being a functional, Lisp-based language, Clojure tends to be more concise than Ruby in general. But on the other hand, Ruby has a lot of really neat jars of syntactical sugar that you can dip into to make your code more readable. For example, \_why uses Ruby's built-in `Dir` class to easily get an array of files matching `'idea-*.txt'`. The syntax is just `Dir['idea-*.txt']`. To translate this to Clojure without relying on any third party libraries, I had to resort to using Java inter-op, which ended up being a little wordier and just didn't have the same level of simplicity that Ruby's `Dir` class methods provide. (See ex. 24.) One wonders whether we might someday get some handy file/directory helper functions in a future version of Clojure. We already have `slurp` and `spit`, which make reading and writing to files dead simple, so it doesn't seem like that much of a stretch. In fact, there is already a `file-seq` function that returns a lazy sequence of files, but to use it, you have to feed it a Java path object using something like `(clojure.java.io/file "/path/to/directory")`. In my translation, I found it simpler to import `java.io.File` and use `(.listFiles "/path/to/directory")`.

By the way, props to driadan on Reddit for pointing out that [Clojure for the Brave and True](http://www.braveclojure.com) is a good example of a "fun book" on Clojure, somewhat analagous to what \_why's guide is to Ruby. I hadn't read it yet, but I just started this past week and it's definitely a fun read. 

Anyway, without further ado, here's...

Chapter 4
=========

{% highlight clojure %}
; ex. 1:
(def blue-crystal 1)
(def leaf-tender 5)
 
; ex. 2:
(catch-a-star pipe)
 
; ex. 3:
(def captive-star (catch-a-star pipe))
 
; ex. 4:
(def star-monkey (attach ratchet captive-monkey captive-star))
 
; ex. 5:
(def star-monkey 
  (hot-glue deco-hand-frog
            (attach ratchet captive-monkey (catch-a-star pipe))))
 
; ex. 6:
(def plastic-cup nil)
 
; ex. 7:
(if plastic-cup "Plastic cup is on the up 'n' up!")
 
; ex. 8:
(if-not plastic-cup "Plastic cup is on the down low.")
 
; ex. 9:
(if plastic-cup "Yeah, plastic cup is up again!")
(if-not plastic-cup "Hardly. It's down.")
 
; ex. 10:
(if (and plastic-cup (not glass-cup)) 
  "We're using plastic 'cause we don't have glass.")
 
; ex. 11:
(def approaching-guy true)
 
; ex. 12:
(if (= approaching-guy true) "That necklace is classic.")
 
; ex. 13:
(if (= approaching-guy false) "Get in here, you conniving devil.")
 
; ex. 14:
(= approaching-guy true)
 
; ex. 15:
(if (= nil true) "This will never see realization.")
 
; ex. 16:
(def at-hotel true)
(def email (if at-hotel "why@hotelambrose.com" "why@drnhowardcham.com"))
 
; ex. 17:
(def email (let [address "why"] (str address "@hotelambrose" ".com")))
 
; ex. 18:
(cond 
  (nil? at-hotel) "No clue if he's in the hotel."
  at-hotel        "Definitely in."
  (not at-hotel)  "He's out."
  :else           "The system is on the freee-itz.")
 
; ex. 19:
(print "Type and be diabolical: ")
(def idea-backwards (clojure.string/reverse (read-line)))
 
; ex. 20: 
(def idea-backwards (clojure.string/reverse (.toUpperCase (read-line))))
 
; ex. 21:
(def code-words
  {"starmonkeys" "Phil and Pete, those prickly chancellors of the New Reich",
   "catapult" "chucky go-go", "firebomb" "Heat-Assisted Living",
   "Nigeria" "Ny and Jerry's Dry Cleaning (with Donuts)",
   "Put the kabosh on" "Put the cable box on"})
 
; ex. 22:
(require '[clojure.string :as str])
(use 'clojure.java.io)
 
(print "Enter your new idea: ")
(def idea (read-line))
(def safe-idea
  (reduce (fn [txt [real code]] (str/replace txt real code)) idea code-words)
 
(print "File encoded.  Please enter a name for this idea: ")
(def idea-name (str/trim (read-line)))
(with-open [w (writer (str "idea-" idea-name ".txt"))]
  (.write w safe-idea))
 
; ex. 23:
(print "55,000 Starmonkey Salute!")
 
; ex. 24:
(require '[clojure.string :as str)
(import 'java.io.File)
 
(doseq [file (->> 
               (.listFiles ".")
               (filter #(re-matches #"idea-.+\.txt" (.getName %))))]
  (let [safe-idea (slurp (.getName file))]
    (println
      (reduce 
        (fn [txt [real code]] (str/replace txt code real)) 
        safe-idea
        code-words))))
 
; ex. 25/26:
(def kitty-toys
  [{:shape "sock", :fabric "cashmere"} {:shape "mouse", :fabric "calico"}
   {:shape "eggroll", :fabric "chenille"}])
 
(sort-by :fabric kitty-toys)
 
; ex. 27:
(doseq [toy (sort-by :shape kitty-toys)]
  (println "Blixy has a" (:shape toy) "made of" (:fabric toy)))
 
; non-printy version that collects the sentences into a seq:
(map #(str "Blixy has a " (:shape %) "made of " (:fabric %)) 
     (sort-by :shape kitty-toys))
 
; ex. 28:
(def non-eggroll (count (filter #(not= (:shape %) "eggroll") kitty-toys)))
 
; ex. 29:
(doseq [toy (take-while #(not= (:fabric %) "chenille") kitty-toys)]
  (prn toy))
{% endhighlight %}