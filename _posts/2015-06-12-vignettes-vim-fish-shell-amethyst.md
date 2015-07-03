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

<a href="{{ site.url }}/assets/2015-06-06-vim.png" class="img-link">
  <img src="{{ site.url }}/assets/2015-06-06-vim.png" width="480" height="300"  title="Me editing this post in Vim - meta as fuck">
</a>

There is an age-old debate over which text editor is better, [Emacs][emacs] or [Vim][vim]. I'm not going to claim that Vim is the best, because I don't feel particularly dogmatic about it. I've tried Emacs too, and it's very compelling in its own right. But for all of my previous efforts to learn Emacs, it just never stuck with me for whatever reason. I always ended up going back to GUI editors like [SublimeText][sublime] and [Light Table][lighttable].

For quick text editing from the command line, I was always a fan of [aoeui][aoeui] (a simple, lightweight editor optimized for the [Dvorak][dvorak] keyboard layout), and it served me well for quick tasks like editing config files or jotting down ideas. 
aoeui's key bindings are nice and intuitive -- so much so that I even started writing [a Light Table plugin][lt-aoeui] to provide aoeui key bindings in Light Table. This exercise in optimizing my text editing environment effectively made me reconsider my resigned choice to use GUI text editors, and ironically, led me to abandon aoeui and start using Vim.

I fell in love with Vim almost immediately. I decided to try it on a whim -- I had tried to become an Emacs user before without success, so I became curious about the other camp. I was pleasantly surprised by how easy it was to learn Vim's key bindings. 
As a Dvorak typist, I was also surprised at how natural it felt to use Vim's default key bindings without modifications. The `hjkl` movement system is clearly designed for QWERTY, but the corresponding positions of these keys in the Dvorak layout actually end up working out pretty well:

<img src="{{ site.url }}/assets/2015-06-06-dvorak-vim.png" width="480" title="hjkl locations in the dvorak layout. (source: http://deskthority.net/keyboards-f2/anyone-using-the-workman-or-norman-layouts-t8921.html)">

`h` and `l` are still essentially under your right pointer and pinkie (as a bonus, you don't have to shift your hand over!), and `j` and `k` are still right next to each other, they're just under your left middle and pointer fingers. 
I think I actually prefer this to the QWERTY positions of these keys, as it clearly separates out horizontal from vertical movement. I sincerely doubt this is by design, but it's a nice plus for Dvorak users. 
I've also found that the rest of the key bindings feel just fine under my Dvorak-inclined fingers -- the idiom with Vim key bindings seems to be not the location of the keys, but the mnemonics for remembering them. The result is that typing `d2w` (**d**elete **2** **w**ords) feels about the same in QWERTY as it does in Dvorak. 

Customizing my Vim setup has also been a pleasant experience. I started with the "awesome version" of [this guy's Vim configuration][ultimate-vim], which includes a bunch of useful plugins and custom key bindings, then added my own tweaks. 

I could probably write several blog posts about the awesome things I can do with Vim, but this is already starting to get a little big for a vignette, so I'll have to move on. Sufficeth to say that I actually get a little excited now whenever I need to edit some text -- using Vim is just that pleasant! 

[emacs]: http://www.gnu.org/software/emacs/
[vim]: http://www.vim.org/
[sublime]: http://www.sublimetext.com/
[lighttable]: http://lighttable.com/
[aoeui]: http://aoeui.sourceforge.net/
[dvorak]: http://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard
[lt-aoeui]: http://github.com/daveyarwood/aoeui
[ultimate-vim]: https://github.com/amix/vimrc

# Fish Shell

<a href="{{ site.url }}/assets/2015-06-11-fish.png" class="img-link">
  <img src="{{ site.url }}/assets/2015-06-11-fish.png" width="417" height="441" title="fish shell">
</a>

I was never really dissatisfied with bash. It's a great shell, and you can do all kinds of awesome things with it. But let's face it, folks -- [this is the 90's][fish]. The "modern shell" is a thing now. There are a plethora of alternative shells out there, and shells like fish and especially [zsh][zsh] seem to be getting very popular. Like a lot of things, I tried it out on a whim and fell in love with it. Why did I choose fish over zsh? I didn't, really. 
fish drew me in first with its style -- the name, the playful headline "Finally, a command line shell for the 90s" (fish was released in 2005), that ASCII art fish... it all really grabbed my attention. I had every intention of trying zsh next if I didn't like fish, but I ended up totally loving fish and I haven't looked back since. 

By far the strongest feature of fish is its autosuggestions. Based on your command history and the current working directory, fish will suggest previous commands you have entered, much the same way that a web browser will suggest previous URLs you have visited. 
You can see these suggestions in light gray as you type. To choose the current autosuggestion, you can press either the right arrow key, or Ctrl+F. You can even start typing a partial command (e.g. `ssh `) and then press the up arrow to browse through all of your previous commands starting with what you have typed. 
I use this feature constantly. Not having to do `history | grep foo` every time I can't remember a particular command I entered is really refreshing. In fact, fish's autosuggestions have become so crucial to my shell experience that it's totally ruined bash for me!

fish also has really smart (and customizable) autocompletions. Out of the box, you can type git commands like `git checkout` and press tab, and you'll see all of the local and remote branches for the current directory as possible completions. fish will even parse your installed man pages and give you relevant options as autocompletions (showing you docstrings), for when you can't remember if that option was supposed to be `-c` or `-C`. Super helpful.

fish does things a little differently than bash, which can make for a rocky transition if you're an advanced bash user and you want to still be able to use all of the same shortcuts (for example, `!!` and `!$` do not work in fish). For the most part, though, I have been able to copy & paste bash commands and they will work just fine in fish. The most common thing I have to replace is `$(this subshell syntax)`, which in fish `(looks like this)`. 
The nice thing is that if I ever really do need to run a bash command as-is, I can always type `bash` to get a bash process, and run it from there. (I've rarely had to do this, though.)

Another thing that fish does differently than bash is the way that it handles environment variables and functions. Interestingly, fish has [three different scopes for variables][fishvars]! The local scope (`set VAR value`) only sets the value of the variable within the most inner currently executing block. 
The global scope (`set -g VAR value`) sets the value of the variable globally for the current fish session. 
And finally, the universal scope (`set -U VAR value`) is for variables intended to be shared between all fish sessions on a computer. This initially felt a little strange, coming from bash, but I quickly grew to enjoy the flexibility that it gave me. 
I've been putting some `set -gx SOMEVAR somevalue` lines in my `fish.config` (which is analogous to a `.bash_profile` -- its contents are executed every time you start a fish shell) for things that I always want set when I start a session, and for other things that I want to be set persistently, but which could change over time, I've found it convenient to run `set -Ux SOMEVAR somevalue` from the command line and the value just sticks persistently until I change it.

Another cool thing is that fish has a built-in type for lists of things, which is analogous to the `foo:bar:baz` syntax you see sometimes in bash (`$PATH` is a good example of this). In fish, you can actually treat these things as proper lists, and not just a string of things between colons. You can do things like `count $PATH`, `echo $PATH[1]`, etc. Appending a path to your `PATH` is as simple as `set PATH $PATH /some/new/path`. 

Functions are handled quite nicely in fish. The prompt goes multi-line (and indents properly) when you start to define one:

<a href="{{ site.url }}/assets/2015-06-11-fish-function.png" class="img-link">
  <img src="{{ site.url }}/assets/2015-06-11-fish-function.png" width="417" height="441" title="defining a function in fish shell">
</a>

fish makes it easy to work with functions interactively from the command line. You can type a function definition in directly, try it out, edit it if needed (`funced my-function` will open up the function definition in your `$EDITOR` of choice), and once you're happy with it, `funcsave my-function` will make it persistent by saving it in its own file in `~/.config/fish/functions`, a folder that fish conveniently sets up for you to hold your functions.
You can view a list of all the functions defined in your current session by typing `functions`, and print the function definition of any function by typing `functions some-function`. Overall, the fact that I can do so much to customize my shell (persistently) without having to keep going back and editing my `config.fish` makes me happy.

I haven't even touched on all of the awesome plugins that exist for fish. I based my fish configuration on [oh-my-fish][ohmyfish], a framework for managing your fish shell configuration that comes packed with a ton of great themes and plugins (it was inspired by [oh-my-zsh][ohmyzsh], a similar framework for zsh), so check that out if you want to get an idea of [some of the cool things it offers][ohmyfish-plugins]. 

[fish]: http://fishshell.com/
[zsh]: http://www.zsh.org/
[fishvars]: http://fishshell.com/docs/current/index.html#variables
[ohmyfish]: https://github.com/oh-my-fish/oh-my-fish
[ohmyzsh]: https://github.com/robbyrussell/oh-my-zsh
[ohmyfish-plugins]: https://github.com/oh-my-fish/oh-my-fish/tree/master/plugins

# Amethyst

<a href="{{ site.url }}/assets/2015-06-12-amethyst.png" class="img-link">
  <img src="{{ site.url }}/assets/2015-06-12-amethyst.png" width="360" height="225" title="amethyst">
</a>

I started using Amethyst around the same time I started using Vim. I had played with a tiling window manager before (specifically [this one][awesome] on a Thinkpad running Linux, and although I enjoyed it, there were a lot of missing pieces that ended up being dealbreakers. 
Essentially, I didn't like having to invest much time in setting up all the components that I wanted in the status bar -- I remember having a hard time setting up gmail-notifier and weather widgets in the status bar (although I'm sure some of that could be chalked up to my inexperience at the time). 
All in all, I liked the idea of tiling windows, but disliked the minimalist aesthetic. I ended up going back to [Xfce][xfce], a fairly simple and lightweight desktop manager with batteries included.

Flash forward 5 years or so and I'm doing all of my work on a Macbook. Although I'm pretty happy with this setup, I have found myself customizing it a fair amount, in some ways making it more like the Linux desktop environments I've set up in the past. When I noticed that a few of my coworkers were using OS X software to simulate a tiling window manager, I was inspired to check out [Amethyst][amethyst]. It turned out to be great!

If you're used to tiling window managers, there's really not a whole lot to write home about with Amethyst. It does most of the things you would expect, and it does them nicely. I can cycle through window layouts using `Ctrl-Shift-Space`. I can move the current window over to the main frame with `Ctrl-Shift-Enter`. I can nudge a window a little bigger or smaller using `Ctrl-Shift-H` (left) and `Ctrl-Shift-L`. 
I can rotate windows within the layout, I can move them around to different screens, and there are [all kinds of other features][amethyst-shortcuts] that I'm not even using. I don't know, it's nice, you should try it!

# *~ fin ~*

That was fun; maybe I'll do it again sometime with 3 new things.

[awesome]: http://awesome.naquadah.org/
[xfce]: http://www.xfce.org/
[amethyst]: https://github.com/ianyh/Amethyst
[amethyst-shortcuts]: https://github.com/ianyh/Amethyst#keyboard-shortcuts
