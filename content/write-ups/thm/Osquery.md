---
title: "Osquery"
date: 2023-02-08
tags:
- writeups
---

[Osquery](https://osquery.io/) is an [open-source](https://github.com/osquery/osquery) agent created by [Facebook](https://engineering.fb.com/2014/10/29/security/introducing-osquery/) in 2014. It converts the operating system into a relational database => ask queries using SQL *(get list of running procs, user creation, etc)*

## Basics

Can interact with the database through `osqueryi` & then executing common SQL syntax to query:

```bash
root@analyst$ osqueryi
Using a virtual database. Need help, type '.help'
# see tables - list .tables
osquery> .table user
  => user_groups
  => user_ssh_keys
  => userassist
  => users
# detail schema
osquery> .schema users
CREATE TABLE users(`uid` BIGINT, `gid` BIGINT, `uid_signed` BIGINT, `gid_signed` BIGINT, `username` TEXT, `description` TEXT, `directory` TEXT, `shell` TEXT, `uuid` TEXT, `type` TEXT, `is_hidden` INTEGER HIDDEN, `pid_with_namespace` INTEGER HIDDEN, PRIMARY KEY (`uid`, `username`, `uuid`, `pid_with_namespace`)) WITHOUT ROWID;
# change mode
osquery> .mode pretty
osquery> select * from programs limit 1;
# on Linux
osquery> select name, path, uid, parent from processes limit 15;
+------------------+------------------------------+------+--------+
| name             | path                         | uid  | parent |
+------------------+------------------------------+------+--------+
| systemd          |                              | 0    | 0      |
| mm_percpu_wq     |                              | 0    | 2      |
| irq/122-pciehp   |                              | 0    | 2      |
| irq/123-aerdrv   |                              | 0    | 2      |
| irq/123-pcie-dpc |                              | 0    | 2      |
| kbfsfuse         | /usr/bin/kbfsfuse            | 1000 | 663    |
| irq/124-aerdrv   |                              | 0    | 2      |
| irq/124-pcie-dpc |                              | 0    | 2      |
| acpi_thermal_pm  |                              | 0    | 2      |
| xenbus_probe     |                              | 0    | 2      |
| scsi_eh_0        |                              | 0    | 2      |
| electron         | /usr/lib/electron17/electron | 1000 | 663    |
| scsi_tmf_0       |                              | 0    | 2      |
| mld              |                              | 0    | 2      |
| electron         | /usr/lib/electron17/electron | 1000 | 1082   |
+------------------+------------------------------+------+--------+
```


**How many tables are returned when we query "table process" in the interactive mode of Osquery?**

![[write-ups/images/Pasted image 20230208090842.png]]

**Looking at the schema of the processes table, which column displays the process id for the particular process?**
![[write-ups/images/Pasted image 20230208091409.png]]

**Examine the .help command, how many output display modes are available for the .mode command?**

```bash
osquery> .help
Welcome to the osquery shell. Please explore your OS!
You are connected to a transient 'in-memory' virtual database.

.all [TABLE]     Select all from a table
.bail ON|OFF     Stop after hitting an error
.connect PATH    Connect to an osquery extension socket
.disconnect      Disconnect from a connected extension socket
.echo ON|OFF     Turn command echo on or off
.exit            Exit this program
.features        List osquery's features and their statuses
.headers ON|OFF  Turn display of headers on or off
.help            Show this message
.mode MODE       Set output mode where MODE is one of:
                   csv      Comma-separated values
                   column   Left-aligned columns see .width
                   line     One value per line
                   list     Values delimited by .separator string
                   pretty   Pretty printed SQL results (default)
.nullvalue STR   Use STRING in place of NULL values
.print STR...    Print literal STRING
.quit            Exit this program
.schema [TABLE]  Show the CREATE statements
.separator STR   Change separator used by output mode
.socket          Show the local osquery extensions socket path
.show            Show the current values for various settings
.summary         Alias for the show meta command
.tables [TABLE]  List names of tables
.types [SQL]     Show result of getQueryColumns for the given query
.width [NUM1]+   Set column widths for "column" mode
.timer ON|OFF      Turn the CPU timer measurement on or off

```


## Schema Doc
Based on the OS tables might change, luckily we can the [osquery schema docs](https://osquery.io/schema/5.7.0/) web interface to filter them out & browse through all of the possibilities *(e.g arp_cache, active_ports, processes, logged in users, groups)* 

**In Osquery version 5.5.1, how many common tables are returned, when we select both Linux and Window Operating system?**
![[write-ups/images/Pasted image 20230208091555.png]]

**In Osquery version 5.5.1, how many tables for MAC OS are available?**
![[write-ups/images/Pasted image 20230208091641.png]]

Then we can retrieve all kinds of info from just following the documentation *(seems like a good tool for living off the land recon)* :

![[write-ups/images/Pasted image 20230208094126.png]]

## Practical
**In the Windows Operating system, which table is used to display the installed programs?** - [doc here](https://osquery.io/schema/5.7.0/#programs)

**In Windows Operating system, which column contains the registry value within the registry table?** - [doc here](https://osquery.io/schema/5.7.0/#registry)

**Which table stores the evidence of process execution in Windows OS?** -- CTRL+f on the docs: [userassist](https://osquery.io/schema/5.7.0/#userassist)

**One of the users seems to have executed a program to remove traces from the disk; what is the name of that program?**
![[write-ups/images/Pasted image 20230208100236.png]]

**Create a search query to identify the VPN installed on this host. What is name of the software?**

![[write-ups/images/Pasted image 20230208100440.png]]

**How many services are running on this host?**
![[write-ups/images/Pasted image 20230208100638.png]]

**A table [autoexec](https://osquery.io/schema/5.7.0/#autoexec) contains the list of executables that are automatically executed on the target machine. There seems to be a batch file that runs automatically. What is the name of that batch file (with the extension .bat)?**

![[write-ups/images/Pasted image 20230208101158.png]]


## Refs
- [room](https://tryhackme.com/room/osqueryf8)

## See Also
- [[Endpoint Security]] 
- [[write-ups/THM]]
