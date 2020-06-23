/**
 * Created 8/8/2018
 * @author Hatem
 * @implementation {AppleWallet} file CDVAppleWallet
 * Copyright (c) Enigma Advanced Labs 2019
 */

#import "CDVAppleWallet.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "AppDelegate.h"

typedef void (^completedPaymentProcessHandler)(PKAddPaymentPassRequest *request);

@interface AppleWallet()<PKAddPaymentPassViewControllerDelegate>


  @property (nonatomic, assign) BOOL isRequestIssued;
  @property (nonatomic, assign) BOOL isRequestIssuedSuccess;

  @property (nonatomic, strong) completedPaymentProcessHandler completionHandler;
  @property (nonatomic, strong) NSString* stringFromData;

  @property (nonatomic, copy) NSString* transactionCallbackId;
  @property (nonatomic, copy) NSString* completionCallbackId;
  
  @property (nonatomic, retain) UIViewController* addPaymentPassModal;

@end


@implementation AppleWallet


+ (BOOL) canAddPaymentPass
{
    return [PKAddPaymentPassViewController canAddPaymentPass];
}

// Plugin Method - check Device Eligibility
- (void) isAvailable:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[AppleWallet canAddPaymentPass]];
    [commandResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

// Plugin Method - check Card Eligibility
- (void) checkCardEligibility:(CDVInvokedUrlCommand*)command {
    NSString * cardIdentifier = [command.arguments objectAtIndex:0];
    Boolean cardEligible = true;
    Boolean cardAddedtoPasses = false;
    Boolean cardAddedtoRemotePasses = false;
    
    PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
//     NSArray<PKPass *> *paymentPasses = [passLibrary passesOfType:PKPassTypePayment];
    NSArray *paymentPasses = [[NSArray alloc] init];
    if (@available(iOS 13.5, *)) { // PKPassTypePayment is deprecated in iOS13.5
      paymentPasses = [passLibrary passesOfType: PKPassTypeSecureElement];
      for (PKPass *pass in paymentPasses) {
        PKSecureElementPass *paymentPass = [pass secureElementPass];
        if ([[paymentPass primaryAccountIdentifier] isEqualToString:cardIdentifier]) {
          cardAddedtoPasses = true;
        }
      }
    } else {
      paymentPasses = [passLibrary passesOfType: PKPassTypePayment];
      for (PKPass *pass in paymentPasses) {
        PKPaymentPass *paymentPass = [pass paymentPass];
        if([[paymentPass primaryAccountIdentifier] isEqualToString:cardIdentifier]) {
          cardAddedtoPasses = true;
        }
      }
    }
    
    if (WCSession.isSupported) { // check if the device support to handle an Apple Watch
        WCSession *session = [WCSession defaultSession];
        [session setDelegate:self.appDelegate];
        [session activateSession];
        
        if ([session isPaired]) { // Check if the iPhone is paired with the Apple Watch

          if (@available(iOS 13.5, *)) {
                paymentPasses = [passLibrary remoteSecureElementPasses]; // remotePaymentPasses is deprecated in iOS13.5
                for (PKSecureElementPass *pass in paymentPasses) {
                    if ([[pass primaryAccountIdentifier] isEqualToString:cardIdentifier]) {
                        cardAddedtoPasses = true;
                    }
                }
            } else {
                paymentPasses = [passLibrary remotePaymentPasses];
                for (PKPass *pass in paymentPasses) {
                    PKPaymentPass * paymentPass = [pass paymentPass];
                    if([[paymentPass primaryAccountIdentifier] isEqualToString:cardIdentifier])
                        cardAddedtoRemotePasses = true;
                }
            }
          
        }
        else
            cardAddedtoRemotePasses = true;
    }
    else
        cardAddedtoRemotePasses = true;

    cardEligible = !cardAddedtoPasses || !cardAddedtoRemotePasses;
    
    CDVPluginResult *pluginResult;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:cardEligible];
    //pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[passLibrary canAddPaymentPassWithPrimaryAccountIdentifier:cardIdentifier]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Plugin Method - check Card Eligibility By Suffix
- (void) checkCardEligibilityBySuffix:(CDVInvokedUrlCommand*)command {
    NSString * cardSuffix = [command.arguments objectAtIndex:0];
    Boolean cardEligible = true;
    Boolean cardAddedtoPasses = false;
    Boolean cardAddedtoRemotePasses = false;
    
    PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
//     NSArray<PKPass *> *paymentPasses = [passLibrary passesOfType:PKPassTypePayment];
    NSArray *paymentPasses = [[NSArray alloc] init];
    if (@available(iOS 13.5, *)) { // PKPassTypePayment is deprecated in iOS 13.5
      paymentPasses = [passLibrary passesOfType: PKPassTypeSecureElement];
        for (PKPass *pass in paymentPasses) {
            PKSecureElementPass *paymentPass = [pass secureElementPass];
            if ([[paymentPass primaryAccountNumberSuffix] isEqualToString:cardSuffix]) {
                cardAddedtoPasses = true;
            }
        }
    } else {
      paymentPasses = [passLibrary passesOfType: PKPassTypePayment];
        for (PKPass *pass in paymentPasses) {
          PKPaymentPass * paymentPass = [pass paymentPass];
          if([[paymentPass primaryAccountNumberSuffix] isEqualToString:cardSuffix])
            cardAddedtoPasses = true;
        }
    }
   
    if (WCSession.isSupported) { // check if the device support to handle an Apple Watch
        WCSession *session = [WCSession defaultSession];
        [session setDelegate:self.appDelegate];
        [session activateSession];
        
        if ([session isPaired]) { // Check if the iPhone is paired with the Apple Watch
          if (@available(iOS 13.5, *)) { // remotePaymentPasses is deprecated in iOS 13.5
            paymentPasses = [passLibrary remoteSecureElementPasses];
            for (PKSecureElementPass *pass in paymentPasses) {
              if ([[pass primaryAccountNumberSuffix] isEqualToString:cardSuffix]) {
                cardAddedtoPasses = true;
              }
            }
          } else {
            paymentPasses = [passLibrary remotePaymentPasses];
            for (PKPass *pass in paymentPasses) {
              PKPaymentPass * paymentPass = [pass paymentPass];
                if([[paymentPass primaryAccountNumberSuffix] isEqualToString:cardSuffix])
                  cardAddedtoRemotePasses = true;
                }
            }

        }
        else
            cardAddedtoRemotePasses = true;
    }
    else
        cardAddedtoRemotePasses = true;
    
    cardEligible = !cardAddedtoPasses || !cardAddedtoRemotePasses;
    
    CDVPluginResult *pluginResult;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:cardEligible];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Plugin Method - check paired devices
- (void) checkPairedDevices:(CDVInvokedUrlCommand *)command 
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    if (WCSession.isSupported) { // check if the device support to handle an Apple Watch
        WCSession *session = [WCSession defaultSession];
        [session setDelegate:self.appDelegate];
        [session activateSession];
        if (session.isPaired) { // Check if the iPhone is paired with the Apple Watch
            [dictionary setObject:@"True" forKey:@"isWatchPaired"];
        } else {
            [dictionary setObject:@"False" forKey:@"isWatchPaired"];
        }
    } else {
        [dictionary setObject:@"False" forKey:@"isWatchPaired"];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Plugin Method - check paired devices By Suffix
- (void) checkPairedDevicesBySuffix:(CDVInvokedUrlCommand *)command 
{
    NSString * suffix = [command.arguments objectAtIndex:0];
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:@"False" forKey:@"isInWallet"];
    [dictionary setObject:@"False" forKey:@"isInWatch"];
    [dictionary setObject:@"" forKey:@"FPANID"];
    PKPassLibrary *passLib = [[PKPassLibrary alloc] init];

    // find if credit/debit card is exist in any pass container e.g. iPad
    for (PKPaymentPass *pass in [passLib passesOfType:PKPassTypePayment]){
        if ([pass.primaryAccountNumberSuffix isEqualToString:suffix]) {
            [dictionary setObject:@"True" forKey:@"isInWallet"];
            [dictionary setObject:pass.primaryAccountIdentifier forKey:@"FPANID"];
            break;
        }
    }
    
    // find if credit/debit card is exist in any remote pass container e.g. iWatch
    for (PKPaymentPass *remotePass in [passLib remotePaymentPasses]){
        if([remotePass.primaryAccountNumberSuffix isEqualToString:suffix]){
            [dictionary setObject:@"True" forKey:@"isInWatch"];
            [dictionary setObject:remotePass.primaryAccountIdentifier forKey:@"FPANID"];
            break;
        }
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString *) getCardFPAN:(NSString *) cardSuffix{
    
    PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
    NSArray<PKPass *> *paymentPasses = [passLibrary passesOfType:PKPassTypePayment];
    for (PKPass *pass in paymentPasses) {
        PKPaymentPass * paymentPass = [pass paymentPass];
        if([[paymentPass primaryAccountNumberSuffix] isEqualToString:cardSuffix])
            return [paymentPass primaryAccountIdentifier];
    }
    
    if (WCSession.isSupported) { // check if the device support to handle an Apple Watch
        WCSession *session = [WCSession defaultSession];
        [session setDelegate:self.appDelegate];
        [session activateSession];
        
        if ([session isPaired]) { // Check if the iPhone is paired with the Apple Watch
            paymentPasses = [passLibrary remotePaymentPasses];
            for (PKPass *pass in paymentPasses) {
                PKPaymentPass * paymentPass = [pass paymentPass];
                if([[paymentPass primaryAccountNumberSuffix] isEqualToString:cardSuffix])
                    return [paymentPass primaryAccountIdentifier];
            }
        }
    }
    
    return nil;
}


- (void) startAddPaymentPass:(CDVInvokedUrlCommand *)command
{
    self.isRequestIssued = false;
    NSLog(@"LOG start startAddPaymentPass");
    CDVPluginResult* pluginResult;
    NSArray* arguments = command.arguments;
    
    self.transactionCallbackId = nil;
    self.completionCallbackId = nil;
    
    if ([arguments count] != 1){
        pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        // Options
        NSDictionary* options = [arguments objectAtIndex:0];
        
        // encryption scheme to be used (RSA_V2 or ECC_V2)
        NSString* scheme = [options objectForKey:@"encryptionScheme"];
        PKEncryptionScheme encryptionScheme = PKEncryptionSchemeRSA_V2;
        if (scheme != nil) {
            if([[scheme uppercaseString] isEqualToString:@"RSA_V2"]) {
                encryptionScheme = PKEncryptionSchemeRSA_V2;
            }
            
            if([[scheme uppercaseString] isEqualToString:@"ECC_V2"]) {
                encryptionScheme = PKEncryptionSchemeECC_V2;
            }
        }

        PKAddPaymentPassRequestConfiguration* configuration = [[PKAddPaymentPassRequestConfiguration alloc] initWithEncryptionScheme:encryptionScheme];
        
        // The name of the person the card is issued to
        configuration.cardholderName = [options objectForKey:@"cardholderName"];
        
        // Last 4/5 digits of PAN. The last four or five digits of the PAN. Presented to the user with dots prepended to indicate that it is a suffix.
        configuration.primaryAccountSuffix = [options objectForKey:@"primaryAccountSuffix"];
        
        // A short description of the card.
        configuration.localizedDescription = [options objectForKey:@"localizedDescription"];
        
        // Filters the device and attached devices that already have this card provisioned. No filter is applied if the parameter is omitted
        configuration.primaryAccountIdentifier = [self getCardFPAN:configuration.primaryAccountSuffix]; //@"V-3018253329239943005544";//@"";
        
        
        // Filters the networks shown in the introduction view to this single network.
        NSString* paymentNetwork = [options objectForKey:@"paymentNetwork"];
        if([[paymentNetwork uppercaseString] isEqualToString:@"VISA"]) {
            configuration.paymentNetwork = PKPaymentNetworkVisa;
        }
        if([[paymentNetwork uppercaseString] isEqualToString:@"MASTERCARD"]) {
            configuration.paymentNetwork = PKPaymentNetworkMasterCard;
        }
        
        // Present view controller
        self.addPaymentPassModal = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:configuration delegate:self];
        
        if(!self.addPaymentPassModal) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Can not init PKAddPaymentPassViewController"];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            self.transactionCallbackId = command.callbackId;
            [self.viewController presentViewController:self.addPaymentPassModal animated:YES completion:^{
                [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                self.completionCallbackId = command.callbackId;
                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];
            }];
        }
    }
}


- (void) addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
          didFinishAddingPaymentPass:(PKPaymentPass *)pass
                               error:(NSError *)error
{
    NSLog(@"didFinishAddingPaymentPass");
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (error != nil){
        self.isRequestIssuedSuccess = NO;
        [self completeAddPaymentPass:nil];
    }else{
        self.isRequestIssuedSuccess = YES;
        [self completeAddPaymentPass:nil];
    }
}

- (void) addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
 generateRequestWithCertificateChain:(NSArray<NSData *> *)certificates
                               nonce:(NSData *)nonce
                      nonceSignature:(NSData *)nonceSignature
                   completionHandler:(void (^)(PKAddPaymentPassRequest *request))handler
{
    NSLog(@"LOG addPaymentPassViewController generateRequestWithCertificateChain");
    
    // save completion handler
    self.completionHandler = handler;
    
    // the leaf certificate will be the first element of that array and the sub-CA certificate will follow.
    NSString *certificateOfIndexZeroString = [certificates[0] base64EncodedStringWithOptions:0];
    NSString *certificateOfIndexOneString = [certificates[1] base64EncodedStringWithOptions:0];
    NSString *nonceString = [nonce base64EncodedStringWithOptions:0];
    NSString *nonceSignatureString = [nonceSignature base64EncodedStringWithOptions:0];
    
    NSDictionary* dictionary = @{ @"data" :
                                      @{
                                          @"certificateLeaf" : certificateOfIndexZeroString,
                                          @"certificateSubCA" : certificateOfIndexOneString,
                                          @"nonce" : nonceString,
                                          @"nonceSignature" : nonceSignatureString,
                                          }
                                  };
    
    // Upcall with the data
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.completionCallbackId];
}


- (void) completeAddPaymentPass:(CDVInvokedUrlCommand *)command
{
    NSLog(@"LOG completeAddPaymentPass");
    CDVPluginResult *commandResult;
    
    // Here to return a reasonable message after completeAddPaymentPass callback
    if (self.isRequestIssued == true){
        if (self.isRequestIssuedSuccess == false){
            // Upcall with the data error
            commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
        }else{
            // Upcall with the data success
            commandResult= [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        }
        [commandResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:commandResult callbackId:self.completionCallbackId];
        return;
    }
    
    // CDVPluginResult* pluginResult;
    NSArray* arguments = command.arguments;
    if ([arguments count] != 1){
        // pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        // [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        PKAddPaymentPassRequest* request = [[PKAddPaymentPassRequest alloc] init];
        NSDictionary* options = [arguments objectAtIndex:0];
        
        NSString* activationData = [options objectForKey:@"activationData"];
        NSString* encryptedPassData = [options objectForKey:@"encryptedPassData"];
        NSString* wrappedKey = [options objectForKey:@"wrappedKey"];
        NSString* ephemeralPublicKey = [options objectForKey:@"ephemeralPublicKey"];
        
        request.activationData = [[NSData alloc] initWithBase64EncodedString:activationData options:0]; //[activationData dataUsingEncoding:NSUTF8StringEncoding];
        request.encryptedPassData = [[NSData alloc] initWithBase64EncodedString:encryptedPassData options:0];
        if (wrappedKey) {
            request.wrappedKey = [[NSData alloc] initWithBase64EncodedString:wrappedKey options:0];
        }
        if (ephemeralPublicKey) {
            request.ephemeralPublicKey = [[NSData alloc] initWithBase64EncodedString:ephemeralPublicKey options:0];
        }
        
        // Issue request
        self.completionHandler(request);
        self.completionCallbackId = command.callbackId;
        self.isRequestIssued = true;
    }
}

- (NSData *)HexToNSData:(NSString *)hexString
{
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [hexString length]/2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    NSLog(@"%@", commandToSend);
    return commandToSend;
}

@end

// in this case, it is handling if it found 2 watches (more than 1 remote device) 
// means if the credit/debit card is exist on more than 1 remote devices, iPad, iWatch etc

// -(void)eligibilityAddingToWallet2:(CDVInvokedUrlCommand*)command{
//     NSArray* arguments = command.arguments;
//     NSDictionary* options = [arguments objectAtIndex:0];
//     NSString* suffix = [options objectForKey:@"primaryAccountSuffix"];
//     NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
//     [dictionary setObject:@"False" forKey:@"Wallet"];
//     [dictionary setObject:@"False" forKey:@"Watch"];
    
//     PKPaymentPass *currentPass;
    
//     PKPassLibrary *passLib = [[PKPassLibrary alloc] init];
//     for (PKPaymentPass *pass in [passLib passesOfType:PKPassTypePayment]){
//         if ([pass.primaryAccountNumberSuffix isEqualToString:suffix]) {
//             currentPass = pass;
//             break;
//         }
//     }
    
//     for (PKPaymentPass *remotePass in [passLib remotePaymentPasses]){
//         if([remotePass.primaryAccountNumberSuffix isEqualToString:suffix]){
//             currentPass = remotePass;
//             break;
//         }
//     }
    
//     if (currentPass != nil){
//         [passLib canAddPaymentPassWithPrimaryAccountIdentifier:currentPass.primaryAccountIdentifier];
//     }
    
//     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
//     [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
//     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
// }
