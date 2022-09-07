---
title: "Relevant"
tags:
- writeups
---

## Recon
![[Pasted image 20220823222922.png]]

![[Pasted image 20220823222939.png]]

### Got creds through SMB 🥳 ... oh wait
Running the [smb-enum-shares](https://nmap.org/nsedoc/scripts/smb-enum-shares.html) script with `nmap` revealed the following shares:

![[Pasted image 20220824172805.png]]

The next thing I did was to check all of them for anonymous login & we got a hit on `/nt4wrksv`:

![[Pasted image 20220823223327.png]]

Seems like we hit the jackpot. The file contains the credentials for 2 users encoded in base64

![[Pasted image 20220824173140.png]]

Now I tried connecting to RDP with them, but nothing came back. Running `psexec` revealed that `bill` doesn't even exist & that the password we got for `bob` is outdated... 

![[Pasted image 20220823225348.png]]

Now, I really thought I needed to do something with those credentials, but there wasn't much I haven't tested. I guess sometimes you just have to accept the situation & let go, instead of persisting on a path that doesn't lead anywhere.

### Strange Ports *(49663, 49667, 49669)*
The only ports I didn't tinker with @ this point were the `4966*` one's, let's have a look

![[Pasted image 20220824173816.png]]

From all of them, `49663` is looking spicy. Looking at the web-server seems that it's the same as the one running on `80` *(that is the default [microsoft web server](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831725(v=ws.11)) page)*. Being quite stuck, I ran `dirsearch` on both of them looking for differences

![[Pasted image 20220824191103.png]]

## Inital Access
As you can see the server on `49663` has a route that's named exactly after our smb share earlier. With that in mind, I wanted to see if what I upload on the `nt4wrksv` share is reflected on the web-server

![[Pasted image 20220823230935.png]]

Aaand it is indeed 😍. OK, finally we have something we can work with. The next step was to generate a payload with `msfvenom`, upload it with `smbclient`, start up a listener & navigate to `http://10.10.111.160:49663/nt4wrksv/pwn.exe`

![[Pasted image 20220824183824.png]]

## Privesc with [[sheets/Token Impersonation|Token Impersonation]]
Once on the box I wanted to see what privileges I had:

![[Pasted image 20220824185227.png]]

We see that `SeImpersonatePrivilege` is enabled which can be abused to let us run commands as system *(check out [[Token Impersonation.md#Tokens]] for more info on this technique)*. Since I've done this before with metasploit in [Alfred](Alfred.md), this time I'll use [PrintSpoofer](https://github.com/itm4n/PrintSpoofer). Get the executable, upload it as before with `smbclient` & execute:

![[Pasted image 20220824190740.png]]


## Refs
- [Abusing Impersonation Privileges on Windows 10 and Server 2019](https://itm4n.github.io/printspoofer-abusing-impersonate-privileges/)

## See Also
- [[sheets/Token Impersonation]]
- [[write-ups/THM]]