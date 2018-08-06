---
layout: default
title:  "Preparing for DEF CON"
date:   2018-08-05 07:00:00 -0500
---

As so many in the infosec space are getting ready to depart for summer camp in Las Vegas, I'm starting to gear up for my first DEF CON experience.

There are many conflicting schools of thought on what sort of tech you should bring with you, from the uber-paranoid "bring nothing at all" to the lackadaisical thinking of treating it like any other event and bring what you want.

This is my first DEF CON, so I'm not really sure what exactly to expect and what advice is rooted in reality and what is merely FUD. To that end, I'm trying to strike a decent balance between the two.

<!--break-->

##### What I'm *not* bringing
Figuring out what to bring is a lot easier when you can cross stuff off the list right away.

- Work computer. This is really a no-brainer for me. My work laptop has access to our company's VPN and our production systems. It has full disk encryption enabled and to get to any of our systems, you need to get past several layers of auth and MFA, but this is still a high-value target. My days at camp are already blocked out at work, so I am not expecting the need to do actual work to come up. Besides, is my job is paying a lot of money to fly me out to Vegas for DEF CON, so I doubt they want me wasting that on day-to-day work? I can answer e-mails and chat from my phone. Everything else can wait until I'm back in D.C.

- DSLR. Infosec cons are pretty hostile to photos in general, and I've been to Vegas a bunch already, I really don't need to spend any time taking photos for my own enjoyment. If something comes up, my Pixel is a good stand in.

- Lock picks. This kind of saddens me. I'll still stop by the Lockpicking Village, but I really like using my own picks. Since I'm flying out of DCA in Virginia, carrying picks isn't really a great idea. VA is a Prime Facie state when it comes to lock picks, which means that just having picks are proof of intent to commit a crime. I don't need that hassle when trying to get to my plane.

##### Packing list
Some people say that you should just leave the laptop at home altogether and just enjoy the con. While I can appreciate this way of thinking, I think it's a bit too extreme on the tin-foil hat side of things. I want to be able to participate in the different Villages and I actually take much better notes when I type, rather than write them out. Plus, between downtime at the con, in my room, in the airport, etc, there will undoubtedly been periods where I'll just want to mess around on the internet or watch a movie or something and that's just better done on a full machine, rather than my phone.

I'm still paranoid enough to declare my daily driver Macbook Pro as out for this trip. Like my work machine, it just has too valuable information on it to risk exposure to the masses at DEF CON.

So, I need a "burner" of sorts. Not really a burner, mind you, in that I'm not going to toss the thing into the Potomac on my cab ride home from the airport, but rather a machine that can keep stuff separate from my personal life.

I was looking at buying a cheap-ish Thinkpad on eBay, but I ran out of time to procure one. I then remembered that I had a 2010-era Macbook Pro that has been sitting in my closet. For about $60, I was able to rehab it with a new battery and SSD. Throw those bad boys in there with a patched up Ubuntu and Kali on a USB stick and I'm ready to go! Again, this will be more an exercise in OpSec, than anything else. I won't be signing into my e-mail or bank accounts on this machine and other classic dumb stuff to land me on the [Wall of Sheep](https://www.wallofsheep.com/pages/wall-of-sheep). When I get back, I'll probably put it on a quarantined LAN, just to see if it tries to beacon out anywhere before I wipe it and stick it back in the closet, although I think that I'll be sorely disappointed.

For the rest of my packing....
- Anker battery pack to keep the phone alive. Unfortunately, since I won't have my USB-C MBP with me, I can't use it to power my laptop, but oh well.
- Phone and charger. Wifi and Bluetooth turned off, of course. VPN turned on.
- Refillable water bottle. I've never been to DEF CON before, but I have been to summertime Vegas plenty, and this is a must.
- Moisture-wicking undershirts.
- Alfa wifi adapter. Just in case there is some interesting WCTF stuff that I have time for.

##### VPN Set-up
Whenever I travel, I always have a VPN that I can use if I need to get around some BS network management practices at hotels or just generally to protect my traffic from open Wifi networks. DEF CON is absolutely no exception to that.

I typically have a OpenVPN server running in AWS 24x7, just so it's there if I need it. For DC, I'm taking the uber paranoid route here and standing up a completely new OpenVPN instance that is purpose built for this trip. The beauty of AWS and other IaaS providers is that I just keep the instance for as long as a suits me and then I just torch it when I'm done.

This VPN will exist for the duration of DEF CON, at which point, I'll simply terminate it. Any potential compromise of the infrastructure is no longer an issue. Again, if I suspect something, I might keep it around for a bit to do some forensics.

I do most of my AWS infra work in Terraform. Since I already had my normal VPC and VPN defined there, it was trivial to duplicate those definitions for an additional DEF CON-specific VPC and VPN instance.

- Gist of my VPC set-up: (https://gist.github.com/jmhale/79a7d1f0a535fc3add83b5a87f6c7d47)
- Gist of my VPN set-up: (https://gist.github.com/jmhale/86c27e245fc47f39998702121bdfecc6)

These won't work right out of the box. As you'll need some files hosted in a S3 bucket for OpenVPN to use. Namely, the `server.conf` and a SSL certificate and private key. Also, these TF gists assume that you have a DNS zone hosted in Route53, so AWS can just add an entry for your VPN server.

Once DEF CON is over, I'll simply remove these definition files and tell Terraform to go wild. Once it sees that the definitions are no longer there, it will mark the "orphaned" resources for destruction and lay waste to them.

That's pretty much the amount of prep I'm going to do. I don't want to get too bogged down in the details here. I'm not sure what I might encounter at DEF CON, but as long as I learn some things and meet new people, I'm willing to call that a win.

2018 Con Status:
- ~~[Shmoocon](http://shmoocon.org/)~~
- ~~[BSidesNOVA](http://www.bsidesnova.org)~~
- ~~[BSidesCharm](http://www.bsidescharm.com)~~ Actually missed this one, due to illness.
- [DEF CON](https://www.defcon.org)
- [DerbyCon](https://www.derbycon.com)
- [BSidesDC](http://www.bsidesdc.org)
