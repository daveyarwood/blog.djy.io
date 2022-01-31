---
layout: post
title: "10 Bash quirks and how to live with them"
tags:
  - bash
  - unix
published: true
---

{% include JB/setup %}

I have a love/hate relationship with Bash.

It's a quirky little language with many subtleties that make it all too easy to
make mistakes. It's not uncommon for programmers writing Bash scripts to
discover bugs in their scripts related to a variety of things, including getting
some obscure syntax wrong, using quotes incorrectly, platform or shell
compatibility issues, and mishandling errors.

On the other hand, Bash is ubiquitous, and it's a great "glue language" for
composing CLI commands together. The [Unix philosophy][unix-philosophy] is chock
full of good ideas that keep Bash scripts simple, easy to understand, and easy
to write (once you know your way around the quirks). Pipes are a simple, but
brilliant idea; you can use a single `|` character to pass in the output of one
command as input to the next, and loads of CLI utilities are designed to
participate in these pipelines.

As great as these strengths of Bash are, the aforementioned quirks can be an
obstacle, standing between you and a safe, working script. So, let's talk about
10 things that are quirky about Bash and how to live with them.

## The quirks

* [Quirk 1: Shebang lines](#quirk-1-shebang-lines)
* [Quirk 2: Variable definition syntax](#quirk-2-variable-definition-syntax)
* [Quirk 3: Single vs. double quotes](#quirk-3-single-vs-double-quotes)
* [Quirk 4: Unbound variables](#quirk-4-unbound-variables)
* [Quirk 5: stdout and stderr](#quirk-5-stdout-and-stderr)
* [Quirk 6: `>` vs. `>>`](#quirk-6--vs-)
* [Quirk 7: Comparing strings and
  numbers](#quirk-7-comparing-strings-and-numbers)
* [Quirk 8: Passing arguments through](#quirk-8-passing-arguments-through)
* [Quirk 9: Bailing out if there is an
  error](#quirk-9-bailing-out-if-there-is-an-error)
* [Quirk 10: Handling errors in a
  pipeline](#quirk-10-handling-errors-in-a-pipeline)

## Quirk 1: Shebang lines

At the top of most shell scripts is a special line that tells your computer
which program to use to run the script.

You'll sometimes see the shebang line point to `/bin/bash` (**don't do this!**):

{% highlight bash %}
#!/bin/bash

echo "Hello world!"
{% endhighlight %}

This only works if you happen to have Bash installed at `/bin/bash`. Depending
on the operating system and distribution of the person running your script, that
might not necessarily be true!

It's better to use `env`, a program that finds an executable on the user's
`PATH` and runs it. `env` is basically _always_ reliably located in the
`/usr/bin` folder, so we can assume that `/usr/bin/env` is there for us to use.

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

> In the examples below, I will leave off the `#!/usr/bin/env bash` line for the
> sake of brevity, but you should always make this the very first line of every
> Bash script you write!

## Quirk 2: Variable definition syntax

Unlike in most other programming languages, when you define a variable in Bash,
you _must not_ include spaces around the variable name.

{% highlight bash %}
# Error: "vegetable: command not found"
vegetable = "broccoli"

# OK
vegetable="broccoli"
{% endhighlight %}

## Quirk 3: Single vs. double quotes

A lot of bugs in Bash scripts are related to quoting, so it's valuable to
understand how quoting works in Bash.

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

## Quirk 4: Unbound variables

You can trust most language runtimes to explode if you mistype the name of a
variable. That's what you _want_ to happen! For example, if you attempt to run
this Ruby program:

{% highlight ruby %}
food = "broccoli"

puts "My favorite food is #{fodo}"
{% endhighlight %}

The Ruby interpreter helpfully returns a non-zero exit code to indicate failure,
and the error message makes it clear what you did wrong:

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

This behavior makes it way too easy for your Bash scripts to have subtle bugs
where a variable that you _thought_ had a value turns out to be an empty string,
all because you mistyped the variable name.

> On rare occasions, it is actually _useful_ for Bash to treat undefined
> variables as empty strings, but I won't get into that here.

The good news is that there is an option (`set -u`) that you can enable to make
Bash behave more like other programming languages and throw an error in this
kind of situation:

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
despite the name, is not only for error messages (although that is one common
use). stderr is a stream where you can print user-facing messages without them
accidentally being interpreted as _output data_ that the next process in the
pipeline will read.

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

In contrast, if we had printed _everything_ to stdout, including the
"Thinking..." message, the output would have looked like this, which isn't quite
what we want:

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

Because our script does a good job of separating standard output from
"human-oriented" messages, we can capture the output in a variable without
getting the messages all mixed up in the output:

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
point of stderr is to print messages where the person running the script can see
them. Meanwhile, the stdout can be redirected into important places like
variables, files, and other processes.

## Quirk 6: `>` vs. `>>`

It's very easy to write to files in Bash. Any time something is being printed to
stdout, you can just slap a `>` on the end, followed by a file name, and the
output data will be written to the file.

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

## Quirk 7: Comparing strings and numbers

In many programming languages, you can check to see if two "things" are equal by
using `==` (equals) and `!=` (not-equals) operators, and this works regardless
of the types of the things you are comparing. Here is Ruby, for example:

{% highlight text %}
irb(main):001:0> 1 == 1
=> true
irb(main):004:0> 1 != 5
=> true
irb(main):005:0> "apple" == "apple"
=> true
irb(main):006:0> "apple" != "orange"
=> true
{% endhighlight %}

And there are also additional operators like `>`, `>=`, `<` and `<=` for
comparing whether numbers are greater than or less than each other. Here's Ruby
again:

{% highlight text %}
irb(main):009:0> 1 < 2
=> true
irb(main):010:0> 2 >= 1
=> true
{% endhighlight %}

Bash is different in a couple of ways:

1. You have to use `[[` to do these sorts of checks.

2. There are two sets of comparison operators:
  * `==` and `!=` for string comparison
  * `-eq`, `-ne`, `-gt`, `-lt`, `-le` `-ge` for numerical comparison

To check whether two strings are equal or not equal:

{% highlight bash %}
# Prints "Equal"
if [[ "foo" == "foo" ]]; then
  echo "Equal"
else
  echo "Not equal"
fi

# Prints "Not equal"
if [[ "foo" != "bar" ]]; then
  echo "Not equal"
else
  echo "Equal"
fi
{% endhighlight %}

To compare numbers:

{% highlight bash %}
# Prints "Equal"
if [[ 1 -eq 1 ]]; then
  echo "Equal"
else
  echo "Not equal"
fi

# Prints "Equal"
if [[ 1 -ne 2 ]]; then
  echo "Not equal"
else
  echo "Equal"
fi

# Prints "5 is greater"
if [[ 5 -gt 4 ]]; then
  echo "5 is greater"
else
  echo "5 is not greater"
fi
{% endhighlight %}

**Be careful not to mix up `==`/`!=` and `-eq`/`-ne`!** You will run into
unexpected behavior if you compare strings using the numerical operators:

{% highlight bash %}
# BAD: numerical comparison
# Prints "Apples and oranges are the same!?"
if [[ "apple" -eq "orange" ]]; then
  echo "Apples and oranges are the same!?"
else
  echo "Apples and oranges are clearly different"
fi

# GOOD: string comparison
# Prints "Apples and oranges are clearly different"
if [[ "apple" == "orange" ]]; then
  echo "Apples and oranges are the same!?"
else
  echo "Apples and oranges are clearly different"
fi
{% endhighlight %}

## Quirk 8: Passing arguments through

A common task, when you're writing Bash scripts, is to pass the arguments of one
script through to another. Just as a silly example, let's write a little
"wrapper script" for the `ls` command:

{% highlight bash %}
#!/usr/bin/env bash

echo "Welcome to ls-wrapper!" >&2

ls
{% endhighlight %}

This works well enough in that it calls `ls` without arguments:

{% highlight text %}
$ chmod +x ls-wrapper
$ ./ls-wrapper
Welcome to ls-wrapper!
<list of files in current directory>
{% endhighlight %}

But it doesn't work if I try to use `ls-wrapper` the same way that I might use
`ls`. For example, I can't ask it to list the files in a different directory
than the one I'm in:

{% highlight text %}
$ ./ls-wrapper /tmp/some-other-dir
Welcome to ls-wrapper!
<still a list of files in the current directory>
{% endhighlight %}

We can make `ls-wrapper` work just like `ls` by passing the arguments of
`ls-wrapper` through to `ls`. So how do we do that? Well, if you google this
question, you're going to find [a lot of complicated
answers][so-arg-passthrough], but the answer is more or less straightforward:
just use `"$@"`:

> You will sometimes see people use `$*`. Don't do that! You should almost
> always use `"$@"`, unless you really know what you're doing and you have a
> specific reason not to.

{% highlight bash %}
#!/usr/bin/env bash

echo "Welcome to ls-wrapper!" >&2

ls "$@"
{% endhighlight %}

Now, here is our `ls` wrapper script in action:

{% highlight text %}
$ ./ls-wrapper /tmp/some-other-dir
Welcome to ls-wrapper!
<list of files in /tmp/some-other-dir>
{% endhighlight %}

## Quirk 9: Bailing out if there is an error

In most programming languages, we expect a program to stop what it's doing
immediately if there is an error. Not in Bash!

Take this program, for example:

{% highlight bash %}
echo "Hello!"

# This will fail because the directory doesn't exist.
ls /ontehn/oeoanthesnu/aotehntaosethuanoteh

echo "We'll never get this far."
{% endhighlight %}

Here's the output when you run this script:

{% highlight text %}
Hello!
ls: cannot access '/ontehn/oeoanthesnu/aotehntaosethuanoteh': No such file or directory
We'll never get this far.
{% endhighlight %}

Oops! We _did_ get that far. But in most cases, if you're running a script that
you wrote, and there is an error halfway through, you don't want it to just keep
going, right? Each line of your script could be depending on the success of the
lines before it.

To make Bash behave more intuitively, we can use the `set -e` option:

{% highlight bash %}
set -e

echo "Hello!"

# This will fail because the directory doesn't exist.
ls /ontehn/oeoanthesnu/aotehntaosethuanoteh

echo "We'll never get this far."
{% endhighlight %}

This makes the Bash interpreter exit immediately as soon as one of the commands
(`ls`, in this case) returns a non-zero exit code to indicate failure:

{% highlight text %}
Hello!
ls: cannot access '/ontehn/oeoanthesnu/aotehntaosethuanoteh': No such file or directory
{% endhighlight %}

This is a much better behavior 99% of the time, in my opinion.

Of course, a lot of the time, you _expect_ certain commands to fail, and you
want your script to proceed in a certain way. A common example is checking for
the existence of a string in a file using `grep`:

{% highlight text %}
$ grep localhost /etc/hosts
127.0.0.1       localhost
::1     ip6-localhost ip6-loopback

# Zero exit code indicates success (string found)
$ echo $?
0

$ grep "something else" /etc/hosts

# Non-zero exit code indicates failure (string not found)
$ echo $?
1
{% endhighlight %}

So you might be worried that `set -e` doesn't account for situations like these,
where you might want to explicitly handle errors yourself:

{% highlight bash %}
set -e

if grep "onions" /etc/hosts; then
  echo "found onions"
fi

grep "onions" /etc/hosts && echo "found onions"

grep "onions" /etc/hosts || echo "no onions found"

echo "proceed to do other work"
{% endhighlight %}

Don't worry! `set -e` takes constructs like `if`, `while`, `&&` and `||` into
account, so your script will Just Work™ the way that you would expect, without
exiting prematurely:

{% highlight text %}
no onions found
proceed to do other work
{% endhighlight %}

> As an aside: It turns out that [using `set -e` is
> controversial][set-e-controversy] because there are various edge cases where
> it behaves unexpectedly. My take is that if you use `set -e` at the top of all
> of your scripts by default (especially if you also use `-o pipefail`, which
> I'll talk about next), even though it may not be _perfect_ and there are
> certain edge cases that you might run into from time to time, it's still well
> worth it because it will help you avoid subtle bugs where some part of your
> script doesn't work, but the script proceeds to run past that point anyway.
>
> The decision about whether or not to use `set -e` and `set -o pipefail` is one
> about trade-offs, and in my opinion, the benefits of `set -e` outweigh the
> costs. If you're new to writing Bash scripts, I recommend that you put
> `set -eo pipefail` at the top of all of your scripts as a general rule, and
> see how you like it in the long run. As you gain more experience with Bash and
> learn more about how `set -eo pipefail` works in practice, you can decide for
> yourself whether or not you prefer to use it. My prediction is that you'll
> prefer to use these safeguards and deal with any edge cases that come up,
> instead of not using them and having to handle every single possible error
> yourself!

## Quirk 10: Handling errors in a pipeline

One weakness of `set -e` is that it doesn't account for the errors that can
happen in the middle of a pipeline.

In the case of the `ls /some/nonexistent/directory` example above, the script
exited immediately because the `ls` command in the middle of the script returned
a non-zero exit code to indicate failure.

But what if we piped that `ls` command into another command? As a simple
example, let's pipe the `ls` command into `cat -`, which just passes through its
input as output:

{% highlight bash %}
set -e

echo "Hello!"

ls /some/nonexistent/directory | cat -

echo "We'll never get this far."
{% endhighlight %}

Even with `set -e`, when the `ls` command fails, the `cat` command still gets
executed. But it's even worse than that. Because the `cat` command executes
successfully, the script doesn't bail out like we want it to. If it weren't for
the error message that `ls` prints on stderr, we would have no idea that the
`ls` command failed, and the script proceeds to execute to the end as if nothing
went wrong!

{% highlight text %}
Hello!
ls: cannot access '/some/nonexistent/directory': No such file or directory
We'll never get this far.
{% endhighlight %}

The remedy for this is the `-o pipefail` option. You can use it on its own with
`set -o pipefail`, but you'll usually see it used in conjunction with `set -e`,
as `set -eo pipefail`:

{% highlight bash %}
set -eo pipefail

echo "Hello!"

ls /some/nonexistent/directory | cat -

echo "We'll never get this far."
{% endhighlight %}

Now, our script is smart enough to recognize that the `ls` command in the
pipeline failed, and so should the script as a whole at that point:

{% highlight text %}
Hello!
ls: cannot access '/some/nonexistent/directory': No such file or directory
{% endhighlight %}

# That's it!

I hope you found this helpful! Despite its quirks, Bash is an indispensable tool
for the modern software developer. Once you know how to navigate the weird
parts, you can reap the benefits of having this wonderful, bizarre language in
your repertoire.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1488142434454417409

[unix-philosophy]: https://en.wikipedia.org/wiki/Unix_philosophy
[so-arg-passthrough]: https://stackoverflow.com/q/4824590/2338327
[set-e-controversy]: http://mywiki.wooledge.org/BashFAQ/105
