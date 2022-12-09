---
title: attacking-kerberos
tags:
- writeups
---

## What is Kerberos ?
- Kerberos is the default authentication service for Microsoft Windows domains\
- an authentication protocol, not authorization. It allows identification 4 each user, but doesn't validate to which reources/services can the user access
- intented to be more secure than NTLM  by using third party ticket authorization as well as stronger encryption
- several **agents** work together to provide authentication in Kerberos:
	- Client/User who wants to access the service
	- Application Server *(AP)* which offers the service required by the user
	- Key Distribution Center *(KDC)*: the main service, responsible of issuing the tickets, installed on the [AD -- Domain Controllers (DC)](../../sheets/AD -- Domain Controllers (DC).md) & supported by the Authentication Service *(AS)*, which issues TGTs

### Tickets
The main structures handled by Kerberos. They're delivered to the users in order to be used by them to perform several actions.

- **Ticket Granting Service (TGS)**: users can use to authenticate against a service. It is encrypted with the service key
	- ![[write-ups/images/Pasted image 20220619113227.png]]
- **Ticket Granting Ticket (TGT)**: presented to the KDC to request for TGSs. It is encrypted with the KDC key
	- ![[write-ups/images/Pasted image 20220619113222.png]]

### Privilege Attribute Certificate *(PAC)*
It's a structure included in almost every ticket. This structure contains the privileges of the user and it is signed with the KDC key.

PAC verification consists of checking only its signature, without inspecting if privileges inside of PAC are correct. Furthermore, a client can avoid the inclusion of the PAC inside the ticket by specifying it in `KERB-PA-PAC-REQUEST` field of ticket request

### Types of mesages
Kerberos uses differents kinds of messages. The most interesting are the following:

|                 |                                                                 |
| --------------- | --------------------------------------------------------------- |
| **KRB_AS_REQ**  | used to request the TGT to KDC                                  |
| **KRB_AS_REP**  | used to deliver the TGT by KDC                                  |
| **KRB_TGS_REQ** | used to request the TGS to KDC, using the TGT                   |
| **KRB_TGS_REP** | used to deliver the TGS by KDCM                                 |
| **KRB_AP_REQ**  | used to authenticate a user against a service, using the TGS    |
| **KRB_AP_REP**  | (optional) used by servicee to identify itself against the user |
| **KPB_ERROR**   | msg to communicate error conditions                             | 

> **NOTE**: Additionally, even if it is not part of Kerberos, but NRPC, the **AP** optionally could use the `KERB_VERIFY_PAC_REQUEST` message to send to **KDC** the signature of **PAC**, and verify if it is correc

Summary of msgs sequency to perform auth:
![[write-ups/images/Pasted image 20220619113911.png]]

### Kerberos Authentication Overview
![[write-ups/images/Pasted image 20220619072424.png]]
1. client requests an Authentication Ticket or Ticket Granting Ticket (TGT)
2. Key Distribution Center verifies the client and sends back an encrypted TGT
3. client sends the encrypted TGT to the Ticket Granting Server (TGS) with the Service Principal Name (SPN) of the service the client wants to access
4. KDC verifies the TGT of the user and that the user has access to the service, then sends a valid session key for the service to the client
5. client requests the service and sends the valid session key to prove the user has access
6. the service grants access

### Attack Privilege Requirement
|                      |                                         |
| -------------------- | --------------------------------------- |
| Kerbrute Enumeration | no domain access required               |
| Pass the Ticket      | access as a user to the domain required |
| Kerberoasting        | access as any user required             |
| AS-REP Roasting      | access as any user required             |
| Golden Ticket        | full domain compromise *(domain admin)* |
| Silver Ticket        | service hash required                   |
| Skeleton Key         | full domain compromise *(domain admin)* | 

## Abusing Pre-Auth
- by brute-forcing in pre-auth we don't trigger the account failed to log an event which can throw up red flags to the blue team
- we can brute-force by only sending a single UDP frame to the KDC allowing you to enumerate the users on the domain from a wordlist
- using [kerbrute]([https://github.com/ropnop/kerbrute/releases](https://github.com/ropnop/kerbrute/releases)):
	- ![[write-ups/images/Pasted image 20220619120038.png]]

## Harvesting & Brute-Forcing Tickets
- harvesting tickets uing [Rubeus](https://github.com/GhostPack/Rubeus): `Rubeus.exe harvest /interval:30`
	- ![[write-ups/images/Pasted image 20220619120554.png]]
- add the domain controller domain name to the windows host file: `echo 10.10.72.127 CONTROLLER.local >> C:\Windows\System32\drivers\etc\hosts`
- *"spray"* against all found user accounts in the domain to find which one may have that password: `Rubeus.exe brute /password:Password1 /noticket`
	- ![[write-ups/images/Pasted image 20220619122207.png]]

> **NOTE**: be mindful of how you use this attack as it may lock you out of the network depending on the account lockout policies

## Kerberoasting
- with `rubues`: `Rubeus.exe kerberoast`
- with [impacket](https://github.com/SecureAuthCorp/impacket): `sudo python3 GetUserSPNs.py controller.local/Machine1:Password1 -dc-ip 10.10.72.127 -request`
	- ![[write-ups/images/Pasted image 20220619122329.png]]
- and crack the hash: `hashcat -m 13100 -a 0 hash.txt Pass.txt`
	- ![[write-ups/images/Pasted image 20220619122724.png]]

### What Can a Service Account do?
- once you havee a service account there's various ways to further exfiltrate data or collecting loot depending on whether the service is a domain admin or not
- if a domain admin you have control similar to that of a golden/silver ticket and can now gather loot such as dumping the NTDS.dit
- if not a domain admin you can use it to log into other systems and pivot or escalate or you can use that cracked password to spray against other service and domain admin accounts



### Mitigations
**Strong Service Passwords**: if the service account passwords are strong then kerberoasting will be ineffective

**Don't Make Service Accounts Domain Admins**: service accounts don't need to be domain admins, kerberoasting won't be as effective if you don't make service accounts domain admins.

## AS-REP Roasting
Similar to Kerberoasting, AS-REP Roasting dumps the krbasrep5 hashes of user accounts that have Kerberos pre-authentication disabled
- During pre-auth the user's hash will be used to encrypt a timestamp that the DC will attempt to decrypt in order to validate that the right hash is being used and is not replaying a previous request
- After validation, the KDC will then issue a TGT for the user
- If pre-auth is disabled we can **request any authentication data for any user and the KDC will return an encrypted TGT** *(which can further be cracked offline)*

![[write-ups/images/Pasted image 20220619123731.png]]

If we crack the hashes: `hashcat -m 18200 AS-REP Pass.txt` we get: `admin2:P@$$W0rd2, user3:Password3`
![[write-ups/images/Pasted image 20220619123955.png]]

### Mitigation
**Have a strong password policy**. With a strong password, the hashes will take longer to crack making this attack less effective

**Don't turn off Kerberos Pre-Authentication unless it's necessary** there's almost no other way to completely mitigate this attack other than keeping Pre-Authentication on.

## Pass the Ticket
Pass the ticket works by dumping the TGT from the LSASS memory of the machine. The [[write-ups/thm/core-windows-processes#lsass exe|lsass.exe]] stores credentials for the AD server & Kerberos tickets along w other creds in memory

A known tool exactly for that is [mimikatz](https://github.com/ParrotSec/mimikatz). This will give us a .kirbi ticket which can be used to gain domain admin if a domain admin ticket is in the LSASS memory.

You can think of a pass the ticket attack like reusing an existing ticket were not creating or destroying any tickets here were simply reusing an existing ticket from another user on the domain and impersonating that ticket.

![[write-ups/images/Pasted image 20220619124706.png]]

- dump all `.kirbi` tickets in the curr dir w `mimikatz`:
	- ![[write-ups/images/Pasted image 20220619125509.png]]
- pass the ticket & impersonate
	- find someone valuable to impersonate, in our case `Administrator`
	- ![[write-ups/images/Pasted image 20220619125719.png]]
	- verifying that we successfully impersonated the ticket by listing our cached tickets: `klist`
	- ![[write-ups/images/Pasted image 20220619125416.png]]

> **NOTE**: this is only a POC to understand how to pass the ticket and gain domain admin, so don't take this as a definitive guide of how to run this attack, since the approach might change based on the environment

### Mitigation
**Don't let your domain admins log onto anything except the domain controller**: this is something so simple however a lot of domain admins still log onto low-level computers leaving tickets around that we can use to attack and move laterally with.

## Golden / Silver Ticket Attacks
- a silver ticket can sometimes be better used in engagements rather than a golden ticket because it is a little more discreet
	- silver ticket: limited to the service that is targeted
	- golden ticket: has access to any Kerberos service
- **use-scenario**: you want to access the domain's SQL server, but the curr compromised user doesn't have access
	- find an accessible service account to get a foothold with by kerberoasting
	- then dump the service hash
	- and finally impersonate their TGT in order to request a service ticket for the SQL service

### What's the difference between a KRBTGT and a TGT ?
- a KRBTGT is the service account for the KDC, which issues all of the tickets to the clients
- by impersonating this acc & creating a golden ticket you give yourself the ability to create a service ticket for anything you want

### Hands-On
- dump the hash as well as the security identifier needed to create a Golden Ticket *(to create a silver ticket change `/name:` to dump the hash of either a domain admin / service acc you're interested in)*
	- ![[write-ups/images/Pasted image 20220619131924.png]]
- create a golden/silver ticket: `Kerberos::golden /user:Administrator /domain:controller.local /sid: /krbtgt: /id:` *(4 silver ticket  simply put a service NTLM hash into the krbtgt slot, the sid of the service account into sid, and change the id to 1103)*
	- ![[write-ups/images/Pasted image 20220619132541.png]]
- use the golden/silver ticket to access other machines: `misc::cmd` which will open a new elevated cmd with the given ticket

## Kerberos Backdoors
Unlike the golden and silver ticket attacks a Kerberos backdoor is much more subtle because it acts similar to a rootkit by implanting itself into the memory of the domain forest allowing itself access to any of the machines with a master password

It works by implanting a skeleton key that abuses the way that the AS-REQ validates encrypted timestamps. A skeleton key only works using Kerberos RC4 encryption.

The DC then tries to decrypt the timestamp with the users NT hash, once a skeleton key is implanted the domain controller tries to decrypt the timestamp using both the user NT hash and the skeleton key NT hash allowing you access to the domain forest

> **NOTE**: the skeleton key will not persist by itself because it runs in the memory

---

## References
- [https://medium.com/@t0pazg3m/pass-the-ticket-ptt-attack-in-mimikatz-and-a-gotcha-96a5805e257a](https://medium.com/@t0pazg3m/pass-the-ticket-ptt-attack-in-mimikatz-and-a-gotcha-96a5805e257a)[](https://medium.com/@t0pazg3m/pass-the-ticket-ptt-attack-in-mimikatz-and-a-gotcha-96a5805e257a)
- [https://ired.team/offensive-security-experiments/active-directory-kerberos-abuse/as-rep-roasting-using-rubeus-and-hashcat](https://ired.team/offensive-security-experiments/active-directory-kerberos-abuse/as-rep-roasting-using-rubeus-and-hashcat)[](https://ired.team/offensive-security-experiments/active-directory-kerberos-abuse/as-rep-roasting-using-rubeus-and-hashcat)
- [https://posts.specterops.io/kerberoasting-revisited-d434351bd4d1](https://posts.specterops.io/kerberoasting-revisited-d434351bd4d1)[](https://posts.specterops.io/kerberoasting-revisited-d434351bd4d1)
- [https://www.harmj0y.net/blog/redteaming/not-a-security-boundary-breaking-forest-trusts/](https://www.harmj0y.net/blog/redteaming/not-a-security-boundary-breaking-forest-trusts/)[](https://www.harmj0y.net/blog/redteaming/not-a-security-boundary-breaking-forest-trusts/)
- [https://www.varonis.com/blog/kerberos-authentication-explained/](https://www.varonis.com/blog/kerberos-authentication-explained/)[](https://www.varonis.com/blog/kerberos-authentication-explained/)
- [https://www.blackhat.com/docs/us-14/materials/us-14-Duckwall-Abusing-Microsoft-Kerberos-Sorry-You-Guys-Don't-Get-It-wp.pdf](https://www.blackhat.com/docs/us-14/materials/us-14-Duckwall-Abusing-Microsoft-Kerberos-Sorry-You-Guys-Don't-Get-It-wp.pdf)[](https://www.blackhat.com/docs/us-14/materials/us-14-Duckwall-Abusing-Microsoft-Kerberos-Sorry-You-Guys-Don't-Get-It-wp.pdf)
- [https://www.sans.org/cyber-security-summit/archives/file/summit-archive-1493862736.pdf](https://www.sans.org/cyber-security-summit/archives/file/summit-archive-1493862736.pdf)[](https://www.sans.org/cyber-security-summit/archives/file/summit-archive-1493862736.pdf)
- [https://www.redsiege.com/wp-content/uploads/2020/04/20200430-kerb101.pdf](https://www.redsiege.com/wp-content/uploads/2020/04/20200430-kerb101.pdf)

## See Also
- [[write-ups/THM]]
