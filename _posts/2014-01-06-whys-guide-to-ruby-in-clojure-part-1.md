---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 1"
category: 
tags: [clojure, ruby]
---
{% include JB/setup %}

When I first started learning Ruby, [Why's (Poignant) Guide to Ruby][wpgtr] was a godsend. From an objective point of view, it's really not the most detailed or thorough language tutorial, but then again, I don't think that was really \_why's goal. I read somewhere that in writing the book, he was experimenting with a format that's a hybrid of a novel and a programming language tutorial. I think the result is fantastic, both as a tribute to the "magic"/"fun" aspect of Ruby, and as at least a supplemental reference in one's quest to learn Ruby. The interesting thing about W(P)GTR is that it's mostly absurdist novel, and probably only about 40% Ruby manual, but as a result, the reader really gets sucked into the novel parts, and treasures the programming bits when they come about. The story (in addition to other bizarre tangents that \_why launches into at times) provides a nice padding around the meaty Ruby examples, making them easier to digest and less tedious to explore (not that they're particularly tedious to begin with -- on the contrary, they're quite enjoyable and, for the most part, easy for even a beginner to understand).

There are only a handful of other languages that have entertaining/fun introductory guides like W(P)GTR -- [Learn You a Haskell][lyah] is a good example. For some reason Clojure doesn't have such a guide yet\*. It's definitely worthy of having such a guide written about it. I think Clojure is certainly a "magical" language, much like Ruby, and definitely a powerful one as well, although that is perhaps where the similarities to Ruby end. So out of curiosity, I had the idea to start translating the examples from Why's (Poignant) Guide to Ruby into Clojure for fun. And it was so much fun, I quickly ended up completing the project! Here is the first Chapter, for your perusal.

(This is actually Chapter 3; Chapters 1-2 of W(P)GTR do not contain any code excerpts)

\*By the way, I noticed that [Raynes][raynes] had the idea to create [a fun guide to Clojure][raynes-book] like this, and apparently even got a book deal for it, but sadly the book has yet to come to fruition. Fingers crossed that one day Clojure will have a (poignant) guide of its own!

[wpgtr]: http://mislav.uniqpath.com/poignant-guide/book
[lyah]: http://learnyouahaskell.com
[raynes]: http://blog.raynes.me
[raynes-book]: http://meetclj.raynes.me

Chapter 3
=========

*A general note: I have left out the necessary "(require 'clojure.whatever)" when utilizing libraries such as clojure.string and clojure.java.io, for the sake of avoiding repetition. In order to run such examples, you will need to first "require" the necessary libraries.*

*Another note: In many examples where the Ruby version "prints" or "puts's" the end result, I have the Clojure version simply return it, rather than using e.g. (prn x), (println x), etc. This is for the sake of simplicity. You could take any of these Clojure examples and easily print them (print ...), wrap them in a function (defn ...), or whatever else your heart may desire.*

{% gist 8641433 %}

Thoughts? Criticisms? Corrections?
