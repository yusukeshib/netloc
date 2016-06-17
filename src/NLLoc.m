//
//  NLLoc.m
//  netloc
//
//  Created by Apple on 6/17/16.
//  Copyright © 2016 fata.io. All rights reserved.
//

#import "NLLoc.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation NLLoc

- (id)initWithName:(NSString*)name setid:(NSString *)setid {
	self = [super init];
	_name = name;
	_setid = setid;
	return self;
}
- (BOOL)isCurrent {
	SCPreferencesRef prefs = SCPreferencesCreate(NULL, (CFStringRef)@"SystemConfiguration", NULL);
	SCNetworkSetRef locCurrent = SCNetworkSetCopyCurrent(prefs);
	NSString *setid_current = (__bridge NSString *)SCNetworkSetGetSetID(locCurrent);
	CFRelease(prefs);
	return [setid_current isEqualToString:_setid];
}
- (void)select {
	if([self isCurrent]) return;
#ifndef NOUSE_SCSELECT
	NSTask* task = [[NSTask alloc] init];
	task.launchPath = @"/usr/sbin/scselect";
	task.arguments = [NSArray arrayWithObjects:_setid, nil];
	[task launch];
	[task waitUntilExit];
#else
	SCPreferencesRef prefs = SCPreferencesCreate(NULL, (CFStringRef)@"SystemConfiguration", NULL);
	NSArray *locations = (__bridge NSArray *)SCNetworkSetCopyAll(prefs);
	for (id item in locations) {
		NSString *item_setid = (__bridge NSString *)SCNetworkSetGetSetID((__bridge SCNetworkSetRef)item);
		if([item_setid isEqualToString setid]) {
			Boolean ret = SCNetworkSetSetCurrent((__bridge SCNetworkSetRef)item);
			break;
		}
	}
	CFRelease((CFArrayRef)locations);
	CFRelease(prefs);
#endif
}

@end
