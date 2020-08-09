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

# BYOBC (bring your own build caching)

The secret sauce in our homebrew build caching setup is a script that
**generates a hash of the content** of the files in the project.

Any time you make a change to a file in your project, add a new file, remove a
file, etc. the hash that the script outputs will be different. If you run the
script twice in a row without making any changes in between, you will see the
same hash. This way, we'll know if we need to rebuild the project (i.e. the hash
is different, which means something changed) or if we can reuse an existing
build.

Once we're able to generate a hash for the current state of the files in the
project, the next step is **store each build in a folder whose name includes the
hash**. Whenever we want to build the project, we first generate the content
hash and check to see if there is already a build for that hash. If there is,
then we're done; we don't need to build it again. If there isn't, then we
compile our code, etc. and we put the build artifacts (executables, etc.) into a
folder whose name includes the hash so that we can reuse it.

Here is an example shell session that should make this easier to visualize:

{% highlight bash %}
$ bin/current-content-hash
e45c9cf94f64b28f852196d2b386d07f4640633d

# We don't have a build yet for the current content, so `bin/build` creates a
# build in the target directory, in a folder whose name includes the content
# hash.
$ bin/build
Building target/e45c9cf94f64b28f852196d2b386d07f4640633d/my-program...
Done.

# If we run `bin/build` again without making changes, it's a no-op.
$ bin/build
Existing build: target/e45c9cf94f64b28f852196d2b386d07f4640633d/my-program

# ... writing code, making changes ...

# After saving a change to a file, the content hash is different.
$ bin/current-content-hash
ff7ada844186e67c0282324452e4a5be537f0771

# Now if we run `bin/build`, it will create a new build because there is no
# folder within the target directory that includes that content hash.
$ bin/build
Building target/ff7ada844186e67c0282324452e4a5be537f0771/my-program...
Done.

# Just like before, the build is cached, so `bin/build` is a no-op:
$ bin/build
Existing build: target/ff7ada844186e67c0282324452e4a5be537f0771/my-program
{% endhighlight %}



# Notes

## More details about the setup

* How `bin/current-content-hash` works / `git write-tree`
  * Include an aside about how it's crucial to include the target directory in
    .gitignore, otherwise builds themselves would invalidate the cache!

* Garbage collection
  * Explain how old builds (e.g. > 7 days old) are periodically cleaned up by
    the build script to save disk space.
  * Include command from `build` script as an example.

## git write-tree

(I'm assuming that your project is version-controlled using Git. If it isn't,
you can still use this overall approach, but you will need to figure out another
way to generate a hash of the content of your project!)

* TODO: explain what `git write-tree` does
  * Considers both the current commit you're on and any un-committed changes you
    may have made.

* TODO: basic explanation of how git stores objects by hash

* TODO: Explain about the git index file

* `current-content-hash` makes a copy of the git index file and uses that as the
  index, in order to avoid affecting the current state of git.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[gradle-bc]: https://guides.gradle.org/using-build-cache/
[codebuild-bc]: https://docs.aws.amazon.com/codebuild/latest/userguide/build-caching.html
[docker-bc]: https://pythonspeed.com/articles/docker-caching-model/
