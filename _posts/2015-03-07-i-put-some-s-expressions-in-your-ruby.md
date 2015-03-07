---
layout: post
title: "I put some S-expressions in your Ruby"
category: null
tags: 
  - lisp
  - ruby
published: true
---

{% include JB/setup %}

I just rediscovered [Rubeque](http://www.rubeque.com), a set of short problems/koans to solve using Ruby, ranging in difficulty from ["What does true equal?"](http://www.rubeque.com/problems/the-truth) to [writing simple AIs](http://www.rubeque.com/problems/battleship) and [solving logic puzzles](http://www.rubeque.com/problems/architect-of-sixcity). The web UI provides an interactive code editor that you can use to write your solution in Ruby and see if the tests pass. 

I found [this problem](http://www.rubeque.com/problems/i-put-some-s-expressions-in-your-ruby/solutions) particularly interesting. The task is to write an [S-expression](http://en.wikipedia.org/wiki/S-expression) evaluator in Ruby. S-expressions are provided in the tests as nested arrays of symbols (`:the :ruby :kind`) and other values. The symbols represent functions, which is convenient because out of the box, Ruby gives you the ability to refer to and call functions by using their names as symbols. For example, `49.to_s` (i.e.calling the method `to_s` on the number `49`) can also be expressed like this: `49.send(:to_s)`. This means we can dynamically send any symbol (representing a function) to any value and it will be evaluated as a function call, which is basically all it takes to write an S-expression evaluator.

Another thing that's convenient about Ruby is that, like in Lisp, arithmetic operators like `+`, `-` and `*` are actually just functions. In Ruby's case, they happen to be instance methods of the Fixnum class. To prove this, you can open up `irb` and type in `75.+(25)`, which you'll see is equivalent to typing `75 + 25`. In Ruby, the `a + b` infix notation is actually syntactic sugar for calling the underlying Fixnum methods. The reason this is convenient is that we can pass and call arithmetic operations just like any other function. In `irb`, try typing `75.send(:+, 25)` and you'll see what I mean.

One difference between Ruby and Lisp, however, is that in Lisp, you can supply as many arguments as you want to the arithmetic functions, e.g. `(+ 1 1 1 1) => 4`. In Ruby, (presumably to be consistent with the infix notation), arithmetic operations are limited to 2 arguments -- OK, technically it's 1 number object receiving the arithmetic function with another number as a single argument. Thanks to monkey-patching, it's easy enough to Lispify Ruby's arithmetic functions by redefining them to take a variable number of arguments:

{% highlight ruby %}
class Fixnum
  alias_method :plus, :+
  def +(*others)
    ([self] + others).inject {|sum, x| sum.plus(x)}
  end

  alias_method :minus, :-
  def -(*others)
    ([self] + others).inject {|diff, x| diff.minus(x)}
  end
end
{% endhighlight %}

From here, implementing an S-expression evaluator is about as simple as separating out the functions from the arguments, and calling said functions with said arguments. We can write some guards to make sure the actual evaluating / passing-arguments-to-functions part only takes place if the head of the S-expression is some kind of function (represented in Ruby as a symbol or a proc). Otherwise, we assume that we're looking at some kind of value, or an array of things that each need to be evaluated recursively.

With this in mind, possible solutions can be delightfully terse:

{% highlight ruby %}
def sexp_eval(sexp)
  return sexp unless sexp.is_a? Array
  return sexp.map {|x| sexp_eval x} unless [Symbol, Proc].include? sexp.first.class
  fn, *args = *sexp
  args = sexp_eval args  
  fn.to_proc.call(*args)
end

# Rubeque's tests
sexp1 = [:flatten, [1, 2, [:to_a, (4..6)], [:-, 8, 4]]]
sexp2 = [:==, [:*, 2, 3], [:remainder, 13, 7]]
sexp3 = [(-> x, y {Math.sqrt(x**2 + y**2)}), [:-, 9, 3, 3], [:+, 1, 1, 1, 1]]

assert_equal sexp_eval(sexp1), [1, 2, 4, 5, 6, 4]
assert_equal sexp_eval(sexp2), true
assert_equal sexp_eval(sexp3), 5.0
{% endhighlight%}