---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 2"
category: 
tags: [clojure, ruby]
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

{% gist 9127194 %}
