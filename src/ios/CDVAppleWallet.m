/**
 * 8/8/2018
 * @author Hatem 
 * @implementation file
 */

#import "CDVAppleWallet.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>

typedef void (^completionHand)(PKAddPaymentPassRequest *request);

@interface AppleWallet()<PKAddPaymentPassViewControllerDelegate>

@property (nonatomic, strong) completionHand completionHandler; 
@property (nonatomic, strong) NSString* stringFromData; 
@property (nonatomic, copy) NSString* transactionCallbackId; 
@property (nonatomic, copy) NSString* completionCallbackId; 
@property (nonatomic, retain) UIViewController* addPaymentPassModal; 


@end


@implementation AppleWallet


+ (BOOL)canAddPaymentPass 
{
    return [PKAddPaymentPassViewController canAddPaymentPass];
}


- (void)available:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[AppleWallet canAddPaymentPass]];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}


- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command 
{
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
        NSDictionary* options = [arguments objectAtIndex:0]; 
        
        PKAddPaymentPassRequestConfiguration* configuration = [[PKAddPaymentPassRequestConfiguration alloc] initWithEncryptionScheme:PKEncryptionSchemeRSA_V2];
        
        // The name of the person the card is issued to
        configuration.cardholderName = [options objectForKey:@"cardholderName"];

        // Last 4/5 digits of PAN. The last four or five digits of the PAN. Presented to the user with dots prepended to indicate that it is a suffix. 
        configuration.primaryAccountSuffix = [options objectForKey:@"primaryAccountSuffix"];

        // A short description of the card.
        configuration.localizedDescription = [options objectForKey:@"localizedDescription"];

        // Filters the device and attached devices that already have this card provisioned. No filter is applied if the parameter is omitted
        configuration.primaryAccountIdentifier = @""; 
        
        
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
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            self.transactionCallbackId = command.callbackId;
            [self.viewController presentViewController:self.addPaymentPassModal animated:YES completion:^{
                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];
                }
             ];
        }

    }
}


- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
                                    didFinishAddingPaymentPass:(PKPaymentPass *)pass
                                    error:(NSError *)error
{
    NSLog(@"didFinishAddingPaymentPass");
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    // return with error if exists
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];
}


- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
                                    generateRequestWithCertificateChain:(NSArray<NSData *> *)certificates
                                    nonce:(NSData *)nonce
                                    nonceSignature:(NSData *)nonceSignature
                                    completionHandler:(void (^)(PKAddPaymentPassRequest *request))handler
{
    NSLog(@"LOG addPaymentPassViewController generateRequestWithCertificateChain");
    
    // save completion handler
    self.completionHandler = handler;
    // NSLog(@"%@", NSStringFromClass([self.completionHandler class]));
    

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
    
//    NSLog(@"Gamal- certificates[0]: %@", certificates[0]);
//    NSLog(@"Gamal- certificates[1]: %@", certificates[1]);
//    NSLog(@"Gamal- nonce: %@", nonce);
//    NSLog(@"Gamal- nonceSignature: %@", nonceSignature);
    
    // Upcall with the data
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];

}


- (void)completeAddPaymentPass:(CDVInvokedUrlCommand*)command
{
    NSLog(@"LOG completeAddPaymentPass");
    
    CDVPluginResult* pluginResult;
    NSArray* arguments = command.arguments;
    if ([arguments count] != 1){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        PKAddPaymentPassRequest* request = [[PKAddPaymentPassRequest alloc] init];
        NSDictionary* options = [arguments objectAtIndex:0];
        
       NSString* activationData = [options objectForKey:@"activationData"];
       NSString* encryptedPassData = [options objectForKey:@"encryptedPassData"];
       NSString* wrappedKey = [options objectForKey:@"wrappedKey"];
        
        request.activationData = [activationData dataUsingEncoding:NSUTF8StringEncoding];
        request.encryptedPassData = [[NSData alloc] initWithBase64EncodedString:encryptedPassData options:0];
        request.wrappedKey = [[NSData alloc] initWithBase64EncodedString:wrappedKey options:0];
        
        // Issue request
        self.completionHandler(request);
        
        // Send result
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        self.completionCallbackId = command.callbackId;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.completionCallbackId]; 
        
    } 
}

@end