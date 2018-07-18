#import <Cordova/CDVPlugin.h>

typedef void (^AddPassResultBlock)(PKPass *pass, BOOL added);


@interface AppleWallet : CDVPlugin


@property (nonatomic, strong) NSString* completionHandler; // Need to verify this type
@property (nonatomic, strong) NSString* stringFromData; // Need to verify this type
@property (nonatomic, copy) AddPassResultBlock transactionCallbackId; // Need to verify this type
@property (nonatomic, copy) AddPassResultBlock completionCallbackId; // Need to verify this type
@property (nonatomic, strong) UIViewController* pkviewController; // Need to verify this type


- (void)available:(CDVInvokedUrlCommand*)command;
- (void)startAddPaymentPass:(CDVInvokedUrlCommand*)command;
- (void)completeAddPaymentPass:(CDVInvokedUrlCommand*)command


@end
