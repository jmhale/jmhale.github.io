---
layout: post
title:  "Deploying WireGuard on AWS with Terraform"
date:   2019-02-24 19:00:00 -0500
tags: vpn wireguard terraform aws
---

I like having a VPN available to me for personal use when I'm traveling. Since I don't at all trust any paid or free VPN service, I run my own in AWS for general privacy and security, as well as one at home to access my infrastructure there, as needed.

WireGuard is new-ish on the VPN scene which is dominated by the likes of IPSec and OpenVPN. I wanted to write a Terraform module to deploy it on AWS.

<!--break-->

## TL;DR: Alright. Shut up and show me the code!
Here you go!
https://github.com/jmhale/terraform-aws-wireguard

## WireGuard and my motivation
I myself run OpenVPN, but I find the implementation a bit heavy and a bit hard to manage. I touch the infrastructure so infrequently, that when I have to dive back into it, I have to relearn how it works.

When I heard about WireGuard, I wanted to give it a try as an alternative to running OpenVPN. I was able to get it set up really quickly, which gave me a lot of confidence that I wasn't misconfiguring something. I then wanted to make the deployment in AWS robust and captured in version control, so I knew how it was put together when I had to come back to it in six months or a year.

A lot of my AWS infrastructure is represented in Terraform code already. [Terraform](https://www.terraform.io/) is a tool to express Infrastructure-as-code in a declarative way. Tell it want you want and it figures out how to get the resources needed to do it.

## The WireGuard module

I wrote a Terraform module to deploy WireGuard in a fairly robust manner on AWS. By instantiating the module in a Terraform project, the module will create (almost) all of the resources necessary to get a WireGuard VPN instance up and running. I say "almost" here because WireGuard needs a public/private key pair in order to establish client connections.

I leave the generation of these key pairs as a excercise to the user, who then stores them securely in AWS using [SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html), although it's pretty simple to do so with WireGuard's client CLI.

`wg genkey | tee client-privatekey | wg pubkey > client-publickey`
`wg genkey | tee server-privatekey | wg pubkey > server-publickey`

The WireGuard module creates the following resources in AWS:
- A autoscaling group and launch configuration.
- A templated WireGuard configuration.
- A IAM policy, role, and instance profile.
- A pair of EC2 security groups to manage access.

## Why autoscaling?
This VPN solution is for my personal use, and not meant for the enterprise. As such, I didn't set out to make this capable of deploying a fully HA, redudent VPN cluster. I did, however, want to ensure that the instance could be spun up and ready to accept client connections without any manual configuration.

Once you are able to tune the user-data to acheve that zero-touch configuration, it's not hard to port that over to a autoscaling group. I'm not using ASGs here in the classical sense, to increase the number of instances based on load, but just to ensure that a single instance stays online always.

```hcl
resource "aws_autoscaling_group" "wireguard_asg" {
  name_prefix          = "wireguard-asg-"
  max_size             = 1
  min_size             = 1
  launch_configuration = "${aws_launch_configuration.wireguard_launch_config.name}"
  vpc_zone_identifier  = ["${var.public_subnet_ids}"]
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
```

Occassionally, AWS will need to terminate a instance for one reason or another. With WireGuard being deployed via a ASG, whose scale is statically set to 1, if it's instance is ever terminated for any reason, a new one will be created in it's place, and take over it's Elastic IP address, automatically.

## Client config
Once the WireGuard module has created the server-side resources, all that is left to do is to configure your client to connect to it.

This is an example WireGuard configuration that will forward all of your traffic to the VPN server.

```
[Interface]
PrivateKey = <<your-client-private-key>>
ListenPort = 21841
Address = 192.168.2.2/32
DNS = 9.9.9.9

[Peer]
PublicKey = <<your-server-public-key>>
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = <<your-vpns-eip>>:51820

```

If you only want a subset of your traffic to traverse the VPN, you can alter the `AllowedIPs` parameter to tell it what to forward. This parameter is also used on the server side, but it means something slightly different, depending on what side of the tunnel you're on.

A good way to remember it is: on the client, it's a route table (where to send what traffic), on the server, it's a ACL (from where should I accept traffic).

## Conclusion
I really enjoy the simplicity of getting WireGuard set up, compared to the PKI headache of OpenVPN. I haven't put it through its paces yet, but I've heard nothing but good things about WireGuard's performance.

If you find the module useful or can think of ways to improve it, let me know or submit a Issue or Pull Request on Github!
