#import "AppDelegate.h"

#import "BNRSimpleWindowController.h"

@interface AppDelegate ()
@property (strong) NSMutableArray *windowControllers;

@end


@implementation AppDelegate
            
- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
    self.windowControllers = NSMutableArray.new;
}

- (void) applicationWillTerminate: (NSNotification *) aNotification {
}


- (IBAction)showSimpleView: (NSButton *) sender {

    BNRSimpleWindowController *swc = [[BNRSimpleWindowController alloc] initWithWindowNibName: @"BNRSimpleWindowController"];
    [swc loadWindow];
    [swc showWindow: self];

    [self.windowControllers addObject: swc];

} // showSimpleView


@end // AppDelegate

