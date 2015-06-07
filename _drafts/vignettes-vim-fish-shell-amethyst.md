---
layout: post
title: "Vignettes: Vim, Fish Shell, Amethyst"
tags: 
  - vim
  - fish
  - amethyst
published: true
---

{% include JB/setup %}

I've been exploring all sorts of awesome things lately. I feel compelled to share the magic™ of these things with you, but to be fair, there are already a ton of great blog posts and tutorials out there about each of these things, and I'm not sure there's much more that I could say that hasn't already been said. 
So, this idea occurred to me of doing one blog post divided into several *vignettes*, in which I'll just give you a brief picture of each thing and why I think it's awesome. I like this idea because it gives me a platform to talk about things I like, without having to deal with the obligation of writing an entire blog post about each thing. (*Instead, I just have to write 1/3 of a blog post for each thing, which I'm tricking myself into feeling is more manageable. #lifehack*)

# Vim

<a href="{{ site.url }}/assets/2015-06-06-vim.png">
  <img src="{{ site.url }}/assets/2015-06-06-vim.png" width="480" height="300"  title="Me editing this post in Vim - meta as fuck">
</a>

There is an age-old debate over which text editor is better, [Emacs][emacs] or [Vim][vim]. I'm not going to claim that Vim is the best, because I don't feel particularly dogmatic about it. I've tried Emacs too, and it's very compelling in its own right. But for all of my previous efforts to learn Emacs, it just never stuck with me for whatever reason. I always ended up going back to GUI editors like [SublimeText][sublime] and [Light Table][lighttable].

For quick text editing from the command line, I was always a fan of [aoeui][aoeui] (a simple, lightweight editor optimized for the [Dvorak][dvorak] keyboard layout), and it served me well for quick tasks like editing config files or jotting down ideas. 
aoeui's key bindings are nice and intuitive -- so much so that I even started writing [a Light Table plugin][lt-aoeui] to provide aoeui key bindings in Light Table. This exercise in optimizing my text editing environment effectively made me reconsider my resigned choice to use GUI text editors, and ironically, led me to abandon aoeui and start using Vim.

I fell in love with Vim almost immediately. I decided to try it on a whim -- I had tried to become an Emacs user before without success, so I became curious about the other camp. I was pleasantly surprised by how easy it was to learn Vim's key bindings. 
As a Dvorak typist, I was also surprised at how natural it felt to use Vim's default key bindings without modifications. The `hjkl` movement system is clearly designed for QWERTY, but the corresponding positions of these keys in the Dvorak layout actually end up working out pretty well:

*picture here*

`h` and `l` are still essentially under your right pointer and pinkie (as a bonus, you don't have to shift your hand over!), and `j` and `k` are still right next to each other, they're just under your left middle and pointer fingers. 
I think I actually prefer this to the QWERTY positions of these keys, as it clearly separates out horizontal from vertical movement. I sincerely doubt this is by design, but it's a nice plus for Dvorak users. 
I've also found that the rest of the key bindings feel just fine under my Dvorak-inclined fingers -- the idiom with Vim key bindings seems to be not the location of the keys, but the mnemonics for remembering them. The result is that typing `d2w` (**d**elete **2** **w**ords) feels about the same in QWERTY as it does in Dvorak. 

Customizing my Vim setup has also been a pleasant experience. I started with the "awesome version" of [this guy's Vim configuration][ultimate-vim], which includes a bunch of useful plugins and custom key bindings, then added my own tweaks. 

I could go on and on about how awesome Vim is, but this is already starting to get a little big for a vignette, so I'll have to move on. Sufficeth to say that I actually get a little excited now whenever I need to edit some text -- using Vim is just that pleasant. 

[emacs]: http://www.gnu.org/software/emacs/
[vim]: http://www.vim.org/
[sublime]: http://www.sublimetext.com/
[lighttable]: http://lighttable.com/
[aoeui]: http://aoeui.sourceforge.net/
[dvorak]: http://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard
[lt-aoeui]: http://github.com/daveyarwood/aoeui
[ultimate-vim]: https://github.com/amix/vimrc
