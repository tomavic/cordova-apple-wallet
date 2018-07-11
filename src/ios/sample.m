/**
Determining if Payment Passes Can Be Added

+ (BOOL)canAddPaymentPass;

====================



*/


#import "CDVPassbook.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>



@property(nonatomic, copy) NSData *encryptedPassData;

@implementation CDVPassbook

// First part
- (void) addPass:(CDVInvokedUrlCommand*)command
{
    PKAddPaymentPassRequestConfiguraion *config = [[PKAddPaymentPassRequestConfiguraion alloc] initWithEncryptionSchemeRSA_V2;]
    config.cardholderName = self.cardInfo.cardHolderName;
    config.primaryAccountSuffix = [self.cardInfo suffix];
    config.localizedDescription = self.cardInfo.name;
    config.paymentNetwork = PKPaymentNetworkVisa; // config.paymentNetwork = PKPaymentNetworkMasterCard;

    self.passViewController = [[PKAddPaymentPassViewController alloc] initWithRequestConfigurtion:config delegate:self];
    if(self.passViewController !=nil) {
        [self presentViewController:self.passViewController animated:YES completion:nil];
    }
}



//second part
- (void)addPaymentPassViewController: (PKAddPaymentPassViewController *)controller 
    generateRequestWithCertification:(NSArray<NSData *> *)certificates 
    nonce: (NSData *)nonce 
    nonceSignature:(NSData *)nonceSignature
    completionHandler: (void(^) (PKAddPaymentPassRequest *request)) handler 

    {
        ApplePayProvider *applePayProvider = [ApplePayProvider sharedInstance];
        InAppDataRequestParameters *params = [applePayProvider requestParamsWithCertificates: certificates nonce:nonce nonceSignature:nonceSignature cardId:self.cardInfo.resourceId];
        [[MCPServer instance] inAppData:params completion:^(NSInteger result, NSString *resultDescription, InAppDataResult *inAppdataResult) {
            if(result == SuccessCode) {
                PKAddPaymentPassRequest *request = [[PKAddPaymentPassRequest alloc] init];
                request.activationData = [applePayProvider activationData: inAppDataResult.activationData];
                request.encryptedPassData = [applePayProvider encryptedPassData: inAppDataResult.passData];
                request.ephemeralPublicKey = [applePayProvider ephemeralPublicKey: inAppDataResult.ephemeralPublicKey];

                if(handler != nil) {
                    handler(request);
                }
            }
            else {
                [slef showFailedAddToWalletAlert]
            }
        }]
    }




- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller 
        didFinishAddingPaymentPass:(PKPaymentPass *)pass 
        error:(NSError *)error
    {

    }

    //under [applePayProvider activationData: inAppDataresult.activationData], [applePayProvider encryptedPassData: inAppDataResult.passData] and
    //[applePayProvider ephemeralPublicKey: inAppDataresult.ephemeralPublicKey] methods lies this transformation from string to data 

-(NSData *) dataFromString: (NSString *) string {
    return [[NSData alloc] initWithBase64EncodeString: string options: NSDataBase64DecodingIgnoreUnkownCharacters];
}

@end