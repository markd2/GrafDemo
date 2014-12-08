#import "BNRLinesView.h"
#import "BNRUtilities.h"

@interface BNRLinesView ()

@property (readonly) CGPoint *points;

@end // extension


@implementation BNRLinesView {
    CGPoint _pointStorage[3];
}

- (CGPoint *) points {
    return _pointStorage;
}


- (void) commonInit {
    _pointStorage[0] = (CGPoint){ 10.0, 10.0 };
    _pointStorage[1] = (CGPoint){ 90.0, 100.0 };
    _pointStorage[2] = (CGPoint){  7.0,  30.0 };
} // commonInit


- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder])) {
        [self commonInit];
    }

    return self;
} // initWithCoder


- (instancetype) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        [self commonInit];
    }

    return self;
} // initWithCoder


- (void) drawNiceBackground {
    CGContextRef context = CurrentContext();
    
    CGContextSaveGState (context); {
        CGContextSetRGBFillColor (context, 1.0, 1.0, 1.0, 1.0); // White
        
        CGContextFillRect (context, self.bounds);
    } CGContextRestoreGState (context);
} // drawNiceBackground


- (void) drawNiceBorder {
    CGContextRef context = CurrentContext();
    
    CGContextSaveGState (context); {
        CGContextSetRGBStrokeColor (context, 0.0, 0.0, 0.0, 1.0); // Black
        CGContextStrokeRect (context, self.bounds);
    } CGContextRestoreGState (context);
} // drawNiceBorder


- (void) drawRect: (NSRect) dirtyRect {
    [super drawRect: dirtyRect];
    
    [self drawNiceBackground];

    NSBezierPath *path = NSBezierPath.new;

    [path moveToPoint: self.points[0]];
    [path lineToPoint: self.points[1]];
    [path lineToPoint: self.points[2]];

    [NSColor.blueColor set];
    path.lineWidth = 10.0;
    [path stroke];

    [NSColor.whiteColor set];
    path.lineWidth = 1.0;
    [path stroke];
    
    [self drawNiceBorder];

} // drawRect


- (BOOL) isFlipped {
    return YES;
} // isFlipped

@end // BNRLinesView
