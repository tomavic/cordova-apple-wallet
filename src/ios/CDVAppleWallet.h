#import <Cordova/CDVPlugin.h>



@interface AppleWallet : CDVPlugin


- (void)available:(CDVInvokedUrlCommand*)command;
- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command;
- (void)completeAddPaymentPass:(CDVInvokedUrlCommand*)command;


@end
