---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 7"
category: null
tags: 
  - clojure
  - ruby
published: true

redirect_from: '/2014/11/23/whys-guide-to-ruby-in-clojure-part-7'
---

{% include JB/setup %}

*Parts 1 through 6 of this series can be found [here][part1], [here][part2], [here][part3], [here][part4], [here][part5] and [here][part6].*

[part1]: {% post_url 2014-01-06-whys-guide-to-ruby-in-clojure-part-1 %}
[part2]: {% post_url 2014-02-20-whys-guide-to-ruby-in-clojure-part-2 %}
[part3]: {% post_url 2014-03-05-whys-guide-to-ruby-in-clojure-part-3 %}
[part4]: {% post_url 2014-03-19-whys-guide-to-ruby-in-clojure-part-4 %}
[part5]: {% post_url 2014-07-09-whys-guide-to-ruby-in-clojure-part-5 %}
[part6]: {% post_url 2014-08-14-whys-guide-to-ruby-in-clojure-part-6 %}

Alright, so I kind of just remembered that there was still one chapter left to go -- so here it is! Until \_why decides to come out of hiding and write an 8th chapter (whenever that happens, if ever...), this will be the final installment of my translation of *\_why's (poignant) guide to ruby* into Clojure. 

This is kind of a weird chapter in that the whole thing is hand-drawn (by one of the foxes, presumably), making the actual code examples a little hard to find. I feel like I've hit all the important bits that would constitute "examples." This is kind of a short chapter in terms of code content, but it's a fun one nonetheless. We've got a very brief example of how you might build a text adventure game using classes and metaprogramming, a function that takes a string and turns it upside-down, an example of overloading an arithmetic operator to work on arrays, and an interesting encryption algorithm.

Chapter 7
=========

{% highlight clojure %}
; ex. 1:
(defprotocol Actions
  (look [room])
  (stab [room])
  (sleep [room]))

(defrecord BanquetRoom []
  Actions
    (look [_] "Red with mirrors")
    (stab [_] "The room screams!")
    (sleep [_] "Ahh, you slept on food"))

(print "Banquet Room. Do what?")
(let [what-to-do (clojure.string/trim (read-line))]
  (eval `(~(symbol what-to-do) (BanquetRoom.))))

; ex. 2:
(defn umop-apisdn [txt]
  (let [in "ahbmfnjpdrutwqye"
        out (reverse in)
        in-out (zipmap in out)]
    (apply str (reverse (map #(in-out % %) txt)))))

; ex. 3:
(def divide /)
(defmulti / (fn [arg1 arg2 & more] (and (coll? arg1) (number? arg2))))
(defmethod / false [& args] (apply divide args))
(defmethod / true [coll n] (partition n n nil coll))

(/ [:mad :bone :and :his :buried :head] 3)
(/ (range 1 11) 5)
{% endhighlight %}

I noticed in the "Decody" example that \_why made a small, but confusing mistake when commenting his code: In the lines of code referring to 2 letters on the same row, he commented "on the same column," and vice versa. I have corrected this for the sake of clarity (and to avoid confusing myself!).

{% highlight clojure %}
; ex. 4:
(defprotocol Encoding
  (locate [decody letter])
  (at [decody row col])
  (encode [decody txt]))

(defrecord DeCody [key]
  Encoding
    (locate [_ letter]
      (let [i (.indexOf key (str letter))]
        [(int (/ i 5)) (rem i 5)]))
    (at [_ row col]
      (get key (+ (* row 5) col)))
    (encode [decody txt]
      (let [pairs (->> (clojure.string/replace txt #"[^a-z]" "")
                       (#(clojure.string/replace % "j" "i"))
                       (partition 2 2 nil)
                       (mapcat (fn [[ltr1 ltr2]]
                                 (cond 
                                   (nil? ltr2) [[ltr1 \x]]
                                   (= ltr1 ltr2) (repeat 2 [ltr1 \q]) 
                                   :else [[ltr1 ltr2]]))))]
        (apply str 
               (mapcat (fn [pair]
                         (let [[l1 l2 :as ls] (map #(locate decody %) pair)]
                           (cond
                             (= (first l1) (first l2)) ; on the same row
                             (letfn [(move-right [[row col]]
                                       [row (rem (inc col) 5)])]
                               (map #(apply at decody (move-right %)) ls))

                             (= (last l1) (last l2)) ; on the same column
                             (letfn [(move-down [[row col]]
                                       [(rem (inc row) 5) col])]
                               (map #(apply at decody (move-down %)) ls))

                             :else ; normal swap
                             [(at decody (first l1) (last l2))
                              (at decody (first l2) (last l1))]))) 
                        pairs)))))

(defn decody [key]
  "Takes a string with arbitrary whitespace and removes all whitespace 
   and other non-letter characters, returning a DeCody instance with 
   the resulting string as a key (25 letters arranged in a 5x5 grid)."
  (DeCody. (clojure.string/replace key #"[^a-z]" "")))

(def dc (decody "k x z p w
                 i g t f a
                 h o s e n
                 y m b r c
                 u l q d v"))

; example usage:
(encode dc "message to be encoded")
{% endhighlight %}
