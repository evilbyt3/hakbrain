---
title: "Zeek"
date: 2022-12-30
tags:
- writeup
- sheet
---

Topic:: [[Blue Team]] | 

---

### CheatSheet

```bash
zeekctl - utility to help the zeek service
[ZeekControl] > stop
[ZeekControl] > status
[ZeekControl] > start

# Will generate logs based on traffic
# (e.g dns, dhcp, conn, http)
zeek -Cr sample.pcap 

# Use zeek-cut to filter events
cat conn.log | zeek-cut uid proto id.orig_h id.orig_p id.resp_h id.resp_p

# -=-=-==[ Signatures ]==-=-=-
# https://docs.zeek.org/en/master/frameworks/signatures.html
signature http-password {
	ip-proto == tcp
	dst_port == 80
	payload /.*password.*/ 
	event "Cleartext Password Found!"
}
signature ftp-admin {
	ip.proto == tcp
	ftp /.*USER.*dmin.*/
	event "FTP Admin Login Attempted"
}
# check signature.log & notice.log
zeek -Cr http.pcap -s http-password.sig
zeek -Cr ftp.pcap -s ftp-admin.sig





# -=-=-==[ Zeek Logs ]==-=-=-
# 

```

![[sheets/zeek_logs_cheatsheet.pdf]]


### [Zeek Logs](https://docs.zeek.org/en/current/script-reference/log-files.html)


Capable of identifying 50+ logs and categorising them into seven categories:

| Category             | Description                                           | Log Files                                                                                                                                                                                                                                                                                                                          |
| -------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Network              | network protocol logs                                 | `conn.log, dce_rpc.log, dhcp.log, dnp3.log, dns.log, ftp.log, http.log, irc.log, kerberos.log, modbus.log, modbus_register_change.log, mysql.log, ntlm.log, ntp.log, radius.log, rdp.log, rfb.log, sip.log, smb_cmd.log, smb_files.log, smb_mapping.log, smtp.log, snmp.log, socks.log, ssh.log, ssl.log, syslog.log, tunnel.log.` |
| Files                | file analysis result logs                             | `files.log, oscp.log, pe.log, x509.log`                                                                                                                                                                                                                                                                                            |
| NetControl           | network control & flow logs                           | `netcontrol.log, netcontrol_drop.log, netcontrol_shunt.log, netcontrol_catch_release.log, openflow.log.`                                                                                                                                                                                                                           |
| Detection            | possible indicator logs                               | `intel.log, notice.log, notice_alarm.log, signatures.log, traceroute.log`                                                                                                                                                                                                                                                          |
| Network Observations | network flow logs                                     | `known_certs.log, known_hosts.log, known_modbus.log, known_services.log, software.log.`                                                                                                                                                                                                                                            |
| Miscellaneous        | additonal logs: cover external alerts, input & errors | `barnyard2.log, dpd.log, unified2.log, unknown_protocols.log, weird.log, weird_stats.log.`                                                                                                                                                                                                                                         |
| Zeek Diagnostic      | cover system msgs, actions & some stats               | `broker.log, capture_loss.log, cluster.log, config.log, loaded_scripts.log, packet_filter.log, print.log, prof.log, reporter.log, stats.log, stderr.log, stdout.log.`                                                                                                                                                                                                                                                                                                                                   |


### Zeek vs [[sheets/Snort]]

| Tool            | Zeek                                                                                                                                                                     | Snort                                                                       |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| **Capabilities**    | heavily focused on network analysis *(specific threats to trigger alerts & detection mechanisms)*                                                                        | More focused on signature patterns & packets as a detection method          |
| **Cons**            | - hard to use <br> - done out of Zeek: manually or by automation                                                                                                         | hard to detect complex threats                                              |
| **Pros**            | - in-depth traffic visibility <br> - useful 4 threat hunting to detect complex one's <br> - has scripting language & supports event correlation <br> - easy to read logs | - easy to write rules <br> - community support <br> - Cisco supported rules |
| **Common Use Case** | - network monitoring <br> - in-depth traffic investigations <br> - intrusion detecting in chained events                                                                 | Intrustion detection & prevention system - stop known attacks/threats                                                                            |


### Zeek Architecture

![[write-ups/images/Pasted image 20230103001753.png]]


## Refs
- [zeek thm room](https://tryhackme.com/room/zeekbro)
- [Try Zeek: Learn Zeek scripting](https://try.bro.org/#/?example=hello)
- [zeek docs](https://docs.zeek.org/en/master/frameworks/index.html)
- [zeek logs cheatsheet](https://f.hubspotusercontent00.net/hubfs/8645105/Corelight_May2021/Pdf/002_CORELIGHT_080420_ZEEK_LOGS_US_ONLINE.pdf)
- [more on zeek events](https://docs.zeek.org/en/master/scripts/base/bif/event.bif.zeek.html?highlight=signature_match)
- [zeek intelligence framework](https://docs.zeek.org/en/master/frameworks/intel.html)
- [zeek package manager](https://packages.zeek.org/) & [git](https://github.com/zeek/packages)
## See Also
- [[write-ups/thm/Zeek Exercises]]
- [[write-ups/THM]]
