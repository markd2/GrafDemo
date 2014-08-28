#import "AppDelegate.h"

#import "BNRSimpleView.h"

@interface AppDelegate ()

@property (weak) IBOutlet BNRSimpleView *simpleView;
@property (weak) IBOutlet NSWindow *window;

@end


@implementation AppDelegate
            
- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
}

- (void) applicationWillTerminate: (NSNotification *) aNotification {
}

- (IBAction) toggleSloppy: (NSButton *) toggle {
    self.simpleView.beSloppy = (toggle.state == NSOnState);
} // toggleSloppy

@end // AppDelegate

