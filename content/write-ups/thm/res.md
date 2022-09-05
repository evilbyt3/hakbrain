---
title: Res
tags:
- writeups
---

## Recon
- `nmap -sC -sV -oN scan.txt <ip>`
	- ![[write-ups/images/Pasted image 20220808101035.png]]
- While checking the website, I ran an all-port scan in the background: `nmap -p- <ip>`
	- ![[write-ups/images/Pasted image 20220808101129.png]]
- Nothing much, just a default apache web server. I let `gobuster` run in the background. 
- Meanwhile, the other nmap scan found a new port
	- ![[write-ups/images/Pasted image 20220808101301.png]]
- A `redis` service, since the name of this box is `res` I expected to find something by poking around this service

### Redis Enumeration
> **What is Redis?**
> It's an open-source, in memory data structure store, used as a database, cache & message broker *(from [their website](https://redis.io/docs/about/))*
- The version seems to be up to date *(`6.0.7`)*
- Let's connect manually to the service: `redis-cli -h <ip>`
	- no auth required... ok
	- get more info & dump config file
```bash
INFO
[ ... Redis response with info ... ]
client list
[ ... Redis response with connected clients ... ]
CONFIG GET *
[ ... Get config ... ]
```

## Redis RCE with PHP
- Since we know the **path** of the web site folder *(`var/www/html`)*, the first question is if we can write files there using redis. Turns out [you can](https://web.archive.org/web/20191201022931/http://reverse-tcp.xyz/pentest/database/2017/02/09/Redis-Hacking-Tips.html) by leveraging [CONFIG SET](https://redis.io/commands/config-set/) to choose where we want to write & [SET](https://redis.io/commands/set/) to write our content as a [key](https://redis.io/commands/keys/).
	- ![[write-ups/images/Pasted image 20220808103318.png]]
- Then just navigate to `http://<ip>/redis.php?c=<cmd>` & execute whatever you want 😋
	- ![[write-ups/images/Pasted image 20220808103515.png]]
	- ![[write-ups/images/Pasted image 20220808124224.png]]

## Getting root
- I started by searching for any SUID binaries: 
	- ![[write-ups/images/Pasted image 20220808124425.png]]
- with a quick look on [GTFOBins](https://gtfobins.github.io/gtfobins/xxd/) we find that we can use `xxd` to read/write files as root
	```bash
	# Get the root flag
	LFILE="/root/root.txt" && xxd "$LFILE" | xxd -r
	# Retrieve /etc/shadow
	LFILE="/etc/shadow" && xxd "$LFILE" | xxd -r
	```

### Cracking `/etc/shadow`
Once `/etc/shadow` & `/etc/passwd` are dumped you need to combine them in a format that `john` understands. For that we have the [unshadow](https://www.commandlinux.com/man-page/man8/unshadow.8.html) utiltiy

![[write-ups/images/Pasted image 20220808125234.png]]

### Hijack `/etc/shadow` to set root password
At this point, you could just submit the flags & move on. But how could I do that without a root shell? 🫠

So we have write access through `xxd`, but what can we do with it? It [turns out](https://medium.com/@gaby_perso/privileges-escalation-with-suid-992c279c9bc3) you can just modify the original `/etc/shadow` file with our own & set the root password. 
If you look in the [shadow documentation](https://linux.die.net/man/5/shadow) it specifies that the 2nd parameter contains the encrypted password of the user by the use of crypt tools
![[write-ups/images/Pasted image 20220808144127.png]]

And we can see that being applied with `vianka`, so why not use `xxd` to place our own password there for root ? First, we need to generate the hash. We know that the salt should be `$6$2p` from `vianka`, so a little python magic is required:
![[write-ups/images/Pasted image 20220808144338.png]]
Once we have the hash just replace the `!` char with it, upload the file to the remote host *(`python -m http.server`)*, change the original one using `LFILE=/etc/shadow && cat my_shadow | xxd | xxd -r - "$LFILE"` & `su root` 
![[write-ups/images/Pasted image 20220808125409.png]]


## Refs
- https://stackoverflow.com/questions/19581059/misconf-redis-is-configured-to-save-rdb-snapshots
- https://www.trendmicro.com/en_us/research/20/d/exposed-redis-instances-abused-for-remote-code-execution-cryptocurrency-mining.html
- https://book.hacktricks.xyz/network-services-pentesting/6379-pentesting-redis#php-webshell
- https://www.npmjs.com/package/redis-dump
- https://lzone.de/cheat-sheet/Redis
- https://github.com/n0b0dyCN/redis-rogue-server
- https://gtfobins.github.io/gtfobins/xxd/
- https://www.commandlinux.com/man-page/man8/unshadow.8.html
- https://medium.com/@gaby_perso/privileges-escalation-with-suid-992c279c9bc3

## See Also
- [[write-ups/THM]]