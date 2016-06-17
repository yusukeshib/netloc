#import "NLObserver.h"
#import <mach/host_info.h>
#import <mach/processor_info.h>

@implementation NLObserver

#define BORDERWIDTH 0.5f
#define BARWIDTH 36.0f
#define DEFAULT_IMAGESIZE 8

-(id)initWithApp:(id)_app {
	self = [super init];
	if(self != nil) {
		proc_lock = [[NSLock alloc] init];
		app = _app;
	}
	return self;
}
-(void)dealloc {
	[self terminate];
	//[super dealloc];
}
+(NLObserver *)runWithApp:(id)app {
	NLObserver *observer = [[NLObserver alloc] initWithApp:app];
	[observer begin];
	return observer;
}
-(void)begin {
	[proc_lock lock];
	[NSThread detachNewThreadSelector:@selector(check:)
													 toTarget:self
												 withObject:nil];
}
-(void)terminate {
	termination_flg = YES;
	[proc_lock lock]; // wait for terminate.
	[proc_lock unlock];
}
-(void)check:(id)param {
	@autoreleasepool {
		while(termination_flg == NO) {
			[NSThread sleepForTimeInterval:(double)5000.0/1000.0];
			// TODO:if changed...
			//NLStore *store = [NLStore GetInstance];
			//NSArray * locItems = [store locItems];
			[app performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
		}
		//
		[proc_lock unlock];
	}
	[NSThread exit];
}

@end
