#import "AppDelegate.h"

#import "BNRSimpleWindowController.h"
#import "GrafDemo-Swift.h"

@interface AppDelegate ()
@property (strong) NSMutableArray *windowControllers;

@end


@implementation AppDelegate
            
- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
    self.windowControllers = NSMutableArray.new;
}

- (void) applicationWillTerminate: (NSNotification *) aNotification {
}


- (void) showViewControllerNamed: (NSString *) vcClassName {
    Class clas = NSClassFromString(vcClassName);
    if (clas == Nil) {
        NSString *swiftClassName = [@"GrafDemo." stringByAppendingString: vcClassName];
        clas = NSClassFromString(swiftClassName);
    }
    assert(clas);
    
    id wc = [[clas alloc] initWithWindowNibName: vcClassName];
    [wc showWindow: self];

    [self.windowControllers addObject: wc];

} // showViewControllerNamed


- (void) hackToGetXcodeToLinkTheClassesIn {
    (void)BNRSimpleWindowController.new;
    (void)BNRLinesWindowController.new;
} // #ilyxc


- (IBAction)showSimpleView: (NSButton *) sender {
    [self showViewControllerNamed: @"BNRSimpleWindowController"];
} // showSimpleView


- (IBAction) showLinesController: (NSButton *) sender {
    [self showViewControllerNamed: @"BNRLinesWindowController"];
} // showLinesController


- (IBAction) showPathController: (NSButton *) sender {
    [self showViewControllerNamed: @"BNRPathWindowController"];
} // showPathController




@end // AppDelegate

