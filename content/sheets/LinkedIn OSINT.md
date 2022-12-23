---
title: "LinkedIn OSINT"
tags:
- sheet
---

# LinkedIn OSINT

- use [Google Dorks](Google%20Dorks): `site:http://linkedin.com/in “<keywords of interest>”` *(e.g name, organization, job title)*
- take note of the profile name *(`https://www.linkedin.com/in/profile_name`)*
	- if they decide to change their names, hide their surname or lock down their profile, you still have an entry point
	- oftenly users have a profile which closely resembles their user name from Linkedin on other platforms: `site:fb.com “williamhgates” OR “william gates” OR “williamgates”`
- view the profile graphic elements & use image search engines
	- `wget /in/username/detail/photo/` to get it
	- Some image search engines
		- [Google Images](https://www.google.com/imghp?hl=en)
		- [Yandex Images](https://yandex.com/images/)
		- [Flickr](https://www.flickr.com/search/)
		- [Shutterstock](https://www.shutterstock.com/)
		- [Getty Images](https://www.gettyimages.co.uk/)
		- [Tin Eye](https://tineye.com/)
- manual detail search
	- `https://www.linkedin.com/search/results/people/?firstName=[_name_]&keywords=[_name_]%20[_surname_]&lastName=[_surname_]`
	- or even more ellaborate: `https://www.linkedin.com/search/results/people/?firstName=[_name_]&lastName=[_surname_]&company=[_company name_]&title=[job title]`
- check the profile's recent activity @ `https://www.linkedin.com/in/username/detail/recent-activity/`
	- activity associated w the user can be: articles, posts, documents
- use 3rd party tools *(e.g [linkedin-api lib 4 python](https://github.com/tomquirk/linkedin-api))*
- use the *"Save to PDF"* feature

> Made a quick tool: check it out in [this gist](https://gist.github.com/vlagh3/8ef7055aa74d47d7ed6fddc1001d58e8)


---

## References
[How to conduct OSINT on Linkedin](https://www.osintme.com/index.php/2020/04/26/how-to-conduct-osint-on-linkedin/)
