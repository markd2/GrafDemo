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
    _pointStorage[0] = (CGPoint){  20.0, 400.0 };
    _pointStorage[1] = (CGPoint){ 150.0, 100.0 };
    _pointStorage[2] = (CGPoint){ 280.0, 400.0 };
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
    CGContextRef context = CurrentContext();
    
    [super drawRect: dirtyRect];
    
    [self drawNiceBackground];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint (path, NULL, self.points[0].x, self.points[0].y);
    CGPathAddLineToPoint (path, NULL, self.points[1].x, self.points[1].y);
    CGPathAddLineToPoint (path, NULL, self.points[2].x, self.points[2].y);
    
    CGContextSaveGState (context); {
        [NSColor.blueColor set];

        CGContextAddPath (context, path);
        if (self.preRenderHook) {
            self.preRenderHook (self, CurrentContext());
        }
        
        CGContextStrokePath (context);
        
    } CGContextRestoreGState (context);
    
    CGContextAddPath (context, path);

    [NSColor.whiteColor set];
    CGContextStrokePath (context);

    
    [self drawNiceBorder];

} // drawRect


- (BOOL) isFlipped {
    return YES;
} // isFlipped


// --------------------------------------------------

- (void) mouseDown: (NSEvent *) event {
    CGPoint localPoint = [self convertPoint: event.locationInWindow
                                   fromView: nil];
    NSLog (@"clicked %@", NSStringFromPoint(localPoint));
} // mouseDown

@end // BNRLinesView




