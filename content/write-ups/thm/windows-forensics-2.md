---
title: Windows Forensics 2
tags:
- writeups
---

## File Allocation Table *(FAT)*
- default file system for Microsoft since the late 70s
- creates a table that indexes the location of bits that are allocated to different files
- [wiki page](https://en.wikipedia.org/wiki/File_Allocation_Table)

### Data Structures
- **Clusters**: a basic storage unit of the FAT file system. Each file stored on a storage device can be considered a group of cluters containing bits of info
- **Directory**: contains info about file identification *(e.g filename, starting cluster, length)*
- **File Allocation Table**: a linked list of all clusters. Contains the status of the cluster and the pointer to the next cluster in the chain

### FAT12, FAT16 & FAT32
- the FAT file format divides the available disk space into clusters for more straightforward addressing *(the nr of clusters depends on the nr of bits used to address that cluster)*
- hence there are multiple variations: 

| Attribute              | FAT12     | FAT16      | FAT32       |
| ---------------------- | --------- | ---------- | ----------- |
| Addressable bitss      | 12        | 16         | 28          |
| Max nr of clusters     | 4096      | 65.536     | 268.435.456 |
| Supported cluster size | 512 - 8KB | 2MB - 32KB | 4KB - 32KB  |
| Max volume size        | 32MB      | 2GB        | 2TB         | 

- in the case of FAT32 there's only 28 bits that address the cluster because the rest is used 4 administrative purposes *(e.g store the end of cluster chain, unusable parts of the disk)*
- chances of coming across FAT12 file systems are pretty rare nowadays, even if FAT16 & FAT32 are still used in some places *(e.g USB, SD cards, digital cams)*, becase the max file/volume size are limiting factors that reduce their usage

### exFAT
- as we started using & adopting higher resolution images and videos, the max file size of FAT32 became a substantial limiting factor for camera manufacturers
- even if Microsoft moved to the [NTFS file system](NTFS file system), it was not suitable for digital media devices as they didn't need the added security features => manufactorers lobying Microsoft to create exFAT
- exFAT: the default file system for SD cards larger than 32GB
	- supports a cluster size of 4KB - 32MB
	- max vol size of 128PB
	- reduces some of the overheads of FAT to make it lighter & more efficient
	- max of 2,796,202 files per dir

## NTFS 
- The New Technology File System was introduced by microsoft in 1993 to address the limitations of the FAT fs *(recovery capabilities, security, reliability)* while introducing new features
- **Journaling**: log of changes to the metadata in the volume
	- helps the system recover from a crash / data movement due to defragmentation
	- log stored in `$LOGFILE` within the volume's root dir
- **Access Controls**: they define the owner of a file/dir & permissions for each user
- **Volume Shadow Copy**: keeps track of changes made to a file, thus a user caan restore previous file versions 4 recovery or a system restore
	- it has been noted that ransware actors delete the shadow copies on a victim's computer to prevent them from recovering data
- **Alternate Data Streams (ADS)**: allows files to have multiple streams of data stored in a single file
	- browsers use this feature to identify file downloaded from the internet *(uing the ADS Zone Transfer)*
	- also malware uses it to hide code

### Master File Table *(MFT)*
- similar to the File Allocation Table there's a more extensive Master File Table in NTFS 
- a structured db that tracks the objects stored in a volume => so the data is organized here
- some critical MFT files 4 forensics:
	- `$MFT`: 1st record in a volume. The Volume Boot Record *(VBR)* points to the cluster where it's located. It stores info about the clusters where all the other objects are located. This file has a dir of all the files present on the volume
	- `$LOGFILE`: stores the transactional logging of the file system. Helps to maintain the integrity of fs in case of crash
	- `$UsnJrnl`: stands for the Update Sequence Number *(USN)* Journal. Present in the `$Extend` record & contains info about all the files changed in the fs & the reason for it *(also called the change journal)*
- we can explore the MFT using `MFTECmd`, one of [Eric Zimmerman's tools](https://ericzimmerman.github.io/#!index.md)<: `MFTECmd.exe -f <path-to-$MFT-file> --csv <path-to-save-results-in-csv>` then use the `EZviewer`
	- ![[write-ups/images/Pasted image 20220623041129.png]]
	- similarly parse the `$Boot` file, which will provide information about the boot sector
	- doesn't support `$LOGFILE` as of now
	- ![[write-ups/images/Pasted image 20220623041612.png]]
- Parse the $MFT file placed in `C:\users\THM-4n6\Desktop\triage\C\` and analyze it. What is the Size of the file located at `.\Windows\Security\logs\SceSetupLog.etl`?
	- ![[write-ups/images/Pasted image 20220623041952.png]]
	- or from cli
	- ![[write-ups/images/Pasted image 20220623042007.png]]
- What is the size of the cluster for the volume from which this triage was taken?
	- ![[write-ups/images/Pasted image 20220623042049.png]]
	- ![[write-ups/images/Pasted image 20220623042218.png]]

## Recovering Deleted Files
- as we delete a file from the file sytstem, it just deletes the entries stored in the db that store the file's location on disk => the locaation is not available / unallocated
- however that doesn't mean the contents of the file are gone, there are still on disk as long as they're not overwritten by the file system
- similarly, there is data on the disk in different unallocated clusters, which can possibly be recovered
- thus, we can recover this data by analyzing the bytes *(& understanding the file struct we're searching for)* with a hex editor or with specialized tools like [Autopsy](https://www.autopsy.com/)

> **NOTE**: if you want to override the file's contents on disk rendering it unavailable we can use tools like `shred` 


## Evidence of Execution
- **Windows Prefetch files**: when a program runs on Windows, it stores its info for future use. This is used to load the program quickly in case of frequent use
	- stored in prefetch files which are located in the `C:\Windows\Prefetch` dir
	- contain the last run times of the application, the number of times the application was run, and any files and device handles used by the file => excellent source for forensics
	- can use Prefetch Parser from Zimmerman's tools to extract the data: `PECmd.exe -f <path-to-prefetch-files> --csv <csv-output>`
- **Windows 10 Timeline**: stores recently used applications and files in an SQLite database called the Windows 10 Timeline
	- can be a source of information about the last executed programs
	- contains  the application that was executed and the focus time of the application
	- found @ `C:\Users\<username>\AppData\Local\ConnectedDevicesPlatform\{randomfolder}\ActivitiesCache.db`
	- fetch thi data with `WxTCmd.exe` from Zimmerman's tools: `WxTCmd.exe -f <path-to-timeline-file> --csv <path-to-save-csv>`
- **Windows Jump Lists**: Windows introduced jump lists to help users go directly to their recently used files from the taskbar
	- can view jumplists by right-clicking an application's icon in the taskbar, and it will show us the recently opened files in that application
	- stored @ `C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations`
	- include information about the applications executed, first time of execution, and last time of execution of the application against an AppID
	- also can see with Zimmerman's tools: `JLECmd.exe -f <path-to-Jumplist-file> --csv <path-to-save-csv>`

## File/Folder Knowledge
- **Shortcut Files**: Windows creates a shortcut file for each file opened either locally or remotely
	- contain information about the first and last opened times of the file and the path of the opened file, along with some other data
	- can be found @ `C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\` & `C:\Users\<username>\AppData\Roaming\Microsoft\Office\Recent\`
	- `LECmd.exe -f <path-to-shortcut-files> --csv <path-to-save-csv>` to explore it
	- can sometimes provide us with information about connected USB devices *(e.g  volume name, type, and serial number)*
- **IE/Edge History**: IE/Edge browsing history is that it includes files opened in the system as well, whether those files were opened using the browser or not
	- can be found @ `C:\Users\<username>\AppData\Local\Microsoft\Windows\WebCache\WebCacheV*.dat`
	- files/folders accessed appear with a `file:///*` prefix in the IE/Edge history
	- can use several tools to analyze Web cache data *(e.g [Autopsy](https://www.autopsy.com/))*
- **External Deivces/USB**: When any new device is attached to a system, information related to the setup of that device is stored in the `setupapi.dev.log` @ `C:\Windows\inf\`

---

## References

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/windows-forensics-1]]
