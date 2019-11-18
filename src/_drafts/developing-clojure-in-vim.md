---
layout: post
title: "Developing Clojure in Vim"
tags:
  - conjure
  - vim
  - prepl
  - clojure
published: true
---

{% include JB/setup %}

# Notes

* Include disclaimer that this isn't the only way to do it.
  * Fireplace / nREPL still in widespread use, the standard choice for Clojure
    development in Vim

* Link to [Minutiae #1][min1], in which I talked about Clojure tooling options
  for Vim.
  * Fireplace, Acid, Iced, Conjure
  * I mentioned that Fireplace is what I would recommend to beginners.

* After several months of using Conjure heavily and seeing it improve and grow
  more stable, I think I can now recommend Conjure for Clojure beginners as a
  way to get your development environment up and running quickly and start
  writing Clojure code.

* Oliver Caldwell (the author of Conjure) has written a bunch of blog posts in
  this vein:
  * [Getting started with Clojure, Neovim and Conjure in minutes][olical1]
  * [REPLing into projects with prepl and Propel][olical2]
  * [Clojure socket prepl cookbook][olical3]

* Since I last wrote about Conjure, Oliver has also made a number of
  improvements that make the out-of-the-box experience quite nice.
  * At this point, if you're a Neovim user and you know how to use a plugin
    manager like [vim-plug], all you have to do is:
      1. Install the Conjure plugin for Neovim
      2. Open a Clojure source file (i.e. `vim /tmp/foo.clj`)
      3. Wait a few seconds for Conjure to connect to its own prepl server.

    Then you can start writing Clojure forms like `(+ 1 2)` and evaluating them
    by pressing `<localleader>ee`, and you'll see the results appear right next
    to the form you evaluated.
    * A gif here would be lovely.

* This is great for one-off REPL experiments involving just the Clojure standard
  library, but the built-in REPL that Conjure connects to out of the box doesn't
  include additional libraries, which you end up using quite a bit in day-to-day
  Clojure development.

  To complete your Clojure development setup, you need to be able to start a
  prepl server that includes your project's source code and all of the
  libraries that it depends on.

  * Discussion of how I start prepl servers.
    * Leiningen
      * I never use Leiningen, but if I ever do, I will refer to Oliver's
        [socket prepl cookbook][olical3], which is chock full of useful
        information about starting prepl servers in various ways.
    * Boot
      * `prepl-server` task in my profile.boot
        * Will be in a future release of Boot someday
    * Clojure CLI
      * `-Aprepl-server` alias in my personal dotfiles
        * Tangent: Clojure CLI lets you have your own personal library of
          Clojure code that you can use everywhere, and it's awesome.
          * It gives you an alternative to writing Bash scripts, if you want.

* Basic demo gif, showcasing:
  * Eval forms in a `comment` block in an implementation namespace
  * Conjure log buffer opens automatically when the eval result is large enough
  * ...or if there is stdout
  * ...or if there is a tapped value

* Conjure's "eval at mark" feature
  * Also affectionately known as the "spellbook" feature because it lets you
    evaluate any number of predefined Clojure forms, on demand, by just pressing
    a few keys.
  * Describe the workflow I'm using now where I set a mark at the function that
    I'm repeatedly invoking in order to test changes to the function's
    implementation.
    * The function makes use of code defined in many different namespaces, so I
      have to jump around in a bunch of different files, making changes and
      testing the changes by re-evaluating the same form.
    * Previously, I had to jump back into my scratch namespace everytime I
      wanted to re-evaluate the form that calls the form.
    * Now, I can stay where I am in the implementation code and just press:
      * `\rr` to reload all of the code that changed
      * `\emT` to re-eval the form at mark `T`
  * A gif here would be super sweet.
    * I could take a gif of my actual integration-tests workflow, but it takes a
      while for the tests to run and a simpler example would be easier to
      follow.
    * I can put together a very simple project with a scratch namespace and a
      couple of implementation namespaces, and demo placing a mark in the
      scratch namespace, editing code in impl ns 1 and re-eval the form at mark,
      editing code in impl ns 2 and re-eval the form at mark.

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[min1]: {% post_url 2019-07-28-minutiae-1 %}
[olical1]: https://oli.me.uk/getting-started-with-clojure-neovim-and-conjure-in-minutes/
[olical2]: https://oli.me.uk/repling-into-projects-with-prepl-and-propel/
[olical3]: https://oli.me.uk/clojure-socket-prepl-cookbook/
[vim-plug]: https://github.com/junegunn/vim-plug
