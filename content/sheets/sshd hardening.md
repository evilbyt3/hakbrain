---
title: "sshd hardening"
date: 2023-01-07
tags:
- sheet
---

Topic:: [[Blue Team]] | 

---

[[SSH]]D *(Secure SHell Daemon)* is the server-side program for secure remote connections cross-platform developed by none other than the [OpenBSD team](https://www.openbsd.org/security.html). We're all familiar with it since it allows sysadmins to quickly hop/configure remote machines: whether is in a small home network, or a large corporation. 

We all use it, but do we secure it? When was the last time you accessed `sshd_config` & really spent some time hardening your server? Maybe we just want a quick & dirty SSH server for testing or development so why bother doing it right?

Well... this note is just that: a guideline for quickly setting up a secure SSH serv er going through all of the best security practices

Because it's commonly used for almost everything, threat actors would almost certainly consider this service a juicy target *(e.g for init access, lateral movement, tunneling, etc)* 


## The Basics


Here are a few best practices / recommendations: 
- change default port *(22)* to something else *(e.g 4711)*
- restrict the key exchange / encryption algorithms to just a few desireble
- disable root login & don't allow empty passwords
- only allow key based auth
- assign specific users / groups which are allowed to use SSH
- bind the service to only run 1 IP address/family 
- limit time for auth, max sessions, disconnect if idle for too long
- keep the openssh daemon up to date
- keep logs & review them
- port knocking ? *([knock](https://github.com/jvinet/knock))*

### Client-Side Config

### Server-Side Config
We need to set the correct permissions & copy the public keys to the `authorized_keys` file:

```bash
# Delete old SSH keys
$ rm /etc/ssh/ssh_host_* ~/.ssh/id_*
# Reset SSH conf to default & generate new key files
$ sudo dpkg-reconfigure openssh-server
# Setup keys & perms
$ vi /home/$USER/.ssh/authorized_keys   # Place client public keys here
$ cd /home/$USER && chmod g-w,o-w .ssh/ # .ssh not writable by group / others
$ chmod 600 /home/$USER/.ssh/authorized_keys # change perms to r+w only for the user
# Restart & reload the ssh daemon
$ service sshd restart
```

Test auth from client: `ssh USER@ssh-server-IP -vv`

### SSHD Configuration

```bash
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# --------------------------------
# -=-=-=={ Server Setup }==-=-=-
# --------------------------------

# Use the latest protocol version
Protocol 2

# Uncomment if you have modular configuration files
# Include /etc/ssh/sshd_config.d/*.conf

# Change the default port (22) to 479
Port 479

# Use only IPv4, to accept both change it to `any`
AddressFamily inet

# Liste on 1 IP & address family, syntax:
#       - [hostname|address]:port [rdomain domain]
ListenAddress 0.0.0.0
# ListenAddress 192.0.2.10

# Specify path to the file containing a private key
#  (can use multiple asymmetric encryption protocols)
HostKey /etc/ssh/ssh_host_ed25519_key   # Only allow ECDSA pubic key authentication

# Host key signature algos the client should accept
#   (i.e served by the server)
# run `ssh -Q HostKeyAlgorithms` to see all options
HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519

# Ciphers and keying
# Specifies max amount of data being sent/rcved
# before new session key is renegotiated
#       - first arg in bytes : 100K, 500M, 5G
#       - 2nd is optional & in secs
# NOTE: rotating session keys after a few GB or based on
# time is a reasonably effective mitigation strategy
#RekeyLimit default none        # no time based rekeyring is done

# Logging - QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1/2/3
LogLevel VERBOSE   # Fingerprint details of failed login attempts
#LogLevel Info     # default
#LogLevel Debug    # violates the privacy of users & not recommended

# Facility code used when logging - DAEMON, USER, AUTH, LOCAL0-7
SyslogFacility AUTH     # authentication and authorization related commands


# --------------------------------
# -=-=-=={ Authentication }==-=-=-
# --------------------------------

LoginGraceTime 30                       # Auth must happen within 30 secs
MaxAuthTries 2                          # Max allowed auth attempts
MaxStartups 2                           # Max concurrent SSH sessions
PermitRootLogin no                      # Disable root login
PermitEmptyPasswords no                 # Don't allow empty passwords

AuthenticationMethods publickey         # Only allow publick key auth
PubkeyAuthentication yes                # Enable public key auth
PasswordAuthentication no               # Disable password auth
HostbasedAuthentication no              # Disable host-based auth
ChallengeResponseAuthentication no      # Unused auth scheme
KbdInteractiveAuthentication no         # new alias for above

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no


# -----------------------
# -=-=-=={ Other }==-=-=-
# -----------------------

X11Forwarding no                        # Disable X11 forwarding
TCPKeepAlive yes                        # Avoid infinitely hanging sesions which consume resources
StrictModes yes                         # Check file modes & ownership of user's ~ be4 login
UseDNS no                               # Only addresses can be used in authorized_keys
AcceptEnv LANG LC_*                     # Allow client to pass locale env vars
IgnoreRhosts yes                        # Don't read user's ~/.rhosts & ~/.shosts
MaxSessions 2                           #
UsePAM no
ClientAliveInterval 100                 # Send msg to client if 100 secs passed with no action
ClientAliveCountMax 2                   # Disconnect client after 2 lost client alive msgs

# Enable sFTP subsystem over SSH
Subsystem sftp  /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server
```

## Keep it even more hardened
- Rate-limit connections
- 2FA authentication
- rotate private keys for the server @ an interval of time
- fake services & blue team active defense implants

## Refs
- [Secure your ssh server with eliptic curve ed25519](https://cryptsus.com/blog/how-to-secure-your-ssh-server-with-public-key-elliptic-curve-ed25519-crypto.html)
- [Force SSH to give RSA key instead of ECDSA](https://askubuntu.com/questions/133172/how-can-i-force-ssh-to-give-an-rsa-key-instead-of-ecdsa)
- [server network-security related conf opts](http://www.uni-koeln.de/~pbogusze/posts/OpenSSH_servers_network-security_related_configuration_options.html)
## See Also
- [[Attacking SSH]]
