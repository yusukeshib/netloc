//
//  NLStore.m
//  netloc
//
//  Created by Apple on 6/17/16.
//  Copyright © 2016 fata.io. All rights reserved.
//

#import "NLStore.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation NLStore
static NLStore *instance = nil;

-(NSArray *)locItems {
	return locItems;
}
-(NLLoc *)locAt:(int)index {
	return [locItems objectAtIndex:index];
}
+(NLStore *)GetInstance {
	if(instance == nil) {
		instance = [[NLStore alloc] init];
	}
	return instance;
}
-(id)init {
	self = [super init];
	locItems = [[NSMutableArray alloc] init];
	[self update];
	return self;
}
-(void)update {
	NSMutableArray *newItems = [[NSMutableArray alloc] init];
	SCPreferencesRef prefs = SCPreferencesCreate(NULL, (CFStringRef)@"SystemConfiguration", NULL);
	NSArray *locations = (__bridge NSArray *)SCNetworkSetCopyAll(prefs);
	for (id item in locations) {
		NSString *name = (__bridge NSString *)SCNetworkSetGetName((__bridge SCNetworkSetRef)item);
		NSString *setid = (__bridge NSString *)SCNetworkSetGetSetID((__bridge SCNetworkSetRef)item);
		NLLoc *loc = [[NLLoc alloc]initWithName:name setid:setid];
		[newItems addObject:loc];
	}
	CFRelease((CFArrayRef)locations);
	CFRelease(prefs);
	//
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
	locItems = [newItems sortedArrayUsingDescriptors:@[sort]];
}

@end
