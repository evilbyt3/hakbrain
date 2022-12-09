---
title: SysMon
tags:
- writeups
---

## Overview
- most commonly used in conjuction w a security information & management system *(SIEM)*
- events are stored in `Applications and Services Logs/Microsoft/Windows/Sysmon/Operational`
- installation:
	- powersshell: `Download-SysInternalsTools C:\Sysinternals`
	- Sysmon binary from the [Microsoft Sysinternals](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon) website
	- download the [Microsoft Sysinternal Suite](https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite)
	- staring it: `Sysmon.exe -accepteula -i sysmonconfig-export.xml`
- [config example](https://github.com/SwiftOnSecurity/sysmon-config)
	- a majority of rules in sysmon-config will exclude events rather than include events
- Event ID 1: Process Creation
	- will look for any processes that have been created
		```xml
		<RuleGroup name="" groupRelation="or">  
			<ProcessCreate onmatch="exclude">  
			  <CommandLine condition="is">
				C:\Windows\system32\svchost.exe -k appmodel -p -s camsvc
			  </CommandLine>  
			</ProcessCreate>  
		</RuleGroup>
		```
	-  exclude the `svchost.exe` process from the event logs
- Event ID 3: Network Connection
	-  will look for events that occur remotely
		```xml
		<RuleGroup name="" groupRelation="or">  
			<NetworkConnect onmatch="include">  
			  <Image condition="image">nmap.exe</Image>  
			  <DestinationPort 
					name="Alert,Metasploit"
					condition="is">
				  4444
			  </DestinationPort>  
			</NetworkConnect>  
		</RuleGroup>
		```
- Event ID 7: Image Loaded
	- will look for DLLs loaded by processes, which is useful when hunting for DLL Injection and DLL Hijacking attacks
	- exercise caution when using this Event ID as it causes a high system load
		```xml
		<RuleGroup name="" groupRelation="or">  
			<ImageLoad onmatch="include">  
			  <ImageLoaded condition="contains">\Temp\</ImageLoaded>  
			</ImageLoad>  
		</RuleGroup>
		```
- Event ID 8: [CreateRemoteThread](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createremotethread)
	- will monitor for processes injecting code into other processes
		```xml
		<RuleGroup name="" groupRelation="or">  
			<CreateRemoteThread onmatch="include">  
			  <StartAddress name="Alert,Cobalt Strike" condition="end with">0B80</StartAddress>  
			  <SourceImage condition="contains">\</SourceImage>  
			</CreateRemoteThread>  
		</RuleGroup>
		```
	- look at the memory address for a specific ending condition which could be an indicator of a Cobalt Strike beacon
	- look for injected processes that do not have a parent process
- Event ID 12 / 13 / 14: Registry Event
	- looks for changes or modifications to the registry
	- malicious activity from the registry can include persistence and credential abuse
		```xml
		<RuleGroup name="" groupRelation="or">  
			<RegistryEvent onmatch="include">  
			  <TargetObject name="T1484" condition="contains">
				  Windows\System\Scripts
			  </TargetObject>  
			</RegistryEvent>  
		</RuleGroup>
		```
- Event ID 15: [FileCreateStreamHash](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=90015)
	- look for any files created in an alternate data stream
	- common technique used by adversaries to hide malware
		```xml
		<RuleGroup name="" groupRelation="or">  
			<FileCreateStreamHash onmatch="include">  
			  <TargetFilename condition="end with">.hta</TargetFilename>  
			</FileCreateStreamHash>  
		</RuleGroup>
		```
	- look for files with the `.hta` extension that have been placed within an alternate data stream
- Event ID 22: DNS Event
	- log all DNS queries and events for analysis
	- most common way to deal with these events is to exclude all trusted domains that you know will be very common "noise" in your environment
	- once you get rid of the noise you can then look for DNS anomalies
		```xml
		<RuleGroup name="" groupRelation="or">  
			<DnsQuery onmatch="exclude">  
			  <QueryName condition="end with">.microsoft.com</QueryName>  
			</DnsQuery>  
		</RuleGroup>
		```
	- exclude any DNS events with the `.microsoft.com` query


## Cutting out the noise
- **Exclude > Include**: it's typically best to prioritize excluding events rather than including events. This prevents you from accidentally missing crucial events and only seeing the events that matter the most
- **Use the CLI**: gives you the most control and filtering allowing for further granular control. You can use either `Get-WinEvent` or `wevutil.exe` to access & filter logs *(see [[write-ups/thm/windows-event-logs]])*
- **Know your env before implementation**: should have a firm understanding of the network or environment you are working within to fully understand what is normal and what is suspicious in order to effectively craft your rules
### Answers
- How many event ID 3 events are in `C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Filtering.evtx`?
	```powershell
	Get-WinEvent -Path .\Filtering.evtx -FilterXPath '*/System/EventID=3' | Measure-Object
	
	Count    : 73591
	```
- What is the UTC time created of the first network event in `C:\Users\THM-Analyst\Desktop\Scenarios\Practice\Filtering.evtx`?: `2021-01-06 01:35:50.464`
	- in Event Viewer: `Filter Current Log > EventID 3 > Sort by date & time`

## Hunting Metasploit

- how malware and payloads interact with the network check out the [Malware Common Ports Spreadsheet](https://docs.google.com/spreadsheets/d/17pSTDNpa0sf6pHeRhusvWG6rThciE8CsXTSlDUAZDyo)
- detect the creation of new network connections: use `EventId=3` & active connections on `4444` & `5555`
	```xml
	<RuleGroup name="" groupRelation="or">  
		<NetworkConnect onmatch="include">  
			<DestinationPort condition="is">4444</DestinationPort>  
			<DestinationPort condition="is">5555</DestinationPort>  
		</NetworkConnect>  
	</RuleGroup>
	```
- Using Powershell's [Get-WinEvent](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.2)
	```powershell
	Get-WinEvent -Path .\Hunting_Metasploit.evtx -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=4444'
	```
	
## Detecting [Mimikatz](https://github.com/ParrotSec/mimikatz)

- looking for files created with the name Mimikatz: simple way to detect activity that has bypassed anti-virus or other detection measures
	```xml
	<RuleGroup name="" groupRelation="or">  
		<FileCreate onmatch="include">  
			<TargetFileName condition="contains">mimikatz</TargetFileName>  
		</FileCreate>  
	</RuleGroup>
	```
> **NOTE:** when dealing with an advanced threat you will need more advanced hunting techniques like searching for LSASS behavior but this technique can still be useful

- abnormal `LSASS` behavior
	- can use the `ProcessAccess` event ID
	- show potential LSASS abuse which usually connects back to Mimikatz some other kind of credential dumping tool
	- if LSASS is accessed by a process other than `svchost.exe` it should be considered suspicious
	```xml
	<RuleGroup name="" groupRelation="or">  
		<ProcessAccess onmatch="exclude">  
			<SourceImage condition="image">svchost.exe</SourceImage>  
		</ProcessAccess>
		<ProcessAccess onmatch="include">  
			<TargetImage condition="image">lsass.exe</TargetImage>  
		</ProcessAccess>  
	</RuleGroup>
	```
	- or with powershell
	```powershell
	Get-WinEvent -Path .\Hunting_Mimikatz.evtx -FilterXPath '*/System/EventID=10 and */EventData/Data[@Name="TargetImage"] and */EventData/Data="C:\Windows\system32\lsass.exe"' | Format-List
	```
	
## Hunting Malware
- RATs typically come with other Anti-Virus and detection evasion techniques
	- also uses a Client-Server model and comes with an interface for easy user administration
	- examples: [Xeexe](https://github.com/jesusgavancho/Xeexe) & [Quasar](https://github.com/quasar/Quasar)
- to detect and hunt malware we will need to first identify the malware that we want to hunt or detect and identify ways that we can modify configuration files, this is known as **hypothesis-based hunting**
- look through and create a configuration file to hunt and detect suspicious ports open on the endpoint
- example from [Ion-Storm](https://github.com/ion-storm/sysmon-edr) which will alert specific ports *(i.e `1034` & `1604`)* as well ass exclude common network conn *(e.g OneDrive)*
	```xml
	<RuleGroup name="" groupRelation="or">  
		<NetworkConnect onmatch="include">  
			<DestinationPort condition="is">1034</DestinationPort>  
			<DestinationPort condition="is">1604</DestinationPort>  
		</NetworkConnect>  
		<NetworkConnect onmatch="exclude">  
			<Image condition="image">OneDrive.exe</Image>  
		</NetworkConnect>  
	</RuleGroup>
	```
	
> **NOTE**: When using configuration files in a production env you need to understand exactly what is happening within the conf file. (e.g  the Ion-Storm configuration file excludes port 53 as an event which adversaries have begun to usse as part of their payloads)

- look for all `Network connection` events that have the destination port `8080`
```powershell
Get-WinEvent -Path .\Hunting_Rats.evtx -FilterXPath '*/System/EventID=3 and */EventData/Data[@Name="DestinationPort"] and */EventData/Data=8080' |Format-List
```

## Hunting Persistence
- persistence is used by attackers to maintain access to a machine once it is compromised
- there's multiple ways an attacker can achieve this, but we will focus on [registry modification](https://attack.mitre.org/techniques/T1112/) & [startup scripts](https://attack.mitre.org/techniques/T1547/) *(i.e File Creation events as well as Registry Modification events)*

### Startup 
- SwiftOnSecurity detections for a file being placed in the `\Startup\` or `\Start Menu` directories.
```xml
<RuleGroup name="" groupRelation="or">  
	<FileCreate onmatch="include">  
		<TargetFilename name="T1023" condition="contains">\Start Menu</TargetFilename>  
		<TargetFilename name="T1165" condition="contains">\Startup\</TargetFilename>  
	</FileCreate>  
</RuleGroup>
```

### Registry Key
- SwiftOnSecurity detection this time for a registry modification that adjusts that places a script inside `CurrentVersion\Windows\Run` and other registry locations

```xml
<RuleGroup name="" groupRelation="or">  
	<RegistryEvent onmatch="include">  
		<TargetObject name="T1060,RunKey" condition="contains">CurrentVersion\Run</TargetObject>  
		<TargetObject name="T1484" condition="contains">Group Policy\Scripts</TargetObject>  
		<TargetObject name="T1060" condition="contains">CurrentVersion\Windows\Run</TargetObject>  
	</RegistryEvent>  
</RuleGroup>
```

## Detecting Evasion Techniques
- Various evasion techniques are used by malware authors to both evade anti-virus & detections *(e.g Alternate Data Streams, Injections, Masquerading, Packing/Compression, Recompiling, Obfuscation, Anti-Reversing Techniques)*
- [Injection techniques](https://attack.mitre.org/techniques/T1055/) come in many different types: Thread Hijacking, PE Injection, DLL Injection, and more

### Hunting ADS
- [Alternate Data Streams are used by malware](https://attack.mitre.org/techniques/T1564/004/) to hide its files from normal inspection by saving the file in a different stream apart from `$DATA`
- Event ID 15 will hash and log any NTFS Streams that are included within the Sysmon configuration file
- To aid in hunting ADS we will be using the SwiftOnSecurity Sysmon configuration file: will look for files in the `Temp` and `Startup` folder as well as `.hta` and `.bat` extension
```xml
<RuleGroup name="" groupRelation="or">  
	<FileCreateStreamHash onmatch="include">  
		<TargetFilename condition="contains">Downloads</TargetFilename>  
		<TargetFilename condition="contains">Temp\7z</TargetFilename>  
		<TargetFilename condition="ends with">.hta</TargetFilename>  
		<TargetFilename condition="ends with">.bat</TargetFilename>  
	</FileCreateStreamHash>  
</RuleGroup>
```

### Detecting Remote Threads
- adversaries also commonly use remote threads to evade detections in combination with other techniques
- remote threads are created using the Windows API `CreateRemoteThread` and can be accessed using `OpenThread` and `ResumeThread`
- used in multiple evasion techniques including DLL Injection, Thread Hijacking, and Process Hollowing
- will be using the Sysmon `eventID 8` from the SwiftOnSecurity configuration file
- exclude common remote threads without including any specific attributes this allows for a more open and precise event rule
```xml
<RuleGroup name="" groupRelation="or">  
	<CreateRemoteThread onmatch="exclude">  
		<SourceImage condition="is">C:\Windows\system32\svchost.exe</SourceImage>  
		<TargetImage condition="is">C:\Program Files (x86)\Google\Chrome\Application\chrome.exe</TargetImage>  
	</CreateRemoteThread>  
</RuleGroup>
```

### Detecting Evasion Techniques with PowerShell
- Detecting Alternate Data Streams: `Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=15'`
- Detecting Remote Thread Creation: `Get-WinEvent -Path <Path to Log> -FilterXPath '*/System/EventID=8'`

## Practical Investigations
Event files used within this task have been sourced from the [EVTX-ATTACK-SAMPLES](https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES/tree/master) and [SysmonResources](https://github.com/jymcheong/SysmonResources)Github repositories.

### 1 - ugh, BILL THAT'S THE WRONG USB!
In this investigation, your team has received reports that a malicious file was dropped onto a host by a malicious USB. They have pulled the logs suspected and have tasked you with running the investigation for it.

- we see 4 `RawAccessRead` events
	- `RawAccessRead` event detects when a process conducts reading operations from the drive using the `\\.\ ` denotation
	- often used by malware for data exfiltration of files that are locked for reading, as well as to avoid file access auditing toolsA
	- exfiltrated 2 files: `explorer.exe` & `svchost.exe` on `\Device\HarddiskVolume3`
- then it changes 2 regisstry keys
	- `HKLM\System\CurrentControlSet\Enum\WpdBusEnumRoot\UMB\`
	- `HKLM\SOFTWARE\Microsoft\Windows Portable Devices\Devices\WPDBUSENUMROOT`
- uses the `WUDFHost.exe` *([Windows User-Mode Driver Framework](https://docs.microsoft.com/en-us/windows-hardware/drivers/wdf/overview-of-the-umdf))*: 
	- ![[write-ups/images/Pasted image 20220615021517.png]]

### 2 - This isn't an HTML file?
Another suspicious file has appeared in your logs and has managed to execute code masking itself as an HTML file, evading your anti-virus detections. Open the logs and investigate the suspicious file

- adversary made use of the `iexplore.exe` to lunch `update.hta` masked as an HTML file: `update.html`
- the `update.hta` was executed by `mshta.exe`, which provides  the [Microsoft HTML Application Host](https://win10.support/mshta-exe-microsoft-r-html-application-host/) that allow execution of `.hta` files *(HTML apps)*
- then, a network connection to their C2 was spawned
	- ![[write-ups/images/Pasted image 20220615025058.png]]

### 3.1 : 3.2 - Where's the bouncer when you need him
Your team has informed you that the adversary has managed to set up persistence on your endpoints as they continue to move throughout your network. Find how the adversary managed to gain persistence using logs provided

- 3.1
	- adversary achieved persistence by uploading a payload to the `HKLM\SOFTWARE\Microsoft\Network\debug` registry
	- then to launch it used powershell: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -c "$x=$((gp HKLM:Software\Microsoft\Network debug).debug);start -Win Hidden -A \"-enc $x\" powershell";exit;uu`
	- details about the connection *(ip, infected host)*
		- ![[write-ups/images/Pasted image 20220615025709.png]]
- 3.2 
	- attacker deployed payload in `c:\users\q\AppData:blah.txt` using `cmd.exe /C echo "payload"`
	- then, created a scheduled task using the deployed payload through `schtasks.exe`
	```powershell
	"C:\WINDOWS\system32\schtasks.exe" /Create /F /SC DAILY /ST 09:00 /TN Updater /TR "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonI -W hidden -c \"IEX ([Text.Encoding]::UNICODE.GetString([Convert]::FromBase64String($(cmd /c ''more < c:\users\q\AppData:blah.txt'''))))\""
	```
	- following for `lsass.exe` to be accessed by the scheduled task

---

## References
- [Malware Back Connect Ports Spreadsheet](https://docs.google.com/spreadsheets/d/17pSTDNpa0sf6pHeRhusvWG6rThciE8CsXTSlDUAZDyo/edit#gid=0)

## See Also
- [[write-ups/thm/windows-event-logs]]
- [[write-ups/THM]]