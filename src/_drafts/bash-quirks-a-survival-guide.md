---
layout: post
title: "Bash quirks: a survival guide"
tags:
  - bash
  - unix
published: true
---

{% include JB/setup %}

I have a love/hate relationship with Bash.

It's a quirky little language with many subtleties that make it easy to make
mistakes. It's not uncommon for programmers writing Bash scripts to discover
bugs in their scripts related to getting some obscure syntax wrong, using quotes
incorrectly, platform or shell compatibility issues, mishandling errors, etc.

On the other hand, Bash is ubiquitous, and it's a great "glue language" for
composing CLI commands together. The [Unix philosophy][unix-philosophy] is chock
full of good ideas that keep Bash scripts simple, easy to understand, and easy
to write (once you know your way around the quirks). Pipes are a brilliant
idea; you can use a single `|` character to pass the output of one command into
the next command as input, and loads of CLI utilities are written with the goal
of being a useful participant in these pipelines.

As great as these strengths of Bash are, the aforementioned quirks are
unfortunate and significant. My goal with this blog post is to get you better
acquainted with the weirdisms of Bash and show you how to either work with or
avoid them.

## Quirk 1: shebang lines

When you look at most shell scripts, you'll see a special line at the top that
tells your shell which program to use to run the script.

You'll sometimes see the shebang line point to `/bin/bash` (don't do this!):

{% highlight bash %}
#!/bin/bash

echo "Hello world!"
{% endhighlight %}

This works, but only if you happen to have Bash installed at `/bin/bash`.
Depending on the operating system and distribution of the person running your
script, that might not necessarily be true!

The better thing to do is to use `env`, a program that finds an
executable on the user's `PATH` (wherever that may be) and runs it. `env` is
basically _always_ reliably located in the `/usr/bin` folder, so we can assume
that `/usr/bin/env` is there for us to use.

{% highlight bash %}
#!/usr/bin/env bash

echo "Hello world!"
{% endhighlight %}

You can also use `env` to run other interpreters, such as Ruby:

{% highlight ruby %}
#!/usr/bin/env ruby

puts "Hello world!"
{% endhighlight %}

And Python:

{% highlight python %}
#!/usr/bin/env python

print("Hello world!")
{% endhighlight %}

After using `chmod` to mark a script like this as executable, you can run it
directly in your shell:

{% highlight text %}
$ chmod +x my-script.sh
$ ./my-script.sh
Hello world!
$ ./my-script.sh
Hello world!
$ ./my-script.sh
Hello world!
{% endhighlight %}

## Quirk 2: variable definition syntax

Unlike in most other programming languages, when you define a variable in Bash,
you _must not_ include spaces around the variable name.

{% highlight bash %}
# Error: "vegetable: command not found"
vegetable = "broccoli"

# OK
vegetable="broccoli"
{% endhighlight %}

## Quirk 3: quoting

I would guess that the majority of bugs in Bash scripts are related in some way
to quoting.

Inside of _double quotes_, a dollar sign (`$`) can be used to insert a variable
value into a string:

{% highlight bash %}
vegetable="broccoli"

# Prints: My favorite vegetable is broccoli
echo "My favorite vegetable is $vegetable"
{% endhighlight %}

If your intention is to use a literal dollar sign, you must remember to escape
it with a backslash:

{% highlight bash %}
# Prints: This broccoli costs .99
# (Whoops, Bash interpreted $1 as a variable!)
echo "This broccoli costs $1.99"

# Prints: This broccoli costs $1.99
echo "This broccoli costs \$1.99"
{% endhighlight %}

Or you can use _single quotes_, which don't expand variables:

{% highlight bash %}
# Prints: This broccoli costs $1.99
echo 'This broccoli costs $1.99'
{% endhighlight %}

## Quirk 4: unbound variables

You can trust most language runtimes to explode if you mistype the name of a
variable. For example, if you attempt to run this Ruby program:

{% highlight ruby %}
food = "broccoli"

puts "My favorite food is #{fodo}"
{% endhighlight %}

The Ruby interpreter helpfully returns a non-zero exit code to indicate failure,
and it is clear from the output what you did wrong:

{% highlight text %}
Traceback (most recent call last):
/tmp/food.rb:3:in `<main>': undefined local variable or method `fodo' for main:Object (NameError)
Did you mean?  food
{% endhighlight %}

However, in Bash, the default behavior is to treat every undefined variable as
if its value is an empty string. So if you run this Bash program:

{% highlight bash %}
food="broccoli"

echo "My favorite food is $fodo"
{% endhighlight %}

The Bash interpreter returns the exit code 0 (indicating success) and prints the
following:

{% highlight text %}
My favorite food is
{% endhighlight %}

This behavior is sort of annoying, because it makes it way too easy to write
Bash scripts that have subtle bugs where a variable that you thought had a value
turns out to be an empty string because you mistyped the variable name.

> On the other hand, there are actually occasions when it is _useful_ for Bash
> to treat undefined variables as empty strings, but I won't get into that here.

The good news is that there is an option (`set -u`) that you can enable to make
Bash behave more like other programming languages and throw an error if you
attempt to use a variable that hasn't been defined:

{% highlight bash %}
set -u

food="broccoli"

echo "My favorite food is $fodo"
{% endhighlight %}

Running the above Bash program results in an exit code of 1 (indicating failure)
and prints the following:

{% highlight text %}
/tmp/food.sh: line 5: fodo: unbound variable
{% endhighlight %}

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[unix-philosophy]: https://en.wikipedia.org/wiki/Unix_philosophy
