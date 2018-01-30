#import <Cocoa/Cocoa.h>

@class BNRLinesView;
typedef void (^BNRLinesViewPreRenderHook)(BNRLinesView *linesView, CGContextRef cgContext);

typedef NS_ENUM(NSInteger, BNRLinesViewRenderMode) {
    kRenderModeSinglePath,     // make one path manually and stroke it
    kRenderModeAddLines,       // make one path via CGPathAddLines
    kRenderModeMultiplePaths,  // one stroke per line segment
    kRenderModeSegments        // use CGContextStrokeLineSegments
};

@interface BNRLinesView : NSView

// OBTW, these are non-atomic because I want to setNeedsDisplay when they change,
// and don't want to jump through KVO hoops, or implement my own atomicity in the setter
// and getter.  Granted, atomic guarantees aren't necessary when UI is involved, but
// they tend to be typical in OS X code.
@property (copy, nonatomic) BNRLinesViewPreRenderHook preRenderHook;
@property (assign, nonatomic) BNRLinesViewRenderMode renderMode;
@property (assign, nonatomic) BOOL showLogicalPath;

@end // NRLinesView
