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

{% gist 9656455 %}
