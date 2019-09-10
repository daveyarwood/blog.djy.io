---
layout: post
title: "Minutiae #4: Strange Loop talk, git submodules"
category: minutiae
tags:
  - alda
  - talks
  - git
published: true
---

{% include JB/setup %}

# Polishing my Strange Loop talk

With [Strange Loop][strangeloop] drawing closer, I've been spending most of my
free time tweaking and practicing [my talk][strangeloop-talk] about the dynamic
relationship between [Alda][alda] and Clojure.

As I tend to do, I planned way too much material and so I ending up having to
trim down the sections of my talk in order to keep it under time. Some things I
had to cut include:

* An extended demo at the beginning of the talk where I review the features of
  Alda and show examples. I realized that, while interesting, an in-depth
  discussion of Alda's features is off-topic, and I wanted to keep the focus of
  the talk on the relationship between Alda and Clojure.

* A short tangent about the [Sapir-Whorf hypothesis][sapir-whorf] as it relates
  to programming languages and music notation software. I think it was good
  material, and it was sure to be interesting to some of the audience, but it
  wasn't entirely relevant to the topic at hand, so I had to cut it for the sake
  of time.

## Timing the sections

To keep track of roughly how long it takes me to present each section of the
talk, I included a comment at the top of each section with a rough estimated
time like `1 minute` or `5 minutes`. Then, I wrote the following script that
parses out all of the estimates and sums them up.

{% highlight bash %}
#!/usr/bin/env bash

scriptdir=$(dirname $0)
rootdir="$scriptdir/.."

function estimated_length() {
  grep -Eo "[[:digit:]]+ minutes?" "$rootdir/index.adoc" \
    | grep -Eo "[[:digit:]]+" \
    | ruby -e 'sum = 0; while n = gets; sum += n.chomp.to_i; end; p sum'
}

echo " (~$(estimated_length)/40 minutes planned)"
{% endhighlight %}

This was handy, as I could time myself practicing each section individually and
update the estimates, and get a rough idea of the total length of my talk. At
one point, I had an estimated 56 minutes of material to fill a 40 minute time
slot, so that was a clear indication that I needed to start trimming it down!

# Git submodules

We use [git submodules][git-submodules] at work as an easy way to share code
between Git repositories. We have a couple of repos filled with common code,
deployment scripts, etc. and we use those repos as submodules in other repos.

The trade-off is complexity; we have to worry about what versions of the
submodules are used within a particular repo. Contributors to any of our
repos that use submodules have to remember to initialize and update the
submodules (i.e. check out the specified version of the submodules), because Git
does not do this for you automatically.

## Making sure the submodules are always checked out properly

Personally, I've found that I almost never want my git submodules to be in a
state other than the commit specified in the repo. When I check out a commit in
a repo, I want the correct submodule versions to be checked out without me
having to think about it. As such, I've created a `gpl` alias that I use
exclusively wherever I would ordinarily run `git pull`. It does the equivalent
of the following:

{% highlight bash %}
git fetch --all --prune && git merge
git submodule init && git submodule update
{% endhighlight %}

This does a couple things that `git pull` doesn't do out of the box:

* When branches are deleted upstream, my local copy of the remote is updated
  accordingly. (This is the `--prune` argument to `git fetch`).

* The correct version of all submodules for the current commit is checked out.

## Updating submodules properly

I've also defined a `gsu` alias that updates the versions of all submodules
based to the latest commit of the upstream master branches of the submodule
repos. Git has a built-in command for this, `git submodule update --remote`,
which works well enough except in the scenario where somebody temporarily
switches branches in the submodule, and now the submodule is no longer tracking
the intended branch of the submodule repo.

I'm leaving out the code for the sake of brevity, but my `gsu` alias does the
following:

* For each submodule in the repo...
  * If the submodule is on a commit included in master, then update to use the
    latest commit on master.

  * If not, then print what branch(es) the commit is on so that I can sort it
    out manually. Typically this means making sure that the alternate branch of
    the submodule gets merged into master and that the submodule is tracking
    master.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda]: https://alda.io
[strangeloop]: https://www.thestrangeloop.com
[strangeloop-talk]: https://www.thestrangeloop.com/2019/aldas-dynamic-relationship-with-clojure.html
[sapir-whorf]: https://en.wikipedia.org/wiki/Linguistic_relativity
[git-submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
