---
layout: default
title:  "Utilizing DigitalOceans' Firewall Feature"
date:   2017-12-23 08:00:00 -0500
---

Recently, DigitalOcean introduced the concept of a "firewall" object that you can define network ingress and egress rules and attach them to multiple droplets. Think Security Groups in AWS, as they're essentially the same thing.

I've always found the lack of this in DigitalOcean's offering to be dissappointing, so I was excited to see them roll it out. I also wanted to switch my DNS proxy implemtation to use it.

<!--break-->

If you've read my series on creating a DNS proxy on DigitalOcean, then you know that I utilize ufw on each of the proxy instances to protect them from abusers, both on the DNS and sniproxy side (I don't want randos querying my instances or using my bandwidth for proxying) and on the SSH side (ditto for skiddies with nothing better to do than port scan).

The problem with this approach is that I enjoy the immutable infrastructure way of doing things. So, as part of my deployment process for each instance, I need to query a pair of Dynamic DNS hostnames to get the two authorized IPs from my infrastructure and set them in UFW. Both IPs are assigned by home ISPs, and therefore, are subject to change at any point. Since the infrastructure is meant to be immutiable, I don't build in a mechanism to change the ufw rules, once set. 

Should the IPs change, then I would need to completely redeploy both instances to pick up the new IP. Since everything is automated in Jenkins, this isn't a huge lift, but it does take time, on the order of a few minutes. There's also the potential to drop traffic that is actively being proxied by the other IP, while the instances are being recycled.

DigitalOcean's firewall concept makes this a lot cleaner. I can handle network traffic before it even hits the droplets and take ufw out of the picture here. If I need to update an IP, it's a simple API call to DigitalOceans `firewalls` endpoint and bam! No need to redeploy instances!