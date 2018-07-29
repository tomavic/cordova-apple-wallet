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
@end


@implementation AppleWallet


+ (BOOL)canAddPaymentPass 
{
    //What is the required logic to do to know if the app can add cards to Apple Pay?
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
        configuration.primaryAccountIdentifier = [options objectForKey:@"primaryAccountIdentifier"]; 
        
        // Filters the networks shown in the introduction view to this single network.
        NSString* paymentNetwork = [options objectForKey:@"paymentNetwork"]; 
        if([[paymentNetwork uppercaseString] isEqualToString:@"VISA"]) {
            configuration.paymentNetwork = PKPaymentNetworkVisa; 
        }
        if([[paymentNetwork uppercaseString] isEqualToString:@"MASTERCARD"]) { 
            configuration.paymentNetwork = PKPaymentNetworkMasterCard;
        }


//        PKPassLibrary *libra = [[PKPassLibrary alloc] init];
//        [libra openPaymentSetup];


         //PKAddPaymentPassViewController *vc = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:configuration delegate:self];
         //vc.delegate = self;
         //NSLog(@"hola vc %@", vc);

        // Present view controller
        self.addPaymentPassModal = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:configuration delegate:self];
        NSLog(@"hola vc %@", self.addPaymentPassModal);
        
        
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewcontroller animated:YES completion:nil];
        
        
        if(!self.addPaymentPassModal) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MISSING_ENTITLEMENTS"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            self.transactionCallbackId = command.callbackId;
            [self.viewcontroller presentViewController:self.addPaymentPassModal animated:YES completion:^
                {
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
    NSLog(@"addPaymentPassViewController");
}

- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
                                    generateRequestWithCertificateChain:(NSArray<NSData *> *)certificates
                                    nonce:(NSData *)nonce
                                    nonceSignature:(NSData *)nonceSignature
                                    completionHandler:(void (^)(PKAddPaymentPassRequest *request))handler
{
    NSLog(@"LOG start addPaymentPassViewController");
    
    //completionHandler:(void(^)(PKAddPaymentPassRequest *request))handler;
    
    // save completion handler
//    self.completionHandler = handler;
//    NSLog(@"%@", NSStringFromClass([self.completionHandler class]));
    
    NSData* cert0 = [certificates objectAtIndex:0];
    NSData* cert1 = [certificates objectAtIndex:1];
    
//    NSString* sCertificateLeaf = [self stringFromData:cert0 asBase64:CERT_DATA_AS_BASE64];
//    NSString* sCertificateSubCA = [self stringFromData:cert1 asBase64:CERT_DATA_AS_BASE64];
//    NSString* sNonce = [self stringFromData:nonce asBase64:NONCE_DATA_AS_BASE64];
//    NSString* sNonceSignature = [self stringFromData:nonceSignature asBase64:NONCE_DATA_AS_BASE64];
    
    NSDictionary* dictionary = @{
                                 @"data" : @{
                                         @"certificateLeaf" : certificates,
                                         @"certificateSubCA" : certificates,
                                         @"nonce" : nonce,
                                         @"nonceSignature" : nonceSignature,
                                         }
                                 };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.transactionCallbackId];
    
}

+ (NSString* ) stringFromData:(NSData *)somedata {
    return @"This is string from data";
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
        NSString* encryptionKey = [options objectForKey:@"encryptionKey"];
        NSString* encryptedPassData = [options objectForKey:@"encryptedPassData"];
        NSString* activationData = [options objectForKey:@"activationData"];
    
        NSLog(@" LOG%@", encryptionKey); NSLog(@" LOG%@", encryptedPassData);
        NSLog(@" LOG%@", activationData);
    
//        request.ephemeralPublicKey = [NSData dataWithHexString:encryptionKey];
//        request.encryptedPassData = [NSData dataWithHexString:encryptedPassData];
//        request.activationData = [self dataFromString:activationData fromBase64:YES];
    
        NSLog(@" A LOG%@", request.ephemeralPublicKey);
        NSLog(@" A LOG%@", request.encryptedPassData);
        NSLog(@" A LOG%@", request.activationData);
        
        // Send result
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        self.completionCallbackId = command.callbackId;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.completionCallbackId]; // Issue request
        
//        OCF_DISPATCH_MAIN_QUEUE_ALWAYS(^{
//            NSLog(@"LOG ocf OCF_DISPATCH_MAIN_QUEUE_ALWAYS ");
//            self.completionHandler(request);
//        });
    }
    
}



@end
