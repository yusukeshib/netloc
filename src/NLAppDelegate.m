#import "NLAppDelegate.h"

@interface NLAppDelegate ()
@property IBOutlet NSWindow *window;
@end

@implementation NLAppDelegate

//@synthesize window;

- (void)menuWillOpen:(NSMenu *)menu {
	is_idle = NO;
}
- (void)menuWillClose:(NSMenu *)menu {
	is_idle = YES;
}
- (IBAction)openNetworkPreference:(id)sender {
	[[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Network.prefPane"];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}
-(void)awakeFromNib{
	menuInitialized = NO;
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:statusMenu];
	[statusItem setHighlightMode:YES];
	//
	// setup
	is_idle = YES;
	// start at login
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	[self _setStartAtLogin:[self loginItemExistsWithLoginItemReference:loginItems ForPath:appPath]];
	CFRelease(loginItems);
	//
	observer = [NLObserver runWithApp:self];
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
}
- (IBAction)setStartAtLogin:(id)sender {
	NSMenuItem *mi = sender;
	[self _setStartAtLogin:(mi.state == NSOffState)];
}
- (void)_setStartAtLogin:(BOOL)val {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if(val) {
		mi_startAtLogin.state = NSOnState;
		[self enableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
	} else {
		mi_startAtLogin.state = NSOffState;
		[self disableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
	}
	CFRelease(loginItems);
}
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
	// We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	if (item)
		CFRelease(item);
}
- (void)updateLoc:(id)sender {
	NSMenuItem *selected = sender;
	NLStore *store = [NLStore GetInstance];
	NLLoc *locItem = [store locAt:(int)selected.tag];
	[locItem select];
	[self update];
}
-(void)update {
	NLStore *store = [NLStore GetInstance];
	NSUInteger currentLocCounts = [[store locItems] count];
	[store update];
	NSArray * locItems = [store locItems];
	NSMenu *menu = [statusItem menu];
	if(menuInitialized) {
		for(int i=0;i<currentLocCounts;i++) {
			[menu removeItemAtIndex:0];
		}
	}
	for(int i=0;i<[locItems count];i++) {
		NLLoc *item = [locItems objectAtIndex:i];
		NSMenuItem *mi = [[NSMenuItem alloc]initWithTitle:item.name action:@selector(updateLoc:) keyEquivalent:@""];
		if([item isCurrent]) {
			mi.state = NSOnState;
			NSMutableAttributedString *title =
			[[NSMutableAttributedString alloc] initWithString:item.name attributes:
			 [NSDictionary dictionaryWithObject:[NSFont menuBarFontOfSize:[NSFont systemFontSize]]
																	 forKey:NSFontAttributeName]];
			statusItem.attributedTitle = title;
		}
		mi.tag = i;
		[menu insertItem:mi atIndex:0];
	}
	menuInitialized = YES;
}

- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
	UInt32 seedValue;
	CFURLRef thePath = NULL;
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in (__bridge NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
				LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
			}
			// Docs for LSSharedFileListItemResolve say we're responsible
			// for releasing the CFURLRef that is returned
			if (thePath != NULL) CFRelease(thePath);
		}
	}
	if (loginItemsArray != NULL) CFRelease(loginItemsArray);
}
- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath {
	BOOL found = NO;  
	UInt32 seedValue;
	CFURLRef thePath = NULL;

	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in (__bridge NSArray *)loginItemsArray) {    
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
				found = YES;
				break;
			}
			// Docs for LSSharedFileListItemResolve say we're responsible
			// for releasing the CFURLRef that is returned
			if (thePath != NULL) CFRelease(thePath);
		}
	}
	if (loginItemsArray != NULL) CFRelease(loginItemsArray);

	return found;
}
@end
