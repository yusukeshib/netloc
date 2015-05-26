#import "NLAppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface NLAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation NLAppDelegate

//@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}
-(void)awakeFromNib{
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    //
    title = [[NSMutableAttributedString alloc]
             initWithString:@""
             attributes:[NSDictionary dictionaryWithObject:[NSFont menuBarFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName]];
    //
    statusItem.attributedTitle = title;
    
    // loc
    locItems = [[NSMutableDictionary alloc] init];
    SCPreferencesRef prefs = SCPreferencesCreate(NULL, (CFStringRef)@"SystemConfiguration", NULL);
    SCNetworkSetRef locCurrent = SCNetworkSetCopyCurrent(prefs);
    NSString *id_current = (__bridge NSString *)SCNetworkSetGetSetID(locCurrent);
    NSArray *locations = (__bridge NSArray *)SCNetworkSetCopyAll(prefs);
    int tagid = 0;
    for (id item in locations) {
        NSString *name = (__bridge NSString *)SCNetworkSetGetName((__bridge SCNetworkSetRef)item);
        NSString *setid = (__bridge NSString *)SCNetworkSetGetSetID((__bridge SCNetworkSetRef)item);
        NSMenuItem *mi = [[NSMenuItem alloc]initWithTitle:name action:@selector(updateLoc:) keyEquivalent:@""];
        if([setid isEqualTo:id_current]) {
            mi.state = NSOnState;
            [title replaceCharactersInRange:NSMakeRange(0,title.string.length) withString:name];
            statusItem.attributedTitle = title;
        }
        mi.tag = tagid;
        NSString *tagKey = [NSString stringWithFormat:@"%ld",mi.tag];
        [locItems setObject:setid forKey:tagKey];
        [statusMenu insertItem:mi atIndex:0];
    }
    CFRelease((CFArrayRef)locations);
    CFRelease(prefs);
    
    // start at login
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    [self _setStartAtLogin:[self loginItemExistsWithLoginItemReference:loginItems ForPath:appPath]];
    CFRelease(loginItems);
}
- (void)updateLoc:(id)sender {
    NSMenuItem *selected = sender;
    NSString *tagKey = [NSString stringWithFormat:@"%ld",selected.tag];
    NSString *setid_update = [locItems objectForKey:tagKey];
    //
    SCPreferencesRef prefs = SCPreferencesCreate(NULL, (CFStringRef)@"SystemConfiguration", NULL);
    NSArray *locations = (__bridge NSArray *)SCNetworkSetCopyAll(prefs);
    for (id item in locations) {
        NSString *setid = (__bridge NSString *)SCNetworkSetGetSetID((__bridge SCNetworkSetRef)item);
        if([setid isEqualTo:setid_update]) {
            Boolean ret = SCNetworkSetSetCurrent((__bridge SCNetworkSetRef)item);
            NSLog(@"%d",ret);
        }
    }
    CFRelease((CFArrayRef)locations);
    CFRelease(prefs);
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
