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
letting emails pile up that you'll get to "later" (which could be days, months,
or even years from now, or perhaps never). You can achieve Inbox Zero by being
disciplined about reviewing your inbox regularly (at least once a day) and
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
in order to reach Inbox Zero, which motivated me to mow the lawn.

After a while, I started wishing that I could see my upcoming tasks ahead of
time. I wanted to see into the future just slightly, so that I could mentally
prepare myself to work on a task that wasn't due yet. This would be better than
forgetting that I had a task scheduled, and then *BAM* -- I get an email,
signaling that I needed to do it right now!

Now, to be fair, you _can_ see all of your scheduled follow-ups by logging in at
followupthen.com -- and I did that from time to time -- but that's a little
cumbersome for something that I'd ideally like to do on a regular basis. Over
time, I've become more and more accustomed to doing things at the command line.
I'm already in a terminal most of the time, so it is typically a lot faster for
me to do something at the command-line as opposed to, say, logging into a
website, navigating to the right page, and clicking a button. I started pining
for a way to manage all of my projects and tasks at the command-line.

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
personal life. So, I started writing a program that I called [`ews`][ews] (named
after the Electronic Worksheet System that I had used in my past job). I was
envisioning `ews` as essentially a port of the AS400 system I had used, where
"cases" (i.e. projects, groups of related tasks) could be managed and summarized
in priority order.

I started writing this tool in [ClojureScript][cljs] targeting
[node.js][nodejs], but I got frustrated with the need to use callbacks when
interfacing with the node.js ecosystem, which was a show-stopper for me. I was
playing with [Rust][rust] at the time, so I did a basic rewrite in Rust, which I
was fairly happy with, although I realized that the strictness of the Rust
compiler caused me to work more slowly than I do in less strict languages.

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
wonder if maybe somebody else had already created something like this. After
some googling, I stumbled upon [this list of useful command-line
tools][useful-cli-tools], which included Taskwarrior, a feature-rich task
management application. So, I decided to give it a try.

# Enter Taskwarrior

I'd briefly encountered Taskwarrior before in the past and thought, "This is
cool, but how is it different from the other command-line TODO apps I've seen?"
I'd dismissed it as "just another TODO list app."

At that point, I'd already come across a number of command-line TODO list
managers in the open source space; it's a fun, easy project that any beginning
programmer can build and get working in a short amount of time. So, by
association, I had come to expect any command-line TODO manager to be simplistic
and fall short of my task management needs.

I didn't want a tool that would simply keep track of a list of tasks and let me
check them off when I did them.  This is akin to a traditional pen-and-paper
TODO list; I've always hated those because there's no way to assign dates to
things and filter out the noise of backlog tasks that aren't yet ready for
action.  It didn't occur to me that there might be a more sophisticated task
management CLI tool that had all of the features I needed in order to follow an
"Inbox Zero" style of task management. Taskwarrior turned out to be exactly what
I needed and more!

## Tasks, Projects, and Urgency

Adding and listing tasks is, of course, a breeze:

{% highlight text %}
$ task add mow the lawn
Created task 1.

$ task
[task next]

ID Age Description  Urg
 1 5s  mow the lawn    0

1 task
{% endhighlight %}

The default behavior when you run `task` is to run the command `task next`,
which lists your most urgent tasks, sorted by urgency.

Tasks can be modified in a number of ways, including, but not limited to:

* Adding tags.
* Categorizing the task as being part of a project.
* Setting the dates/times when the task will be visible, scheduled, and due.
* Assigning a priority (the default priorities are L, M, and H, and you can
  customize or replace them or add more priorities).
* Marking the task as "active" (i.e. you've started working on it).

Watch what happens to my task when I designate it as part of the "home" project:

{% highlight text %}
$ task 1 modify project:home
Modifying task 1 'mow the lawn'.
Modified 1 task.
The project 'home' has changed.  Project 'home' is 0% complete (1 task remaining).

$ task
[task next]

ID Age  Project Description  Urg
 1 2min home    mow the lawn    1

1 task
{% endhighlight %}

Notice that the urgency level changed from 0 to 1! We can see why if we view
information about the task:

{% highlight text %}
$ task 1
No command specified - assuming 'information'.

Name          Value
ID            1
Description   mow the lawn
Status        Pending
Project       home
Entered       2018-05-04 19:56:15 (2min)
Last modified 2018-05-04 19:58:56 (8s)
Virtual tags  PENDING READY UNBLOCKED LATEST PROJECT
UUID          906c34ce-b065-4736-ab8e-6cecb5099c29
Urgency          1

    project      1 *    1 =      1
                            ------
                                 1

Date                Modification
2018-05-04 19:58:56 Project set to 'home'.
{% endhighlight %}

It turns out that Taskwarrior considers a task to be higher priority if it is
part of a project, which I think makes sense. I also like this because it
encourages me to assign a project to tasks whenever possible.

For the sake of example, I'll add another task that has a different project.  I
can concisely add the task and assign the project in a single command:

{% highlight text %}
$ task add write blog post about taskwarrior project:blog
Created task 2.
The project 'blog' has changed.  Project 'blog' is 0% complete (1 task remaining).

$ task
[task next]

ID Age   Project Description                       Urg
 1 16min home    mow the lawn                         1
 2 31s   blog    write blog post about taskwarrior    1

2 tasks
{% endhighlight %}

Notice that both tasks are the same urgency level (1) because they're both tasks
that have a project, and out-of-the-box, Taskwarrior doesn't know which tasks
and projects I consider to be the most urgent. But it turns out that I can
customize that by setting up "coefficients" that are applied whenever a task
meets certain criteria. For example, I can specify that a task is more important
if it belongs to the "home" project:

{% highlight text %}
$ task config urgency.user.project.home.coefficient 2.0
Are you sure you want to add 'urgency.user.project.home.coefficient' with a value of '2.0'? (yes/no) y
Config file /home/dave/.taskrc modified.

$ task
[task next]

ID Age   Project Description                       Urg
 1 24min home    mow the lawn                         3
 2 8min  blog    write blog post about taskwarrior    1

2 tasks

$ task 1
No command specified - assuming 'information'.

Name          Value
ID            1
Description   mow the lawn
Status        Pending
Project       home
Entered       2018-05-04 19:56:15 (24min)
Last modified 2018-05-04 19:58:56 (22min)
Virtual tags  PENDING READY UNBLOCKED PROJECT
UUID          906c34ce-b065-4736-ab8e-6cecb5099c29
Urgency          3

    project           1 *    1 =      1
    PROJECT home      1 *    2 =      2
                                 ------
                                      3

Date                Modification
2018-05-04 19:58:56 Project set to 'home'.
{% endhighlight %}

Now, mowing the lawn is at the top of my list because I've configured the "home"
project to be more important than others. I chose a coefficient of 2.0 here,
which is rather arbitrary, but the important thing is how that coefficient
compares to other coefficients that I've defined. For example, if I had another
project that I considered even more important, I might give it a coefficient of
2.5 or 3.0.

Taskwarrior considers a number of other factors when determining how urgent a
given task is. Here's a real example from my tasks:

{% highlight text %}
Urgency               18.08

    project        1 *    1 =      1
    active         1 *    4 =      4
    scheduled      1 *    5 =      5
    blocking       1 *    8 =      8
    age        0.041 *    2 =  0.082
                              ------
                               18.08
{% endhighlight %}

This task is particularly urgent because I've designated it as blocking another
task by setting `depends:25` (25 being the ID of this task) on the other task.
The other task won't show up in my list until I've completed this task, which
makes this task more urgent. Makes sense.

I've also marked this task as "active" by running `task 25 start`, so that makes
it more urgent because, I guess, it's easier to finish a task you've already
started, and when you finish a task, that motivates you to keep working on other
tasks.

Taskwarrior also prioritizes "scheduled" tasks over a task that you've added
without thinking about when you want to do it, which really means you don't care
about finishing that task as much, when it comes down to it.

Older tasks are also given priority, which I think is good because nothing
demotivates me more than having really old items on my TODO list, looming on the
backburner, taunting me with my inability to complete them. So I appreciate that
Taskwarrior gives these tasks priority, encouraging me to finish them and move
onto newer things.

These are all good decisions, in my book. With minimal effort, I can enter all
of my tasks into Taskwarrior and describe them as belonging to projects,
blocking other tasks, having scheduled dates and due dates, etc., and I can
trust Taskwarrior to put them into the priority order that makes the most sense.

## Task Management, Inbox Zero style

The most crucial aspect of Taskwarrior, in my opinion, is the way that it allows
you to assign dates and times to tasks, both controlling when a task is due
(which affects how urgent it is) and when it is scheduled (which affects when
you start to see it in your list of tasks that are ready to be done).

Let's look at my example tasks again:

{% highlight text %}
$ task
[task next]

ID Age   Project Description                       Urg
 1 57min home    mow the lawn                         3
 2 41min blog    write blog post about taskwarrior    1

2 tasks
{% endhighlight %}

Right now, it's almost 9 PM, so mowing the lawn is not really an option. And I
know that I'll be busy tomorrow (Saturday). So, I figure that Sunday is going to
be the next time that I can mow the lawn. So, I'll schedule mowing the lawn for
Sunday:

{% highlight text %}
$ task 1 modify scheduled:sunday
Modifying task 1 'mow the lawn'.
Modified 1 task.
Project 'home' is 0% complete (1 task remaining).
{% endhighlight %}

Now, I can list all tasks that are ready for work, sorted by urgency, with the
`task ready` command:

{% highlight text %}
$ task ready

ID Age   Project Description                       Urg
 2 44min blog    write blog post about taskwarrior    1

1 task
{% endhighlight %}

Notice that "mow the lawn" is not part of this list. That's because it's
scheduled for Sunday, which means I can't work on it until then. So Taskwarrior
helpfully hides it from me, eliminating a source of noise in my TODO list. This
is absolutely vital to the way that I approach task management! It's what allows
me to achieve Inbox Zero with my tasks.

I like this workflow so much, I've even added a count of tasks that are ready
for work (by parsing the output of `task ready`) to my command-line prompt. This
motivates me to take care of my TODO list as soon as possible, the same way
that my email inbox's unread message count motivates me to tend to my email.

{% highlight text %}
blog.djy.io (1 task ready) → task 2 done
Completed task 2 'write blog post about taskwarrior'.
Completed 1 task.
You have more urgent tasks.
The project 'blog' has changed.  Project 'blog' is 100% complete (0 of 1 tasks remaining).

blog.djy.io → task ready
No matches.
{% endhighlight %}

Ahh, so satisfying!

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
