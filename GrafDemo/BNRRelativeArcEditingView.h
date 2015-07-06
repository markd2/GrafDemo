// Totally copy and pasted from BNRArcEditingView - refactor after CocoaConf/Columbus.

#import <Cocoa/Cocoa.h>

@interface BNRRelativeArcEditingView : NSView

@property (assign) CGPoint center;
@property (assign) CGFloat radius;
@property (assign) CGFloat startAngle;
@property (assign) CGFloat deltaAngle;

@end // BNRArcEditingView
