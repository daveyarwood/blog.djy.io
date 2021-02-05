---
layout: post
title: "How I deploy my personal projects"
tags:
  - deployment
  - namecheap
  - digitalocean
  - jekyll
  - netlify
  - nginx
  - vps
published: true
---

{% include JB/setup %}

Just for fun, here is a quick run-down of how I deploy my personal projects. If
you're reading this and you have projects of your own that you might like to
deploy, then hopefully some part of this will be helpful to you.

# Domains and DNS

Whenever I've bought a domain, I've used [Namecheap][namecheap], not necessarily
because it's the best option, but just because I've always found Namecheap to be
easy and intuitive, and it does everything that I need when it comes to
registering and managing domains.

Namecheap [gives you a few options][namecheap-nameserver] about what DNS
nameserver to use. Depending on the project, I use either their free, default
DNS service, or I choose the "Custom DNS" option and use DigitalOcean's
nameservers if the project is hosted there. (I'll say more about DigitalOcean
below.)

Namecheap also makes it straightforward to define [all kinds of host
records][namecheap-host-records]. I'm pretty far from understanding what all of
the different kinds of records (A, AAAA, ALIAS, CNAME, NS, SRV, ...) are for,
but I've learned just enough to be able to do the basic stuff that you usually
need to do when you're building small websites and web applications.

# Static websites

When I was a kid, I learned how to write HTML and CSS, built a lot of
stupid-looking websites, and put them up on the Internet for the world (well,
mostly just my friends) to see. This was the late 90's and early 00's, and as
far I could tell at the time, the only way you could do this was to keep a copy
of your website on your computer and copy the files over to your web space any
time you make changes, using an [FTP][ftp] client. Git didn't exist yet, let
alone GitHub Pages, and I couldn't have told you what source control was if
you'd asked me. This felt alright to me at the time, but in retrospect, it's
funny how painfully manual it was to deploy my websites back then.

Thankfully, it's a lot easier these days to whip up a simple, nice-looking
website and make it pubicly available on the Internet, even on a custom domain
with an SSL certificate.

When I first created this blog in 2014, I built it using [Jekyll][jekyll] and
deployed it via [GitHub Pages][github-pages]. This was the path of least
resistance, as GitHub did (and still does) an excellent job of documenting how
to set up your own GitHub Pages site with Jekyll. I still think this is a pretty
nice setup for new programmers who want to get into building their own websites.

Fun fact: this blog is _still_ built using Jekyll. I've re-styled the template a
few times, and I've migrated the site away from GitHub Pages, but as much as I'm
not crazy about Jekyll, it still gets the job done well enough that I have no
interest in building it all again using some other static website generator.
Maybe if I were to start over, I would explore other options that are available
now, like [Hugo][hugo] or something. But for now, Jekyll is working out just
fine.

I mentioned just now that at one point, I migrated this site away from GitHub
Pages. That was because I found [Netlify][netlify]. Netlify does a lot of
things, but the big thing they do is that they make it easy to automate
deploying your static sites for free. It's trivial to take a site that you're
deploying to GitHub Pages and convert it to use Netlify instead. Why would you
want to do that? Because Netlify gives you a lot more control over the way your
site is deployed. The reason I switched is that I ended up wanting to use some
Jekyll feature that will only work on newer versions of Jekyll, and I found that
with GitHub Pages, I couldn't control the version of Jekyll that was used to
build the site. With Netlify, I can control pretty much everything about the
build, including any dependencies I want to bring in and what command to run.
Another awesome thing about Netlify is that they make it super easy to set up
your site to serve on a custom domain, and they'll even generate an SSL
certificate for you automatically. Once you're set up, you can deploy your site
effortlessly simply by pushing commits to the default branch of your repo.

# My VPS

> TODO: To discuss:
> * My single, $5/mo Droplet and what I use it for
> * nginx / wildcard DNS record
> * recently started using DigitalOcean App Platform to build an API for Alda
>   releases, from version 2 onward

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[namecheap]: https://www.namecheap.com/
[namecheap-nameserver]: https://www.namecheap.com/support/knowledgebase/article.aspx/9434/10/using-default-nameservers-vs-hosting-nameservers/
[namecheap-host-records]: https://www.namecheap.com/support/knowledgebase/article.aspx/579/2237/which-record-type-option-should-i-choose-for-the-information-im-about-to-enter/
[ftp]: https://en.wikipedia.org/wiki/File_Transfer_Protocol
[jekyll]: https://jekyllrb.com/
[github-pages]: https://pages.github.com/
[hugo]: https://gohugo.io/
[netlify]: https://www.netlify.com/
