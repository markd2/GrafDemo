#import "BNRSimpleView.h"

@implementation BNRSimpleView

- (instancetype) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
    }

    return self;

} // initWithFrame


- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder])) {
    }

    return self;

} // initWithCoder


- (void) setBeSloppy: (BOOL) beSloppy {
    _beSloppy = beSloppy;
    [self setNeedsDisplay: YES];
} // setBeSloppy


- (CGContextRef) currentContext {
    return [NSGraphicsContext.currentContext graphicsPort];
} // currentContext


// --------------------------------------------------


- (void) drawSloppyBackground {
    CGContextFillRect (self.currentContext, self.bounds);
} // drawSloppyBackground


- (void) drawSloppyContents {
    CGRect innerRect = CGRectInset (self.bounds, 20, 20);

    CGContextSetLineWidth (self.currentContext, 6.0);

    [[NSColor greenColor] set];
    CGContextFillEllipseInRect (self.currentContext, innerRect);

    [[NSColor blueColor] set];
    CGContextStrokeEllipseInRect (self.currentContext, innerRect);
    
} // drawSloppyContents


- (void) drawSloppyBorder {
    CGContextStrokeRect (self.currentContext, self.bounds);
} // drawSloppyBorder


- (void) drawSloppily {
    // Set the background and border size attributes.
    [[NSColor whiteColor] setFill];
    [[NSColor blackColor] setStroke];
    CGContextSetLineWidth (self.currentContext, 3.0);
    
    [self drawSloppyBackground];
    [self drawSloppyContents];
    [self drawSloppyBorder];

} // drawSloppily


// --------------------------------------------------

- (void) drawNiceBackground {
    CGContextSaveGState (self.currentContext); {
        CGContextFillRect (self.currentContext, self.bounds);
    } CGContextRestoreGState (self.currentContext);
} // drawNiceBackground


- (void) drawNiceContents {
    CGContextSaveGState (self.currentContext); {
        CGRect innerRect = CGRectInset (self.bounds, 20, 20);
        
        CGContextSetLineWidth (self.currentContext, 6.0);
        
        [[NSColor greenColor] set];
        CGContextFillEllipseInRect (self.currentContext, innerRect);
        
        [[NSColor blueColor] set];
        CGContextStrokeEllipseInRect (self.currentContext, innerRect);

    } CGContextRestoreGState (self.currentContext);
    
} // drawNiceContents


- (void) drawNiceBorder {
    CGContextSaveGState (self.currentContext); {
        CGContextStrokeRect (self.currentContext, self.bounds);
    } CGContextRestoreGState (self.currentContext);
} // drawNiceBorder


- (void) drawNicely {
    // Set the background and border size attributes.
    [[NSColor whiteColor] setFill];
    [[NSColor blackColor] setStroke];
    CGContextSetLineWidth (self.currentContext, 3.0);
    
    [self drawNiceBackground];
    [self drawNiceContents];
    [self drawNiceBorder];

} // drawNicely


- (void) drawRect: (NSRect) dirtyRect
{
    [super drawRect: dirtyRect];

    if (self.beSloppy) {
        [self drawSloppily];
    } else {
        [self drawNicely];
    }

} // drawRect

@end // BNRSimpleView

