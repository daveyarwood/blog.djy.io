---
layout: post
title: "Conjuring Clojure in Vim: 2020 Edition"
tags:
  - conjure
  - vim
  - clojure
  - nrepl
published: true
---

{% include JB/setup %}

Clojure tooling for Vim has been getting more and more interesting over the last
several years.

When I first came to Clojure, [Fireplace][fireplace] was the standard Vim plugin
for Clojure development, providing Clojure developers with a great in-editor
REPL experience. I think it's still the case that the majority of Clojurian
Vimmers use Fireplace, but in recent years, a number of viable alternatives
have begun to appear, including the plugins [Acid][acid], [Iced][iced], and
[Conjure][conjure].

I've tried all of these plugins at one time or another, but I've been an avid
user of Conjure since pretty early on in the life of the project. Conjure is a
[Neovim][neovim] plugin that provides an excellent Clojure development
environment out of the box. It is easy enough to get started that I would
recommend Conjure to any Vim users who want to try Clojure for the first time.

# What is this sorcery?

The elevator pitch for Conjure is that it effortlessly connects to your Clojure
REPL and lets you evaluate Clojure code and see the results without having to
leave Vim or take your eyes off of your code. You can do all of this with zero
configuration, and with a handful of standard key mappings that are easy to
learn.

But that really describes all of the Clojure Vim plugins that I mentioned above,
so what sets Conjure apart from the rest of the pack?

The author of Conjure, Oliver Caldwell, has put a ton of thought and effort into
making the out-of-the-box user experience nice and comfortable.

If you're a Neovim user and you know how to use a plugin manager like
[vim-plug], all you have to do is:

1. Install the Conjure plugin for Neovim.
2. `cd` into the directory of a Clojure project.
  * (You can easily start a new one by just making an empty directory.)
3. Start an nREPL server (more about this below).
4. In another terminal, `cd` into the same directory and open a Clojure source
   file in Neovim (e.g. `nvim foo.clj`).

Conjure will automatically connect to your nREPL server. Then, you can
immediately start writing forms like `(+ 1 2)` and evaluating them by pressing
`<localleader>ee`, and you'll see the results appear in a neat little popup
window.

> TODO: update this gif

<center>
<img src="{{ site.url }}/assets/2019-11-21-conjure-basic-usage.gif"
     title="Basic usage of Conjure"
     width="75%">
</center>

> TODO: continue reviewing the old blog post below and updating it as needed

# BYOP (bring your own prepl)

This is great for one-off REPL experiments involving just the Clojure standard
library, but the built-in REPL that Conjure connects to out of the box doesn't
include your project's source code or the libraries it depends on. To complete
your Clojure development setup, you'll need to be able to start a prepl server
within the context of your project.

For an in-depth discussion of various ways to do this, you can refer to Oliver's
[socket prepl cookbook][olical3].

The majority of Clojure projects that I interact with use either [Boot][boot] or
the [Clojure CLI][clj-cli] as a build tool.

For Boot projects, I have a custom `prepl-server` task that I defined in my
`profile.boot`:

{% highlight clojure %}
(deftask prepl-server
  "Start a prepl server."
  [p port PORT int "The port on which to start the prepl server (optional)."]
  (comp
    (socket-server
      :accept 'clojure.core.server/io-prepl
      :port   port)
    (wait)))
{% endhighlight %}

> Worth noting: I contributed this task to Boot, and it got merged into the
> master branch, so in some future release of Boot, `prepl-server` will be
> available out of the box as a built-in task!

My Clojure CLI setup is [a little bit more complicated][clj-cli-gist], but the
result is that I can start a prepl server in any Clojure project directory
with a `deps.edn` by running `clj -Aprepl-server`.

Both my Boot task and my Clojure CLI alias spit out a `.socket-port` file in the
current directory containing the port number on which the prepl server is
running. Configuring Conjure to automatically connect to the prepl server on the
correct port is super easy:

{% highlight clojure %}
;; ~/.config/conjure/conjure.edn
{:conns
 {:cwd {:port #slurp-edn ".socket-port"}}}
{% endhighlight %}

With this setup in place, I can start a prepl server via `boot` or `clj` and
start editing Clojure source files, and Conjure will automatically connect to
my prepl server. Then I can evaluate code within the context of my project, and
I can use any dependencies that I've included in my `build.boot` or `deps.edn`.

<center>
<img src="{{ site.url }}/assets/2019-11-21-conjure-clj-http.gif"
     title="Using clj-http via Conjure to fetch ASCII cat art from the internet"
     width="75%">
</center>

# A refreshing experience

Conjure provides a convenient way to reload code that changed in your prepl via
`clojure.tools.namespace/refresh`. Ordinarily, you would need to include
clojure.tools.namespace as a dependency in your project in order to do that, but
through clever use of [mranderson], Conjure automatically injects the dependency
into your prepl connection. That means refreshing your REPL is always just a few
keystrokes away!

I haven't tended to use clojure.tools.namespace refreshing much in the past, but
since the feature was added to Conjure, I've found myself using it more and more
because it's right there under my fingertips and it requires no setup. It's
really handy for those times when I've changed a bunch of code and I don't
remember exactly what I changed; I can simply reload everything by pressing
`<localleader>rr`.

You can even configure Conjure at the project level to run hooks before and
after refresh, which can be handy when you're developing something that you
might want to restart every time you make changes, like a web server.

# Casting spells

One day, in the `#conjure` channel on [Clojurians slack][clj-slack], an
off-the-cuff discussion about re-evaluating the same form over and over again
during development led to an intriguing new Conjure feature called "eval at
mark."

This feature is also affectionately known as the "spellbook" feature because it
lets you evaluate any number of predefined Clojure forms, on demand, just by
pressing a few keys. I've been using this feature a lot since it was introduced,
and I love it!

In a typical workflow, I might set the mark `F` at a function call in a scratch
namespace, and then I can call that function from anywhere, e.g. while I'm
editing code in another namespace, by pressing `<localleader>emF`.

This sort of workflow helps a lot in common scenarios where I'm testing the
behavior of a function that I'm writing, and that function itself calls a number
of other functions that are defined in other namespaces. Sometimes, in the heat
of development, I end up jumping around through a bunch of different files as
I'm chasing a bug or implementing a complex feature.

Previously, I had to jump back into my scratch namespace everytime I wanted to
re-evaluate a form that calls the function I'm testing. Now, I can stay where I
am in the implementation code and just press:

* `<localleader>rr` to reload all of the code that changed, then

* `<localleader>emF` to re-eval the form at mark `F`

<center>
<img src="{{ site.url }}/assets/2019-11-21-conjure-eval-at-mark.gif"
     title="Using Conjure's 'eval at mark' feature"
     width="75%">
</center>

# Try it!

If you're a Vim-using Clojurist or a Clojure-using Vimmer, hopefully I've
inspired you to give [Conjure][conjure] a try. Go ahead, it's fun!

# Notes

1. Write a new blog post about how the new version of Conjure is even
   better.
2. Update the previous blog post to include a link to the new one.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[fireplace]: https://github.com/tpope/vim-fireplace
[acid]: https://github.com/clojure-vim/acid.nvim
[iced]: https://github.com/liquidz/vim-iced
[conjure]: https://github.com/Olical/conjure
[neovim]: https://neovim.io/
[vim-plug]: https://github.com/junegunn/vim-plug
[boot]: https://github.com/boot-clj/boot
[clj-cli]: https://clojure.org/guides/deps_and_cli
[clj-cli-gist]: https://gist.github.com/daveyarwood/f890bf1529cb633c04b90ce5d5201d6d
[clj-slack]: http://clojurians.net/
[mranderson]: https://github.com/benedekfazekas/mranderson
[rewrite-2020]: https://github.com/Olical/conjure/releases/tag/v3.0.0
[nrepl]: https://nrepl.org

