# cordova-apple-wallet

This plugin provides support for showing/Adding your credit cards to Apple Wallet


## Installation

    cordova plugin add cordova-apple-wallet --save

Or the latest (unstable) version:

    cordova plugin add --save https://github.com/tomavic/cordova-apple-wallet 

## Supported Platforms

- iOS

## Example

### Will be Available Soon

**Preparing Examples**

```javascript
    AppleWallet.downloadPass('https://d.pslot.io/cQY2f', function (pass, added) {
        console.log(pass, added);
        if (added) {
            AppleWallet.openPass(pass);
        } else {
            alert('Please add the pass');
        }
    }, function (error) {
        console.error(error);
    });
```

### Adding Headers

```javascript

   var callData =  {
                    "url":'https://d.pslot.io/cQY2f',
                    "headers":{ "authorization": "Bearer <token>" }
                  };

    AppleWallet.downloadPass(callData, function (pass, added) {
        console.log(pass, added);
        if (added) {
            AppleWallet.openPass(pass);
        } else {
            alert('Please add the pass');
        }
    }, function (error) {
        console.error(error);
    });
```

## Documentation

Plugin documentation: [doc/index.md](doc/index.md)


## Credits
This Plugin was originally by [TOoma](https://github.com/tomavic).