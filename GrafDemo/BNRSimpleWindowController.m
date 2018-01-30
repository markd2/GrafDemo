#import "BNRSimpleWindowController.h"
#import "GrafDemo-Swift.h"


#import "BNRSimpleView.h"

@interface BNRSimpleWindowController ()
@property (weak) IBOutlet BNRSimpleView *simpleView;
@property (weak) IBOutlet SimpleView *swSimpleView;

@end // extension



@implementation BNRSimpleWindowController


- (void) loadWindow {
    [super loadWindow];
}

- (void) windowDidLoad {
    [super windowDidLoad];
} // windowDidLoad



- (IBAction) toggleSloppy: (NSButton *) toggle {
    self.simpleView.beSloppy = (toggle.state == NSOnState);
    self.swSimpleView.beSloppy = (toggle.state == NSOnState);
    
} // toggleSloppy


@end
