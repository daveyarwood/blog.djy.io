---
layout: post
title: "Bash survival guide"
tags:
  - bash
  - unix
published: true
---

{% include JB/setup %}

I have a love/hate relationship with Bash.

It's a quirky little language with many subtleties that make it easy to make
mistakes. Programmers who write Bash scripts are constantly discovering bugs in
their scripts related to getting some obscure syntax wrong, using quotes
incorrectly, platform or shell compatibility issues, mishandling errors, etc.

On the other hand, Bash is ubiquitous, and it's a great "glue language" for
composing CLI commands together. The [Unix philosophy][unix-philosophy] is chock
full of good ideas that keep Bash scripts simple, easy to understand, and easy
to write (once you know your way around the quirks). Pipes are a brilliant
idea; you can use a single `|` character to pass the output of one command into
the next command as input, and loads of CLI utilities are written with the goal
of being a useful participant in these pipelines.

> ... but the quirks are unfortunate and significant, so my goal with this blog
> post is to help you avoid the quirks, etc.
>
> reword the above, it's just off the top of my head at the moment

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[unix-philosophy]: https://en.wikipedia.org/wiki/Unix_philosophy
