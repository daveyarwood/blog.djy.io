---
layout: post
title: "Clojure character utilities, now available as a clojar!"
category: 
tags: [clojure]

redirect_from: '/2014/12/25/clojure-character-utilities-now-available-as-a-clojar/'
---
{% include JB/setup %}

A couple months ago I posted about a [character utility library I whipped up for Clojure][char-utils]. It's still a work-in-progress, but I think it's in good enough shape for general use. I decided to make a [clojar][clojars] out of it, for anyone who might find it useful. Now anyone can try out the library by including `[djy "0.1.2"]` (0.1.2 is the latest version as of writing -- if you're reading this from the future, you may want to check the [clojars page][clojar] or [github repo][github] for the latest version number) as a dependency in your `project.clj` or `build.boot`, then `(require '[djy.char :as char])` and you're good to go.

[char-utils]: {% post_url 2014-10-14-a-character-utility-library-for-clojure %}
[clojars]: https://www.clojars.org
[clojar]: https://clojars.org/djy
[github]: https://github.com/daveyarwood/djy

This is my first ever clojar, which is a little exciting. The deploy process was refreshingly smooth thanks to the very awesome [Boot](http://www.boot-clj.com) build tool, created by two of my dashing coworkers at Adzerk. The [bootlaces](https://github.com/adzerk/bootlaces) library provides a few handy tasks for building and deploying snapshots or releases to Clojars -- after some quick & easy setup (check out the [`build.boot`](https://github.com/daveyarwood/djy/blob/master/build.boot)), I gained the ability to push a new version to Clojars whenever I want by simply updating the version number in `build.boot` and then running `boot build-jar push-release` or `boot build-jar push-snapshot`. Pretty awesome stuff.

(P.S. -- Merry Christmas!)
