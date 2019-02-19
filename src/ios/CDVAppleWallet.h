/**
 * 8/8/2018
 * @author Hatem 
 * @header file
 */
#import <Cordova/CDVPlugin.h>

@interface AppleWallet : CDVPlugin

- (void)isAvailable:(CDVInvokedUrlCommand*)command;
- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command;
- (void)completeAddPaymentPass:(CDVInvokedUrlCommand*)command;

@end