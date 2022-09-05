---
title: Windows Forensics 1
tags:
- writeups
---

- **Forensic Artifacts**: are essential pieces of information that provide evidence of human activity *(e.g during the investigation of a crime scene: fingerprints, tools used to perform the crime, etc are all considered forensic artifacts)*. Basically all the artifacts are combined to recreate the story of how the crime was committed. In the digital world, artifacts can be small footprints of activity left on the computer system

## Windows Registry
- A a collection of databases that contains the system's configuration data about the hardware, software, user's information *(e.g recently used files, programs used, devices connected)*
- It consists of Keys and Values
- A [Registry Hive](https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-hives#:~:text=Registry Hives. A hive is a logical group,with a separate file for the user profile.) is a group of Keys, subkeys, and values stored in a single file on the disk
- more about it on the [official doc](https://docs.microsoft.com/en-US/troubleshoot/windows-server/performance/windows-registry-advanced-users)
### Structure
| Folder/predefined Key | Description                                                                                                                                                                                                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `HKEY_CURRENT_USER`   | Contains the root of the configuration information for the user who is currently logged on. The user's folders, screen colors, and Control Panel settings are stored here. This information is associated with the user's profile. This key is sometimes abbreviated as HKCU. |
| `HKEY_USERS`          | Contains all the actively loaded user profiles on the computer. `HKEY_CURRENT_USER` is a subkey of `HKEY_USERS`. `HKEY_USERS` is sometimes abbreviated as HKU.                                                                                                                |
| `HKEY_LOCAL_MACHINE`  | Contains configuration information particular to the computer (for any user). This key is sometimes abbreviated as HKLM.                                                                                                                                                      |
| `HKEY_CLASSES_ROOT`   | Is a subkey of `HKEY_LOCAL_MACHINE\Software`. The information that is stored here makes sure that the correct program opens when you open a file by using Windows Explorer. This key is sometimes abbreviated as HKCR.                                                        |
| `HKEY_CURRENT_CONFIG` | Contains information about the hardware profile that is used by the local computer at system startup.                                                                                                                                                                         | 

### Accessing hives offline
If you only have access to a disk image, you must know where the registry hives are located on the disk. The majority of these hives are located in the `C:\Windows\System32\Config` directory and are:
- **DEFAULT**: `HKEY_USERS\DEFAULT`
- **SAM**: `HKEY_LOCAL_MACHINE\SAM`
- **SECURITY**: `HKEY_LOCAL_MACHINE\Security`
- **SOFTWARE**: `HKEY_LOCAL_MACHINE\Software`
- **SYSTEM**: `HKEY_LOCAL_MACHINE\System`

Apart from these hives, two other hives containing user information can be found in the User profile directory *(`C:\Users\<username>`)*:
- `NTUSER.dat` *(mounted on `HKEY_CURRENT_USER` upon login)*
- `USRCLASS.dat` *(mounted on `HKEY_CURRENT_USER\Software\CLASSES`)*

> **NOTE**: These are hidden files

There's also another hive called **AmCache** located in `C:\Windows\AppCompat\Programs\Amcache.hve`. Windows creates it to save information on programs that were recemtly run on the system

### Transaction Logs & Backups
 The transaction logs can be considered as the journal of the changelog of the registry hive. This means that thee logs can often have the latest changes in the registry that haven't made their way to the registry hives themselves.
 
 They're stored aas a `.LOG` file in the same directory as the hive itself *(e.g for the SAM hive will be located in `C:\Windows\System32\Config` in the filename `SAM.LOG`)*
 
 Registry backups are the opposite of Transaction logs. These are the backups of the registry hives located in the `C:\Windows\System32\Config` directory. These hives are copied to the `C:\Windows\System32\Config\RegBack` directory every ten days

## Data Acquisition
For the sake of accuracy, it is recommended practice to image the system or make a copy of the required data and perform forensics on it. This is called data acquisition.

When we go to copy the registry hives from `%WINDIR%\System32\Config`, we cannot because it is a restricted file. For that we can use some tools:
- [Kape](https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape): is a live data acquisition and analysis tool which can be used to acquire registry data
- [Autopsy](https://www.autopsy.com/): gives you the option to acquire data from both live systems or from a disk image
- [FTK Imager](https://www.exterro.com/ftk-imager): similar to Autopsy and allows you to extract files from a disk image or a live system by mounting the said disk image or drive in FTK Imager
- [AccessData's Registry Viewer](https://accessdata.com/product-download/registry-viewer-2-0-0): let's you explore the regitry similar to Windows Registry Editor *(only loads one hive at a time, and it can't take the transaction logs into account)*
- [Eric Zimmerman's Tools](https://ericzimmerman.github.io/#!index.md): handful of tools that are very useful for performing Digital Forensics and Incident Response
- [RegRipper](https://github.com/keydet89/RegRipper3.0): utility that takes a registry hive as input and outputs a report that extracts data from some of the forensically important keys and values in that hive


## System Information & Accounts

- to find the OS version check the `SOFTWARE\Microsoft\Windows NT\CurrentVersion`
	- ![[write-ups/images/Pasted image 20220621200246.png]]
- the hives containing the machine’s configuration data used for controlling system startup are called Control Sets. Commonly there's 2:
	- ControlSet001: will point to the Control Set that the machine booted with *(@ `SYSTEM\ControlSet001`)*
	- ControlSet002: will be the last known good configuration *(@ `SYSTEM\ControlSet002`)*
- Windows creates a volatile Control Set when the machine is live, called the CurrentControlSet (`HKLM\SYSTEM\CurrentControlSet`). To find out which Control et is being used a the CurrentControlSet we can look @ `SYSTEM/Select/Current`. Similary the last known good config can be found @ `SYSTEM/Select/LastKnownGood`
- find the Computer Name from: `SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName`
- it's important to establish the time zone of the computer to better understand the chronology of events. It can be found @ `SYSTEM\CurrentControlSet\Control\TimeZoneInformation`
- **Network Interfaces & Past Networks**
	- the following registry key will give a list of network interfaces on the machine we are investigating: `SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces`
	- ![[write-ups/images/Pasted image 20220621201045.png]]
	- each Interface is represented with a unique identifier (GUID) subkey, which contains values relating to the interface’s TCP/IP configuration. Will provide us with info like IP address, DHCP, Subnet Masks, DNS, etc
	- the past networks a given machine was connected to can be found in the following locations: `SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged` & `SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Managed`
	- the last write time of the registry key points to the last time these networks were connected.
- **Autoruns**
	- include information about programs or commands that run when a user logs on
		- `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Run`
		- `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\RunOnce`

		- `SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce`
		- `SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer\Run`
		- `SOFTWARE\Microsoft\Windows\CurrentVersion\Run`
	- information about services: `SYSTEM\CurrentControlSet\Services`
		- ![[write-ups/images/Pasted image 20220621201358.png]]
		- if `start` is set to `0x02` => service will start on boot
- **SAM hive and user information**: SAM hive contains user account information, login information, and group information & is mainly located @ `SAM\Domains\Account\Users`

## Usage of files/folders
- **Recent Files**: Windows maintains a list of recently opened files for each user. This info is stored in the `NTUSER` hive @ `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs`
	- ![[write-ups/images/Pasted image 20220621201742.png]]
	- if we're looking for a specific extenstion *(e.g `.pdf`)* we can check the following reg key: `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs\.pdf`
- **Office Recent Files**: Microsoft Office also maintains a list of recently opened documents @ `NTUSER.DAT\Software\Microsoft\Office\VERSION`
	- version number for each Microsoft Office release is different *(e.g `NTUSER.DAT\Software\Microsoft\Office\15.0\Word`)*
	- Starting from Office 365, Microsoft now ties the location to the user's [live ID](https://www.microsoft.com/security/blog/2008/05/07/what-is-a-windows-live-id/): `NTUSER.DAT\Software\Microsoft\Office\VERSION\UserMRU\LiveID_####\FileMRU`
- **ShellBags**: When any user opens a folder, it opens in a specific layout, users can change this to their preferences. Layouts can be different for different folders. This info about the WIndows *shell* is stored & can identify the most recently used files/folders. Since this setting is different 4 each usser it's located in the user hives
	- `USRCLASS.DAT\Local Settings\Software\Microsoft\Windows\Shell\Bags`
	- `USRCLASS.DAT\Local Settings\Software\Microsoft\Windows\Shell\BagMRU`
	- `NTUSER.DAT\Software\Microsoft\Windows\Shell\BagMRU`
	- `NTUSER.DAT\Software\Microsoft\Windows\Shell\Bags`
	- we can use the [ShellBag Explorer from Zimmerman](https://ericzimmerman.github.io/#!index.md)
	- ![[write-ups/images/Pasted image 20220621204106.png]]
- **Open/Save and LastVisited Dialog MRUs**: When we open or save a file, a dialog box appears asking us where to save or open that file from, Windows remembering that location => we can find out recently used files if we get our hands on this information
	- `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePIDlMRU`
	- `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU`
- **Windows Explorer Address/Search Bars**: to identify a user's recent activity is by looking at the paths typed in the Windows Explorer address bar or searches performed using the following registry keys, respectively:
	- `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths`
	- `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery`

## Evidence of Execution
- **UserAssist**: Windows keeps track of applications launched by the user using Windows Explorer for statistical purposes in the User Assist registry keys
	- contain info about the programs launched, the time of their launch, and the number of times they were executed
	- programs that were run using the command line can't be found in the User Assist keys
	- he User Assist key is present in the NTUSER hive, mapped to each user's GUID, we can find it @ `NTUSER.DAT\Software\Microsoft\Windows\Currentversion\Explorer\UserAssist\{GUID}\Count`
	- ![[write-ups/images/Pasted image 20220621204651.png]]
- **ShimCache**: is a mechanism used to keep track of application compatibility with the OS and tracks all applications launched on the machine
	- main purpose in Windows is to ensure backward compatibility of applications
	- also called Application Compatibility Cache (AppCompatCache) & found @ `SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache`
	- stores file name, file size, and last modified time of the executables
	- use `AppCompatCache Parser` tool to output a CSV: `AppCompatCacheParser.exe --csv <path to save output> -f <path to SYSTEM hive for data parsing> -c <control set to parse>`
		- ![[write-ups/images/Pasted image 20220621204814.png]]
- **AmCache**: AmCache hive is an artifact related to ShimCache
	- performs a similar function to ShimCache, and stores additional data related to program executions *(e.g execution path, installation, execution and deletion times, and SHA1 hashes)*
	- located in the file system @: `C:\Windows\appcompat\Programs\Amcache.hve`
	- info about the last executed programs can be found @ `Amcache.hve\Root\File\{Volume GUID}\`
	- ![[write-ups/images/Pasted image 20220621205001.png]]
- **BAM/DAM**: Background Activity Monitor *(BAM)* keeps a tab on the activity of background applications. Similar Desktop Activity Moderator *(DAM)* is a part of Microsoft Windows that optimizes the power consumption of the device
	- contain data about last run programs, their full paths & last execution time @ 
	- `SYSTEM\CurrentControlSet\Services\bam\UserSettings\{SID}`
	- `SYSTEM\CurrentControlSet\Services\dam\UserSettings\{SID}`
	- ![[write-ups/images/Pasted image 20220621205142.png]]

## External Devices
- **Device identification**: the following locations keep track of USB keys plugged into a system
	- `SYSTEM\CurrentControlSet\Enum\USBSTOR` & `SYSTEM\CurrentControlSet\Enum\USB`
	- store data such as: vendor id, product id, and version of the USB device plugged in *(can be used to identify unique devices)*
	- ![[write-ups/images/Pasted image 20220621205416.png]]
- **First/Last Times**: the following registry key tracks the first time the device was connected, the last time it was connected and the last time the device was removed from the system
	- `SYSTEM\CurrentControlSet\Enum\USBSTOR\Ven_Prod_Version\USBSerial#\Properties\{83da6326-97a6-4088-9453-a19231573b29}\####`
	- the `####` can be replaced with the following digits
		- ![[write-ups/images/Pasted image 20220621205520.png]]
- **USB Device Volume Name**: device name of the connected drive can be found at the following location: `SOFTWARE\Microsoft\Windows Portable Devices\Devices`
	- ![[write-ups/images/Pasted image 20220621205611.png]]

## Hands-On Challenge
**Scenario**: One of the Desktops in the research lab at Organization X is suspected to have been accessed by someone unauthorized. Although they generally have only one user account per Desktop, there were multiple user accounts observed on this system. It is also suspected that the system was connected to some network drive, and a USB device was connected to the system. The triage data from the system was collected and placed on the attached VM. Can you help Organization X with finding answers to the below questions?

- How many user created accounts are present on the system?
	- open the `SAM` hive @ `C:\Users\THM-4n6\Desktop\triage\C\Windows\System32\config\SAM` w regitry explorer
	- HINT: accounts with RIDs starting with 10xx are user created accounts
	- ![[write-ups/images/Pasted image 20220621214753.png]]
	- so we have 3: `THM-4n6`, `thm-user`, `thm-user2`
- What is the username of the account that has never been logged in?
	- by looking @ the `Last Login Time` column we see that `thm-user2` never logged in
	- ![[write-ups/images/Pasted image 20220621215045.png]]
- What's the password hint for the user THM-4n6?
	- ![[write-ups/images/Pasted image 20220621215116.png]]
	- `count`
- When was the file 'Changelog.txt' accessed?
	- open the `NTUSER.dat` from `C:\Users\THM-4n6\Desktop\triage\C\Users\THM-4n6` 
	- you will be alerted about a dirty hive, just load the `.LOG1 & 2` files to generate a clean one
	- then navigate to `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs`
	- ![[write-ups/images/Pasted image 20220621215459.png]]
- What is the complete path from where the python 3.8.2 installer was run?
	- navigate to the UserAssist `NTUSER.DAT\Software\Microsoft\Windows\Currentversion\Explorer\UserAssist\{GUID}\Count` & search for `python`
	- ![[write-ups/images/Pasted image 20220621215906.png]]
- When was the USB device with the friendly name 'USB' last connected?
	- open the `C:\Users\THM-4n6\Desktop\triage\C\Windows\System32\config\SYSTEM` hive *(do the same with the `.LOG` files)*
	- navigate to `SYSTEM\CurrentControlSet\Enum\USBSTOR` to see when the devices were first installed & last connected
	- ![[write-ups/images/Pasted image 20220621220850.png]]


---

## References

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/windows-forensics-2]]