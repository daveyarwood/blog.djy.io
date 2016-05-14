---
layout: post
title: "Vignettes: Vimwiki, HTTPie, jq"
tags:
  - vim
  - httpie
  - http
  - jq
  - json
published: true
---

{% include JB/setup %}

I [tried this once before][vignettes1] and it was pretty fun. I continue to find and use awesome things (the internet has many of them), so here are a few more things I've been enjoying lately.

[vignettes1]: {% post_url 2015-06-12-vignettes-vim-fish-shell-amethyst %}

# Vimwiki

<a href="{{ site.url }}/assets/2016-05-10-vimwiki.png" class="img-link">
  <img src="{{ site.url }}/assets/2016-05-10-vimwiki.png" width="450" height="280" title="vimwiki (source: http://vimwiki.github.io)">
</a>

I think keeping a [personal wiki][pwiki] is a great way to organize your life. It's like the digital equivalent of a handy scratchpad that you can use to jot down notes about anything that comes to your mind. (I use mine to keep track of fragments of melodies and lyrics that pop into my head, stupid band name ideas, programming project ideas, talk proposals, and all kinds of other things.) You can organize your ideas into separate files and link them to each other. Over time, you'll gradually build your own interconnected web of information that is useful to you.

[Vimwiki][vwiki] is a Vim plugin that lets you maintain a personal wiki in the form of a bunch of interlinked text files. Wiki pages can be written in Markdown or MediaWiki syntax, and the interface and keybindings are quite intuitive. Links can be made easily by highlighting text and pressing Enter, then opened by pressing Enter again.

[pwiki]: https://en.wikipedia.org/wiki/Personal_wiki
[vwiki]: http://vimwiki.github.io

# HTTPie

<a href="{{ site.url }}/assets/2016-05-11-httpie.png" class="img-link">
  <img src="{{ site.url }}/assets/2016-05-11-httpie.png" width="450" height="375" title="vimwiki (source: http://vimwiki.github.io)">
</a>

[HTTPie][httpie] is a user-friendly cURL replacement. In addition to pretty-printing and syntax-highlighting JSON responses, it provides a nicer syntax for setting request parameters that I find easier to remember than the equivalent cURL syntax. HTTPie also features a number of sane defaults for things like Accept and Content-Type headers, making it fast and easy to make HTTP requests without having to do as much double-checking that your headers are correct.

The "hello world" example in the HTTPie documentation does a nice job of illustrating the relative ease of using it instead of cURL:

{% highlight shell %}
# cURL
curl -i -X PUT httpbin.org/put -H Content-Type:application/json -d '{"hello": "world"}'

# HTTPie
http PUT httpbin.org/put hello=world
{% endhighlight %}

You can also redirect input from files, which is a handy feature:

{% highlight shell %}
http PUT httpbin.org/put < hello_world.json
{% endhighlight %}

I've been using HTTPie for a while, and I use it 90% of the time instead of cURL. There was a slight learning curve in that advanced usage requires a basic understanding of what defaults HTTPie uses, but in my experience with it so far, the defaults make sense in the majority of cases.

The 10% of cases where I *don't* use HTTPie are support-related, e.g. when I'm debugging another person's cURL command that isn't working, or when I'm seeking support for an HTTP request that *I* can't get to work, and I need to provide a cURL example of the request that I'm trying. cURL is the de facto standard way to make HTTP requests, so I'm effectively forced to use cURL when other people are involved, or else I'd have to explain what HTTPie is and another layer of complexity would be introduced to the support issue. This is probably for the best, as it keeps my cURL skills from getting rusty.

[httpie]: http://httpie.org

# jq

<a href="{{ site.url }}/assets/2016-05-13-jq.png" class="img-link">
  <img src="{{ site.url }}/assets/2016-05-13-jq.png" width="450" height="300" title="vimwiki (source: http://vimwiki.github.io)">
</a>

I don't know which one of my coworkers started using [`jq`][jq] first, but it spread like wildfire! We work with JSON data almost constantly, and we also like to do things as much in line with the Unix philosophy as possible. Bearing those two things in mind, it was only natural that we would need a flexible command-line tool that we could pipe JSON to and manipulate it with ease.

For me, it wasn't immediately obvious that I would need such a thing -- editing JSON in a file is easy enough, right?  -- but ever since I started using `jq`, it has been utterly indispensable.

[jq]: https://stedolan.github.io/jq/

