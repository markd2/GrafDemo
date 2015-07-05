
#import "BNRPathWindowController.h"
#import "GrafDemo-Swift.h"

@interface BNRPathWindowController ()
@property (strong) IBOutlet PathSamplerView *pathSamplerView;
@end // extension


@implementation BNRPathWindowController


- (void)windowDidLoad {
    [self.pathSamplerView addSamplePath];
} // windowDidLoad

@end // BNRPathWindowController

