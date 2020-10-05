---
layout: post
title: "Conjuring Clojure in Vim"
tags:
  - conjure
  - vim
  - prepl
  - clojure
published: true
---

{% include JB/setup %}

> **UPDATE:** In May 2020, [a ground-up rewrite of Conjure was
> released][rewrite-2020]. It works a little differently than the older version
> of Conjure that I was talking about when I wrote this blog post. The big
> change is that Conjure now uses nREPL instead of prepl. [nREPL][nrepl] is a
> well-established protocol that offers a ton of useful features out of the box,
> and as a result, Conjure is now able to do a lot more with a lot less effort.
>
> I've been using the new Conjure since it dropped, and I have to say, it's even
> more awesome than the older Conjure described below!
>
> See [Conjuring Clojure in Vim: 2020 Edition][cciv-2020] for an updated version
> of this blog post based on the newer version of Conjure.

Clojure tooling for Vim has been getting more and more interesting over the past
few years, especially in the last year or so.

When I first came to Clojure, [Fireplace][fireplace] was the standard Vim plugin
for Clojure development, providing Clojure developers with a great in-editor
REPL experience. I think it's still the case that the majority of Clojurian
Vimmers use Fireplace, but in recent years, a number of viable alternatives
have begun to appear, including the plugins [Acid][acid], [Iced][iced], and
[Conjure][conjure].

I talked about these plugins a little bit [several months ago][min1-vim], and I
mentioned that Fireplace is what I would recommend for beginners. After six
months of using Conjure heavily and watching it improve and grow more stable, I
think I can now recommend Conjure as a way for Clojure beginners to get their
development environment up and running quickly and start writing Clojure code.

# What is this sorcery?

The author of Conjure, Oliver Caldwell, has written a bunch of blog posts that
help to make Conjure, as well as Clojure's prepl, approachable for newcomers:

* [Getting started with Clojure, Neovim and Conjure in minutes][olical1]
* [REPLing into projects with prepl and Propel][olical2]
* [Clojure socket prepl cookbook][olical3]

Since I last wrote about Conjure, Oliver has also made a number of improvements
that make the out-of-the-box experience with the plugin quite nice. At this
point, if you're a Neovim user and you know how to use a plugin manager like
[vim-plug], all you have to do is:

1. Install the Conjure plugin for Neovim
2. Open a Clojure source file (i.e. `vim /tmp/foo.clj`)
3. Wait a few seconds for Conjure to connect to its own prepl server.

Then you can start writing forms like `(+ 1 2)` and evaluating them by pressing
`<localleader>ee`, and you'll see the results appear right next to the form you
evaluated.

<center>
<img src="{{ site.url }}/assets/2019-11-21-conjure-basic-usage.gif"
     title="Basic usage of Conjure"
     width="75%">
</center>

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

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1197860958842044416

[fireplace]: https://github.com/tpope/vim-fireplace
[acid]: https://github.com/clojure-vim/acid.nvim
[iced]: https://github.com/liquidz/vim-iced
[conjure]: https://github.com/Olical/conjure
[min1-vim]: {% post_url 2019-07-28-minutiae-1 %}#vim-clojure-tooling-and-the-prepl
[olical1]: https://oli.me.uk/getting-started-with-clojure-neovim-and-conjure-in-minutes/
[olical2]: https://oli.me.uk/repling-into-projects-with-prepl-and-propel/
[olical3]: https://oli.me.uk/clojure-socket-prepl-cookbook/
[vim-plug]: https://github.com/junegunn/vim-plug
[boot]: https://github.com/boot-clj/boot
[clj-cli]: https://clojure.org/guides/deps_and_cli
[clj-cli-gist]: https://gist.github.com/daveyarwood/f890bf1529cb633c04b90ce5d5201d6d
[clj-slack]: http://clojurians.net/
[mranderson]: https://github.com/benedekfazekas/mranderson
[rewrite-2020]: https://github.com/Olical/conjure/releases/tag/v3.0.0
[nrepl]: https://nrepl.org
[cciv-2020]: {% post_url 2020-10-05-conjuring-clojure-in-vim-2020-edition %}
