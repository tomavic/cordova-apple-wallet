# cordova-apple-wallet

This plugin provides basic support for Apple Wallet on iOS.
It allows you to add credit/debit cards to Apple Wallet.


## Installation

    cordova plugin add cordova-apple-wallet

## Supported Platforms

- iOS

## Methods

- AppleWallet.available
- AppleWallet.downloadPass


## AppleWallet.available

Returns if AppleWallet is available on the current device to the `resultCallback` callback with a boolean as the parameter.

    AppleWallet.available(resultCallback);

### Parameters

- __resultCallback__: The callback that is passed if AppleWallet is available.


### Example

    // onSuccess Callback
    // This method accepts a boolean, which specified if AppleWallet is available
    //
    var onResult = function(isAvailable) {
    	if(!isAvailable) {
    		alert('AppleWallet is not available');
    	}
    };

   	AppleWallet.available(onResult);

## AppleWallet.downloadPass

Downloads a pass from a the provided URL and shows it to the user.
When the pass was successfully downloaded and was shown to the user, and the user either canceld or added the pass, the `passCallback` callback executes. If there is an error, the `errorCallback` callback executes with an error string as the parameter

    AppleWallet.downloadPass(callData,
                         [passCallback],
                         [errorCallback]);

### Parameters

- __callData__: It could be either an URL or an Object in the form `{ url:<url>, headers?:<{}> }` .

- __passCallback__: (Optional) The callback that executes when the pass is shown to the user. Returns the downloaded pass (passTypeIdentifier, serialNumber, passURL) and if it was added to AppleWallet.

- __errorCallback__: (Optional) The callback that executes if an error occurs, e.g if AppleWallet is not available, the URL is invalid or no valid pass was found at the given URL.


### Simple Example

```javascript
    // onSuccess Callback
    function onSuccess(pass, added) {
        console.log('Pass shown to the user');
        console.log(pass, added);
    }

    // onError Callback receives a string with the error message
    //
    function onError(error) {
    	alert('Could now show pass: ' + error);
    }

    AppleWallet.downloadPass('https://d.pslot.io/cQY2f', onSuccess, onError);
```

### Adding Header

```javascript
// onSuccess Callback
function onSuccess(pass, added) {
    console.log('Pass shown to the user');
    console.log(pass, added);
}

// onError Callback receives a string with the error message
//
function onError(error) {
  alert('Could now show pass: ' + error);
}

var callData =  {
                 "url":'https://d.pslot.io/cQY2f',
                 "headers":{ "authorization": "Bearer <token>" }
               };
AppleWallet.downloadPass(callData, onSuccess, onError);


```

## AppleWallet.addPass

Add a pass from a the provided local file and shows it to the user.
When the pass was successfully shown to the user, and the user either canceled or added the pass, the `passCallback` callback executes. If there is an error, the `errorCallback` callback executes with an error string as the parameter

    AppleWallet.addPass(file,
                         [passCallback],
                         [errorCallback]);

### Parameters

- __file__: The file of the pass that should be downloaded. (e.g. file:///..../sample.pkpass)

- __passCallback__: (Optional) The callback that executes when the pass is shown to the user. Returns the local pass (passTypeIdentifier, serialNumber, passURL) and if it was added to AppleWallet.

- __errorCallback__: (Optional) The callback that executes if an error occurs, e.g if AppleWallet is not available, the URL is invalid or no valid pass was found at the given URL.


### Example

    // onSuccess Callback
    function onSuccess(pass, added) {
        console.log('Pass shown to the user');
        console.log(pass, added);
    }

    // onError Callback receives a string with the error message
    //
    function onError(error) {
    	alert('Could now show pass: ' + error);
    }

    AppleWallet.addPass(cordova.file.applicationDirectory + 'sample.pkpass', onSuccess, onError);
