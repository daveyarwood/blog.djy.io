---
layout: post
title: "4Clojure Problem #178"
category:
tags: [clojure]
---
{% include JB/setup %}

On a whim today, I decided to take on [4Clojure Problem #178][p178], which gives you as input a collection of 5 strings like `"HA"` (ace of hearts) or `"D2"` (2 of diamonds), representing a poker hand, and asks you to write a function that determines the best hand you could play with those cards (straight flush, full house, etc.)

I had already done [Problem #128][p128], which asks for a function that will take a string like `"HA"` or `"D2"` and return a map with the suit and rank (from 0-12, where 0-8 are 2-10, 9 is Jack, 10 is Queen, 11 is King and 12 is Ace), for example `{:suit :heart, :rank 12}` for the ace of hearts. So I simply reused my solution for that problem within a `let` binding.

I should note that this solution is presented here as a single function only because that's the way you have to write it in order for 4Clojure to test it. Otherwise, I probably would have written each part of the `let` binding as a `def` or `defn` at the top level. Nonetheless, I think this is a good example of how easy it is to write concise, readable code in Clojure. Enjoy!

[p178]: http://www.4clojure.com/problem/178
[p128]: http://www.4clojure.com/problem/128

{% gist 9967243 %}

I'd be curious to see your own solutions to this problem, either in Clojure or any other language!
