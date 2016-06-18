//
//  NLLoc.h
//  netloc
//
//  Created by Apple on 6/17/16.
//  Copyright © 2016 fata.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLLoc : NSObject {
	BOOL isCurrent;
	NSString *_setid;
	NSString *_name;
}
- (id)initWithName:(NSString*)name setid:(NSString *)setid;
- (void)select;
- (BOOL)isCurrent;
@property(readonly) NSString *name;
@property(readonly) NSString *setid;


@end
