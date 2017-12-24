---
layout: default
title:  "The Great Home Lab Rebuild -- Part 1: Storage"
date:   2017-12-24 17:00:00 -0500
---
I returned from AWS re:Invent 2017, opened closet door that houses my home lab gear and heard *that* sound. You know the sound. Time to take action. So, do I buy another drive to keep the PC or NAS (I wasn't sure which at this point), or do I rebuild the whole thing?

Well, since all of my lab gear was pushing 10 years, and a blog post about a drive swap would be boring AF, you can guess where we're going...

The Great Home Lab Rebuild!

<!--break-->

Since I moved out of my college apartment, I've always had some set of infrastructure that functioned as my home lab. At its height, when I had a basement and a lot of spare room, I had an old Buffalo Terastation NAS, a couple of Mac G5's, some Optiplex 740s. The 740s ran, amongst other things, my 2003 AD domain (oh god, what was I thinking?).

Gear has come and gone since then, and when I moved into my current place, the amount of available space for such gear has shrunk considerably and I had to pare it down to the bare necessities. That pretty much left me with the Terrastation and a more recent, Optiplex 960. The NAS was just serving NFS mounts and the 960 ran everything else: Plex, rTorrent, Crashplan (to back up the NAS), UniFi controller. As well as some lightweight home-lab stuff, like Jenkins and Docker. At this point, it's pretty much maxed out on memory, so I can't fit much else on it.

Ye Ole Lab
![]({{ site.url }}/assets/images/homelab-pt1/old-lab-1.jpg)
![]({{ site.url }}/assets/images/homelab-pt1/old-lab-2.jpg)

 Ultimately, I'd like to keep all of these running, as most of them are "needed", but I'd like to build in some extra room for a decent Infosec lab, running KVM or ESXi and some VMs.

Between that requirement and my NAS letting out it's death rattle, I decided that enough was enough and it was time to just rebuild all of it. Of course, I don't have a bunch of cash to shell out for all new gear at the same time, so I'll have to piecemeal this a bit.

Since storage is the foundation of this set up, and is the most at-risk, getting that sorted would be the first step.

After doing a crapload of research on various Drobo, Synology and QNAP NASes, I decided on the [QNAP TS-453A](https://www.amazon.com/QNAP-Professional-Grade-Attached-Supports-TS-453A-4G-US/dp/B017YB7T6U). I knew that I wanted a 4-bay NAS, as that would provide me a decent level of storage and afford me some future proofing. 

Who doesn't love a good unboxing?!
![]({{ site.url }}/assets/images/homelab-pt1/qnap-unboxing-1.jpg)
![]({{ site.url }}/assets/images/homelab-pt1/qnap-unboxing-2.jpg)
![]({{ site.url }}/assets/images/homelab-pt1/qnap-unboxing-3.jpg)

I ordered it with a pair of 4TB WD Red's, which are specifically built for running in NAS environments. The only reason I didn't just load out the NAS with Reds was mainly a cash flow issue. Thankfully, the QNAP is chock full of features and one of them is that it allows you to live reconfigure RAID set ups. I can put a pair of the 4TB drives in a RAID 1 now, and not lose any storage capacity, then throw two more in down the road, and convert the whole lot to a RAID 5, which would give me an additional 8TB of storage with no downtime. Sold!

![]({{ site.url }}/assets/images/homelab-pt1/wd-reds-1.jpg)

The QNAP also has a decent Intel Celeron N3150 Quad Core chip and comes with 4GB of memory in the configuration that I got. So, I was able to offload my Plex Media Server and Crashplan set up to the NAS itself. Admittedly, trying to run Crashplan on the QNAP was kind of a mess, since it needs to run within a Docker container (which QNAP also supports!).

Overall, I'm pretty happy with my choice. 

I'll keep writing about the rebuild as I go along. I think the next step will be rounding out the storage with two more Reds and then turning my attention to the 960. I intend to evacuate all of the "critical" services off of it, so it's replacement can be strictly a lab machine. I'm thinking a [Skull Canyon NUC](https://www.newegg.com/Product/Product.aspx?Item=N82E16856102166)?!
