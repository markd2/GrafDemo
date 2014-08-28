#import <Cocoa/Cocoa.h>

@interface BNRSimpleView : NSView

// Should drawing be sloppy with graphic saves and restores?
@property (assign, nonatomic) BOOL beSloppy;

@end // BNRSimpleView
