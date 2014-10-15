---
published: true
layout: post
title: A character utility library for Clojure
tags: [clojure]
---

{% include JB/setup %}

(Note: some of the supplementary Unicode characters on this page may not display
properly if you don't have CJK fonts installed.)

So, I've been kicking this idea around for a while, and I've finally decided to 
try my hand at writing a library of character- and Unicode-related utility 
functions for Clojure. I've noticed that for whatever reason, Clojure in its
current state happens to lack a character utility library. I'm sure this is at 
least partially due to how easy it is to just use Java inter-op to call methods 
from Java's Character class. For example:

{% highlight clojure %}
(Character/toUpperCase \ü)
;=> \Ü
{% endhighlight %}

But I have found Java's Character class to be a little unwieldy. For example,
this is the function I ended up writing in order to determine whether a given
character is a punctuation character according to the Unicode standard:

{% highlight clojure %}
(defn punctuation?
  [ch]
  (contains? #{Character/CONNECTOR_PUNCTUATION, Character/DASH_PUNCTUATION,
               Character/START_PUNCTUATION, Character/END_PUNCTUATION, 
               Character/INITIAL_QUOTE_PUNCTUATION, Character/FINAL_QUOTE_PUNCTUATION,
               Character/OTHER_PUNCTUATION}
             (Character/getType (code-point-of ch))))
{% endhighlight %}

Complicating matters is the inherent difficulty of working with supplementary
characters in Java. For those who might not be familiar: Java characters (which
are what Clojure character literals refer to) are 16-bit, which allows them to
store a code point with a value between 0 and 65,535 (inclusive). This is a huge
amount of characters, and most of the text you see anytime you use a computer,
especially in the Western world, consists of characters in this range, which is
called the [Basic Multilingual Plane][bmp-wiki]. This vast collection of 
characters encompasses almost all modern languages, including a ton of Chinese,
Japanese and Korean (CJK) characters, as well as a variety of other goodies.
With the expansion of available Unicode characters, at some point it became 
necessary for additional characters to be represented in 32 bits. Because Java
characters could only hold 16 bits, the solution was to represent these 
[supplementary characters][sc-wiki] as pairs of "surrogates": combining just the
right two surrogate characters in a string creates a particular character in one
of the Supplementary Planes, i.e. characters with Unicode code points between 
65,536 and 1,114,111 (inclusive). When your OS displays a string containing a
valid surrogate pair, you will see the corresponding supplementary character,
assuming that you have the appropriate font installed. 

[bmp-wiki]: http://en.wikipedia.org/wiki/Plane_%28Unicode%29#Basic_Multilingual_Plane
[sc-wiki]: http://en.wikipedia.org/wiki/UTF-16#Code_points_U.2B010000_to_U.2B10FFFF

Naturally, working with supplementary characters in Java (and by extension, 
Clojure) can get a little bit complicated. The methods in Java's Character class 
tend to accept either a character literal or a code point as an argument, 
allowing you to call some methods on supplementary characters by supplying their 
code points as integers. Clojure's facilities for dealing with characters are
essentially limited to methods dealing with Java character literals, i.e. only
characters in the Basic Multilingual Plane. The `char` function in `clojure.core`,
which returns the character at a given Unicode code point, will throw an 
exception if you give it any number greater than 65535:

{% highlight clojure %}
(char 20154) ; BMP character
;=> \人

(char 167122) ; supplementary character
;=> IllegalArgumentException Value out of range for char: 167122  clojure.lang.RT.charCast (RT.java:962)
{% endhighlight %}

One of my favorite functions that I came up with for this library is (name 
subject to change) `char'`, which is like `clojure.core/char`, except that it
knows what to do with supplementary characters:

{% highlight clojure %}
(require '[djy.char :as char])

user=> (char/char' 128570)
;=> "😺"
{% endhighlight %}

The inability of supplemental "characters" to be represented as individual
characters in Java and Clojure can potentially cause problems if you're working
with text that might contain supplementary characters. Let's say you have a 
string containing a supplementary character:

{% highlight clojure %}
"This character looks fun to write: 𣲷"
{% endhighlight %}

Using Clojure's `seq` function to represent this string as a sequence of 
characters yields this:

{% highlight clojure %}
(seq "This character looks fun to write: 𣲷")
;=> (\T \h \i \s \space \c \h \a \r \a \c \t \e \r \space \l \o \o \k \s \space \f \u \n \space \t \o \space \w \r \i \t \e \: \space \? \?)
{% endhighlight %}

Notice that our supplementary character becomes two surrogate characters 
(represented in my REPL as question marks; surrogate characters are technically
not really characters, just code points). Imagine that you want to inspect some 
text from a Chinese news article and get an accurate character count. For all 
you know, there could be some supplementary characters in there, and if that's
the case, then your character count will be inaccurate if all you're doing is 
evaluating the size of the string in characters. This inspired me to write a
function called `char-seq`, which behaves just like `seq`, but if it encounters
a supplementary character, it represents it as one string rather than two 
characters:

{% highlight clojure %}
(char/char-seq "This character looks fun to write: 𣲷")
;=> (\T \h \i \s \space \c \h \a \r \a \c \t \e \r \space \l \o \o \k \s \space \f \u \n \space \t \o \space \w \r \i \t \e \: \space "𣲷")
{% endhighlight %}

That's just a small taste of what I've been working on. I'm currently proposing
this to the Clojure development group either as a contrib library or as a part
of Clojure itself (i.e. a "clojure.char" namespace). There's a 
[discussion](https://groups.google.com/forum/#!topic/clojure-dev/CVT5nqCz9XI) 
going on the Clojure dev Google group, so feel free to join in the discussion
if you have any feedback or suggestions. The library, still a work in progress,
is available [here](http://github.com/daveyarwood/djy) on GitHub.