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
vegetable = 'broccoli'

# OK
vegetable='broccoli'
{% endhighlight %}

## Quirk 3: quoting

I would guess that the majority of bugs in Bash scripts are related in some way
to quoting.

Inside of _double quotes_, the dollar sign (`$`) can be used to insert variable
values into the string:

{% highlight bash %}
vegetable='broccoli'

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

$todo

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[unix-philosophy]: https://en.wikipedia.org/wiki/Unix_philosophy
