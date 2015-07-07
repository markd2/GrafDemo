#import "BNRTransformsWindowController.h"
#import "GrafDemo-Swift.h"


@interface BNRTransformsWindowController ()
@property (strong) IBOutlet TransformView *transformView;
@end // extension


@implementation BNRTransformsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
} // windowDidLoad


- (IBAction) animate: (NSButton *) sender {
    NSLog (@"OOK");
    [self.transformView startAnimation];
} // animate


- (IBAction) reset: (NSButton *) sender {
    [self.transformView reset];
} // reset

@end // BNRTransformsWindowController
