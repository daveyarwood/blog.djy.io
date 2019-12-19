---
layout: post
title: "Reorganizing my vimrc"
tags:
  - vim
published: true
---

{% include JB/setup %}

When I first started using Vim, I used ["the ultimate vimrc"][ultimate-vimrc] as
the foundation of my Vim config. I had no idea where to start configuring Vim,
and this looked like a good starting point for a nice, batteries-included Vim
setup. It comes with a bunch of useful plugins installed and configured out of
the box, a variety of sensible default settings, and some useful mappings.

There are a bunch of other, similar vimrc "starter packs" out there. [spf13-vim]
is another popular one. I can't really say that I would recommend one over the
other at this point; I chose "the ultimate vimrc" somewhat arbitrarily, and if I
were to do it all over again, I would go a different route entirely.

After having used Vim for years, my view on these starter Vim setups has
changed. With the benefit of hindsight, I wish I had chosen to start with
[something more minimal][minimal-vimrc], taken the time to understand what each
setting did, and let my ideal setup grow from that organically. The more I've
used Vim, customized it to my liking, and learned about its inner workings, the
more I've had to contend with how my own custom settings and mappings interact
with the base vimrc I started with and figure out which settings I need and
which ones I don't.

I recently decided that enough was enough, and I spent a few hours combing
through all of the remaining settings left over from "the ultimate vimrc,"
jettisoned a bunch that aren't relevant to my setup, and promoted useful ones
into my own custom setup. The result of this process is a smaller, more focused
Vim config that I think is a lot easier to understand and maintain.

During this process, I also took the opportunity to organize related chunks of
configuration into separate files in a single directory. The file names are all
prefixed with numbers so that I can source them in alphabetical order; that way,
it's easy for me to understand in what order the settings are applied.

Here's my `~/.vimrc` in its entirety:

{% highlight viml %}
set shell=bash
set nocompatible

for f in split(glob('~/.vim/custom/*.vim'), '\n')
  exe 'source' f
endfor
{% endhighlight %}

The files in `~/.vim/custom/` are:

{% highlight bash %}
$ ls -1 ~/.vim/custom/
000-vim-settings.vim
100-plugins.vim
300-filetypes.vim
400-mappings.vim
401-visual-mode-search.vim
402-buffer-management.vim
403-clipboard.vim
404-next-and-last-text-objects.vim
405-zoom-toggle.vim
500-plugins-config.vim
600-iabbrevs.vim
700-colorscheme.vim
{% endhighlight %}

If you use Vim, you can probably guess what types of configuration you might
find in each file. And if you don't use Vim, then you probably wouldn't find it
all that interesting!

For the curious: my complete Vim configuration can be found [here in my
dotfiles][vim-dotfiles].

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1207643496699617280

[ultimate-vimrc]: https://github.com/amix/vimrc
[spf13-vim]: https://github.com/spf13/spf13-vim
[minimal-vimrc]: https://gist.github.com/benmccormick/4e4bc44d8135cfc43fc3
[vim-dotfiles]: https://github.com/daveyarwood/dotfiles/tree/master/vim
