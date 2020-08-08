---
layout: post
title: "Using git write-tree to cache builds"
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

I don't know about you, but when I'm repeating this cycle over and over again, I
don't want to have to worry about whether or not the build that I'm running was
compiled from the same code that I'm currently looking at. In other words, each
time I run the command that runs the build (e.g.  `java -jar
target/project.jar`), I have to wonder whether or not I've run the command that
compiles my code (e.g.  `javac ...`) since the last time I made changes to the
code. It would be nice to remove any uncertainty and be 100% confident that the
build I'm running corresponds to the code I'm looking at.

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

# Run the jar file, passing along the arguments from `bin/run ...`
java -jar target/project.jar "$@"
{% endhighlight %}

Now, your build cycle is a little simpler:

* Write code
* Run `bin/run`
* Observe results

This isn't totally satisfying, though. Sometimes, you might want to run the
**same** build a bunch of times in a row, i.e.:

* Write code
* Run `bin/run some arguments`
* Observe results
* Run `bin/run some other arguments`
* Observe results
* Run `bin/run some different arguments`
* Observe results

In this situation, you have to sit there and wait for the same code to
recompile, each and every time you run `bin/run`, even though you didn't make
any changes to the code!

This is the problem that **build caching** is meant to solve.

# Build caching

The idea with build caching is that we can speed up builds by not doing any more
work than we have to. If we haven't made any changes to the code, then there is
no reason for us to recompile; we can just reuse the last build.

It's worth noting that some platforms and build tools (like
[Gradle][gradle-bc], [AWS CodeBuild][codebuild-bc], and [Docker][docker-bc])
have their own built-in caching to speed things up for the end user. For
example, Gradle has an **incremental build** feature where it can reuse _parts_
of previous builds in the current build, which can speed things up
substantially.

The technique I'm about to describe can provide some additional benefit in that
it allows you to skip the build tool altogether if the code hasn't changed. It
also provides build caching for the common case where the build tool doesn't
provide it.

# Notes

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

* There is now a good blog post about by Julia Evans about `entr` that I can
  link to!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[gradle-bc]: https://guides.gradle.org/using-build-cache/
[codebuild-bc]: https://docs.aws.amazon.com/codebuild/latest/userguide/build-caching.html
[docker-bc]: https://pythonspeed.com/articles/docker-caching-model/
