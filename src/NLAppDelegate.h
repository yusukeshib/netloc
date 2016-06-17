#import <Cocoa/Cocoa.h>
#import "NLObserver.h"

@interface NLAppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate> {
	//NSWindow *window;
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	IBOutlet NSMenuItem *mi_startAtLogin;
	bool is_idle;
	NLObserver *observer;
	BOOL menuInitialized;
}
- (void)update;
- (void)updateLoc:(id)sender;
- (IBAction)setStartAtLogin:(id)sender;
- (IBAction)openNetworkPreference:(id)sender;
- (void)_setStartAtLogin:(BOOL)val;

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath;
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
@end

