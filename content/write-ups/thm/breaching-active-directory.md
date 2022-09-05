---
title: "Breaching Active Directory"
tags: 
- writeups
---

Covers techniques to recover AD credentials in this network:
- NTLM Authenticated Services
- LDAP Bind Credentials
- Authentication Relays
- Microsoft Deployment Toolkit
- Configuration Files

We can use these techniques on a security assesment by targeting systems of an organisation that are internet-facing or by implanting a rogue device on the organisation's network

- **Setup**
	- configure DNS by adding `DNS=<THMDC IP>` to the `/etc/systemd/resolved.conf` file 
	- save it & restart the service: `systemctl restart systemd-resolved`
	- test modifications: `nslookup thmdc.za.tryhackme.com`
	
## OSINT 
[OSINT](OSINT) is used to disscover information online. In the case of AD this can happen for several reasons such as:
- Users who ask questions on public forums such as [Stack Overflow](https://stackoverflow.com/) but disclose sensitive information such as their credentials in the question.
- Developers that upload scripts to services such as [Github](https://github.com/) with credentials hardcoded.
- Credentials being disclosed in past breaches since employees used their work accounts to sign up for other external websites. Websites such as [HaveIBeenPwned](https://haveibeenpwned.com/) and [DeHashed](https://www.dehashed.com/) provide excellent platforms to determine if someone's information, such as work email, was ever involved in a publicly known data breach.

A detailed room on Red Team OSINT can be found [here.](https://tryhackme.com/jr/redteamrecon)

## Phising
Phishing is another excellent method to breach AD. Phishing usually entices users to either provide their credentials on a malicious web page or ask them to run a specific application that would install a Remote Access Trojan (RAT) in the background. This is a prevalent method since the RAT would execute in the user's context, immediately allowing you to impersonate that user's AD account. This is why phishing is such a big topic for both Red and Blue teams.

A detailed room on phishing can be found [here.](https://tryhackme.com/module/phishing)

## NTLM Authentication Services
- [New Technology LAN Manager (NTLM)](New Technology LAN Manager (NTLM)) is the suite of security protocols used to authenticate users' identities in [AD](../../sheets/Active Directory.md)
- services that use NetNTLM can also be exposed to the internet. The following are some of the popular examples:
	- Internally-hosted Exchange (Mail) servers that expose an Outlook Web App (OWA) login portal.
	- Remote Desktop Protocol (RDP) service of a server being exposed to the internet.
	- Exposed VPN endpoints that were integrated with AD.
	- Web applications that are internet-facing and make use of NetNTLM
- allows the application to play the role of a middle man between the client and AD. All authentication is forwarded to the [AD -- Domain Controllers (DC)](../../sheets/AD -- Domain Controllers (DC).md) in the form of a challenge which will authenticate the user
	- ![[write-ups/images/Pasted image 20220618195656.png]]
	- it prevents the application from storing AD credentials, which should only be stored on a Domain Controller
### Password Spraying
- since most AD envs have account lockout configured, we won't be able to run a full brute-force attack
- instead of trying multiple different passwords *(which will trigger an alert/account lockout)* we choose 1 passwoird and attempt to authenticate with all the usernames acquired
> **NOTE**:  these types of attacks can be detected due to the amount of failed authentication attempts they will generate

- we're provided with a list of usernames discovered during a red team OSINT exercise
	- also indicated the organisation's initial onboarding password: `Changeme123`
- we're gonna use a simple python script to try the default password for all users @ the web app *([http://ntlmauth.za.tryhackme.com](http://ntlmauth.za.tryhackme.com/))*

## LDAP Blind Credentials
- another method of AD authentication that applications can use is Lightweight Directory Access Protocol (LDAP) authentication
- similar to NTLM authentication, but the application directly verifies the user's creds
	- has a pair of AD creds that it can use to query LDAP & verify
- popular mechanism amongst third-party (non-Microsoft) applications that integrate with AD *(e.g Gitlab, Jenkins, custom web-apps, printers, VPNs)*
- process of authentication through LDAP:
	- ![](https://tryhackme-images.s3.amazonaws.com/user-uploads/6093e17fa004d20049b6933e/room-content/d2f78ae2b44ef76453a80144dac86b4e.png)
- can use the same typee of attacks as those leveraged against NTLM, however, since LDAP auth requires a set of AD credentials, it opens up additional attack avenues
	- we can attempt to recover the AD credentials used by the service to gain authenticated access to AD
	- once you gain a foothold on the correct host, such as a Gitlab server, it might be as simple as reading the configuration files to recover these AD credentials

### LDAP Pass-Back
- can be performed when already have access to device's configuration *(e.g printer with default creds)*
- then we alter the LDAP conf such as the IP or hostname of the device is redirected to our machine so we can intercept the authentication attempt & recover the credentials
- we have an interesting endpoint @ `http://printer.za.tryhackme.com/settings`
	- ![[write-ups/images/Pasted image 20220619004402.png]]
- can redirect to our ip adddr & try to catch the auth req: `nc -nvlp 389`
	- ![[write-ups/images/Pasted image 20220619004119.png]]
	- `suppportedCapabilities` indicates that we have a problem
	- before the printer sends the creds, it's trying to negotiaate the LDAP auth method details => will select the most secure authentication method that both the printer and the LDAP server support
	- depending on the auth method used the creds will not be sent over in cleartext *(in some casess they'll not be transmitted over the network @ all)*

### Rogue LDAP server
- install requirments
	```bash
	sudo apt-get update && sudo apt-get -y install slapd ldap-utils && sudo systemctl enable slapd
	```
- reconfigure ldap server: `sudo dpkg-reconfigure -p low slapd`
	- domain name & organizaation name: `za.tryhackme.com`
	- remove db when slapd purged: no
	- move old database: yes
- downgrade the supported auth mechanisms to only `PLAIN` & `LOGIN` from `olcSaslSecProps.ldif`
	```
	dn: cn=config 
	replace: olcSaslSecProps 
	olcSaslSecProps: noanonymous,minssf=0,passcred
	```
- patch our LDAP server config from the above file: `sudo ldapmodify -Y EXTERNAL -H ldapi:// -f ./olcSaslSecProps.ldif && sudo service slapd restart`
- verify if everything's good
	- ![[write-ups/images/Pasted image 20220619021230.png]]
- capture ldap credentials: `tcpdump -SX -i tun0 tcp port 389 -w ldap_pass -vv`
- go to `http://printer.za.tryhackme.com/settings` & send LDAP auth
- ![[write-ups/images/Pasted image 20220619021410.png]]

## Authentication Relays

- setup [responder](https://github.com/lgandx/Responder): `responder -I tun0` A
	- ![[write-ups/images/Pasted image 20220619025323.png]]
- crack the hash: `hashcat -m 5600 svcFileCopy_hash passwordlist.txt`
	- ![[write-ups/images/Pasted image 20220619025204.png]]

## Microsoft Deployment Toolkit

- Microsoft Deployment Toolkit (MDT) is a Microsoft service that assists with automating the deployment of Microsoft Operating Systems (OS)
- large organizations use MDT to deploy new images in their esstate more efficiently since the base images can be maintained & updated in a central location
- usually MDT is integrated with Microsoft's System Center Configuration Manager *(SCCM)*: which manages all updates for all Microsoft applications, services, and operating systems
	- allows the IT team to preconfigure and manage boot images
	- when a new machine needs configuration, just plug in the network & everything happens automatically *(e.g install Office365 & AV of choice)*
- SCCM can be seen as almost an expansion and the big brother to MDT
	- once the software is installed, SSCM does this type of patch management
	- allows the IT team to review available updates to all software installed across the estate
	- can also test these patches in a sandbox environment to ensure they are stable before centrally deploying them to all domain-joined machines


### PXE Boot
- Use PXE boot to allow new devices that are connected to the network to load and install the OS directly over a network connection
- usually integrated with DHCP, which means that if DHCP assigns an IP lease, the host is allowed to request the PXE boot image and start the network OS installation process. Communication flow is shown below
	- ![[write-ups/images/Pasted image 20220619025535.png]]
- once that's finished the client will use a TFTP connection to download the PXE boot image
- this is quite often targeted by adveraries since one can:
	- inject a privilege escalation vector, such as a Local Administrator account, to gain Administrative access to the OS once the PXE boot has been completed
	- perform password scraping attacks to recover AD credentials used during the install
### Exploitation

## Configuration Files
- configuration files are an excellent avenue to explore in an attempt to recover AD credentials. Depending on the host that was breached, various configuration files may be of value for enumeration *(e.g webapp, service, registry keys, centrally deployed apps)*
- several enumeration scripts, such as [Seatbelt](https://github.com/GhostPack/Seatbelt), can be used to automate this process.
- sql enumeration: 
	- ![[write-ups/images/Pasted image 20220619041116.png]]
		```sql
		CREATE TABLE AGENT_PROXY_CONFIG(
			PROXY_USAGE INTEGER NOT NULL, 
			BYPASS_LOCAL INTEGER NOT NULL, 
			ALLOW_USER_CONFIG INTEGER NOT NULL, 
			EXCLUSION_LIST TEXT, 
			SYSTEM_PROXY_HTTP_AUTH_REQD INTEGER,
			SYSTEM_PROXY_HTTP_USER TEXT, 
			SYSTEM_PROXY_HTTP_PASSWD TEXT,
			SYSTEM_PROXY_FTP_AUTH_REQD INTEGER,
			SYSTEM_PROXY_FTP_USER TEXT, 
			SYSTEM_PROXY_FTP_PASSWD TEXT, 
			PRIMARY KEY (PROXY_USAGE, BYPASS_LOCAL, ALLOW_USER_CONFIG) 
				ON CONFLICT REPLACE
		);
		```
	- ![[write-ups/images/Pasted image 20220619041608.png]]
- ![[write-ups/images/Pasted image 20220619052118.png]]

## Mitigation
- **User awareness and training** - The weakest link in the cybersecurity chain is almost always users. Training users and making them aware that they should be careful about disclosing sensitive information such as credentials and not trust suspicious emails reduces this attack surface.
- **Limit the exposure of AD services and applications online** - Not all applications must be accessible from the internet, especially those that support NTLM and LDAP authentication. Instead, these applications should be placed in an intranet that can be accessed through a VPN. The VPN can then support multi-factor authentication for added security.
- **Enforce Network Access Control (NAC)** - NAC can prevent attackers from connecting rogue devices on the network. However, it will require quite a bit of effort since legitimate devices will have to be allowlisted.
- **Enforce SMB Signing** - By enforcing SMB signing, SMB relay attacks are not possible.
- **Follow the principle of least privileges** - In most cases, an attacker will be able to recover a set of AD credentials. By following the principle of least privilege, especially for credentials used for services, the risk associated with these credentials being compromised can be significantly reduced.

---

## References
- [Taking over Windows Workstations thanks to LAPS and PXE](https://www.riskinsight-wavestone.com/en/2020/01/taking-over-windows-workstations-pxe-laps/)

## See Also
- [[write-ups/THM]]
