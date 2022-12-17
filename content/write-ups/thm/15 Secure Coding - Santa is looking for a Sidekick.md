---
title: "15 Secure Coding - Santa is looking for a Sidekick"
date: 2022-12-17
tags:
- writeups
---

## Story
Santa is looking to hire new staff for his security team and has hired a freelance developer to create a web application where potential candidates can upload their CVs. Elf McSkidy is aware that third-party risks can be serious and has tasked you, Exploit McRed, with testing this application before it goes live. Since the festivities are right around the corner, we will have to focus on the core feature of the website, namely the ability to upload a CV

### Learning Objectives
- Input validation of file upload funtionality
- Unrestricted file upload vulnerabilities
- Phishing through file uploads
- How to properly secure file upload functionality

## Notes

### Input Validation
Insufficient input validation is one of the biggest security concerns for web applications. The issue occurs when user-provided input is inherently trusted by the application. Since this input can be controlled by an attacker we can see how this blind inherent trust can lead to problems.

Many web-app vulnerabilities *(e.g SQLi, XSS, file uplaods, RCEs)* stem from the issue of insufficient user input validation.

### Properly Securing File Uploads 

Validate the following:
- file content type
- the content's extension
- file size
- rename uploaded files to random names *(e.g GUID)*
- scan file with known AV solutions for malware

**Example in `C#`**
```csharp
public IActionResult OnPostUpload(FileUpload fileUpload) {
	var allowed = True;
	// Store file outside the web roor
	var fullPath = "D:\CVUploads\";
	var formFiile = fileUpload.FormFile;

	// Create a GUID for the file name
	Guid id = Guid.NewGuid();
	var filePath = Path.Combine(fullPath, id + ".pdf");

	// Validate content type
	string contentType = fileUpload.ContentType.Split('/')[1].ToLower();
	if !(contentType.equals("ContentType=PDF")) {
		allowed = False;
	}

	// Validate content extension
	string contentExt = Path.GetExtension(fileUpload);
	if !(contentExt.equals("PDF")) {
		allowed = False;
	}

	// Validate content size
	int contentSize = fileUpload.ContentLength;
	int maxFileSize = 10 * 1024 * 1024; // max of 10MB
	if (contentSize > maxFileSize) {
		allowed = False;
	}

	// Scan the content for malware
	var clam = new ClamClient(this._configuration["ClamAVServer:URL"], 
				Convert.ToInt32(this._configuration["ClamAVServer:Port"]));
	scanRes = await clam.SendAndScanFileAsync(fileBytes);
	if (scanRes == ClamScanResults.VirusDetected) {
		allowed = False;
	}

	// Only upload if all checks passed
	if (allowed) {
		using (var stream = System.IO.File.Create(filePath)) {
			formFile.CopyToAsync(stream);
		}
	}
}
```


## Practical
Going to the website we're presented with a page where we can upload files. Since it's about recruiting it probably intends that we upload a PDF, so let's do that:

![[write-ups/images/Pasted image 20221217060208.png]]

The message gives us some more information & let's us know that there will be human interaction with our file. So let's try give it an executable:

![[write-ups/images/Pasted image 20221217060317.png]]

That seems to work because the freelancer haven't properly validate our input *(i.e our uploaded file)*. I tried to take advantage of this by creating a payload for windows: 

![[write-ups/images/Pasted image 20221217060911.png]]

Then let's start a listener with metasploit

![[write-ups/images/Pasted image 20221217061007.png]]

Now we only need to upload the file, wait for an "elf" to open it for review & get our shell 

![[write-ups/images/Pasted image 20221217061223.png]]

Answers:

![[write-ups/images/Pasted image 20221217061632.png]]

## Refs
- [Official Walkthrough](https://www.youtube.com/watch?v=9Pniza-s1ds)
- [File Upload](https://book.hacktricks.xyz/pentesting-web/file-upload)
- [Intro to web hacking module](https://tryhackme.com/module/intro-to-web-hacking)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/14 Web Apps - I'm dreaming of secure web apps]] | [[16 Secure Coding - SQLi's the king, the carolers sing]]
