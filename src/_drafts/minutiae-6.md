---
layout: post
title: "Minutiae #6: Reorganizing my vimrc, PlantUML, OSC/TCP/UDP"
category: something
tags:
  - osc
  - udp
  - tcp
  - vim
  - plantuml
published: true
---

{% include JB/setup %}

Here are a few things that I've been tinkering with recently:

# Reorganizing my vimrc

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

# PlantUML

A coworker of mine introduced us to [PlantUML][plantuml] a year or two ago and
we used it to create an architecture diagram of our distributed systems. I
revisited that old architecture diagram recently and I ended up making a bunch
of tweaks and updates just for fun. The PlantUML language is intuitive and it's
quite nice to be able to throw together quick diagrams by editing text.

As an example, here's the PlantUML source for a basic architecture diagram for
[Alda][alda]:

{% highlight plantuml %}
@startuml

actor User

[Client]

[Server] #lightgray

[Worker 1] #lightgray
note left
  <&musical-note>
end note

[Worker 2] #lightgray
[Worker 3] #lightgray

User ---> Client: alda play -f some-file.alda
Client -> Server: Command
Server -> [Worker 1]: Command
[Worker 1] --> Server: Response
[Worker 2] <..> Server
[Worker 3] <..> Server
Server --> Client: Response
Client -> User: ""Playing...""

@enduml
{% endhighlight %}

And here's the output:

<center>
<img src="{{ site.url }}/assets/2019-12-11-alda-plantuml.png"
     title="Alda architectural diagram made using PlantUML" />
</center>

# Working with OSC: UDP vs. TCP

If you've seen [my talk at Strange Loop this year][strange-loop-talk], you may
have noticed, during the part where I talked about the future direction of Alda
where we'll be using [OSC][osc] to communicate between the client and the player
processes. I've been spending a lot of my time lately implementing this, and
it's coming along nicely.

An interesting development from the last couple weeks is that I ended up
deciding to use TCP instead of UDP for this communication.

I was initially hoping to use UDP because latency is important, and I was
assuming that any dropped packets could be re-sent easily.

It turns out that there is a limit to the size of a UDP packet. From what I read
in [this discussion][udp-discussion], the UDP protocol allows a limit of 64K
bytes, but the practical guaranteed limit is a measly 576 bytes. Because the OSC
protocol adds a small number of additional bytes, it is best to restrict the
payload of each packet to a smaller number like 512 bytes, just to be safe.

As a consequence, an Alda score of sufficient size translates into a UDP packet
that can't be sent because it's larger than the actual limit, which can vary
from system to system. A simple "hello world" 5-note example score serialized
into a 544-byte UDP packet. Longer scores easily got up into the tens of
thousands of bytes! I observed that if the score was long enough, the packet
seemed to vanish into thin air, probably because it exceeded the particular
limit of my system, which seems to be somewhere around 64K bytes.

"No problem," I thought. "I'll break the bundle up into a couple hundred
packets that are each under 512 bytes!"

So I tried that, but I ran into some serious technical hurdles. One issue is
that the order in which the packets are received is not guaranteed, so I had to
include a sequence number on each packet and reconstruct them in order on the
receiving end. Another issue is that packets can be lost. I knew about that
property of UDP coming into this, but I had no idea that the packet loss is so
frequent! A significant amount of the time, less than 100% of the packets
arrived. At that point, it became clear to me that UDP wouldn't work for my use
case. TCP is really more appropriate for any scenario where you care about
losing even a single packet.

I haven't been able to fully test using TCP yet, but I'm hopeful that the
trade-off in latency won't be too bad. My current blocker is that neither of the
OSC libraries I'm using ([go-osc] and [JavaOSC]) currently support sending OSC
packets over TCP. So, I've been digging into how these two libraries work and
preparing to contribute TCP support to both. Wish me luck!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[ultimate-vimrc]: https://github.com/amix/vimrc
[spf13-vim]: https://github.com/spf13/spf13-vim
[minimal-vimrc]: https://gist.github.com/benmccormick/4e4bc44d8135cfc43fc3
[vim-dotfiles]: https://github.com/daveyarwood/dotfiles/tree/master/vim
[plantuml]: https://plantuml.com/
[alda]: https://alda.io
[strange-loop-talk]: https://www.youtube.com/watch?v=6hUihVWdgW0
[osc]: https://en.wikipedia.org/wiki/Open_Sound_Control
[udp-discussion]: https://forum.juce.com/t/osc-blobs-are-lost-above-certain-size/20241/2
[go-osc]: https://github.com/hypebeast/go-osc
[JavaOSC]: https://github.com/hoijui/JavaOSC
