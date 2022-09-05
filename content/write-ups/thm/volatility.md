---
title: Volatility
tags:
- writeups
---

## Obtaining Memory Samples
- live machines (turned on) can have their memory captured with one of the following tools
	- [FTK Imager](https://accessdata.com/product-download/ftk-imager-version-4-2-0)
	- [Redline](https://www.fireeye.com/services/freeware/redline.html)
	- `DumpIt.exe`
	- `win32dd.exe` / `win64dd.exe` *(psexec support, great for IT departments if your EDR solution doesn't support this)*
- will typically output a `.raw` file which contains an image of the system memory
- offline maachines can have their memory pulled relatively easily as long as their drives aren't encrypted
	- in Windows by getting the `%SystemDrive%/hiberfil.sys` file
	- known as the Windows hibernation file contains a compressed memory image from the previous boot *(4 faster boot-up times)*
- what about virtual machines? quick sampling of the memory capture process containing a memory image for different hypervisors
	- VMware: `.vmem` 
	- Hyper-V:    `.bin`  
	- Parallels:  `.mem`  
	- VirtualBox: `.sav`      
	- can often be found simply in the data store of the corresponding hypervisor and often can be simply copied without shutting the associated virtual machine off
	- allows for virtually zero disturbance to the virtual machine, preserving it's forensic integrity

## Examining the patient
- Determining profile

	```bash
	# vol2
	volatility -f cridex.vmem imageinfo

	# vol3
	vol.py -f cridex.vmem windows.info.info
	```
	- ![[write-ups/images/Pasted image 20220619160741.png]]

- Process Information
	```bash
	# vol2
	vol.py -f “/path/to/file” ‑‑profile <profile> pslist
	vol.py -f “/path/to/file” ‑‑profile <profile> psscan
	vol.py -f “/path/to/file” ‑‑profile <profile> pstree
	vol.py -f “/path/to/file” ‑‑profile <profile> psxview

	# vol3
	vol.py -f “/path/to/file” windows.pslist
	vol.py -f “/path/to/file” windows.psscan
	vol.py -f “/path/to/file” windows.pstree
	```
	- ![[write-ups/images/Pasted image 20220619161107.png]]
	- fairly common for malware to attempt to hide itself and the process associated with it. We can view hidden procs with `psxview` 
	- ![[write-ups/images/Pasted image 20220619161125.png]]
	- as we can see the `csrss.exe` has only 1 `False` field
- `ldrmodules`: if any of these 3 cols *(InLoad, InInit, InMem)* are false => that module has been likely injected 
	- ![[write-ups/images/Pasted image 20220619161504.png]]
	- `csrss.exe` has all 3 columns to `False` => further inspection
- Processes aren't the only area we're concerned with when we're examining a machine. With `apihooks` we can view unexpected patches in the standard system DLLs: if we see an instance of `Hooking module: <unknown>` it's pretty bad
	- ![[write-ups/images/Pasted image 20220619161857.png]]
	- I've only included a small part that shows all of the extraneous code introduced by the malware
- Injected code can be a huge issue and is highly indicative of very very bad things: we can check for this with `malfind` & also dump to file: `/volatility -f ~/thm/volatility/cridex.vmem --profile=WinXPSP2x86 malfind -D maldump`
	- ![[write-ups/images/Pasted image 20220619162055.png]]
- View all DLLss loaded into memory w `dlllist`
	- shared system libraries utilized in system processes
	- ommonly subjected to hijacking and other side-loading attacks
	```bash
	# vol2
	vol.py -f “/path/to/file” ‑‑profile <profile> dlllist -p <PID>
	
	# vol3
	vol.py -f “/path/to/file” windows.dlllist ‑‑pid <PID>
	```
	- ![[write-ups/images/Pasted image 20220619162601.png]]
	
## Post Actions
![[write-ups/images/Pasted image 20220619163718.png]]
![[write-ups/images/Pasted image 20220619163836.png]]
[Cridex Malware](https://www.computerhope.com/jargon/c/cridex-malware.htm)

---

## References
- [Volatility Cheatsheet - Haktricks](https://book.hacktricks.xyz/generic-methodologies-and-resources/basic-forensic-methodology/memory-dump-analysis/volatility-examples)
- [Another cheatsheet with vol 2 & 3](https://blog.onfvp.com/post/volatility-cheatsheet/)

## See Also
- [[write-ups/THM]]
