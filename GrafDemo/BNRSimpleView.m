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
    CGContextRef context = self.currentContext;

    CGRect innerRect = CGRectInset (self.bounds, 20, 20);

    CGContextSetRGBFillColor (context, 0.0, 1.0, 0.0, 1.0); // Green
    CGContextFillEllipseInRect (context, innerRect);

    CGContextSetRGBStrokeColor (context, 0.0, 0.0, 1.0, 1.0); // Blue
    CGContextSetLineWidth (context, 6.0);
    CGContextStrokeEllipseInRect (context, innerRect);
    
} // drawSloppyContents


- (void) drawSloppyBorder {
    CGContextStrokeRect (self.currentContext, self.bounds);
} // drawSloppyBorder


- (void) drawSloppily {
    CGContextRef context = self.currentContext;
    
    CGContextSetRGBStrokeColor (context, 0.0, 0.0, 0.0, 1.0); // Black
    CGContextSetRGBFillColor (context, 1.0, 1.0, 1.0, 1.0); // White
    
    [self drawSloppyBackground];
    [self drawSloppyContents];
    [self drawSloppyBorder];
    
} // drawSloppily


// --------------------------------------------------

- (void) drawNiceBackground {
    CGContextRef context = self.currentContext;

    CGContextSaveGState (context); {
        CGContextFillRect (context, self.bounds);
    } CGContextRestoreGState (context);
} // drawNiceBackground


- (void) drawNiceContents {
    CGContextRef context = self.currentContext;

    CGContextSaveGState (context); {
        CGRect innerRect = CGRectInset (self.bounds, 20, 20);
        
        CGContextSetLineWidth (context, 6.0);
        
        CGContextSetRGBFillColor (context, 0.0, 1.0, 0.0, 1.0); // Green
        CGContextFillEllipseInRect (context, innerRect);
        
        CGContextSetRGBStrokeColor (context, 0.0, 0.0, 1.0, 1.0); // Blue
        CGContextStrokeEllipseInRect (context, innerRect);

    } CGContextRestoreGState (context);
    
} // drawNiceContents


- (void) drawNiceBorder {
    CGContextRef context = self.currentContext;

    CGContextSaveGState (context); {
        CGContextStrokeRect (context, self.bounds);
    } CGContextRestoreGState (context);
} // drawNiceBorder


- (void) drawNicely {
    CGContextRef context = self.currentContext;

    // Set the background and border size attributes.
    CGContextSetRGBStrokeColor (context, 0.0, 0.0, 0.0, 1.0); // Black
    CGContextSetRGBFillColor (context, 1.0, 1.0, 1.0, 1.0); // White
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

