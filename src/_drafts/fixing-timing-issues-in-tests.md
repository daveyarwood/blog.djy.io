---
layout: post
title: "Fixing timing issues in tests"
tags:
  - tests
  - functional programming
published: true
---

{% include JB/setup %}

# The premise

Let's say you're writing some tests that describe the behavior of something
asynchronous. Imagine that you have a worker process that consumes messages from
a queue and uses them to update some state, and you want to test that when you
put a message on the queue, the worker ends up receiving the message and doing
what it's supposed to do.

Let's make this more concrete with an example scenario: the state that we're
updating is a running tally of votes for users' favorite ice cream flavors.

{% highlight kotlin %}
// e.g. {"butter pecan": 42, "cookie dough": 100}
val iceCreamVotes = mutableMapOf<String, Int>()
{% endhighlight %}

Our worker process consumes messages from a queue. Each message is simply a
string like `"maple walnut"`, representing a vote for an ice cream flavor.

{% highlight kotlin %}
val queue = LinkedBlockingQueue<String>()

// worker process
thread {
  while (true) {
    val flavor = queue.take()
    val currentCount = iceCreamVotes.getOrElse(flavor) { 0 }
    iceCreamVotes[flavor] = currentCount + 1
  }
}
{% endhighlight %}

# The problem

So now we want to test that, when a user votes for their favorite flavor, the
data shows that their vote was counted.

{% highlight kotlin %}
fun voteCountedForRockyRoad() : Boolean {
  queue.put("rocky road")
  val votesForRockyRoad = iceCreamVotes.getOrElse("rocky road") { 0 }
  return votesForRockyRoad > 0
}
{% endhighlight %}

The test above will probably fail! The problem is that the message we put on the
queue is processed off to the side in a separate thread (our worker process),
and we can't guarantee how long it's going to take before each vote is
reflected in the tally.

To better illustrate my point, let's imagine that the worker is a bit lazy and
it decides to take a little break before it tallies each vote.

{% highlight kotlin %}
// worker process
thread {
  while (true) {
    val flavor = queue.take()

    // Taking a quick catnap...
    Thread.sleep(500)

    val currentCount = iceCreamVotes.getOrElse(flavor) { 0 }
    iceCreamVotes[flavor] = currentCount + 1
  }
}
{% endhighlight %}

Now, our test case will almost _certainly_ fail. The issue is that we're putting
a message on the queue and then _immediately_ checking the tally for the flavor
in question. By the time we check the results, the worker is still napping!

# `sleep` considered harmful

Perhaps you've worked on codebases before with tests that have similar timing
issues. You've probably seen people write quick 'n dirty fixes for the failing
tests for the timing issues by sprinkling `sleep` statements on them.

{% highlight kotlin %}
fun voteCountedForRockyRoad() : Boolean {
  queue.put("rocky road")
  // Give the worker a little time to update the tally.
  Thread.sleep(5000)

  // Surely by now it's updated?
  val votesForRockyRoad = iceCreamVotes.getOrElse("rocky road") { 0 }
  return votesForRockyRoad > 0
}
{% endhighlight %}

This tends to get the tests passing in the short term, but it's not a very
reliable approach.  Even if we're seeing the tests pass most of the time right
_now_, we're bound to see them fail at some point, when we least expect it.
Maybe the worker will be especially lazy that day, and it will take longer than
our `sleep` accounted for.

It's also worth noting that in this simple example, we're storing our vote data
in memory, so reading and writing it is not going to contribute much to the
slowness of the worker.

But if this were more like a real world application, we would probably be
putting our votes into some kind of database instead. At that point, our tests
would be even _more_ susceptible to timing issues because we would also have to
contend with obstacles like network latency and database locks.

# If at first you don't succeed...

So, how do we make our tests more reliable?

Right now, we might be tempted to ask ourselves: "How long do we need to wait
before we check the results?" This amounts to trying to find the right magic
number of seconds to wait before we check. This is a delicate balancing act
between not waiting long enough (so tests fail when they shouldn't) and waiting
so long that it takes a painfully long time to finish running all of the tests.

Ideally, we would only have to wait until the result we're expecting has
arrived. So, a better question to ask is: "How do we wait for the result we're
expecting?"

There's a reliable and easy-to-implement solution to this problem: the **retry
loop**.

Here's how it works:

* We have a success condition in mind. (In this case, it's seeing at least one
  vote for Rocky Road in the tally.)

* We check whether the condition is met.

* If it is, then great! Our test passed.

* If it isn't, then we accept that there are timing issues and wait for a
  little bit, then check again.

* In the event that the success condition is never met (due to a bug, etc.), we
  wouldn't want our tests to run _forever_, so at a certain point (which we call
  the **timeout**), we can stop checking and conclude that the test has failed.

  A good timeout value is a length of time that it would be more than reasonable
  to wait before we expect that the result would have happened already.
  Depending on how fast you expect the result, this value could be somewhere
  between 5 seconds and a minute.

Here's how we might implement a retry loop for our Rocky Road test case:

{% highlight kotlin %}
fun voteCountedForRockyRoad() : Boolean {
  queue.put("rocky road")

  val intervalMs = 100 // Wait 100 ms between retries.
  val timeoutMs = 30000 // Taking more than 30 seconds is considered a failure.

  val deadline = System.currentTimeMillis() + timeoutMs

  while (System.currentTimeMillis() < deadline) {
    val votesForRockyRoad = iceCreamVotes.getOrElse("rocky road") { 0 }
    if (votesForRockyRoad > 0) {
      return true // success!
    }

    Thread.sleep(intervalMs)
  }

  // If we get this far, it's been more than 30 seconds and we still haven't
  // seen the result we're expecting, so fail.
  return false
}
{% endhighlight %}

Now the test case will pass or fail reliably, and it's better than just adding a
long `sleep` before we check the results, because we can consider the test to
have passed and move on as soon as we see the result that we're looking for.
Problem solved!

# Cleaning it up

This is sort of unsatisfying, though, because now the code in our test case is
longer and harder to understand at a glance. And there are a lot more ice cream
flavors that we might want to test voting for, so it would be nice if we could
refactor this a bit and make the retry logic reusable across all of the test
cases.

It is often useful to write helper functions that contain all of the retry
logic, so that your test cases can be nice and concise:

{% highlight kotlin %}
fun voteCountedForNeapolitan() : Boolean {
  queue.put("neapolitan")
  retryUntilTrue(100, 30000, {
    iceCreamVotes.getOrElse("neapolitan") { 0 } > 0
  })
}

fun voteCountedForRaspberryRipple() : Boolean {
  queue.put("raspberry ripple")
  retryUntilTrue(100, 30000, {
    iceCreamVotes.getOrElse("raspberry ripple") { 0 } > 0
  })
}

fun voteCountedForSeaSaltCaramel() : Boolean {
  queue.put("sea salt caramel")
  retryUntilTrue(100, 30000, {
    iceCreamVotes.getOrElse("sea salt caramel") { 0 } > 0
  })
}
{% endhighlight %}

The `retryUntilTrue` helper used above looks like this:

{% highlight kotlin %}
fun retryUntilTrue(
  intervalMs : Long, timeoutMs : Long, test : () -> Boolean
) : Boolean {
  val deadline = System.currentTimeMillis() + timeoutMs

  while (System.currentTimeMillis() < deadline) {
    if (test()) {
      return true
    }

    Thread.sleep(intervalMs)
  }

  return false
}
{% endhighlight %}

This technique relies on your language of choice supporting **first class
functions**; in this case, that means being able to pass a function in as an
argument to another function.

I ended up writing the code examples above in Kotlin because it's easy to read
and it happens to have a nice, clean syntax for representing the types of
function values. But you can write `retryUntilTrue` in any programming language
that supports functions as first class values; this includes Python, Ruby, Go,
JavaScript, and even Java (although it can be a bit verbose and painful to do
in Java!).

Hopefully this approach will be helpful the next time you find yourself dealing
with timing issues in tests. Good luck, and don't let time outsmart you!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME
