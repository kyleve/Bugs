//
//  AppDelegate.m
//  ALERT3570
//
//  Created by Kyle Van Essen on 12/14/17.
//  Copyright © 2017 Square, Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "RGUI_ALERT3570_TextField.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [RGUI_ALERT3570_TextField setFailedToApplyALERT3570FixBlock:^(NSError * _Nonnull error) {
        // In here, pass your error to Fabric, Bugsnag, or assert, etc...
    }];
    
    __unused UITextField *const field = [[RGUI_ALERT3570_TextField alloc] init];
    
    return YES;
}

@end
