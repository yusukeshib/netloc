#import <AppKit/AppKit.h>
#import "NLStore.h"

@interface NLObserver : NSObject {
	BOOL termination_flg;
	NSLock *proc_lock;
	id app;
}

-(id)initWithApp:(id)app;
+(NLObserver *)runWithApp:(id)app;
-(void)begin;
-(void)terminate;
-(void)check:(id)param;

@end
