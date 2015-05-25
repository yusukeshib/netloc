//
//  AppDelegate.m
//  netloc
//
//  Created by shibata on 5/25/27 H.
//  Copyright (c) 27 Heisei fata.io. All rights reserved.
//

#import "NLAppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface NLAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation NLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    SCPreferencesRef prefs = SCPreferencesCreate(NULL, (CFStringRef)@"SystemConfiguration", NULL);
    NSArray *locations = (__bridge NSArray *)SCNetworkSetCopyAll(prefs);
    for (id item in locations) {
        NSString *name = (__bridge NSString *)SCNetworkSetGetName((__bridge SCNetworkSetRef)item);
        NSLog(@"loc:%@",name);
    }
    CFRelease((CFArrayRef)locations);
    CFRelease(prefs);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
