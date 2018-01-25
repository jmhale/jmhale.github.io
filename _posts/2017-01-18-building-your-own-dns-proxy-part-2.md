---
layout: default
title:  "Building your own DNS proxy, part 2: Writing the code"
date:   2017-01-18 17:00:00 -0500
---

[In my first post]({{ site.baseurl }}{% post_url 2017-01-02-building-your-own-dns-proxy-part-1 %}) about building your own DNS “smart” proxy, I touched on the basics of how a smart DNS proxy works, how to build a basic version on a cloud provider and the paid alternatives that are out there. In this post, we’ll take that knowledge and productionalize, operationalize or whatever buzzword you want to use to refer to it as “not sucking”.

<!--break-->

DNS is a core component of your network’s infrastructure. If it goes down, you are dead in the water. For the smart proxy to do its job, you need to be able to trust it to work properly.

In most home routers, you can specify more than one DNS server for your network to use. This is so that, in case your primary DNS server goes down, the secondary or tertiary DNS address in your router can take over. So, given the option, it makes total sense to always have more than one DNS server in your router’s configuration, right? Right!

This sort of set up only works if the expected behavior of all DNS servers involved are exactly the same. Meaning that DNS server B will always return the same results as DNS server A or C, for a given query. Since we’re altering the behavior for some select zones in our proxy, that behavior won’t be exhibited in DNS servers run by your ISP, Google, OpenDNS, etc, so we can’t use any of those for our backups.

The exception to this is: if you know, for sure, that your router implementation will always try the first entry in your DNS resolver list before any other, i.e. not randomly. If so, you can utilize a proxy server primary/public server backup and expect consistent results, so long as the proxy is online. If it dies, then you fail over to your ISP/Google. You won’t have your proxy magic, but you’ll still be online. If you can’t guarantee this behavior, then you may get some funky and inconsistent results. One query returns the normal result, while the next query returns the modified result. Inconsistent = unpredictable = bad.

{% highlight bash %}
$ dig +short mlb.tv
45.55.107.76
159.203.144.22
$ dig +short mlb.tv
209.102.210.40
$ dig +short mlb.tv
45.55.107.76
159.203.144.22
{% endhighlight %}

This inconsistency makes the proxy hard to use. Also, if your device caches DNS results, and grabs the wrong one (or the right one, depending on how you look at it), it’s even harder to deal with.

The only way around this is to deploy multiple proxy servers on your IaaS provider, preferably in different Availability Zones or regions, and add both to your router.

Having to create and configure these proxies by hand gets old pretty quick. In a cloud-y world, you can be sure that you’ll have to do this more than once, as instances are subject to be restarted or terminated on a whim, as the cloud provider makes capacity adjustments or has issues with the hypervisor layer.

You can mitigate some of this by saving off a vanilla image or AMI of your proxy, once it’s configured. If you lose an instance, you can deploy a new one from your image.

In my set-up, I am using the OS firewall to limit my exposure to the outside world, which involves whitelisting some IPs. Since these IPs are liable to change over time, I’d rather not hardcore them into an image, which will almost always be out of date, when I can inject them at instance launch. This isn’t to debate the merits of pre-baked images vs configure at launch. There are great uses for both. In fact, Packer would probably solve a lot of my issues with pre-baked images, but I digress.

Here, I opt to inject a userdata script via cloud-init, which will do all of my proxy package installs, configuration steps and grab a couple of IP addresses by their dynamic DNS hostnames and throw them into ufw.

You can find the full userdata script that I use on Github here. Don’t let the .py extension fool you, it is a Shell script at heart. I just name it that so I can import it into my other scripts as a string in order to use it with the DigitalOcean Python SDK. More on that below.

You’ll find most of the script to be a concatenation of the config files from part one of this series. The tricky part comes in where I need to configure ufw to whitelist the IPs associated with my ddns hostnames.

***
<br>

### Set IP Addresses
{% highlight shell %}
ADMIN_IPS=(`dig +short my-admin-host.ddns.net | tail -1`)
USER_IPS=(`dig +short my-user-host.ddns.net | tail -1` `dig +short my-admin-host.ddns.net | tail -1`)
{% endhighlight %}

***
<br>

### Set ufw rules
{% highlight shell %}
for ADMIN_IP in "${ADMIN_IPS[@]}"; do
  ufw allow from ${ADMIN_IP} proto tcp to any port 22
done

for USER_IP in "${USER_IPS[@]}"; do
  ufw allow from ${USER_IP} to any port 53
  ufw allow from ${USER_IP} proto tcp to any port 80
  ufw allow from ${USER_IP} proto tcp to any port 443
done
ufw enable
{% endhighlight %}

Here, we’re taking the hostname of my admin machine, which I want to be able to use to SSH in to the instances and doing a dig on it to get it’s IP, and storing that IP in the `$ADMIN_IPS` env var. We do the same with a list of hostnames for `$USER_IPS`. These IPs will only be allowed access to port 53 for DNS resolution and TCP/80, TCP/443 for proxy access. All other traffic will be dropped. We loop though each set of IPs, add them to the appropriate rules, and enable the firewall.

Now that we have our userdata, we can just throw that into our instance’s metadata and call it a day, right? While it’s true that we’ve significantly cut down our deployment time by not configuring the proxy by hand, it’s still way too much a manual process. Let’s script it!

In that same repo, you’ll find three Python scripts. We can use these to create a new proxy instance, using our handy userdata script, re-associate a floating IP to the new instance, and finally terminate the old instance. Granted, that last step isn’t applicable if we’re replacing a already dead instance, but I also like putting “immutable infrastructure” into practice, which involves killing off perfectly healthy instances from time to time.

If I need to update a IP on the firewall, I’m not going to ssh into each instance that I’m running and execute ufw commands. I’m just going to spin up a new one, let my userdata script do it’s magic, re-point the floating IP and shoot the old node in the head.

Aside: since I technically don’t have a need to log into the instances, I can very well kill off the adding of port TCP/22 to the userdata above.

***
<br>

### Creating a proxy:
{% highlight bash %}
$ export DO_TOKEN=XXXXXXXXXXXX
$ python dns-proxy/create_dns_instance.py nyc3
Creating Droplet: dns-proxy-nyc3-20170118193349
37859472
{% endhighlight %}

You can see that our script called DigitalOcean, created our proxy instance and gave it a very sensible name. It also spit back the Droplet ID. We’ll need this to run the second script to re-associate the floating IP.

Now, we take that droplet ID and our floating IP and feed them into the second script:

{% highlight shell %}
$ python dns-proxy/reassociate_floating_ip.py 37859472 xx.xx.xx.xx
Unassociating Floating IP from Droplet: 36081924
{% endhighlight %}

The output here leaves a bit to be desired, but we get what’s important, which is the droplet ID of the old proxy instance. If you guessed that we’ll be feeding that into our third script, you’re correct!

Also, if you noticed that each script conveniently outputs the data needed to execute the next step, then you’re ahead of the game. That is intentional so we can chain it into a pipeline.

{% highlight shell %}
$ python dns-proxy/terminate_instance.py 36081924
Terminating Droplet: dns-proxy-nyc3-20170102114045
Droplet: dns-proxy-nyc3-20170102114045 destroyed. :(
{% endhighlight %}

And there you have it, we just recycled our nyc3 DNS proxy infrastructure, using nothing but code and three commands! Neat, huh?

If this is still too manual for you, then you’re in luck. In the next post, I’ll go over how to tie all three of these steps into a Jenkins pipeline, using Groovy, and turn this recycle action into a single click.
