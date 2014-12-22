#import "BNRLinesView.h"
#import "BNRUtilities.h"

@interface BNRLinesView ()

@property (readonly) CGPoint *points;
@property (assign) NSInteger draggedPoint;

@end // extension

static const NSInteger kPointCount = 4;
static const NSInteger kNoDraggedPoint = -1;

@implementation BNRLinesView {
    CGPoint _pointStorage[kPointCount];
}

- (CGPoint *) points {
    return _pointStorage;
}


- (void) commonInit {
    _pointStorage[0] = (CGPoint){  17.0, 400.0 };
    _pointStorage[1] = (CGPoint){ 175.0, 20.0 };
    _pointStorage[2] = (CGPoint){ 330.0, 275.0 };
    _pointStorage[3] = (CGPoint){ 150.0, 371.0 };
    
    _renderAsSinglePath = YES;
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



- (void) renderSinglePath {
    CGContextRef context = CurrentContext();

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint (path, NULL, self.points[0].x, self.points[0].y);
    
    for (NSInteger i = 1; i < kPointCount; i++) {
        CGPathAddLineToPoint (path, NULL, self.points[i].x, self.points[i].y);
    }
    
    CGContextAddPath (context, path);
    
    CGContextStrokePath (context);
    
} // renderSinglePath


- (void) renderAsSegments {
    CGContextRef context = CurrentContext();

    for (NSInteger i = 0; i < kPointCount - 1; i++) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint (path, NULL, self.points[i].x, self.points[i].y);
        CGPathAddLineToPoint (path, NULL, self.points[i + 1].x, self.points[i + 1].y);
        
        CGContextAddPath (context, path);
        CGContextStrokePath (context);
    }

} // renderAsSegments


- (void) renderPath {
    if (self.renderAsSinglePath) {
        [self renderSinglePath];
    } else {
        [self renderAsSegments];
    }
    
} // renderPath


- (void) drawRect: (NSRect) dirtyRect {
    CGContextRef context = CurrentContext();
    
    [super drawRect: dirtyRect];
    
    [self drawNiceBackground];
    
    CGContextSaveGState (context); {
        [NSColor.blueColor set];

        if (self.preRenderHook) {
            self.preRenderHook (self, CurrentContext());
        }
        [self renderPath];
        
    } CGContextRestoreGState (context);
    

    [NSColor.whiteColor set];
    [self renderPath];
    
    [self drawNiceBorder];

} // drawRect


- (BOOL) isFlipped {
    return YES;
} // isFlipped


// --------------------------------------------------

- (NSInteger) pointIndexForMouse: (CGPoint) mousePoint {
    NSInteger index = kNoDraggedPoint;
    
    static const CGFloat kClickTolerance = 8.0;
    
    for (NSInteger i = 0; i < kPointCount; i++) {
        CGFloat distance = hypotf(mousePoint.x - self.points[i].x,
                                  mousePoint.y - self.points[i].y);
        if (distance < kClickTolerance) {
            index = i;
            break;
        }
    }

    return index;
} // mousePoint


- (void) mouseDown: (NSEvent *) event {
    CGPoint localPoint = [self convertPoint: event.locationInWindow
                                   fromView: nil];
    NSLog (@"clicked %@", NSStringFromPoint(localPoint));
    
    self.draggedPoint = [self pointIndexForMouse: localPoint];
    [self setNeedsDisplay: YES];
} // mouseDown


- (void) mouseDragged: (NSEvent *) event {
    if (self.draggedPoint != kNoDraggedPoint) {
        CGPoint localPoint = [self convertPoint: event.locationInWindow
                                       fromView: nil];
        self.points[self.draggedPoint] = localPoint;
        [self setNeedsDisplay: YES];
    }
    
} // mouseDragged


- (void) mouseUp: (NSEvent *) event {
    self.draggedPoint = kNoDraggedPoint;
} // mouseUp


@end // BNRLinesView




