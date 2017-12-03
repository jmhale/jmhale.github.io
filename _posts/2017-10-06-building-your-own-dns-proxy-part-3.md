---
layout: default
title:  "Building your own DNS proxy, part 3: Automation!!"
date:   2017-10-06 17:00:00 -0500
---
In the first two posts, we've gone over how to build your own DNS "smart" proxy, like Unlocator and UnblockUS.

We covered the basics concepts and how to get a minimum viable product in [Part 1]({{ site.baseurl }}{% post_url 2017-01-02-building-your-own-dns-proxy-part-1 %}), and then extended that into a more robust version in [Part 2]({{ site.baseurl }}{% post_url 2017-01-18-building-your-own-dns-proxy-part-2 %}).

We're going to take it one step further and turn it into a one-click deploy using Jenkins.

<!--break-->

In my job as an Automation Engineer (or a DevOps engineer, saying what you want about that term), I strive to automate everything that I can. Even in my home environment, I don't want to manage the boring stuff by hand. Manually configuring core infrastructure has the huge potential to introduce errors, especially if you don't have your hands on it every day.

I'm not messing with this DNS proxy all the time. I just want it to work and then I can forget about it and work on other cool stuff (or binge watch Netflix). So, I want to be able to forget about it.

In the intervening nine months since I wrote Parts 1 & 2 of this (sorry Scott), I've done exactly that. I had to go back and see what the hell I did, in order to write a semi-coherent blog post about it. Although, the fact that I haven't had to even touch this set-up in that time should lend a clue to it's robustness.


Setting up Gradle:

- `brew cask install java`
- `brew install gradle`
- `gradle init`

__If you want Codenarc:__

Stub out your ruleset configs:
- `mkdir -p ./config/codenarc`
- `touch ./config/codenarc/ruleset.groovy`
- `touch ./config/codenarc/ruleset-test.groovy`**

```
apply plugin: 'codenarc'

codenarc {
  codenarcMain {
    configFile file('config/codenarc/ruleset.groovy')
  }
}
```
