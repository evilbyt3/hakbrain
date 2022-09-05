---
title: Windows Event Logs
tags:
- writeups
---

## Event Viewer

```powershell
# Get all powershell log events w id = 800
Get-EventLog 'Windows Powershell' | Where-Object {$_.EventID -eq 800}

# Display properties 
Get-EventLog 'Windows Powershell' | Where-Object {$_.EventID -eq 800} | Select-Object -Property *

	EventID		: 800
	MachineName	: WIN-1O0UJBNP9G7
	Data		: {}
	Index		: 4213
	Category	: Pipeline Execution Details
	CategoryNr	: 8
```

## `wevtutil.exe`
- enables you to retrieve information about event logs and publishers. You can also use this command to install and uninstall event manifests, to run queries, and to export, archive, and clear logs.
- help: `wevtutil.exe /?` & `wevtutil.exe CMD /?`


```powershell
# how many log names are in the machine
wevtutil.exe el | Measure-Object
	Count: 1071
# get the 3 most recent application log events in text format
wevtutil.exe qe Application /c:3 /rd:true /f:text
```

## [`Get-WinEvent`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-5.1)
- gets events from event logs and event tracing log files on local and remote computers
- **Get-WinEvent** cmdlet replaces the [Get-EventLog](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-eventlog?view=powershell-5.1) cmdlet
- generally you can filter events like so: `Get-WinEvent -LogName Application | Where-Object { $_.ProviderName -Match 'WLMS' }`
- `FilterHashtable` parameter [is recommended](https://docs.microsoft.com/en-us/powershell/scripting/samples/Creating-Get-WinEvent-queries-with-FilterHashtable?view=powershell-7.2&viewFallbackFrom=powershell-7.1) to filter event logs
	- Guidelines
	- ![[write-ups/images/Pasted image 20220613010805.png]]
	```powershell
	Get-WinEvent -FilterHashTable @{
		LogName="Application"
		ProviderName="WLMS"
	}
	```
	- [Event Viewer](https://docs.microsoft.com/en-us/shows/inside/event-viewer) can provide quick information on what you need to build your hash table
	- more about hashtables in general [here](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.2&viewFallbackFrom=powershell-7.1)
	
## [XPath](https://docs.microsoft.com/en-us/previous-versions/dotnet/netframework-4.0/ms256115(v=vs.100)) Queries
- W3C created XPath (or **XML Path Language**). The Windows Event Log supports a subset of [XPath 1.0](https://www.w3.org/TR/1999/REC-xpath-19991116/)
- ![[write-ups/images/Pasted image 20220613011533.png]]
- an XPath event query starts with `'*'` or `'Event'`
- can use Event Viewer's `Details > XML View` to build queries: 
	- `Get-WinEvent -LogName Application -FilterXPath '*/System/EventID=100'`
	- ![[write-ups/images/Pasted image 20220613014242.png]]
	- or on a different element w attributes: `Get-WinEvent -LogName Application -FilterXPath '*/System/Provider[@Name="WLMS"]'`
- combining queries: `Get-WinEvent -LogName Application -FilterXPath '*/System/EventID=101 and */System/Provider[@Name="WLMS"]'`
- for elements within `EventData` it will be slightly different: `Get-WinEvent -LogName Security -FilterXPath '*/EventData/Data[@Name="TargetUserName"]="System"'`
	- ![[write-ups/images/Pasted image 20220613014440.png]]

### Answers
![[write-ups/images/Pasted image 20220613013949.png]]
- Using **Get-WinEvent** and **XPath**, what is the query to find WLMS events with a System Time of 2020-12-15T01:09:08.940277500Z?
	```powershell
	Get-WinEvent -LogName Application -FilterXPath '*/System/TimeCreated[@SystemTime="2020-12-15T01:09:08.940277500Z"] and */System/Provider[@Name="WLMS"]'
	```
- Using **Get-WinEvent** and **XPath**, what is the query to find a user named Sam with an Logon Event ID of 4720?
	```powershell
	Get-WinEvent -LogName Security -FilterXPath '*/EventData/Data[@Name="TargetUserName"]="Sam" and */System/EventID=4720'
	```
- Based on the previous query, how many results are returned? : 2
- Based on the output from the question #2, what is Message? : `A user account was creaated`
- Still working with Sam as the user, what time was Event ID 4724 recorded? (**MM/DD/YYYY H:MM:SS AM/PM**): `12/17/2020 1:57:14 PM`
- What is the Provider Name? `Microsoft-Windows-Security-Auditing`

## Event IDs
When it comes to monitoring and hunting, you need to know what you are looking for. How do we pick from the large pool of event IDs? 

- [The Windows Logging Cheat Sheet (Windows 7 - Windows 2012)](https://static1.squarespace.com/static/552092d5e4b0661088167e5c/t/580595db9f745688bc7477f6/1476761074992/Windows+Logging+Cheat+Sheet_ver_Oct_2016.pdf)
- [Various Windows cheatsheetss](https://www.malwarearchaeology.com/cheat-sheets)
- [Spotting the Adversary with Windows Event Log Monitoring](https://apps.nsa.gov/iaarchive/library/reports/spotting-the-adversary-with-windows-event-log-monitoring.cfm) *(NSA)*
- from [[Mitre ATT&CK]]
- [Events to Monitor Windows](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor)
- [The Windows 10 and Windows Server 2016 Security Auditing and Monitoring Reference](https://www.microsoft.com/en-us/download/confirmation.aspx?id=52630) *(a comprehensive list **over 700 pages**)*

> **Note**: Some events will not be generated by default, and certain features will need to be enabled/configured on the endpoint, such as PowerShell logging. This feature can be enabled via **Group Policy** or the **Registry**: `Local Computer Policy > Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell`
- more on enabling it
	- [About Logging Windows](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_windows?view=powershell-7.1)
	- [Greater Visibility Through PowerShell Logging](https://www.fireeye.com/blog/threat-research/2016/02/greater_visibilityt.html)
	- [Configure PowerShell logging to see PowerShell anomalies in Splunk UBA](https://docs.splunk.com/Documentation/UBA/5.0.4/GetDataIn/AddPowerShell)

## Answers

- **Scenario I**: The server admins have made numerous complaints to Management regarding PowerShell being blocked in the environment. Management finally approved the usage of PowerShell within the environment. Visibility is now needed to ensure there are no gaps in coverage. You researched this topic: what logs to look at, what event IDs to monitor, etc. You enabled PowerShell logging on a test machine and had a colleague execute various commands
	- What event ID is to detect a PowerShell downgrade attack?: `400` from [this](https://www.leeholmes.com/detecting-and-preventing-powershell-downgrade-attacks/)
	- What is the **Date and Time** this attack took place? (**MM/DD/YYYY H:MM:SS AM/PM**)
		
		```powershell
		Get-WinEvent -Path .\merged.evtx |
			Where-Object Id -eq 400 |
			Foreach-Object {
				$version = [Version] ($_.Message -replace '(?s).*EngineVersion=([\d\.]+)*.*','$1')
				if($version -lt ([Version] "5.0")) { $_ }
		}
		# yields: 12/18/2020 7:50:33 AM
		```
		
- **Scenario II**: The Security Team is using Event Logs more. They want to ensure they can monitor if event logs are cleared. You assigned a colleague to execute this action.
	- ![[write-ups/images/Pasted image 20220613024859.png]]
	- A **Log clear** event was recorded. What is the 'Event Record ID'? `27736`
	- What is the name of the computer? `PC01.example.corp`
- **Scenario III**: The threat intel team shared its research on **Emotet**. They advised searching for event ID 4104 and the text "ScriptBlockText" within the EventData element. Find the encoded PowerShell payload.
	- ![[write-ups/images/Pasted image 20220613030426.png]]
		```powershell
		Get-WinEvent -Path .\merged.evtx -FilterXPath '*/System/EventID=4104 and */EventData/Data[@Name="ScriptBlockText"]' -Oldest -MaxEntries 1 | Format-List
		```
	- What is the name of the first variable within the PowerShell command? `$Va5w3n8`
	- What is the **Date and Time** this attack took place? (**MM/DD/YYYY H:MM:SS AM/PM**): `8/25/2020 10:09:28`
	- What is the **Execution Process ID**? `6620`
- **Scenario IV**: A report came in that an intern was suspected of running unusual commands on her machine, such as enumerating members of the Administrators group. A senior analyst suggested searching for "`C:\Windows\System32\net1.exe`". Confirm the suspicion
	- What is the **Group Security ID** of the group she enumerated? `S-1-5-32-544`
	- What is the event ID? `4799`


---

## References
- [Windows Event Attack Samples](https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES)
- [Powershell the bluee team](https://devblogs.microsoft.com/powershell/powershell-the-blue-team/)
- [Tampering with Windows Event Tracing: Background, Offense, and Defense](https://blog.palantir.com/tampering-with-windows-event-tracing-background-offense-and-defense-4be7ac62ac63)

## See Also
- [[write-ups/thm/sysinternals]]
- [[write-ups/thm/core-windows-processes]]
- [[write-ups/THM]]
