---
title: "Windows 11 Minimum Requirments Bypass"
tags:
- sheets
---

I recently stumbled upon this error in VirtualBox when trying to setup Windows 11
```
This computer does not meet the minimum system requirements to install this version of Windows.
```
Even though it had 8GB RAM, 100GB storage and 4 CPU cores 🤔
Just press `Shift + F10` which should spawn a command prompt. Then `regedit` and prepare yourself to make some changes
- go to `HKEY_LOCAL_MACHINE\System\Setup`, right-click & `New -> Key` *(`LabConfig` as name)*
- Inside the `LabConfig` create 4 `New -> DWORD (32-bit) Value` & set them all to hex value `1`
	-   BypassTPMCheck
	-   BypassSecureBootCheck
	-   BypassRAMCheck
	-   BypassCPUCheck
- ![[write-ups/images/Pasted image 20220821074413.png]]

Close everything down, click the `X` & run the installation from the start again meaning without doing any reboots

## Refs
- [How to fix Windows 11 'does not meet the requirements' error on VirtualBox](https://devcoops.com/fix-windows-11-virtualbox-error/)