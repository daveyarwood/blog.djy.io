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

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[unix-philosophy]: https://en.wikipedia.org/wiki/Unix_philosophy
