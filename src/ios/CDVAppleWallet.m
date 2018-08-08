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
        configuration.cardholderName = @"Test user";

        // Last 4/5 digits of PAN. The last four or five digits of the PAN. Presented to the user with dots prepended to indicate that it is a suffix. 
        configuration.primaryAccountSuffix = @"0492";

        // A short description of the card.
        configuration.localizedDescription = @"description test";

        // Filters the device and attached devices that already have this card provisioned. No filter is applied if the parameter is omitted
        configuration.primaryAccountIdentifier = @"";
        
        // Network type has been set static for testing sake 
        configuration.paymentNetwork =@"VISA";
        
        
        // Filters the networks shown in the introduction view to this single network.
    /*
       NSString* paymentNetwork = [options objectForKey:@"paymentNetwork"];
       if([[paymentNetwork uppercaseString] isEqualToString:@"VISA"]) {
           configuration.paymentNetwork = PKPaymentNetworkVisa;
       }
       if([[paymentNetwork uppercaseString] isEqualToString:@"MASTERCARD"]) {
           configuration.paymentNetwork = PKPaymentNetworkMasterCard;
       }
    */

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
//    NSLog(@"%@", NSStringFromClass([self.completionHandler class]));
    

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
    NSLog(@"LOG start completeAddPaymentPass");
    
    CDVPluginResult* pluginResult;
    NSArray* arguments = command.arguments;
    if ([arguments count] != 1){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        PKAddPaymentPassRequest* request = [[PKAddPaymentPassRequest alloc] init];
        NSDictionary* options = [arguments objectAtIndex:0];
        
//        NSString* wrappedKey = [options objectForKey:@"wrappedKey"];
//        NSString* encryptedPassData = [options objectForKey:@"encryptedPassData"];
//        NSString* activationData = [options objectForKey:@"activationData"];

        NSString* activationData = @"eyJ2ZXJzaW9uIjoiMiIsImV4cGlyYXRpb25EYXRlSW5jbHVkZWQiOmZhbHNlLCJ0b2tlblVuaXF1ZVJlZmVyZW5jZUluY2x1ZGVkIjpmYWxzZSwic2lnbmF0dXJlQWxnb3JpdGhtIjoiUlNBLVNIQTI1NiIsInNpZ25hdHVyZSI6ImFIYWFHaXhUdXJFY3hqVm9hQTVReHBCZE5yYmFKcGs5Vk1OS2x0TmU3SDdVbDN1NGluS1pnRzY0VG5UdksvTVRTN0x5STkxT1J6NjZtQzFqZjJEVWIvVll0NGFzVExoVElHOFB4anhvTXZCOWJXaGhrU3A2Yk04V1lOWVRJYXVnbng4dUI4WG56ZmF0eWV0RUFIV2g1Y0lPM2VZZi83eXFQVXlsTGFKN1ZVWHM2MzVPMHRXMllIKzVBUDN2OTdUZXhLczcvWE5oeTl2dUtwcjB5YU5FTnZjTlMzYjFLNlA1ck5uRWhpSnYvNDZXdFhNWnZHT0tBYWRtcEFyK1hWSVVRRlU1NjZMSm4yNG1GN0pqMWdzODJEZHdpK0RFNStKVDRCMC9jWkhOM2ViYUNrTG84N1VuRGRsVnJQQW1sSVh4cHZXSyt4bittQzEwU2RvRGllSTVLZz09In0=";
        NSString* encryptedPassData = @"YSqWD0auueYRGyO26U78PIiZv1z9gLWy2RbmO4cW3+di6SeGAClGJJIw+zm9iAomcYg1PAGDvtod6OK4Y94RD7WtjQmgAwcBfnwKXwul2qFdTzs/RQG9qBXxESJaZ5ZWnVD8jXl3aXQO9rXylgb8Azmhua0z8C6q9peALBtLw+cUsC/NPQoJobrEiFuilwAVEduD8xpNyLrBOd9Q7qOX6Lbtkgdvnui3QQQYPKW8AHOuxrPcrgDoDARO0hjn3hJAItTm+gumAtj/UeLlmjuOfI8fd/s=";
        NSString* wrappedKey = @"BND8StI9swVULz66Rn7pp3g3ET+s5d2VS+llopwTyBwfUQc0gF+QY0JdYd5NYQETdV1mQ8Dn9bHm1tK2qHbX/UY=";
        
        request.activationData = [activationData dataUsingEncoding:NSUTF8StringEncoding];
        request.encryptedPassData = [[NSData alloc] initWithBase64EncodedString:encryptedPassData options:0];
        request.wrappedKey = [[NSData alloc] initWithBase64EncodedString:wrappedKey options:0];
        
        self.completionHandler(request);
        
        // Send result
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        self.completionCallbackId = command.callbackId;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.completionCallbackId]; // Issue request
        
    } 
}

@end