#import "CDVAppleWallet.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>


@implementation AppleWallet

//- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command
//{
//    NSLog(@"LOG start startAddPaymentPass");
//}

//////////////////////


- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command {
    NSLog(@"LOG start startAddPaymentPass");
    CDVPluginResult* pluginResult;
    NSArray* arguments = command.arguments;
    self.transactionCallbackId = nil;
    self.completionCallbackId = nil;
    if ([arguments count] != 1){
        pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        // Options
        NSDictionary* options = [arguments objectAtIndex:0]; // Configuration
        PKAddPaymentPassRequestConfiguration* configuration = [[PKAddPaymentPassRequestConfiguration alloc] initWithEncryptionScheme:PKEncryptionSchemeECC_V2];
        configuration.cardholderName = [options objectForKey:@"cardholderName"]; // The name of the person the card is issued to
        configuration.primaryAccountSuffix = [options objectForKey:@"primaryAccountSuffix"]; // Last 4/5 digits of PAN. The last four or five digits of the PAN. Presented to the user with dots prepended to indicate that it is a suffix.
        configuration.localizedDescription = [options objectForKey:@"localizedDescription"]; // A short description of the card.
        configuration.primaryAccountIdentifier = [options objectForKey:@"primaryAccountIdentifier"]; // Filters the device and attached devices that already have this card provisioned. No filter is applied if the parameter is omitted
        
        // Filters the networks shown in the introduction view to this single network.
        NSString* paymentNetwork = [options objectForKey:@"paymentNetwork"]; 
        if([[paymentNetwork uppercaseString] isEqualToString:@"VISA"]) {
            configuration.paymentNetwork = PKPaymentNetworkVisa; 
        }
        if([[paymentNetwork uppercaseString] isEqualToString:@"MASTERCARD"]) { 
            configuration.paymentNetwork = PKPaymentNetworkMasterCard;
        }

        // Present view controller
        self.viewController = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:configuration delegate:self];
        if(!self.viewController) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MISSING_ENTITLEME NTS"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            self.transactionCallbackId = command.callbackId;
            [self.viewController presentViewController:self.viewController animated:YES completion:^{[self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];}];
        }
    }
}

/* Certificates is an array of NSData, each a DER encoded X.509 certificate, with the leaf first and root last. * The continuation handler must be called within 20 seconds, or the flow will terminate with
 * PKAddPaymentPassErrorInvalidRequest.
 */

/*
- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
                                    generateRequestWithCertificateChain:(NSArray<NSData *> *)certificates
                                    nonce:(NSData *)nonce
                                    nonceSignature:(NSData *)nonceSignature
{
    completionHandler:(void(^)(PKAddPaymentPassRequest *request))handler NSLog(@"LOG start addPaymentPassViewController");
    // save completion handler
    self.completionHandler = handler;
    NSLog(@"%@", NSStringFromClass([self.completionHandler class]));
    // the leaf certificate will be the first element of that array and the sub-CA certificate will follow.
    NSData* cert0 = [certificates objectAtIndex:0];
    NSData* cert1 = [certificates objectAtIndex:1];
    NSString* sCertificateLeaf = [self stringFromData:cert0 asBase64:CERT_DATA_AS_BASE64];
    NSString* sCertificateSubCA = [self stringFromData:cert1 asBase64:CERT_DATA_AS_BASE64];
    NSString* sNonce = [self stringFromData:nonce asBase64:NONCE_DATA_AS_BASE64];
    NSString* sNonceSignature = [self stringFromData:nonceSignature asBase64:NONCE_DATA_AS_BASE64];
    NSDictionary* dictionary = @{ @"data" : @{@"certificateLeaf" : sCertificateLeaf, @"certificateSubCA" : sCertificateSubCA, @"nonce" : sNonce,@"nonceSignature" : sNonceSignature, }};
    // Upcall with the data
    CDVPluginResult* pluginResult =
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];
}

- (void)completeAddPaymentPass:(CDVInvokedUrlCommand*)command {
    NSLog(@"LOG start completeAddPaymentPass"); CDVPluginResult* pluginResult;
    NSArray* arguments = command.arguments;
    if ([arguments count] != 1){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } else {
            PKAddPaymentPassRequest* request = [[PKAddPaymentPassRequest alloc] init];
            NSDictionary* options = [arguments objectAtIndex:0];
            NSString* encryptionKey = [options objectForKey:@"encryptionKey"];
            NSString* encryptedPassData = [options objectForKey:@"encryptedPassData"];
            NSString* activationData = [options objectForKey:@"activationData"];
        
            NSLog(@" LOG%@", encryptionKey); NSLog(@" LOG%@", encryptedPassData);
            NSLog(@" LOG%@", activationData);
        
            request.ephemeralPublicKey = [NSData dataWithHexString:encryptionKey];
            request.encryptedPassData = [NSData dataWithHexString:encryptedPassData];
            request.activationData = [self dataFromString:activationData fromBase64:YES];
        
            NSLog(@" A LOG%@", request.ephemeralPublicKey); NSLog(@" A LOG%@", request.encryptedPassData);
            NSLog(@" A LOG%@", request.activationData);
            
            // Send result
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]]; self.completionCallbackId = command.callbackId;
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.completionCallbackId]; // Issue request
            OCF_DISPATCH_MAIN_QUEUE_ALWAYS(^{NSLog(@"LOG ocf OCF_DISPATCH_MAIN_QUEUE_ALWAYS ");self.completionHandler(request); });
        }
}

*/

////////////////

@end
