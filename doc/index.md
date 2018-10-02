# cordova-apple-wallet

This plugin provides support for adding your credit/debit cards to Apple Wallet


### Important

> Adding payment passes requires a special entitlement issued by Apple. Your app must include this entitlement before you can use this class. For more information on requesting this entitlement, see the Card Issuers section at developer.apple.com/apple-pay/.

# Installation

    cordova plugin add cordova-apple-wallet --save

Or the latest (unstable) version:

    cordova plugin add --save https://github.com/tomavic/cordova-apple-wallet 

# Supported Platforms

- iOS

# Usage


### Ionic 3 and above

In order to use it with Ionic 3, please follow this [instructions](https://ionicframework.com/docs/native/apple-wallet/)


### Phonegap

In order to use it with normal cordova based project, please define a global variable, so that you can use it without lint errors

  `var AppleWallet;`


# Example

### Availability

Simple call to check whether the app can add cards to Apple Pay.

```javascript
    AppleWallet.available()
    .then((res) => {
      // Apple Wallet is enabled and a supported card is setup. Expect:
      // boolean value, true or false
    })
    .catch((message) => {
      console.error("ERROR AVAILBLE>> ", message);
    });
```


### Start Adding card

Simple call with the configuration data needed to instantiate a new PKAddPaymentPassViewController object.

> The encryption scheme, cardholder name, and primary account suffix are required for configuration. The configuration information is used for setup and display only. It should not contain any sensitive information.

In order to get testing data check this [Apple Sandbox](https://developer.apple.com/apple-pay/sandbox-testing)

```javascript
    let data = {
      cardholderName: 'Test User',
      primaryAccountNumberSuffix: '1234',
      localizedDescription: 'Description of payment card',
      paymentNetwork: 'VISA'
    }
    AppleWallet.startAddPaymentPass(data)
    .then((res) => {
      // User proceed and successfully asked to add card to his wallet
      // Use the callback response JSON payload to complete addition process
    })
    .catch((err) => {
      // Error or user cancelled.
    });
```

You should expect the callback success response to be as follow

```javascript
    {
      data: {
        "certificateSubCA":"Base64 string represents certificateSubCA",
        "certificateLeaf":"Base64 string represents certificateLeaf"
        "nonce":"Base64 string represents nonce",
        "nonceSignature":"Base64 string represents nonceSignature",
      }
    }
```

*This method provides the data needed to create an add payment request. Pass the certificate chain to the issuer server. The server returns an encrypted JSON file containing the card data. After you receive the encrypted data, pass it to `completeAddPaymentPass` method*

For more information, please check Apple docs from [here](https://developer.apple.com/documentation/passkit/pkaddpaymentpassviewcontrollerdelegate/1615915-addpaymentpassviewcontroller?language=objc)



### Complete adding card

Simple call contains the card data needed to add a card to Apple Pay.

- `activationData`: The request’s activation data.
- `encryptedPassData` : An encrypted JSON file containing the sensitive information needed to add a card to Apple Pay.
- `ephemeralPublicKey` The ephemeral public key used by elliptic curve cryptography (ECC). or `wrappedKey` if you are using RSA


```javascript
    let encryptedData = {
        activationData: "encoded Base64 activationData from your server",
        encryptedPassData: "encoded Base64 encryptedPassData from your server",
        wrappedKey: "encoded Base64 wrappedKey from your server"
    }
    AppleWallet.completeAddPaymentPass(encryptedData)
    .then((res) => {
      // callback success response means card has been added successfully,
      // PKAddPaymentPassViewController will be dismissed
    })
    .catch((err) => {
      // Error and can not add the card, or something wrong happend
      // PKAddPaymentPassViewController will be dismissed
    });
```



# Contribute 

Please support us by giving advice on how to apply best practice to Objective-C native code.



# License

MIT


# Credits

Made with ❤️ by Hatem. Follow me on [Twitter](https://twitter.com/toomavic) to get the latest news first! I will be happy to receive your feedback via [Email](hbasheer@live.com) ! We're always happy to hear your feedback.
Enjoy!



    ░░░░░░░░░░░░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ 
    ░░░░░░░░░░█░░░░░░▀█▄▀▄▀██████░░░▀█▄▀▄▀██████ 
    ░░░░░░░░ ░░░░░░░░░░▀█▄█▄███▀░░░░░░▀█▄█▄███▀░

   All copyrights reserved © 2018 | TOmas™ Inc. 


