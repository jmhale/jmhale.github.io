---
layout: default
title:  "Configuring AWS CLI access with MFA"
date:   2017-06-03 08:00:00 -0500
---

When protecting important resources online these days, MFA is a must. Bank accounts, utilities, e-mail accounts, etc.

Protecting your account on your infrastructure provider should be no different. Especially considering not doing so can cause you great financial pain if someone deletes your critical resources, exfiltrates your data or spins up their own Bitcoin mining operation, at your expense.

AWS’ IAM, thankfully, has supported MFA for user accounts for quite some time now. Users can log into their accounts, register their virtual MFA token (Google Authenticator or what have you) and you’re off and running.

<!--break-->

However, if you’re dealing with, or you yourself are, a power user who requires CLI access, the equation changes a bit.

How do you leverage MFA when accessing AWS’ APIs?

AWS provides a number of documents on the subject, which revolve around one of two use cases:

1. You’re accessing resources in the SAME AWS account that your IAM user resides.

2. You’re accessing resources from a DIFFERENT AWS account as your IAM user.

 Case #2 is pretty well documented and the user experience is nice and easy. After you set up your roles and MFA, you simply put the relevant role and MFA ARNs into your `~/.aws/config` file and awscli takes care of the rest. It handles the MFA token prompt and all of the STS magic in the background. You just call your service with the proper profile name. Easy peasy.

The first case, however, isn’t as straight forward. At least, not the way AWS’ documentation makes it out to be. Their documentation states that, in order to access your MFA-protected resources, you’ll need to make a separate call to `sts:GetSessionToken`, authenticating with your TOTP token, to get a set of temporary credentials, then take those and inject them either into an environment variable, or into your awscli config file. Oh, and when your STS token expires, you’ll have to do this all over again.

Why is this so cumbersome? Especially considering the fact that, in case #1, with the cross-account assume role method, awscli is doing the EXACT SAME THING, but the handling of the STS credentials is taken care of automatically.

It’s been my experience as both an administrator and a security professional, that if you significantly increase the level of effort that users need to go through to do their everyday job, they’ll either find a way to go around you and your protections technologically (they build in some sort of back door access, without these extra steps) or administratively (they scream up their chain of command until you get orders to rip it all out).

In reality, it’s actually quite easy to achieve the user experience of case #2, but with everything being in the same AWS account.

Instead of using `GetSessionToken` for our temporary credentials, we’ll simply assume a “local” role for admin access (as opposed to a cross-account role).

The premise of the local role is identical to that of the cross-account role, except in your role’s trust policy, you just specify the same account number that you’re in, instead of a different one.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111222333444:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
```

You can then give the role whatever permissions you want, including Administrator. The Bool in the trust policy, `"aws:MultiFactorAuthPresent": "true”` asserts that a IAM user can assume that role ONLY IF they have authenticated to AWS using MFA. If they didn’t (because they didn’t set MFA up or whatever the reason), then they get a Permission Denied from `sts:AssumeRole`.

The second part of the setup is telling awscli to use this role for any actions, instead of trying to perform them using your long-lived IAM secret access key. In case you’re unfamiliar, your awscli config consists of two files, which live in `~/.aws`: `credentials` and `config`.

Your `credentials` file should remain unchanged, assuming that your IAM secret access key and associated key ID are already in there, add them if not.

In your `config` file, you’ll want to create a profile block, which will contain three pieces of information:

- `source_profile`: this is the profile in the `credentials` file which AWS will use to source the secret access key.
```
source_profile = personal
```


- `role_arn`: This is the ARN of the role you just created in your AWS account. For example, if you called the role “admin-mfa”, then your `role_arn` would look like this:
```
role_arn = arn:aws:iam::111222333444:role/admin-mfa
```

- `mfa_serial`: This is the ARN of your MFA virtual device when is created when you register your token with your IAM account. You can find this on the Security Credentials tab of your IAM user in the AWS console.
```
mfa_serial = arn:aws:iam::111222333444:mfa/johnny-test
```

Save your `config` file and try to call an AWS for which your role has granted you access. You will be prompted to input an MFA token. If the token is correct, the rest of the call will success like any other.

Tip: If you’re playing around with MFA in awscli, you’ll find that successive calls won’t prompt for your MFA device, if done within a certain amount of time (default: 60 minutes). This is due to awscli caching the STS token and reusing it for API calls, until it expires. If you want to manually “expire” your token, so you get prompted again, just delete the cache at `~/.aws/cli/cache`.
