---
layout: post
title: "Taskwarrior, where have you been all my life?"
tags:
  - productivity
  - taskwarrior
  - followupthen
published: true
---

{% include JB/setup %}

<p align="center">
  <img src="{{site.url}}/assets/2018-04-27-taskwarrior-screenshot.png"
       alt="Screenshot of Taskwarrior in action"
       title="Screenshot of Taskwarrior in action"
       width="800"
       height="146"/>
</p>

I've been thinking a lot about task management lately. I've actually been
thinking about it for years. I've always been searching for the optimal way to
sort through the bajillion things I have to do and remain productive.

This all started when, as a programmer, I realized that I had the power to
automate the tasks that I found repetitive in my digital life. I would write
scripts, for example, to do things like organize my photos, clean up my music
library, and back up my data. Over the years, I've developed my own homegrown
approach to task management, which has included a couple of attempts at writing
a command-line tool to manage my tasks in a way that's in line with my approach.
Then, recently, I discovered that there is already a robust command-line tool
that does exactly what I need.

That tool is [Taskwarrior][taskwarrior]. But before I get into it, here's a
brief dive into the journey that led me to using it.

# Inbox Zero: my gateway drug

Around the same time that I was starting to write scripts to automate the
monotonous parts of my day-to-day life, I was also discovering the joy of [Inbox
Zero][inboxzero]. If you're unfamiliar with Inbox Zero, the basic idea is that
you endeavor to keep your email inbox empty as much as possible, instead of
letting emails accumulate that you'll get to "later" (which could be days,
months, or even years later, or perhaps never). You can achieve Inbox Zero by
being disciplined about reviewing your inbox regularly (at least once a day) and
taking action on every email. Taking action on an email can mean deleting or
archiving it, replying (even if a quick reply is all you have time for), or
perhaps making a note for yourself on your calendar to do something later.

(You might be wondering what Inbox Zero has to do with task management. That
will become clear very shortly. Read on!)

# FollowUpThen: email as task manager

Sometime around 2013, I discovered an excellent, free service called
[FollowUpThen][fut]. The elevator pitch for FollowUpThen is that you can send or
forward an email to an address like `tomorrow@followupthen.com` (or
`tomorrow@fut.io`, for short) and tomorrow at 6 AM, the email that you sent or
forwarded will arrive in your inbox, like clockwork. FollowUpThen supports a
[wide variety][fut-formats] of time and date formats, many of which are highly
useful. I often found myself forwarding an email to `2weeks@fut.io` or sending
an email to `september@fut.io`, for example.

FollowUpThen quickly became the primary tool in my Inbox Zero toolbox. If I had
a lot of work to do and a handful of emails that I just didn't have time for at
the moment, I could use FollowUpThen to "snooze" the emails until a particular
time later in the day when I knew I would be more available.

I also started to use FollowUpThen as a task manager. For example, if I was
planning to mow the lawn on Saturday, I would send an email with the subject
`mow the lawn` to `saturday@fut.io`. Then when Saturday rolled around, I would
get an email with the subject `mow the lawn`, and I would have to mow the lawn
in order to reach Inbox Zero, thereby motivating me to mow the lawn.

After a while, I started wishing that I could see my upcoming tasks ahead of
time. I wanted to see into the future just slightly, so I could mentally prepare
myself to work on a task that wasn't due yet. This would be better than
forgetting that I had a task scheduled, and then *BAM* -- I get an email,
signaling that I needed to do it right now! Now, to be fair, you _can_ see all
of your scheduled follow-ups by logging in at followupthen.com -- and I did that
from time to time -- but that's a little cumbersome for something that I'd
ideally like to do on a regular basis. Over time, I've become more and more
accustomed to doing things at the command line. I'm already in a terminal most
of the time, so it is typically a lot faster for me to do something the
command-line way as opposed to, say, logging into a website, navigating to the
right page, and clicking a button. I started pining for a way to manage all of
my projects and tasks at the command-line.

# Attempt 1: `ews`

As I imagined an ideal command-line task management workflow, I found myself
thinking about the ancient AS400 system that I used in my previous life as a
claims adjudicator.

I was managing a caseload of anywhere from 50 to 200 claims, each of which had a
log of past actions (called _log items_) and a schedule of upcoming actions
needed (called _action items_). Some of the action items were designated `IA`,
which meant that Immediate Action was needed. This was really just a way of
designating some action items as being higher priority than others.

The best part of the system was the case summary screen. This was a top-level
summary of all of my cases, with statistics about how many cases fell into
certain categories.  For example, there was a "Cases needing immediate action"
category, which displayed the number of cases with Immediate Action follow-up
actions either due or overdue. There were also useful categories like "Cases
without action in 30 days." When I was working at that job, I developed a highly
productive workflow in which I was able to effectively manage large caseloads
and ensure that the most urgent tasks were done first. My daily process was to
go through the categories on the case summary screen in priority order, and
endeavor to get the number to the right of each category down to zero, over
time. I was following the Inbox Zero philosophy with my workload, and it worked
very well for me.

I wanted to replicate this sort of workflow for day-to-day task management in my
personal life. So, I started building a tool that I called [`ews`][ews] (named
after the Electronic Worksheet System that I had used in my past job). I was
envisioning `ews` as essentially a port of the AS400 system I had used, where
"cases" (i.e. projects, groups of related tasks) could be managed and summarized
in priority order. I started writing this tool in [ClojureScript][cljs]
targeting [node.js][nodejs], but I got frustrated with the need to use callbacks
when interfacing with the node.js ecosystem, which was a show-stopper for me. I
was playing with [Rust][rust] at the time, so I did a basic rewrite in Rust,
which I was fairly happy with, although I realized that the strictness of the
Rust compiler caused me to work more slowly than I do in less strict languages.

I was on the verge of yet another rewrite in [Crystal][crystal] when I finally
took a step back and thought about what I really wanted to create. This led me
to my next iteration, which was different enough that I decided to give it a
different name.

# Attempt 2: `tdz`

I had a shower-thought that Google Calendar provides a database for events and
an API for interacting with them, so I could leverage this platform to build my
tool. So, I started writing [tdz][tdz] as an experiment in that direction. (NB:
I didn't get very far, so don't expect to find much in that repo!)

While I was thinking about how my mental model of projects and tasks could map
onto the Google Calendar API, I also realized that the model could be
simplified. I didn't really need to manage projects; I only needed to manage
individual tasks that have scheduled dates and due dates. (If I could organize
them into projects, that would be icing on the cake, but it wasn't a
requirement.)

With the conceptual model simplified to just tasks, I (finally) started to
wonder if maybe somebody else had already created something like my idea. So,
after some googling, I stumbled upon [this article][useful-cli-tools], which
mentions Taskwarrior, a feature-rich, command-line TODO management application.

# Enter Taskwarrior

I'd briefly encountered Taskwarrior before in the past and thought, "This is
cool, but how is it different from the other command-line TODO apps I've seen?"

At that point, I'd already come across a number of command-line TODO list
managers in the open source space; it's a fun, easy project that any beginning
programmer can build and get working in a short amount of time. So, by
association, I had come to expect any command-line TODO manager to be simplistic
and devoid of useful features.

I didn't want a tool that would simply keep track of a list of tasks and let me
check them off when I did them.  This is akin to a traditional paper-and-pen
TODO list; I've always hated those because there's no way to assign dates to
things and filter out the noise of backlog tasks that aren't yet ready for
action.  It didn't occur to me that there might be a more sophisticated task
management CLI tool that had all of the features I needed in order to follow an
"Inbox Zero" style of task management. Taskwarrior turned out to be the right
tool for the job.

As I started to explore Taskwarrior, I was blown away. It turned out that it was
exactly the tool I not only envisioned, but had started to build for myself.
Getting to throw away what I was working on and use a high-quality tool that
already exists is an amazing feeling! It goes to show you that when you have an
idea for a project, it's worth investing some time up-front researching and
considering alternatives.

[taskwarrior]: https://taskwarrior.org
[inboxzero]: https://www.google.com/search?q=inbox+zero
[fut]: https://followupthen.com
[fut-formats]: https://www.followupthen.com/how#timeformats
[ews]: https://github.com/daveyarwood/ews
[tdz]: https://github.com/daveyarwood/tdz
[cljs]: https://clojurescript.org
[nodejs]: https://nodejs.org
[rust]: https://rust-lang.org
[crystal]: https://crystal-lang.org
[useful-cli-tools]: https://stackify.com/top-command-line-tools/
