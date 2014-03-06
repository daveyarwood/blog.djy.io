---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 3"
category: 
tags: [clojure, ruby]
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

{% gist 9387659 %}

Hope you enjoyed this as much as I enjoyed translating it! Comment below if I missed anything or if you think you might have a better translation for any of these examples. The rest of Chapter 5 is coming soon -- get ready for the Animal Lottery!
