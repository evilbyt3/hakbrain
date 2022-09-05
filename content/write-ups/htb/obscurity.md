---
title: Obscurity
tags:
- writeups
---

![](https://i.imgur.com/OcukgEq.png)

## Enumeration

I started with a simple nmap to get a basic overview:
```bash
nmap -sC -sV -oA nmap/obscurity 10.10.10.168
```

![](https://i.imgur.com/UtwqgOP.png)

As you can see ports `8080` (**http**), `22`(**ssh**) and `9000` are open.

## Website

Once on the web page we are prompted with this:

![](https://i.imgur.com/DyVcVsf.png)

If you scroll a little bit more we find something peculiar:

![](https://i.imgur.com/nx5y6OA.png)

So we need to find the `SuperSecureServer.py` file in order to get the backend code of this web app. For that I used [ffuf](https://github.com/ffuf/ffuf):

![](https://i.imgur.com/SZfkC5u.png)

After letting `ffuf` to do it's job for a while, we are prompted with the desired folder: `develop`. So, the directory was not so secret afterall because we can access the file at `/develop/SuperSecureServer.py`:

![](https://i.imgur.com/2PDFkRP.png)

Well, now it's time to look for a **RCE** or something that we can exploit. This task is not so complicated since the following line looks like this:

![](https://i.imgur.com/vhBYHsX.png)

So we can execute code if we format correctly the `path` variable. Therefore, I came up with this little python script:

![](https://i.imgur.com/Mxg9BRw.png)

When the server processes the request, the `info` variable will look like this:

```
output = 'Document'
<reverse_shell>
ape=''
```

This is valid python code. As a result, we get back a shell:

![](https://i.imgur.com/QootNLC.png)

---

## User

If we take a look at the folder where the user flag is we find these interesting files:
![](https://i.imgur.com/ECmODcN.png)

We have just 4 files we care about:
1. `SuperSecureCrypt.py` - Python script to encrypt files
2. `check.txt` - Clear text of `out.txt`
3. `out.txt` - Ciphertext of clear text `check.txt`
4. `passwordreminder.txt` - Encrypted password of the robert user

By taking a look at how the encryption/decryption algorithm works, we find a funny thing. That is, we can obtain the password used in an encrypted text if we know the clear text:

![](https://i.imgur.com/M03zheF.png)

Thus, in order to find the password used to encrypt the `out.txt` file we just need to execute the following:

![](https://i.imgur.com/rajzLAI.png)

The password used to encrypt the text was: **alexandrovich**

Now that we know the password, we can decrypt the `passwordreminder.txt`

```bash
python3 SuperSecretCrypt.py -k "alexandrovich" -i passwordreminder.txt -o /tmp/pass -d
```

The password for robert being **SecThruObsFTW**. Login with *SSH* and cat `user.txt`
![](https://i.imgur.com/hvTjk0v.png)

---

## Root

Now that we have access to the robert user, we can look at a file we ommited on our journey of getting the user flag. That file is `BetterSSH.py`

![](https://i.imgur.com/wsIffJq.png)

The first part of the script is just authenticating the user we provide with the password. What is more interesting is the second part:

![](https://i.imgur.com/DmMQfyp.png)

The 4th line is of interest because it executes commands with `sudo -u` and our input, so we can do something like: `sudo -u robert -u root whoami`, which in theory should display **root**.

First I tried to execute the script with sudo:

![](https://i.imgur.com/Grny92t.png)

Ok.. so we are not allowed to run the script. At this point I decided to run [linpeas](https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/tree/master/linPEAS), which gave me this:

![](https://i.imgur.com/rHySzW3.png)

Now it all makes sense we need to execute:
```bash
sudo /usr/bin/python3 /home/robert/BetterSSH/BetterSSH.py
```

And then input `-u root cat /root/root.txt`

![](https://i.imgur.com/kizLVnn.png)

## See Also
- [[write-ups/HTB]]