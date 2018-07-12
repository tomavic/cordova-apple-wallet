#import <Cordova/CDVPlugin.h>




@interface AppleWallet : CDVPlugin {

}
@property (nonatomic, strong) NSString* transactionCallbackId;
@property (nonatomic, strong) NSString* completionCallbackId;
@property (nonatomic, strong) NSString* completionHandler;
@property (nonatomic, strong) NSString* stringFromData;



- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command;
//- (void)addPaymentPassViewController:(CDVInvokedUrlCommand*)command;


@end
