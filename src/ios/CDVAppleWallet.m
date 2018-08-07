#import "CDVAppleWallet.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>

//typedef void (^AddPassResultBlock)();
typedef void (^completionHand)(PKAddPaymentPassRequest *request);

@interface AppleWallet()<PKAddPaymentPassViewControllerDelegate>

@property (nonatomic, strong) completionHand completionHandler; // Need to verify this type
@property (nonatomic, strong) NSString* stringFromData; // Need to verify this type
@property (nonatomic, copy) NSString* transactionCallbackId; // Need to verify this type
@property (nonatomic, copy) NSString* completionCallbackId; // Need to verify this type
@property (nonatomic, retain) UIViewController* addPaymentPassModal; // Need to verify this type

- (NSData* ) dataFromString:(NSString *)base64String fromBase64:(BOOL)isFromBase64;
//- (NSString* ) stringFromData:(NSData *)base64String ;
//- (NSString* ) stringFromData:(NSData *)base64String asBase64:(NSData *)sdata ;

@end


@implementation AppleWallet

//- (NSString* ) stringFromData:(NSData *)base64String asBase64:(NSData *)sdata {
//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//    return decodedString;
//}

//- (NSString* ) stringFromData:(NSData *)somedata {
//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:somedata options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//    return decodedString;
//}

- (NSData* ) dataFromString:(NSString *)string fromBase64:(BOOL)isFromBase64 {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return decodedData;
}

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
        
        // Filters the networks shown in the introduction view to this single network.
//        NSString* paymentNetwork = [options objectForKey:@"paymentNetwork"];
//        if([[paymentNetwork uppercaseString] isEqualToString:@"VISA"]) {
//            configuration.paymentNetwork = PKPaymentNetworkVisa;
//        }
//        if([[paymentNetwork uppercaseString] isEqualToString:@"MASTERCARD"]) {
//            configuration.paymentNetwork = PKPaymentNetworkMasterCard;
//        }
        
        configuration.paymentNetwork =@"VISA";

//        PKPassLibrary *libra = [[PKPassLibrary alloc] init];
//        [libra openPaymentSetup];
         //PKAddPaymentPassViewController *vc = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:configuration delegate:self];
         //vc.delegate = self;


        // Present view controller
        self.addPaymentPassModal = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:configuration delegate:self];
        // NSLog(@"hola vc %@", self.addPaymentPassModal);
        
        if(!self.addPaymentPassModal) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MISSING_ENTITLEMENTS"];
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
    NSLog(@"%@", error);
    [controller dismissViewControllerAnimated:YES completion:nil];
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
    NSLog(@"%@", NSStringFromClass([self.completionHandler class]));
    
    // the leaf certificate will be the first element of that array and the sub-CA certificate will follow.
    NSString *certificateOfIndexZeroString = [certificates[0] base64EncodedStringWithOptions:0];
    NSString *certificateOfIndexOneString = [certificates[1] base64EncodedStringWithOptions:0];
    NSString *nonceString = [nonce base64EncodedStringWithOptions:0];
    NSString *nonceSignatureString = [nonceSignature base64EncodedStringWithOptions:0];
    
//    NSLog(@"Gamal-certificateOfIndexZeroString: %@", certificateOfIndexZeroString);
//    NSLog(@"Gamal-certificateOfIndexOnetring: %@", certificateOfIndexOneString);
//    NSLog(@"Gamal-nonceString: %@", nonceString);
//    NSLog(@"Gamal-nonceSignatureString: %@", nonceSignatureString);
    
    NSDictionary* dictionary = @{ @"data" :
                                      @{
                                          @"certificateLeaf" : certificateOfIndexZeroString,
                                          @"certificateSubCA" : certificateOfIndexOneString,
                                          @"nonce" : nonceString,
                                          @"nonceSignature" : nonceSignatureString,
                                        }
                                };

//    for(NSString *key in [dictionary allKeys]) {
//        NSLog(@"%@",[dictionary objectForKey:key]);
//    }

    // Upcall with the data
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];

}

// - (void) getDelegateData:(CDVInvokedUrlCommand*)command
// {
//     CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[AppleWallet canAddPaymentPass]];
//     [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
// }


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
        
        NSString* wrappedKey = [options objectForKey:@"wrappedKey"];
        NSString* encryptedPassData = [options objectForKey:@"encryptedPassData"];
        NSString* activationData = [options objectForKey:@"activationData"];

    
//        request.wrappedKey = [NSData dataWithHexString:wrappedKey];
//        request.encryptedPassData = [NSData dataWithHexString:encryptedPassData];
        request.activationData = [self dataFromString:activationData fromBase64:YES];
    
        NSLog(@" A LOG%@", request.wrappedKey);
        NSLog(@" A LOG%@", request.encryptedPassData);
        NSLog(@" A LOG%@", request.activationData);
        
        // Send result
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        self.completionCallbackId = command.callbackId;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.completionCallbackId]; // Issue request
        
        
        //NEED IMPLEMENTAION
//        OCF_DISPATCH_MAIN_QUEUE_ALWAYS(^{
//            NSLog(@"LOG ocf OCF_DISPATCH_MAIN_QUEUE_ALWAYS ");
//            self.completionHandler(request);
//        });
        
    }
    
}


@end

