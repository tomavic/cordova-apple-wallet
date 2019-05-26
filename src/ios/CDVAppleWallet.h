/**
 * 8/8/2018
 * @author Hatem 
 * @header file
 * Copyright (c) Enigma Advanced Labs 2019
 */
#import "Foundation/Foundation.h"
#import "Cordova/CDV.h"
#import <PassKit/PassKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

typedef void (^completedPaymentProcessHandler)(PKAddPaymentPassRequest *request);

@interface AppleWallet(): CDVPlugin<PKAddPaymentPassViewControllerDelegate>

- (void) isAvailable:(CDVInvokedUrlCommand*)command;
- (void) checkCardEligibility:(CDVInvokedUrlCommand*)command;
- (void) checkCardEligibilityBySuffix:(CDVInvokedUrlCommand*)command;

- (void) checkPairedDevices:(CDVInvokedUrlCommand*)command;
- (void) checkPairedDevicesBySuffix:(CDVInvokedUrlCommand*)command;

- (void) startAddPaymentPass:(CDVInvokedUrlCommand*)command;
- (void) completeAddPaymentPass:(CDVInvokedUrlCommand*)command;


  @property (nonatomic, assign) BOOL isRequestIssued;
  @property (nonatomic, assign) BOOL isRequestIssuedSuccess;
  @property (nonatomic, strong) completedPaymentProcessHandler completionHandler;
  @property (nonatomic, strong) NSString* stringFromData;
  @property (nonatomic, copy) NSString* transactionCallbackId;
  @property (nonatomic, copy) NSString* completionCallbackId;
  @property (nonatomic, retain) UIViewController* addPaymentPassModal;

@end

