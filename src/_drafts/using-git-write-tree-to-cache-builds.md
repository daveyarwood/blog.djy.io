---
layout: post
title: "Using git write-tree to cache builds"
category: something
tags:
  - git
  - unix
  - command line
  - productivity
published: true
---

{% include JB/setup %}

# Write, compile, run, observe

When you're writing a program in a compiled language, you might find yourself
repeating this cycle:

* Write code
* Compile executable
* Run executable
* Observe results

(Lather, rinse, repeat.)

When you're repeating this cycle over and over again, it can be cumbersome to
have to worry about whether the build that you're running was compiled from the
same code that you're looking at. In other words, each time you run the command
that you use to run the build (e.g.  `java -jar target/project.jar`), you have
to wonder whether or not you ran the command to compile your code (e.g. `javac
...`) since the last time you changed the code.

# Always build it before you run it

A simple solution to this problem is to condense the "compile" and "run" steps
of your build cycle into a single step: "compile and run."

Picture a `bin/run` script in your project that looks something like this:

{% highlight bash %}
#!/usr/bin/env bash

# Exit immediately if the build fails
set -e

# Compile executable jar file
javac # ... arguments go here ...

# Run the jar file
java -jar target/project.jar
{% endhighlight %}

Now, your build cycle is:

* Write code
* Run `bin/run`
* Observe results

This isn't totally satisfying, though. Sometimes you want to run the **same**
build a bunch of times in a row, and when that happens, you have to sit there
and wait for the same code to recompile, each and every time you run `bin/run`.

The solution to this problem is **build caching**.

# Notes

## Use case

* TODO: basic explanation of build caching

* Language-specific build tools will often do this sort of thing for you
  automatically

* What follows is a simple, made-from-scratch solution that works just as well
  as (if not better than!) the caching that these build tools do.

* The end result is a single `bin/run` script that I can use to run the latest
  build, building it only if it hasn't already been built. This is nice because
  it means I never have to ask the question "Am I running the code that I'm
  looking at right now?" when I'm developing.

## The target directory

* gitignored

* one folder per content SHA
  * use `tree` to show an example

* build script periodically cleans up old builds (> 7 days old)
  * include command from `build` script as an example

## git write-tree

* TODO: basic explanation of how git stores objects by hash

* TODO: explain what `git write-tree` does

## Scripts

### `current-content-sha`

* Uses `git write-tree` to print a SHA of the current content of the repo.
  * Considers both the current commit you're on and any un-committed changes you
    may have made.

* TODO: Explain about the git index file

* `current-content-sha` makes a copy of the git index file and uses that as the
  index, in order to avoid affecting the current state of git.

* TODO: explain further

### `build`

* Uses `current-content-sha` to identify the current content version.

* Checks if the `target` directory already contains a build for that content.

* If not, builds again, outputting the result into `target/$content_sha`

### `run`

* Runs the `build` script, which might be a no-op if the current content was
  already built.

* Runs the built executable directly.

## `find` + `entr` workflow

* Re-builds and re-runs (via the `run` script) every time I save a change to a
  file in my editor.

* I can easily re-run by just saving again with the same content, and it runs
  right away, using the cached build (because the content of the repo didn't
  change).

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME
