---
title: "Breaking Grad"
date: 2023-03-19
tags:
- writeups
---


**Description**: You and your buddy corrected the math in your physics teacher's paper on the decay of highly excited massive string states in the footnote of a renowned publication. He's just failed your thesis out of spite, for making a fool out of him in the university's research symposium. Now you can't graduate, unless you can do something about it... 🤷


Visiting the webpage there's not much going on, just a button that checks if we passed

![[write-ups/images/Pasted image 20230319091728.png]]

Intercepting the traffic with burp it's revealing that the logic behind checking if we passed or not is made with a `POST` to `/api/calculate/`:

![[write-ups/images/Pasted image 20230319091928.png]]

We can try messing with the `name` value, but before doing anything else let's look @ the source code provided by the challenge

## Code Analysis

```javascript
router.get('/debug/:action', (req, res) => {
    return DebugHelper.execute(res, req.params.action);
});

router.post('/api/calculate', (req, res) => {
    let student = ObjectHelper.clone(req.body);

    if (StudentHelper.isDumb(student.name) || !StudentHelper.hasBase(student.paper)) {
        return res.send({
            'pass': 'n' + randomize('?', 10, {chars: 'o0'}) + 'pe'
        });
    }

    return res.send({
        'pass': 'Passed'
    });
});
```

- `/debug/:action` - stands out since it's something for developers. It takes the action provided by us & executes with with `DebugHelper`
- `/api/calculate` - is using an `ObjectHelper` class with our `POST` body and creates a student Object which is further checked: 
	- `isDumb()` - checks if `student.name` includes `"Baker" or "Purvis"`
	- `hasBase()` - an additional `paper` key is provided & it just checks if the `grade >= 10`

So in order for us to pass we need to just provide a name different than the one's checked and add an additional key-val pair:

![[write-ups/images/Pasted image 20230319093044.png]]

However that doesn't really help us much so let's take a deeper look @ `ObjectHelper` and `DebugHelper`

### ObjectHelper
```javascript
// ObjectHelper.js
module.exports = {
    isObject(obj) {
        return typeof obj === 'function' || typeof obj === 'object';
    },

    isValidKey(key) {
        return key !== '__proto__';
    },

    merge(target, source) {
        for (let key in source) {
            if (this.isValidKey(key)){
                if (this.isObject(target[key]) && this.isObject(source[key])) {
                    this.merge(target[key], source[key]);
                } else {
                    target[key] = source[key];
                }
            }
        }
        console.log(target)
        return target;
    },

    clone(target) {
        return this.merge({}, target);
    }
}
```

The `clone` function simply merges our request body to an empty js object. It loops through all properties of our request body. If the property is an object or function it will overwrite the empty object's original implementation. Otherwise it will populate the empty object.

Note the `isValidKey` function, which checks if the key is `__proto__`.  Hmm... this is hinting us that the developer is trying to prevent a [prototype pollution vulnerability](https://portswigger.net/web-security/prototype-pollution). Despite his attempts we might be able to bypass it by using [alternatives](https://book.hacktricks.xyz/pentesting-web/deserialization/nodejs-proto-prototype-pollution#prototype-pollution) such as `prototype` or `constructor.prototype`  

### DebugHelper

```javascript
// DebugHelper.js
execute(res, command) {

	res.type('txt');

	if (command == 'version') {
		let proc = fork('VersionCheck.js', [], {
			stdio: ['ignore', 'pipe', 'pipe', 'ipc']
		});

		proc.stderr.pipe(res);
		proc.stdout.pipe(res);

		return;
	} 
	
	if (command == 'ram') {
		return res.send(execSync('free -m').toString());
	}
	
	return res.send('invalid command');
}
// VersionCheck.js
const package = require('./package.json');
const nodeVersion = process.version;

if (package.nodeVersion == nodeVersion) {
    console.log(`Everything is OK (${package.nodeVersion} == ${nodeVersion})`);
}else{
    console.log(`You are using a different version of nodejs (${package.nodeVersion} != ${nodeVersion})`);
}
```

We basically have 2 commands:
- `/debug/version`: uses [fork](https://nodejs.org/api/child_process.html#child_processforkmodulepath-args-options) to check our node version & return it to the user
- `/debug/ram`: executes `free -m` and returns it's output

Trying to navigate to `/debug/ram` throws an error, telling us that the `free` command does not exist. However, `/debug/version` works

![[write-ups/images/Pasted image 20230319095351.png]]

## Exploitation

### Prototype Pollution POC
Let's play with the prototype pollution locally first. I added a `/static/js/poc.js` file containing our `merge` with more logging so that we can play with it in the browser
```javascript
// poc.js
function isObject(obj) {
        return typeof obj === 'function' || typeof obj === 'object';
    }

function isValidKey(key) {
        return key !== '__proto__';
    }

function merge(target, source) {
        for (let key in source) {
            if (this.isValidKey(key)){
                console.log("VALID");
                if (this.isObject(target[key]) && this.isObject(source[key])) {
                    this.merge(target[key], source[key]);
                    console.log('target[key]: ', target[key]);
                    console.log('target: ', target);
                    console.log("END IF");
                } else {
                    console.log("ELSE");
                    target[key] = source[key];
                    console.log('target[key]: ', target[key]);
                    console.log('target: ', target);
                }
            }
        }
        return target;
    }

// index.html
<script src='/static/js/poc.js' type='text/javascript'></script>
```
Now we can start playing

![[write-ups/images/Pasted image 20230319100424.png]]

The empty object was indeed populated with the new provided one. Every object in JavaScript is linked to another object of some kind, known as its [prototype](https://portswigger.net/web-security/prototype-pollution/javascript-prototypes-and-inheritance)

![[write-ups/images/prototype-pollution-prototype-chain.svg]]

This can be accessed with an built-in property `__proto__` which refers to the constructor of the object & serves as both a getter and setter for the object's prototype. Even if it's filtered we can use `constructor.prototype` which will refer to the same thing.

In our example the constructor for our empty object `{}` is the `Object` function. Appending a property to the `Object`'s prototype will make all existing and new objects contain this property inherited

![[write-ups/images/Pasted image 20230319102110.png]]

### Chain for RCE

Ok so we can add properties to all objects, but how can we leverage this to gain RCE. A good place to start would be [[#DebugHelper]] since it has 2 functions executing code `fork` and `execSync`. Notice that an object literal is passed into the `fork` function, meaning that our polluted values/keys will be present. Looking at the [docs](https://nodejs.org/api/child_process.html#child_processforkmodulepath-args-options) we find that it accepts an `execPath` and `execArgv` as parameters

```bash
execPath <string> Executable used to create the child process.
execArgv [<string[]>List of string arguments passed to the executable. Default: process.execArgv
```

Modifying our payload to pollute these, we can gain RCE

![[write-ups/images/Pasted image 20230319103205.png]]

![[write-ups/images/Pasted image 20230319103220.png]]

## Conclusion

I've went into this challenge quite blindly, knowing about prototype pollution only from posts online. Going through the material provided by [portswigger Web Academy](https://portswigger.net/web-security/prototype-pollution) definitely made me fully grasp what I was attacking and how javascript works under the hood which helped clear the path of how should I approach this challenge.

Thanks for reading, stay curios and keep it fun
EvBit out.

## Refs
- [what is prototype pollution](https://portswigger.net/web-security/prototype-pollution)
- [javascript prototypes and inheritaance](https://portswigger.net/web-security/prototype-pollution/javascript-prototypes-and-inheritance)
- [haktricks  prototype pollution](https://book.hacktricks.xyz/pentesting-web/deserialization/nodejs-proto-prototype-pollution)

## See Also
- [[write-ups/HTB]]
