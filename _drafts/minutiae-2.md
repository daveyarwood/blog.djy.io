---
layout: post
title: "Minutiae #2: Crux, slideshow tools, Asciidoc"
category: minutiae
tags:
  - talks
  - asciidoc
  - antora
  - reveal.js
  - crux
published: true
---

{% include JB/setup %}

Here's some stuff I've been spending time on lately:

# Crux tutorial

The UK-based Clojure consulting company JUXT recently released [Crux][crux], an
open source, bitemporal, document-oriented database. I thought it was
interesting when I heard about it, but I haven't had a good opportunity to try
it out yet. Now they have an entertaining [tutorial][crux-tutorial] that guides
you through the concepts at a gradual pace, interleaving code examples, excerpts
of the actual documentation, and a delightful sci-fi story. I've gone through
the first few chapters and it's quite fun!

# Making slides

The last N times I've prepared a talk/presentation, I've used
[slides.com][slides.com]. Slides.com is great, but I've finally gotten to a
point where I'm tired of manually laying out each slide, dragging text blocks
around to the best-looking (X, Y) coordinates, etc. So, I've bitten the bullet
and started looking into HTML5 presentation frameworks.

Two of them that I tried recently are [Bespoke.js][bespoke] and
[Reveal.js][reveal].

## Bespoke.js

I really like the idea behind Bespoke.js, which bills itself as a "DIY
presentation micro-framework." It strives to be minimal and modular and to
support a rich ecosystem of plugins to provide all sorts of presentation
functionality.

I tried it out and I think it has promise, but unfortunately, I didn't have a
great out-of-the-box experience. I had a hard time getting a syntax highlighting
plugin to work. Based the commit history, it seems like Bespoke.js may be an
under-maintained project at this point. Hopefully someday development will pick
up or someone will make a new project with similar ambitions.

## Reveal.js

Reveal.js is more of a "batteries included" framework with numerous features
available out of the box. There are also a vast array of plugins providing
additional features. The community effort is clearly larger around Reveal.js; if
GitHub stardom is any indicator, Reveal.js has over 10x the number of stars as
Bespoke.js.

I was pleased to find that I could easily customize my slides' appearance with
Reveal.js.  It's basically just a matter of copying the `simple` Reveal.js theme
CSS and adjusting it to my liking.

(Worth mentioning: slides.com actually uses Reveal.js under the hood!)

I'm totally enjoying working on my slides in CSS and HTML (I'm actually writing
my slides in Asciidoc and compiling them to HTML; more on that below).
Working on text files allows me to stay focused on the content of my
presentations, whereas before I was finding myself spending a lot of time
dragging around text blocks on each slide to line them up just right, or
otherwise fiddling with things to see what looks best.

# Asciidoc

I've been getting more and more into [Asciidoc][asciidoc]. It's an incredibly
rich text document format that's suitable for writing quick notes,
documentation, articles, books, websites, slideshows, etc. etc. I decided to try
it out on a whim as an alternative to writing Markdown, and I've been very happy
with it so far. See [this blog post][adoc-over-md] for a good comparison of
Asciidoc vs. Markdown.

I will likely continue to use Markdown in many places, as it is a de facto
standard and I don't want to force some weird format onto collaborators who are
used to Markdown, but I'm tending to write more and more of my own documents in
Asciidoc and I'm enjoying it. Maybe someday I'll explore writing blog posts in
Asciidoc. I'm using [Jekyll][jekyll], which is Markdown-based, but it looks like
there is an Asciidoc plugin that I could try.

## Antora

[Antora][antora] is a really cool static site generator centered around using
Asciidoc to maintain your documentation. I saw that [CIDER][cider] recently
published [its documentation site][cider-docs] using Antora, and I think the
result looks fantastic. I recently played around a little bit with using Antora
to make a documentation site for Alda. We'll see how that goes.

[crux]: https://juxt.pro/crux/
[crux-tutorial]: https://juxt.pro/blog/posts/crux-tutorial-setup.html
[slides.com]: https://slides.com/
[bespoke]: http://markdalgleish.com/projects/bespoke.js/
[reveal]: https://revealjs.com
[asciidoc]: http://asciidoc.org/
[adoc-over-md]: https://www.makeuseof.com/tag/compare-markup-language-asciidoc-markdown/
[jekyll]: https://jekyllrb.com/
[antora]: https://antora.org/
[cider]: https://cider.mx/
[cider-docs]: https://docs.cider.mx
