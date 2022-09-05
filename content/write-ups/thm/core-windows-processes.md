---
title: core-windows-processes
tags:
- writeups
---

## TaskManager
- add columns by right-click on column headers
- `details`
	- good columns to add: `Image path name` & `command line`
	- if the Image path name or Command line is not what it's expected to be, then we can perform a deeper analysis on this process
- lacks certain important information when analyzing processes, such as **parent process information**
- where other utilities, such as [Process Hacker](https://processhacker.sourceforge.io/) and [Process Explorer](https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer) come to the rescue
- cmd-line equivalents: `tasklist`, `Get-Process` or `ps` *(PowerShell)*, and `wmic`

## System
> "_The System process (process ID 4) is the home for a special kind of thread that runs only in kernel mode a kernel-mode system thread. System threads have all the attributes and contexts of regular user-mode threads (such as a hardware context, priority, and so on) but are different in that they run only in kernel-mode executing code loaded in system space, whether that is in Ntoskrnl.exe or in any other loaded device driver. In addition, system threads don't have a user process address space and hence must allocate any dynamic storage from operating system memory heaps, such as a paged or nonpaged pool._"

### Unusual behavior 4 this process
- A parent process (aside from System Idle Process (0))
- Multiple instances of System. (Should only be 1 instance) 
- A different PID. (Remember that the PID will always be PID 4)
- Not running in Session 0

## Core Procs

### `smss.exe`
- also known as the **Windows Session Manager**, is responsible for creating new sessions. This is the first user-mode process started by the kernel
- it starts the kernel mode & user mode of the Windows subsystem *(more on [NT Architecure](https://en.wikipedia.org/wiki/Architecture_of_Windows_NT))*. Includes: 
	- `win32k.sys` *(kernel mode)*
	- `winrv.dll` *(user mode)*
	- `csrss.exe` *(user mode)*
- `smss.exe`: the first child intance creates child instances in new seshs by copying itself in the new sessions & self-terminating *(more [here](https://en.wikipedia.org/wiki/Session_Manager_Subsystem))*
	- `crss.exe` *(Win subsystem)* & `wininit.exe` in Session 0 *(isolated win sesh for the OS)*
	- `csrss.exe` & `winlogon.exe` for Session 1 *(user sesh)*
- any other subsystem listed in the `Required` value of `HKLM\System\CurrentControlSet\Control\Session Manager\Subsystems` is also launched
- also responsible for creating environment variables, virtual memory paging files and starts `winlogon.exe` *(the Windows Logon Manager)*


### `csrss.exe` *(Client Server Runtime Process)*
- user-mode side of the Windows subsystem
- always running and is critical to system operation
	- if terminated it will result in system failure
	- responsible for the Win32 console window and process thread creation and deletion
	- for each instance `csrsrv.dll`, `basesrv.dll`, and `winsrv.dll` are loaded *(along w others)*
- also responsible for making the Windows API available to other processes, mapping drive letters, and handling the Windows shutdown process
- more [here](https://en.wikipedia.org/wiki/Client/Server_Runtime_Subsystem)

### `wininit.exe` *(Windows Initialization Process)*
Responsible for launching:
- `services.exe` *(Service Control Manager)*
- `lsass.exe` *(Local Security Authority)*
- `lsaiso.exe` within Session 0

> NOTE: `lsaiso.exe` is a process associated with **Credential Guard and Key Guard**. You will only see this process if Credential Guard is enabled


### `services.exe` *(Service Control Manager)*
- spawned by `wininit.exe`
- primary responsibility is to handle system services: loading services, interacting with services, starting/ending services, etc
- maintains a db, accesible through the `sc.exe` cmd
- info regarding services is stored in `HKLM\System\CurrentControlSet\Services`
- also loads device drivers marked as auto-start into memory
- when user logs into a machine, this proc is responsible for setting the value of the `Last Known Good` control set, in `HKLM\System\Select\LastKnownGood`, to that of the `CurrentControlSet`
- is the parent of severaal other key procs *(e.g `svchost.exe`, `spoolsv.exe`, `msmpeng.exe`, `dllhost.exe`)*
- more [here](https://en.wikipedia.org/wiki/Service_Control_Manager)

### `svchost.exe` *(Service Host)*
- responsible for hosting and managing Windows services
- services are implemented as DLLs
	- the DLL to implement is stored in the regisstry for the service under the `Parameters` subkey in `ServiceDLL`
	- full path: `HKLM\SYSTEM\CurrentControlSet\Services\SERVICE NAME\Parameters`
	- ![[write-ups/images/Pasted image 20220609184419.png]]
- look for this info in Process Hacker
	- right-click the `svchosts.exe` proc: `Services > DcomLaunch > Go to Service`
	- ![[write-ups/images/Pasted image 20220609184640.png]]
	- right-click the service & select `Properties`
	- ![[write-ups/images/Pasted image 20220609184650.png]]
	- notice the `-k` parameter which is used to group similar services to share the same process *(done in order to reduce resource consumption)*. 
- since `svchost.exe` will always have multiple running procs it has been of high interest for malicious uses
	- adversaries create malware masquerading as this proc to try to hide amongst the legitimate `svchosts.exe` procs *(name the malware `svchost.exe` or misspell it slightly: `scvhost.exe`)*
	- another tactic is to install/call a malicious service *(i.e DLL)*
	- [nice article about the topic](https://www.hexacorn.com/blog/2015/12/18/the-typographical-and-homomorphic-abuse-of-svchost-exe-and-other-popular-file-names/)
- more about it [here](https://en.wikipedia.org/wiki/Svchost.exe)


### `lsass.exe` 
> "Local Security Authority Subsystem Service (**LSASS**) is a process in Microsoft Windows operating systems that is responsible for enforcing the security policy on the system. It verifies users logging on to a Windows computer or server, handles password changes, and creates access tokens. It also writes to the Windows Security Log."

- creates security tokens for 
	- SAM *(Security Account Manager)*
	- AD *(Active Directory)*
	- NETLOGON
- uses auth pkgs specified in: `HKLM\System\CurrentControlSet\Control\Lsa`
- also targeted by adversaries since it manages authentication
	- common tools such as `mimikats` is used to dump credentials or they mimic this proc to hide in plain sight
	- [How LSASS is maliciously used and additional features that Microsoft has put into place to prevent these attacks](https://yungchou.wordpress.com/2016/03/14/an-introduction-of-windows-10-credential-guard/)

### `winlogon.exe`
- launched by `smss.exe`
- responsible for handling the **Secure Attention Sequence** (SAS)
	- the `ALT+CTRL+DELETE` key combination users press to enter their username & password
- loads the user profile: by loading the user's `NTUSER.DAT` into HKCU and via `userinit.exe` to load the shell
- locks the creen & runs the user's screensaver
- more about it [here](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc939862(v=technet.10)?redirectedfrom=MSDN)

### `explorer.exe`
- gives the user access to their folders and files
- provides functionality to other features such as the Start Menu, Taskbar, etc.
- has many child processes


---

## References
- [User mode VS Kernel mode](https://docs.microsoft.com/en-us/windows-hardware/drivers/gettingstarted/user-mode-and-kernel-mode)
- [https://www.threathunting.se/tag/windows-process/](https://www.threathunting.se/tag/windows-process/)[](https://www.threathunting.se/tag/windows-process/)
- [https://www.sans.org/security-resources/posters/hunt-evil/165/download](https://www.sans.org/security-resources/posters/hunt-evil/165/download)[](https://www.sans.org/security-resources/posters/hunt-evil/165/download)
- [https://docs.microsoft.com/en-us/sysinternals/resources/windows-internals](https://docs.microsoft.com/en-us/sysinternals/resources/windows-internals)

## See Also
- [[write-ups/THM]]