#import <AppKit/AppKit.h>

//#define IMAGESIZE_NORMAL 8
//#define IMAGESIZE_BIG    11
//#define IMAGESIZE_SMALL  4

@interface NLObserver : NSObject {
	BOOL termination_flg;
	NSLock *proc_lock;
	NSStatusItem *statusItem;
	int updateInterval;
	int imageSize;
	NSImage *barimage;
	NSMutableAttributedString *title;
}

- (void)setUpdateInterval:(int)val;
- (int)updateInterval;
- (void)setImageSize:(int)size;
- (int)imageSize;

-(id)initWithStatusItem:(NSStatusItem *)statusItem;
+(NLObserver *)runWithStatusItem:(NSStatusItem *)statusItem;
-(void)begin;
-(void)terminate;
-(void)update:(id)param;

@end
