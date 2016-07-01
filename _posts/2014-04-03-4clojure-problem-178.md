---
layout: post
title: "4Clojure Problem #178"
category:
tags: [clojure]

redirect_from: '/2014/04/03/4clojure-problem-178/'
---
{% include JB/setup %}

On a whim today, I decided to take on [4Clojure Problem #178][p178], which gives you as input a collection of 5 strings like `"HA"` (ace of hearts) or `"D2"` (2 of diamonds), representing a poker hand, and asks you to write a function that determines the best hand you could play with those cards (straight flush, full house, etc.)

I had already done [Problem #128][p128], which asks for a function that will take a string like `"HA"` or `"D2"` and return a map with the suit and rank (from 0-12, where 0-8 are 2-10, 9 is Jack, 10 is Queen, 11 is King and 12 is Ace), for example `{:suit :heart, :rank 12}` for the ace of hearts. So I simply reused my solution for that problem within a `let` binding.

I should note that this solution is presented here as a single function only because that's the way you have to write it in order for 4Clojure to test it. Otherwise, I probably would have written each part of the `let` binding as a `def` or `defn` at the top level. Nonetheless, I think this is a good example of how easy it is to write concise, readable code in Clojure. Enjoy!

[p178]: http://www.4clojure.com/problem/178
[p128]: http://www.4clojure.com/problem/128

{% highlight clojure %}

(fn best-hand [card-strings]
  (let [card-parser (fn [[s r]]
                      (let [suit ({\S :spade, \H :heart, 
                                   \D :diamond, \C :club} s)
                            rank (if (> (Character/digit r 10) -1)
                                   (- (Character/digit r 10) 2)
                                   ({\T 8, \J 9, 
                                     \Q 10, \K 11, \A 12} r))]
                        {:suit suit, :rank rank}))
        cards (map card-parser card-strings)
        suits (map :suit cards)
        ranks (map :rank cards)
 
        flush? 
        (if (= 1 (count (set suits))) :flush nil)
 
        straight? 
        (let [aces-high (sort ranks)
              aces-low (sort (replace {12 -1} ranks))]
               (if (or
                     (= aces-high (take 5 (iterate inc (first aces-high))))
                     (= aces-low  (take 5 (iterate inc (first aces-low)))))
                 :straight
                 nil))
 
        straight-flush?
        (if (and flush? straight?) :straight-flush nil)
 
        pair? 
        (if (some (fn [[r num]] (>= num 2)) (frequencies ranks)) 
          :pair 
          nil)
 
        three-of-a-kind?
        (if (some (fn [[r num]] (>= num 3)) (frequencies ranks)) 
          :three-of-a-kind
          nil)
 
        four-of-a-kind?
        (if (some (fn [[r num]] (= num 4)) (frequencies ranks))
          :four-of-a-kind
          nil)
 
        two-pair?
        (if (or 
              (some (fn [[r num]] (>= num 4)) (frequencies ranks))
              (= 2 (count (filter (fn [[r num]] (>= num 2)) 
                                  (frequencies ranks)))))
          :two-pair
          nil)
 
        full-house?
        (if (and
              (some (fn [[r num]] (= num 3)) (frequencies ranks))
              (some (fn [[r num]] (= num 2)) (frequencies ranks)))
          :full-house
          nil)
 
        possible-hands 
        (remove nil? [straight-flush? four-of-a-kind? full-house? flush?
                      straight? three-of-a-kind? two-pair? pair?])]
    (if-not (empty? possible-hands)
      (first possible-hands)
      :high-card)))

{% endhighlight %}

I'd be curious to see your own solutions to this problem, either in Clojure or any other language!
