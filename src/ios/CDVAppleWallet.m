#import "CDVAppleWallet.h"
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>

@implementation AppleWallet

- (void)echo:(CDVInvokedUrlCommand*)command {
    NSString* phrase = [command.arguments objectAtIndex: 0];
    NSLog(@"%@", phrase);
}

@end
