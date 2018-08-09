# cordova-apple-wallet

This plugin provides support for showing/Adding your credit cards to Apple Wallet


###Important

> Adding payment passes requires a special entitlement issued by Apple. Your app must include this entitlement before you can use this class. For more information on requesting this entitlement, see the Card Issuers section at developer.apple.com/apple-pay/.

## Installation

    cordova plugin add cordova-apple-wallet --save

Or the latest (unstable) version:

    cordova plugin add --save https://github.com/tomavic/cordova-apple-wallet 

## Supported Platforms

- iOS

## Example


### Ionic 3 and above

In order to use it with Ionic 3 declare a global variable in your component.ts file as follows

```javascript

declare var AppleWallet;
```



### available

Simple call to check whether the app can add cards to Apple Pay.

```javascript
    AppleWallet.available()
    .then((res) => {
      console.log("Apple Wallet is available>> ", res);
    })
    .catch((message) => {
      console.error("ERROR AVAILBLE>> ", message);
    });
```


### startAddPaymentPass

Simple call with the configuration data needed to instantiate a new PKAddPaymentPassViewController object.

In order to get testing data check this [Apple Sandbox](https://developer.apple.com/apple-pay/sandbox-testing)

```javascript
    let data = {
      cardholderName: 'Test User',
      primaryAccountNumberSuffix: '1234',
      localizedDescription: 'Description of payment card',
      paymentNetwork: 'VISA'
    }
    AppleWallet.startAddPaymentPass(data)
    .then((message) => {
      console.log("startAddPaymentPass >> ", JSON.stringify(res));
    })
    .catch((err) => {
      console.error("startAddPaymentPass >> ", err);
    });
```

The callback response is an object contains array of certifcates, nonce and nonceSignature encoded in Base64.
For more information check Apple docs from [here](https://developer.apple.com/documentation/passkit/pkaddpaymentpassviewcontrollerdelegate/1615915-addpaymentpassviewcontroller?language=objc)




### completeAddPaymentPass

Simple call contains the card data needed to add a card to Apple Pay.

-activationData: The request’s activation data.
-encryptedPassData : An encrypted JSON file containing the sensitive information needed to add a card to Apple Pay.
-ephemeralPublicKey The ephemeral public key used by elliptic curve cryptography (ECC). or wrappedKey if you are using RSA



```javascript
    let encryptedData = {
        activationData: "",
        encryptedPassData: "",
        wrappedKey: ""
    }
    AppleWallet.completeAddPaymentPass(encryptedData)
    .then((res) => {
      console.log("completeAddCardToAppleWallet >> ", res);
    })
    .catch((err) => {
      console.error("completeAddCardToAppleWallet >> ", err);
    });
```



## Documentation

Plugin documentation: [doc/index.md](doc/index.md) 


## Credits
This Plugin was originally by [TOoma](https://github.com/tomavic).   /play trombone