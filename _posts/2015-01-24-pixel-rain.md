---
published: true
layout: post
title: "Pixel Rain"
category: music
tags: 
  - chiptune
  - quitasol
  - mml
---

{% include JB/setup %}

<br>
<center>
<iframe width="75%" height="166" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/187668774&amp;color=ff5500&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false"></iframe>
</center>
<br>

Here's a little blast from the past -- I just realized that I composed and programmed this "NES classical" piece for a composition class almost exactly 10 years ago. I had recently discovered [MML](http://battleofthebits.org/lyceum/View/PPMCK/), a music programming language that an increasingly vibrant community of chiptune musicians were using to make NES music. I was also studying music composition an UNC at the time. So, this piece represented a lot of things I was learning at the time about both classical music theory and programming NES music with MML. 

To give you a flavor of MML, here's a little excerpt of the MML code for *Pixel Rain*:

    #TITLE Pixel Rain
    #COMPOSER Quitasol
    #PROGRAMER 2005 Dave Yarwood
    #BANK-CHANGE 0,1
    #BANK-CHANGE 2,2
     
    @v2 = { 15 12 10 8 6 3 2 1 0 }
    @v3 = { 15 15 14 14 13 13 12 12 11 11 10 10 9 9 8 8 7 7 6 6 5 }
    @v0 = { 11 8 6 4 2 1 0 }
    @v1 = { 11 11 10 10 9 9 8 8 7 7 6 6 5 5 4 4 3 3 2 2 1 }
    @v4 = { 13 13 12 12 11 11 10 10 9 9 8 8 8 7 7 7 5 5 4 4 3 }
    @v5 = { 15 15 14 14 13 13 12 12 11 11 10 10 10 9 9 9 7 7 6 6 5 4 3 }
    @MP0 = { 8 4 3 }
    @MP1 = { 8 4 1 }
    @DPCM0 = { "samples\kick2.dmc",15 }
     
    A l8 o4 @01 v8 q8 MP0
    B l8 o4 @01 v8 q8 MP0
    C l8 o4 q8 MP0
    D l16
    E o0 l4
     
    ABCDE t125
     
    A g2f+2g1>c<b>ced+2e4^16. r32^8^2 c<b>ced+d4.c4^32 r64 r2 <f+4
    B d2d+2e2^8ec<gag+a>c<b4.ag4^16. r32^8^2 ag+a>c<a4.g+a4^32 r64 r4 >c2
    C b2>c2<b>e<bge2<a4.^16..r64ab>d+f+ MPOF e4d4c4<b4 MP0 a2b>dfe<a4^32 r64 >a2.
    DE r1^1^1^1^2.^8^64^1
     
    A g2f+2g1 MPOF gf+gb-a2 MP0 g4^16. r32^8^2 t110 gf+gb- t95 ab->c<a
    B d2d2e-2^8b-ge- MPOF ed+egf+2 MP0 g4^16. r32^8^2 t110 e-de-g t95 f+2
    C b-2>c2<b->e-<b-ge-2c2<a>cdf+ MPOF g4f4e-4d4 MP0 t110 c2 t95 d2
    DE r1^1^1^1 t110 r2 t95 r2

You can take a look at the complete MML file [here](https://gist.github.com/daveyarwood/c76643bf85f15608f874), if you're so inclined.