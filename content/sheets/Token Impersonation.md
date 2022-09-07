---
title: Token Impersonation
tags:
- sheets
---

## Description
Adversaries may duplicate then impersonate another user's token to escalate privileges and bypass access controls. An adversary can create a new access token that duplicates an existing token using `DuplicateToken(Ex)`. The token can then be used with `ImpersonateLoggedOnUser` to allow the calling thread to impersonate a logged on user's security context, or with `SetThreadToken` to assign the impersonated token to a thread.

An adversary may do this when they have a specific, existing process they want to assign the new token to. For example, this may be useful for when the target user has a non-network logon session on the system.

[Source](https://attack.mitre.org/techniques/T1134/001/)


## Techniques

### Check [Privileges](https://docs.microsoft.com/en-us/windows/win32/secauthz/privilege-constants)
Get a table of priviliges for the current user *(name, description & state : enabled/disabled)*
```bash
whoami /priv
```

The privileges of an account *(which are either given to the account when created or inherited from a group)* allow a user to carry out particular action. [Priv2Admin](https://github.com/gtworek/Priv2Admin) has a great table on privileges of interest that can be abused. 



### Metasploit
```bash
# Load token module
load incognito

# List available tokens
list_tokens -g

# Impersonate token
impersonate_token <token_name_from_above>

# Revert to original token
rev2self
```
A good example of seeing this in action is in the [[write-ups/thm/alfred]] room

## Refs
- [McAfee Accesss Token Theft Manipulation Attacks](https://www.mcafee.com/enterprise/en-us/assets/reports/rp-access-token-theft-manipulation-attacks.pdf)
- [Abusing Token Privileges for LPE](https://www.exploit-db.com/papers/42556)
- [Client Impersonation microsoft docs](https://docs.microsoft.com/en-us/windows/win32/secauthz/client-impersonation)
