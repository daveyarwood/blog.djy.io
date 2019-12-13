---
layout: post
title: "Working with OSC: UDP vs. TCP"
category: alda
tags:
  - osc
  - udp
  - tcp
published: true
---

{% include JB/setup %}

If you've seen [my talk at Strange Loop this year][strange-loop-talk], you may
have noticed, during the part where I talked about the future direction of
[Alda][alda] where we'll be using [OSC][osc] to communicate between the client
and the player processes. I've been spending a lot of my time lately
implementing this, and it's coming along nicely.

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

[tweet]: https://twitter.com/dave_yarwood/status/1205472303892570112

[strange-loop-talk]: https://www.youtube.com/watch?v=6hUihVWdgW0
[alda]: https://alda.io
[osc]: https://en.wikipedia.org/wiki/Open_Sound_Control
[udp-discussion]: https://forum.juce.com/t/osc-blobs-are-lost-above-certain-size/20241/2
[go-osc]: https://github.com/hypebeast/go-osc
[JavaOSC]: https://github.com/hoijui/JavaOSC
