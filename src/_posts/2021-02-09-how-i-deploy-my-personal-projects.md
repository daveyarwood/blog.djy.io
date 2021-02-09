---
layout: post
title: "How I deploy my personal projects"
tags:
  - deployment
  - namecheap
  - digitalocean
  - circleci
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

Whenever I register a domain, I use [Namecheap][namecheap], not necessarily
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

Just as an aside: When I was a kid, I learned how to write HTML and CSS, built a
lot of stupid-looking websites, and put them up on the Internet for the world
(well, mostly just my friends) to see. This was the late 90's and early 00's,
and as far as I could tell at the time, the only way you could do this was to
keep a copy of your website on your computer and copy the files over to your web
space any time you make changes, using an [FTP][ftp] client. Git didn't exist
yet, let alone GitHub Pages, and I couldn't have told you what source control
was if you'd asked me. This felt alright to me at the time, but in retrospect,
it's funny how painfully manual it was to deploy my websites back then.

Thankfully, it's a lot easier these days to whip up a simple, nice-looking
website and make it publicly available on the Internet, even on a custom domain
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
build, including which dependencies to bring in and what command to run to build
the site. Another awesome thing about Netlify is that they make it super easy to
set up your site to serve on a custom domain, and they'll even generate an SSL
certificate for you automatically. After a quick and painless setup, you can
deploy your site by simply pushing commits to the default branch of your repo.

# DigitalOcean

I first started using [DigitalOcean][digitalocean] as a way to explore having my
own [VPS][vps] that I could use to deploy arbitrary static sites and web
applications. I ended up only using my VPS to host static sites, which I now
realize was kind of pointless, because I could have just used Netlify to host
all of them, and it would have been a lot easier and more convenient. But it
really wasn't pointless, because learning how to set up a VPS was a valuable
exercise in itself.

If you're curious about setting up a VPS, I will say that it's easy and fun to
do it with DigitalOcean. I paid $5 per month for a Droplet (i.e. server) that
ran 24/7 and could do anything I wanted. There are all kinds of useful things
that you can do with a VPS, but I ended up only using mine to host web pages and
other files. The setup for that was kind of interesting. I set up a wildcard
CNAME (`*.djy.io`) to direct to the IP address of my Droplet. Then, I followed
one of DigitalOcean's guides to set up [nginx][nginx] to serve the content from
various folders in `/var/www` (sites that I had written and uploaded to the
VPS). With this setup in place, I was able to create a new site whenever I
wanted by syncing the HTML and assets into a folder in `/var/www` and using a
simple nginx config file to specify which sites were to serve on which
subdomains (e.g. `something.djy.io`).

I got rid of the $5/month VPS once I figured out that I wasn't using it for
anything that Netlify couldn't handle for me in a much better way, and for free.

Lately, though, I have been using DigitalOcean again, to host an actual web
application. I built an API to provide information about new [Alda][alda]
releases, as part of the ground-up rewrite (Alda v2) that I've been working on
over the last couple of years.

There are two components to the Alda Releases API: the API server and the asset
storage. For the asset storage, I found DigitalOcean's [Spaces][do-spaces] to do
the job nicely. Spaces is an Amazon S3-compatible file storage service that is
affordable and has some nice features like a built-in CDN. I've set up a
[CircleCI][circleci] automated build pipeline that uploads the executables to a
DigitalOcean Space whenever I push a release tag up to the GitHub remote. The
API server has a background thread that regularly checks for updates to the
executables in the Space so that it can provide up-to-date information about
Alda releases.

I deploy the Alda API using the DigitalOcean [App Platform][do-app-platform], a
platform-as-a-service (PaaS) offering that automates building and deploying the
app every time I push a commit to my repo's default branch. App Platform is very
new (it was only released to the general public four months ago, in October
2020), and accordingly has some rough edges, but overall, using it to deploy the
Alda API has been a nice experience. There is the usual trade-off with using any
PaaS product, which is that you don't have to worry about infrastructure,
however, when something goes wrong, it can be difficult to see what's going on
under the hood. For a simple, low-maintenance (and low-cost) application like
this one, I think the trade-off makes sense, but it's not the kind of thing I
would do in my day job.

# That's it!

I hope you found this at least somewhat interesting!

# Comments?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/1359130014105632769

[namecheap]: https://www.namecheap.com/
[namecheap-nameserver]: https://www.namecheap.com/support/knowledgebase/article.aspx/9434/10/using-default-nameservers-vs-hosting-nameservers/
[namecheap-host-records]: https://www.namecheap.com/support/knowledgebase/article.aspx/579/2237/which-record-type-option-should-i-choose-for-the-information-im-about-to-enter/
[ftp]: https://en.wikipedia.org/wiki/File_Transfer_Protocol
[jekyll]: https://jekyllrb.com/
[github-pages]: https://pages.github.com/
[hugo]: https://gohugo.io/
[netlify]: https://www.netlify.com/
[digitalocean]: https://digitalocean.com
[vps]: https://en.wikipedia.org/wiki/Virtual_private_server
[nginx]: https://www.nginx.com/resources/wiki/
[alda]: https://alda.io
[do-spaces]: https://www.digitalocean.com/products/spaces/
[circleci]: https://circleci.com/
[do-app-platform]: https://www.digitalocean.com/products/app-platform/
