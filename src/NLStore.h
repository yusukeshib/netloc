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
	NSMutableArray *locItems;
}

+(NLStore *)GetInstance;
-(void)update;
-(NSMutableArray *)locItems;
-(NLLoc *)locAt:(int)index;


@end
