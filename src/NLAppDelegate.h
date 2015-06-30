#import <Cocoa/Cocoa.h>

@interface NLAppDelegate : NSObject <NSApplicationDelegate> {
    //NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    IBOutlet NSMenuItem *mi_startAtLogin;
    NSMutableAttributedString *title;
    NSMutableDictionary *locItems;
}
- (IBAction)setStartAtLogin:(id)sender;
- (void)_setStartAtLogin:(BOOL)val;

- (IBAction)openNetworkPreference:(id)sender;

- (void)setupLoc;
- (void)updateLoc:(id)sender;

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath;
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
@end

