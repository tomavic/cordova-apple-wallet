#import "CDVAppleWallet.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>

@implementation AppleWallet

- (void)echo:(CDVInvokedUrlCommand*)command {
    NSLog(@"Hola World!");
}

@end
