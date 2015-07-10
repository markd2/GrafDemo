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
    [self.transformView startAnimation];
} // animate


- (IBAction) reset: (NSButton *) sender {
    [self.transformView reset];
} // reset


- (IBAction) toggleTranslate: (NSButton *) sender {
    self.transformView.shouldTranslate = sender.state == NSOnState;
} // toggleTranslate


- (IBAction) toggleRotate: (NSButton *) sender {
    self.transformView.shouldRotate = sender.state == NSOnState;
} // toggleRotate


- (IBAction) toggleScale: (NSButton *) sender {
    self.transformView.shouldScale = sender.state == NSOnState;
} // toggleScale


@end // BNRTransformsWindowController
