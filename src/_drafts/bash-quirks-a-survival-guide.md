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

As great as these strengths of Bash are, the aforementioned quirks can be an
obstacle, standing between you and a working script. This blog post is a deep
dive into the weirdisms of Bash, and how you can either work with them or avoid
them.

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

## Quirk 3: single vs. double quotes

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
variable. That's what you _want_ to happen. For example, if you attempt to run
this Ruby program:

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

This behavior is sort of annoying, because it makes it way too easy for you to
write Bash scripts that have subtle bugs where a variable that you thought had a
value turns out to be an empty string because you mistyped the variable name.

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

## Quirk 5: stdout and stderr

Unlike functions in other languages, Bash functions don't really have concrete
return values. Instead, Bash implements an idea from the Unix philosophy that
the output of any program can be the input of another. The standard I/O is a
_data stream_, which, for practical purposes, we can think of as lines of text.

So, in Bash, a function, command or process does not really return a value; it
_prints something to standard out (stdout)_. Other functions or commands can
read that output and do other things with it, like print it out, capture it in a
file or variable, pipe it into some other process, etc.

For example, the `ls` command lists the names of files in a particular
directory. It prints each file name to stdout:

{% highlight text %}
$ ls ~/recipes
beef-and-broccoli.txt
broccoli-cheese-casserole.txt
eggplant-parmesan.txt
garlic-parmesan-roasted-broccoli.txt
taco-salad.txt
{% endhighlight %}

You can use `|` to pipe stdout into another process or command. The `grep`
command can be used to filter out any lines of text that don't contain a
particular string. So, you could find only recipes with "broccoli" in the file
name by piping the stdout of the `ls` command above into `grep`:

{% highlight text %}
$ ls ~/recipes | grep broccoli
beef-and-broccoli.txt
broccoli-cheese-casserole.txt
garlic-parmesan-roasted-broccoli.txt
{% endhighlight %}

There is another standard data stream called _standard error (stderr)_ that,
despite the name, is not necessarily just for error messages (although that is
one way you can use it). stderr is a stream where you can print user-facing
messages without them accidentally being interpreted as _output data_ that gets
read by the next process in the pipeline.

The syntax for "redirecting" some output to stderr is `>&2`. `>` means "pipe
stdout into" whatever is on the right, which could be a file, etc., and `&2` is
a reference to "file descriptor #2" which is stderr.

To better illustrate the difference between stdout and stderr, here is a code
example with a function that prints a message to stderr for informational
purposes (to tell the user that some work is happening), and then, after the
work is done (simulated by a 2 second pause), the output data is printed to
stdout.

Then, we call our function and capture its output into a variable. When we print
the variable's value at the end, we can see that the value is only the stdout
from the function, and not the stderr (which was only printed for informational
purposes).

{% highlight bash %}
the_best_dinosaur() {
  echo "Thinking..." >&2
  sleep 2
  echo "stegosaurus"
}

# Runs `the_best_dinosaur` function, storing its output in the variable `dino`.
dino="$(the_best_dinosaur)"

echo "The best dinosaur is $dino."
{% endhighlight %}

When you run this program, it prints:

{% highlight text %}
Thinking...
The best dinosaur is stegosaurus.
{% endhighlight %}

If we had printed _everything_ to stdout, including the "Thinking..." message,
the output would have looked like this, which isn't quite what we want:

{% highlight text %}
The best dinosaur is Thinking...
stegosaurus.
{% endhighlight %}

The same idea applies to working at the command line. Imagine if the function
above were a standalone script:

{% highlight text %}
$ ./the_best_dinosaur.sh
Thinking...
stegosaurus
{% endhighlight %}

We've kept the same implementation, so the `Thinking...` message is printed to
`stderr` and the output `stegosaurus` is printed to stdout.

Because our script does a good job of separating output from "human-oriented"
messages, we can capture the output in a variable without getting the messages
all mixed up in the output:

{% highlight text %}
$ dino="$(./the_best_dinosaur.sh)"
Thinking...
$ echo "The best dinosaur is $dino."
The best dinosaur is stegosaurus.
{% endhighlight %}

Notice how, when we ran `dino="$(./the_best_dinosaur.sh)"` to capture the
script's output in the variable `dino`, the stdout (`stegosaurus`) was hidden
from us because it was redirected into the variable. However, we still saw the
message on stderr (`Thinking...`) in the terminal, because that part _wasn't_
redirected. That's good! We want that output in the terminal, because the whole
point of stderr is to print messages to the terminal, where the person running
the script can see them. Meanwhile, the stdout can be redirected into important
places like variables, pipelines and other processes.

## Quirk 6: `>` vs. `>>`

Bash makes it unprecedentedly easy to write to files. Any time something is
being printed to stdout, you can just slap a `>` on the end with a file name to
the right of it, and the output data is written into the file.

{% highlight text %}
$ date
Thu 01 Jul 2021 10:27:14 AM EDT
$ date > /tmp/current-date-and-time.txt
{% endhighlight %}

When we use `cat` to print the contents of the file, we can see that the output
of the `date` command was written to the file:

{% highlight text %}
$ cat /tmp/current-date-and-time.txt
Thu 01 Jul 2021 10:27:24 AM EDT
{% endhighlight %}

Let's say that we wanted to write several entries into the same file. Can we use
`>` for that? Let's see:

{% highlight text %}
$ date > /tmp/current-date-and-time.txt
$ date > /tmp/current-date-and-time.txt
$ date > /tmp/current-date-and-time.txt
$ cat /tmp/current-date-and-time.txt
Thu 01 Jul 2021 10:30:57 AM EDT
{% endhighlight %}

Nope! The thing is, `>` will _overwrite_ the current contents of the file, if
the file already exists.

If you want to _append_ lines instead, use `>>`:

{% highlight text %}
$ date >> /tmp/current-date-and-time.txt
$ date >> /tmp/current-date-and-time.txt
$ date >> /tmp/current-date-and-time.txt
$ cat /tmp/current-date-and-time.txt
Thu 01 Jul 2021 10:30:57 AM EDT
Thu 01 Jul 2021 10:32:43 AM EDT
Thu 01 Jul 2021 10:32:46 AM EDT
Thu 01 Jul 2021 10:32:48 AM EDT
{% endhighlight %}

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[unix-philosophy]: https://en.wikipedia.org/wiki/Unix_philosophy
