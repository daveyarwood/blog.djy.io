---
layout: post
title: "_why's (Poignant) Guide to Ruby in Clojure: Part 6"
category: null
tags: 
  - clojure
  - ruby
published: true

redirect_from: '/2014/08/14/whys-guide-to-ruby-in-clojure-part-6'
---

{% include JB/setup %}

*Parts 1 through 5 of this series can be found [here][part1], [here][part2], [here][part3], [here][part4] and [here][part5].*

[part1]: {% post_url 2014-01-06-whys-guide-to-ruby-in-clojure-part-1 %}
[part2]: {% post_url 2014-02-20-whys-guide-to-ruby-in-clojure-part-2 %}
[part3]: {% post_url 2014-03-05-whys-guide-to-ruby-in-clojure-part-3 %}
[part4]: {% post_url 2014-03-19-whys-guide-to-ruby-in-clojure-part-4 %}
[part5]: {% post_url 2014-07-09-whys-guide-to-ruby-in-clojure-part-5 %}

OK, to be honest I almost forgot that I was doing this! We're in the home stretch now. It's a little hard to follow the fascinating [Dwemthy's Array][part5], but the rest of Chapter 6 is pretty interesting in its own right. Here \_why shows us `method_missing` (something rightfully missing in Clojure), string interpolation, and an interesting little bit about `eval` in example #30.

Chapter 6 (Sections 4-5)
========================

It's probably possible to assemble something like `method_missing` in Clojure, but it would be considered dangerous and not very practical. `method_missing` in Ruby is something you define for a particular class, giving that class some instructions for how to handle calls to methods it doesn't have. The closest analog Clojure has to classes would be records and protocols, but protocols require you to explicitly declare any methods they provide.

From a practical standpoint, you probably won't ever run into a situation, programming in Clojure, where you would need the type of functionality that `method_missing` provides. But for the sake of translating this example, a multimethod with a default implementation would be kind of similar in spirit, in that you can define custom behavior for when a particular method hasn't been implemented:

{% highlight clojure %}
; ex. 28:
(defmulti call (fn [method & args] method))
 
(defmethod call :default [method & args]
  (printf "You're calling '%s' and you say:\n" (name method))
  (doseq [arg args] (println " " arg))
  (println "But no one is there yet."))
 
(defmethod call :deirdre [_ & args]
  (println "Deirdre is right here and you say:")
  (doseq [arg args] (println " " arg))
  (println "And she loves every second of it.")
  (println "(I think she thinks you're poetic.)"))
 
(call :deirdre "Deirdre!")
(call :simon "Hello?" "Hello? Simon?")
{% endhighlight %}

The key difference between something like the above and Ruby's `method_missing` is that the code above constrains the "default method" behavior to when the multimethod `call` is, well, called. By contrast, `method_missing` is a more generalized operation that changes the behavior of an entire class... this can quickly lead to unpredictable and unsafe code.

For any interested parties, here's some [food for thought][so-mm] about `method_missing` and Clojure.

[so-mm]: http://stackoverflow.com/questions/7295016/clojure-method-missing

Interestingly, Eduardo Julián has come up with [Jormungandr][jorm], a library that provides a prototype-based object oriented functionality to Clojure. In researching how one might implement `method_missing` in Clojure, I stumbled upon [this conversation][grokbase] in which Eduardo introduced his library and [Mikera][mikera] proposed making some modifications and implementing the ability to add a custom method to each object that would execute when the object is passed a method it doesn't have... sound familiar?

[jorm]: https://github.com/eduardoejp/jormungandr
[mikera]: https://github.com/mikera
[grokbase]: http://grokbase.com/t/gg/clojure/132ajp0f6a/jormungandr-prototype-based-oo-on-top-of-functions

{% highlight clojure %}
; ex. 29:
; excerpt of method_missing code in Ruby

; ex. 29-1/2 (irb snippets)
(format "Seats are taken by %s and %s." "a frog" "a frog with teeth")

(def frogs [44 162.30])
(def stats "Frogs have filled %d seats and paid %.2f blue crystals.")
(apply (partial format stats) frogs)

(format "Please move over, %s." "toothless frog")
(format "Here is your 1098 statement for the year, %s." "teeth frog")
(format "Frogs are piled %d deep and travel at %d mph." 5 56)
(format "This bus has %1$d more stops before %2$d o'clock.
         That's %1$d more stops." 16 8)
(format "In the back of the bus: %30s." "frogs")
(format "At the front of the bus: %-30s." "frogs")
{% endhighlight %}

String interpolation doesn't come baked into Clojure, although [some Clojurians][strint-1] have come up with [libraries][strint-2] that will do it in a way more like Ruby's `"#{syntax}."` Personally, I don't think this is too unwieldy:

[strint-1]: http://cemerick.com/2009/12/04/string-interpolation-in-clojure
[strint-2]: http://clojure.github.io/core.incubator/clojure.core.strint-api.html

{% highlight clojure %}
(def cat "Blix")
(str "Does " cat " see what's up?  Is " cat " aware??")
{% endhighlight %}

It's about the same amount of typing as `#{this syntax}`.

{% highlight clojure %}
(def fellows ["Blix" "Fox Tall" "Fox Small"])
(str "Let us follow "
     (clojure.string/join " and " fellows)
     " on their journey.")

(def blix-went :north)

(str "Blix didn't speak, he ducked off to the " (name blix-went) " through "
     (case blix-went
       :north "a poorly laid avenue behind the paint store"
       :south "the circuitry of apartment buildings"
       "... well, who knows where he went")
     ". But before we follow them...")
{% endhighlight %}

The "bats!" example features a demonstration of Ruby's `%(long string here)` syntax, which functions exactly like a double-quoted string. There is no equivalent in Clojure, but that isn't really a big deal. You can always just use quotes, even if your string spans multiple lines:

{% highlight clojure %}
; ex. 30:
(def m "bats!")
(eval (read-string (str
  "(defn " m " []
     (apply str (take 100 (repeat \"{\"))))")))
{% endhighlight %}

Notice that you still have to escape double-quotes within the string, in contrast to Ruby's `%( )` syntax... of course, `eval` also works differently in Clojure, so it's a moot point. Observe!

{% highlight clojure %}
(def m "bats!")
(eval
  `(defn ~(symbol m) []
     (apply str (take 100 (repeat "{")))))

; ex. 31:
(loop []
  (print "Enter your password: ")
  (flush)
  (let [password (read-line)]
    (when-not (re-find #"^\w{8,15}$" password)
      (println "** Bad password! Must be 8 to 15 characters!")
      (recur))))
{% endhighlight %}

This might be a little nitpicky, but I noticed that \_why's use of the `PreEventualist.searchfound` function here is not entirely consistent with what the function actually does. The way it's being used here, it's supposed to search the `PreEventualist` database and return the contents of the page as one long, multi-line string. However, when we defined this function back in ex. 10, it actually did a little more than that. Not only does it grab the content of the query results page, it also splits it into an array of individual results! So that will save us a little work for this example. Now all we have to do is filter out the results that don't contain "truck."

{% highlight clojure %}
; ex. 32:
(require 'ex.preeventualist :as pe)

(filter #(re-find #"truck" %) (pe/searchfound "truck"))

; ex. 33:
(filter #(re-find #"[Tt][Rr][Uu][Cc][Kk]" %) (pe/searchfound "truck"))

; ex. 34:
(filter #(re-find #"(?i)truck" %) (pe/searchfound "truck"))

; ex. 35:
(filter #(re-find #"T-\d000" %) (pe/search/found "truck"))

; ex. 35-1/2 (irb snippets):
(re-find #"\d{3}-\d{3}-\d{4}" "Call 909-375-4434")
(re-find #"\(\d{3}\)\s*\d{3}-\d{4}" "The number is (909) 375-4434")

(def song "I swiped your cat / And I stole your cathodes")
(clojure.string/replace song "cat" "banjo")
(clojure.string/replace song #"\bcat\b" "banjo")
{% endhighlight %}

The next chapter should be fun... can't wait!
