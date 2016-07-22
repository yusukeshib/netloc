//
//  NLStore.h
//  netloc
//
//  Created by Apple on 6/17/16.
//  Copyright © 2016 fata.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLLoc.h"

@interface NLStore : NSObject {
	NSArray *locItems;
}

+(NLStore *)GetInstance;
-(void)update;
-(NSArray *)locItems;
-(NLLoc *)locAt:(int)index;


@end
