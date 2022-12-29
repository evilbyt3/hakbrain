---
title: "Snort"
date: 2022-12-29
tags:
- sheet
---

Topic:: [[Blue Team]] | 

---

## Operation Modes
- Sniffer: `sudo snort -dev -i eth0 -X`
- Packet Logger: `sudo snort -dev -l .`
	- ascii mode `-K ASCII` vs normal mode
	- ![[sheets/images/Pasted image 20221229194825.png]]
	- reading logs: `sudo snort -r snort.log.1638459842` *(log files can be opened with tcpdump / [[Wireshark]] as well)*
	- can use [BPF](https://en.wikipedia.org/wiki/Berkeley_Packet_Filter) format to filter: `sudo snort -r logname.log 'udp and port 53'`
- IDS/IPS modes
	- disable logging: `sudo snort -c /etc/snort/snort.conf -N`
	- start in background: `sudo snort -c /etc/snort/snort.conf -D`
	- Alert modes: `sudo snort -c /etc/snort/snort.conf -A console`
		- **console**: Provides fast style alerts on the console screen.
		- **cmg**: Provides basic header details with payload in hex and text format.
		- **full:** Full alert mode, providing all possible information about the alert.  
		- **fast:** Fast mode, shows the alert message, timestamp, source and destination ıp along with port numbers.
		- **none:** Disabling alerting
	- use rule without conf file: `sudo snort -c /etc/snort/rules/local.rules -A console`
	- IPS mode & dropping packets: `sudo snort -c /etc/snort/snort.conf -q -Q --daq afpacket -i eth0:eth1 -A console`
- Investigate PCAP files: `sudo snort -c /etc/snort/snort.conf -q -r icmp-test.pcap -A console -n 10` or pass multiple files with `--pcap-list="icmp-test.pcap http2.pcap"`

## Rules

![[sheets/images/Pasted image 20221229195609.png]]


![[sheets/images/Pasted image 20221229195552.png]]


### Examples


## Refs
- ...
## See Also
- [[IPS & IDS Devices]]
