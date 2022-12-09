---
title: SysInternals
tags:
- writeups
---

The Sysinternals tools is a compilation of over 70+ Windows-based tools which fall under the following categories:
- **File & Disk Utilities**
- **Networking Utilities**
- **Process Utilities**
- **Security Utilities**
- **System Information**
- **Miscellaneous**

These tools are popular amongst IT professionals who manage Windows systems. Even red teamers & adversaries usse them

- **Installation**
	- You can download them [from here](https://docs.microsoft.com/en-us/sysinternals/downloads/) or with powershell module: `Download-SysInternalsTools C:\Tools\Sysint`
	- Add the folder path to the environment vars *(accesible though `System Properties`: `sysdm.cpl`)*

- **Sysinternals Live**: run the tools from the [web](https://live.sysinternals.com/) 
	- enables you to execute Sysinternals tools directly from the Web without hunting for and manually downloading them
	- enter a tool's path into Windows Explorer or a cmd prompt as: `live.sysinternals.com/<toolname>` or `\\live.sysinternals.com\tools\<toolname>`
	- enable the [WebDAV](https://docs.microsoft.com/en-us/iis/configuration/system.webserver/webdav/) client which must be installed & running
		- ![[write-ups/images/Pasted image 20220611153319.png]]
		- this protocol is what allows a local machine to access a remote machine running a WebDAV share and perform actions in it
		- ![[write-ups/images/Pasted image 20220611153722.png]]
		- install the `WebDAV Redirector` *(via `Server Manager` or powershell)*
			- `Install-WindowsFeature WebDAV-Redirector –Restart` *(needs reboot)*
			- verify installation:  `Get-WindowsFeature WebDAV-Redirector | Format-Table –Autosize`
	- **Network Discovery** needs to be enabled as well *(through `Network & Sharing Center`)*
		- `control.exe /name Microsoft.NetworkAndSharingCeenter`
		- `Change Advanced Sharing Settings > Turn on Network Discovery`
	- 2 ways to run the tools
		- from the cmd-line: `\\live.sysinternals.com\tools\procmon.exe`
		- from a mapped drive: `net use * \\live.sysinternals.com\tools\` *(the `*` will auto-assign a drive letter)*
			- website is not browsable within the local machine @ `Y:`

- **Real-world scenario**: As a security engineer, I had to work with vendors to troubleshoot why an agent wasn't responding on an endpoint—the tools used were **ProcExp**, **ProcMon**, and **ProcDump**.
	-  [procexp](../../sheets/procexp.md) = to inspect the agent process, its properties, and associated threads and handles.
	-  [procmon](../../sheets/procmon.md) = to investigate if there were any indicators on why the agent was not operating as it should.
	-  [procdump](../../sheets/procdump.md) = to create a dump of the agent process to send to the vendor for further analysis.

## [File & Disk Utilities](https://docs.microsoft.com/en-us/sysinternals/downloads/file-and-disk-utilities)

- [Sigcheck](../../sheets/Sigcheck.md)
- [streams](../../sheets/streams.md)
- [sdelete](../../sheets/sdelete.md)

### Answer
- ![[write-ups/images/Pasted image 20220611161119.png]]
- There is a txt file on the desktop named file.txt. Using one of the three discussed tools in this task, what is the text within the ADS?
	- I am hiding in the stream.

## [Network Utilities](https://docs.microsoft.com/en-us/sysinternals/downloads/networking-utilities)
"**TCPView** is a Windows program that will show you detailed listings of all TCP and UDP endpoints on your system, including the local and remote addresses and state of TCP connections. On Windows Server 2008, Vista, and XP, TCPView also reports the name of the process that owns the endpoint. TCPView provides a more informative and conveniently presented subset of the Netstat program that ships with Windows. The TCPView download includes Tcpvcon, a command-line version with the same functionality."

- Windows has a built-in utlity that providess the same functionality: `Resource Monitor` - `resmon`

### Answer
- Using WHOIS tools, what is the ISP/Organization for the remote address in the screenshots above?
	- `whois 52.154.170.73` => `Microsoft Corporation`


## [Process Utilities](https://docs.microsoft.com/en-us/sysinternals/downloads/process-utilities)

- [autoruns](../../sheets/autoruns.md)
- [procdump](../../sheets/procdump.md)
- [procexp](../../sheets/procexp.md)
- [procmon](../../sheets/procmon.md)
- [psexec](../../sheets/psexec.md)

### Answers
![[write-ups/images/Pasted image 20220611165145.png]]

- What iss the updated value?: `c:\tools\sysint\procexp.exe`
- What entry was updated?: `taskmgr.exe`

## [Security Utilies](https://docs.microsoft.com/en-us/sysinternals/downloads/security-utilities)

- [sysmon](write-ups/thm/sysmon.md)

## [Miscellaneous](https://docs.microsoft.com/en-us/sysinternals/downloads/misc-utilities)
- [BgInfo](https://docs.microsoft.com/en-us/sysinternals/downloads/bginfo): displays relevant information about a Windows computer on the desktop's background, such as the computer name, IP address, service pack version, and more
	- handy utility if you manage multiple machines
	- typically utilized on servers
	- ![[write-ups/images/Pasted image 20220611170911.png]]
- [RegJump](https://docs.microsoft.com/en-us/sysinternals/downloads/regjump): takes a registry path and makes Regedit open to that path. It accepts root keys in standard *(e.g. `HKEY_LOCAL_MACHINE`)* and abbreviated form *(e.g. `HKLM`)*
	- query the Windows Registry without using the Registry Editor *(cmd: `reg query` & powershell: `Get-Item`, `Get-ItemProperty`)*
	- `regjump HKLM\System\CurrentControlSet\Services\WebClient -accepteula`: automatically open the editor directly at the path, so one doesn't need to navigate it manually
- [Strings](https://docs.microsoft.com/en-us/sysinternals/downloads/strings): cans the file you pass it for UNICODE (or ASCII) strings of a default length of 3 or more UNICODE (or ASCII) characters
	- ![[write-ups/images/Pasted image 20220611171259.png]]

### Answer
![[write-ups/images/Pasted image 20220611171830.png]]

- Run the Strings tool on ZoomIt.exe. What is the full path to the .pdb file?
	- `C:\agent\_work\112\ss\Win32\Release\ZoomIt.pdb`


---

## References
- [sysinternals docs](https://docs.microsoft.com/en-us/sysinternals/)
- [talosintelligence](https://talosintelligence.com/)
- Mark's Blog - [https://docs.microsoft.com/en-us/archive/blogs/markrussinovich/](https://docs.microsoft.com/en-us/archive/blogs/markrussinovich/)[](https://docs.microsoft.com/en-us/archive/blogs/markrussinovich/)
- Windows Blog Archive - [https://techcommunity.microsoft.com/t5/windows-blog-archive/bg-p/Windows-Blog-Archive/label-name/Mark Russinovich](https://techcommunity.microsoft.com/t5/windows-blog-archive/bg-p/Windows-Blog-Archive/label-name/Mark Russinovich)
- License to Kill: Malware Hunting with Sysinternals Tools - [https://www.youtube.com/watch?v=A_TPZxuTzBU](https://www.youtube.com/watch?v=A_TPZxuTzBU)  
- Malware Hunting with Mark Russinovich and the Sysinternals Tools - [https://www.youtube.com/watch?v=vW8eAqZyWeo](https://www.youtube.com/watch?v=vW8eAqZyWeo)

## See Also
- [[write-ups/thm/core-windows-processes]]
- [[write-ups/THM]]
- [[write-ups/thm/sysmon]]
