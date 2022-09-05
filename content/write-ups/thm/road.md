---
title: Road
tags:
- writeups
---

## Enumeration
![[write-ups/images/Pasted image 20220819191421.png]]

nmap gives us just 2 ports open: `80` and `22`

### Web Server
![[write-ups/images/Pasted image 20220819191517.png]]
I let `gobuster` run in the background while browsing the website with burp open.
![[write-ups/images/Pasted image 20220819191726.png]]
Found a login page @ `/v2/admin/login.html`, which also lets us to register. So I made an account & logged in afterwards
![[write-ups/images/Pasted image 20220819191859.png]]
Couldn't inject anything by the search functionality
![[write-ups/images/Pasted image 20220819191937.png]]

## Bypass restriction on password reset & get admin
At this point I just clicked everything on the dashboard to see what kind of functionality does it provide & I found that I could reset my password @ `/v2/ResetUser.php`
![[write-ups/images/Pasted image 20220819192123.png]]

As you can see, it seems that we can't change the username field from the browser... But what about Burp?

![[write-ups/images/Pasted image 20220819192242.png]]

And it just passes through 🥳 . Ok, we can reset the password of any user & posibly take over their account, but how do we know the users available? We need some kind of user enumeration or leakeage, so i started looking around. If we go on our `profile.php` we see that we can change our user profile only if we're admin & we're conveniently given an email address. Nothing could go wrong right?

![[write-ups/images/Pasted image 20220819192623.png]]

So repeat the process from before, log out & sign in as admin with your new password 😄

## Webshell upload
We now have the upload functionality available, and we all know it's kind of bad if not properly configured. So I just grabbed a [revshell](https://www.revshells.com/) & uploaded it.
![[write-ups/images/Pasted image 20220819193211.png]]

It seems that it went through, but where do we access it. I got stuck here for a bit, trying to brute-force my way in finding a path. After a while, I decided to take a look at the good old html source & found this:

![[write-ups/images/Pasted image 20220819193340.png]]

Guess, I've wasted some valuable time there 😅 . But now that we know the path just start a listener & go to `http://10.10.10.29/v2/profileimages/revsh.php`
![[write-ups/images/Pasted image 20220819193530.png]]

## Escalating to user
Once on the box I ran the [enumerate module](https://pwncat.readthedocs.io/en/latest/enum.html) from pwncat & noticed that both mysql & mongodb are running. Trying to connect to mysql gave me nothing, thus I tried `mongo` as well. Here I found a `backup` db where it stored the password for the `webdeveloper` user
![[write-ups/images/Pasted image 20220819194027.png]]

Just connect through `ssh` & we got user
![[write-ups/images/Pasted image 20220819194149.png]]

## Getting root
Running pwncat `enumerate` shows us that we can execute `/usr/bin/sky_backup_utility` as root without a password
![[write-ups/images/Pasted image 20220819194334.png]]
So let's try it
![[write-ups/images/Pasted image 20220819194420.png]]

Seems that it just makes a backup of the web server. We see that it's an ELF executable & that it sets the environment for `LD_PRELOAD`
![[write-ups/images/Pasted image 20220819194757.png]]

Since `LD_PRELOAD` is enabled, we can add a path to our own shared library that the loader will use before any other shared library. So we can create a simple `shell.c` in `/tmp`:
```c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
  unsetenv("LD_PRELOAD");
  setgid(0);
  setuid(0);
  system("/bin/bash");
}
```

Retrieve it, compile as shared library, set `LD_PRELOAD` to it & execute.
![[write-ups/images/Pasted image 20220819195136.png]]

## Refs
- [LD_PRELOAD & LD_LIB_PATH privesc haktricks](https://book.hacktricks.xyz/linux-hardening/privilege-escalation#ld_preload-and-ld_library_path)

## See Also
- [[write-ups/THM]]