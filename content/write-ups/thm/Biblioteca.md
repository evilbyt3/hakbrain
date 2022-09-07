---
title: "Biblioteca"
tags:
- writeups
---

## Recon

![[Pasted image 20220602213700.png]]

Going to the http server gets us this:
![[Pasted image 20220813102932.png]]
Thought about brute-forcing the login form, but since the box has this message: `"Shhh. Be very very quiet, no shouting inside the biblioteca."`, they probably don't want us to do that 😇

We see that the back-end of the web-app is running [Werkzeug](https://werkzeug.palletsprojects.com/en/2.2.x/), a comprehensive [WSGI](https://wsgi.readthedocs.io/en/latest/) web application library. At this poing I started to search the internet for any known vulnerabilities, but I just found an [RCE through the debug console](https://www.rapid7.com/db/modules/exploit/multi/http/werkzeug_debug_rce/) & a bypass for the `/console` endpoint if protected by a pin. But we have no debugging enabled so, no luck I guess.

## Init Access
Proceeding forward, I tried basic sqli on the login form & it worked

![[Pasted image 20220813103043.png]]

Hmm, we're logged in as `smokey`, that might be one of the users.  I also noticed that once logged in, we're assigned this cookie:

![[Pasted image 20220813103317.png]]

Tried to modify it in order to enumerate users or change my privileges, but that was a dead-end. So let's just do the obvious & leverage our sqli. Maybe we can leak some password hashes & crack em.
```bash
sqlmap -u http://10.10.50.239:8000/login --data "username=a&password=b" --method POST -D website --dump
```

![[Pasted image 20220813103535.png]]

Well, seems like we don't need to crack anything @ all 🙃

## Users are dumb
I then used these credentials to `ssh` onto the system & enumerate some more

![[Pasted image 20220813103818.png]]

[logratate is exploitable](https://book.hacktricks.xyz/linux-hardening/privilege-escalation#logrotate-exploitation) apparently, but not is not a SUID in this case. Moving on, I looked for users on the box. Once I found another user `hazel`, I knew that I needed to first pivot to him & then try to gain root

![[Pasted image 20220813103909.png]]

On a glimpse of hope, I found this in the source code of the web-app:
```python
# /var/opt/app/app.py
app.secret_key = '$uperS3cr3tK3y'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'smokey'
app.config['MYSQL_PASSWORD'] = '$tr0nG_P@sS!'
app.config['MYSQL_DB'] = 'website'
```

But none of these passwords worked for `hazel`. Finally, after 1 hour spent in the darkness of the guessing-void, I found out that it was just `hazel:hazel` 🫠 , should've known from the hint tho.


## Hijacking python libraries to gain root
Since I knew that this is not going to be a *SUID* privesc from my previous attempt, I let `linpeas` run in the background while I did a simple `sudo -l` hoping for a direct root shell. Instead, I was greeted with this:

![[Pasted image 20220813104645.png]]

Ok so we can run `hasher.py` as root, but only with the correct path. So no replacing the script or some `PATH` mambo jambo. The script looks like this:
![[Pasted image 20220813104919.png]]

So here's our situation:
- we can launch the `hasher.py` script using `sudo` *(provided with the right path)*
- the python script uses an external library *(`hashlib`)*
- we can't simply inject a payload into the script, since we don't have write privileges

Finding a way to bypass this might seem impossible. Well, it's not let me introduce you to [[PYTHONPATH Hijacking]]. `PYTHONPATH` is an environment variable which you can set to add additional directories where python will look for modules and packages. Thus, by controlling this variable we can create our own version of `hashlib` & specify its path before executing `hasher.py`. As a result, when python will look to import the module it will load our own & since we can run as `sudo` we gain `root` privileges 😉

Let's have a look @ it in action:
```bash
echo "import os;os.system('bash')" > /dev/shm/hashlib.py
sudo PYTHONPATH=/dev/shm/ python3 ~/hasher.py
```


![[Pasted image 20220813105502.png]]

## Refs
- https://mikadmin.fr/blog/linux-privilege-escalation-python-library-hijacking/
- https://book.hacktricks.xyz/linux-hardening/privilege-escalation#setenv
- https://www.sudo.ws/docs/man/1.8.15/sudoers.man/#SETENV

## See Also
- [[write-ups/THM]]