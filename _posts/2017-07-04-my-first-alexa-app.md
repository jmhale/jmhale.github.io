---
layout: default
title:  "Publishing my first Alexa app"
date:   2017-07-04 08:00:00 -0500
---
Last week, I got word that my first app for Amazon's Echo (Alexa) was published to the skills store. While the final iteration of the app and the resulting certification process took ten days, the idea was two years in the making.

<!--break-->

Back in June 2015, I ordered the Amazon Echo. Back then, ordering an Echo in the US was still invite-only for Prime members. Being a Prime member already, I submitted my name to the list and, after several weeks, finally got the notification on June 20th, that one was available for me to purchase. I submitted my order and waited for my Echo (it was released to the general public three days later :| ).

Before I ordered the Echo, I knew that you would be able to extend its functionality through "skills", so as soon as I got mine, after the initial futzing around with what came already on it. I immediately started to look into what I could build for it. My initial problem was that I had no idea what to build. When trying to teach myself a new skill (programming language, whatever), I must have a task to accomplish, or I either don't absorb the concepts well, or I just plain get bored with the project. Which probably explains why I generally sucked in my college CS classes. Trying to force myself to write a skill, just for the sake of it, wasn't going to work.

Back then, my wife relied on the city bus system to get to and from work downtown, from our apartment in the northern part of the city. Part of her morning routine involves checking when the next bus is servicing your stop, so you didn't have to wait outside longer than necessary. There were several iOS and Android apps that served this purpose, but nothing for Alexa. This wasn't surprising, considering how new the platform was, but it gave me a project to focus on.

## First pass: A heap of (Javascript) shit

Around that time, AWS' "serverless" framework, Lambda, was starting to gain speed, so the recommended way to deploy your Alexa Skill was to run it there. Alternatively, you could run it on your own web server infrastructure, since your skill just needs to be able to take a JSON request and return the appropriate JSON response.

Since I was just playing around and I wanted to focus on developing the skill, I definitely didn't want to spend time on standing up and maintaining any infrastructure for this. Lambda was the way to go.

I was still pretty green when it came to writing any serious code. I had started to teach myself Python to make my day-to-day sysadmin-ing easier. I definitely sucked at it, but it was the only language that I had any sort of knowledge in, aside from Bash.

Of course, the first versions of Lambda only supported Javascript, a language that I suck at (to this day) even worse than Python. It was my only choice, so I took some examples from the Alexa Skills Kit and started to rip them apart and glue pieces back together until I got the Alexa version of a "Hello World".

Now it was time to take that and pivot it over to something that accomplishes what I want: telling me (rather, my wife), when the next Metro Bus is coming.
In my mind, the project consisted of two steps:

1. Get the bus arrival data from WMATA. and
2. Parsing that data and having the Echo output it as something intelligible.

Thankfully, step 1 was pretty easy. With the rise of the mainstream hacker culture (and not the "break into your shit" kind), WMATA has a rather fully featured public API <https://developer.wmata.com>, where they expose all sorts of information about their services: arrival times for bus & rail, service alerts, etc. I signed up for an account and banged on their API endpoint for a few hours, until I got the results for my local bus stop. Bingo.

After a few weeks (hours of actual coding time), I had something that sorta worked as a proof of concept. Most of the time spent was on tweaking the results of Metro's API to actually sound natural when spoken. The API output consisted of a lot of abbreviations that needed to be translated to their actual words. For instance, "Street" instead of "St." and "Northwest" instead of "Nw", etc. The arrival time result also needed to be fudged a little. A bus "arriving in 0 minutes" or "arriving in 1 minutes" just didn't roll off Alexa's tongue, so I came up with some janky conditionals to massage that language a bit.

Once I got the output the way I wanted it, I zipped up the code and sent it off to a Lambda function in my AWS account. AWS' free tier with Lambda gives you a LOT of room to play with that stuff, so you don't really need to worry about incurring costs, unless your app becomes super popular. My WMATA API key would max out long before that happened, so I wasn't worried about it.

Cut to a few hours of me setting up my Amazon Developer account, creating the Alexa app and trying to wrap my head around what exactly the hell Intents and Sample Utterances are, I got my Echo to response to my requests and actually give me something useful back.

I showed my hard work to my wife, expecting a "that's nice" and a pat on the head. Instead, she was over the moon about it. So much so that it replaced her morning ritual of checking her phone for when her bus was coming.

Unfortunately, our nearest stop's ID was the one hardcoded in the app, and there was no functionality for users to set their own, so it wasn't very portable. Since it wasn't published in the Alexa Skills store, it existed only on my Echo.

My wife loved it, so my mission was accomplished for now. I'll get around to making it better real soon, I promise.

## Rewrite in a real language
Two freakin' years later is the next time I would touch this thing. Over that time, my wife had been telling her friends, who all live in the area and also commute by bus, and who also have Amazon Echos, about my accomplishment. It generated a lot of interest among them, but alas, since it was still in development, I couldn't share it with any Echos not registered to me.

One Saturday morning, it was already too damn hot to go for a bike ride by the time I got up, so I said screw it. I made my coffee, sat down at my table and fired up a brand new Python project.

In the intervening years, AWS Lambda rolled out support for several languages, including Python, which happens to be my language of choice (read: the one I suck the least at). Now I have no excuses for this project to live on in developer purgatory.

## Time to go live!

## Aftermath: My first review! (Spoiler alert: it wasn't good)

## Timeline of events
- 2015-06-20: Purchased Amazon Echo
- 2015-07-05: Deployed MVP of NextBus app in Javascript
- 2017-06-17: Started re-write of NextBus app in Python
- 2017-06-18: Submitted app to Amazon for certification, first time.
- 2017-06-20: App rejected for certification, first time.
- 2017-06-20: Submitted app to Amazon for certification, second time.
- 2017-06-22: App rejected for certification, second time.
- 2017-06-22: Submitted app to Amazon for certification, third time.
- 2017-06-25: App rejected for certification, third time.
- 2017-06-25: Submitted app to Amazon for certification, fourth time.
- 2017-06-27: App approved for certification and published to the Alexa Skills Store
- 2017-07-04: Received promo code for free Echo Dot and submitted order.
