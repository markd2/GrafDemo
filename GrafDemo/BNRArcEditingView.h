#import <Cocoa/Cocoa.h>

@interface BNRArcEditingView : NSView

@property (assign) CGPoint center;
@property (assign) CGFloat radius;
@property (assign) CGFloat startAngle;
@property (assign) CGFloat endAngle;
@property (assign) BOOL clockwise;

@end // BNRArcEditingView
