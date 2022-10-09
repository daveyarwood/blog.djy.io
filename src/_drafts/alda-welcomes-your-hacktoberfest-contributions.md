---
layout: post
title: "Alda welcomes your Hacktoberfest contributions!"
category: alda
tags:
  - alda
  - open source
  - github
published: true
---

{% include JB/setup %}

An community member in the [Alda Slack group][alda-slack] recommended that I
register [Alda][alda] as an open source project for
[Hacktoberfest][hacktoberfest] participants to contribute pull requests to, so
after giving it some thought, I did!

The idea behind Hacktoberfest is that [the organizers][digitalocean] will reward
anyone who makes 4 contributions that are accepted to participating code
repositories during the month of October. The first 40,000 people to accomplish
this will receive either a tree planted in their name, or a free Hacktoberfest
2022 T-shirt.

> Hacktoberfest gained some [notoriety][shitoberfest] in 2020, when some open
> source maintainers were unpleasantly surprised to find their projects' repos
> bombarded with meaningless pull requests made with the sole intention of
> scoring a free T-shirt. I remember Alda receiving a couple PRs like that back
> in 2020, so I was initially a little cautious about the possibility of
> subjecting myself to that again, but from what I've read, DigitalOcean took
> the complaints seriously and has implemented counteractive measures, including
> implementing a spam reporting system. Good on them!

If you're participating in [Hacktoberfest][hacktoberfest] this year, please have
a look at the open issues labeled `hacktoberfest` in the [alda-lang/alda] and
[alda-lang/alda.io] repos and consider contributing to Alda!

---

Incidentally, I also took this as an opportunity to try out [GitHub
Discussions][gh-discussions] as a way to separate bug reports from discussions
about future features and enhancements that could be made to Alda. Up until now,
I've been using GitHub issues to track both of these things, but a downside of
that approach was that Alda had dozens of open issues, some having been created
as far back as 6 years ago, and this has made it more difficult to find and keep
track of the bug reports. For Hacktoberfest, I already needed to go through and
tag the issues that I felt were actionable for new contributors with the
`hacktoberfest` label. So, while I was at it, I decided to convert most of the
other issues (the ones that really represented longer term feature discussions)
into GitHub Discussions.

I'm happy with the result. I'm down to only 11 open issues (from 44), and I feel
that they all represent true issues/bugs with Alda that need to be addressed.
(And I'm hoping that Hacktoberfest participants might be able to help me with
that!).

You might think that I just swept those other 33 issues under the rug, but I'm
excited about [still having them around][alda-discussions] in the form of
Discussions. They look about the same as they did before when they were issues,
but now they're presented in a format more conducive to discussion. I like that
the comments, and especially the discussions themselves, are upvotable. This
means that the Alda community can upvote the feature ideas that they like the
most, and that can give me better visibility into the areas I should focus on
the most.

# What do you think?

Reply to [this tweet][tweet] with any comments, questions, etc.!

[tweet]: https://twitter.com/dave_yarwood/status/FIXME

[alda]: https://alda.io
[alda-slack]: https://slack.alda.io
[hacktoberfest]: https://hacktoberfest.com
[digitalocean]: https://digitalocean.com
[shitoberfest]: https://ongchinhwee.me/shitoberfest-ruin-hacktoberfest/
[alda-lang/alda]: https://github.com/alda-lang/alda/issues?q=is%3Aissue+is%3Aopen+label%3Ahacktoberfest
[alda-lang/alda.io]: https://github.com/alda-lang/alda.io/issues?q=is%3Aissue+is%3Aopen+label%3Ahacktoberfest
[gh-discussions]: https://github.com/features/discussions
[alda-discussions]: https://github.com/alda-lang/alda/discussions
