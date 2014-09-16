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


// --------------------------------------------------


- (void) drawSloppyBackground {
    NSRectFill (self.bounds);
} // drawSloppyBackground


- (void) drawSloppyBorder {
    [[NSBezierPath bezierPathWithRect: self.bounds] stroke];
} // drawSloppyBorder


- (void) drawSloppyContents {
    CGRect innerRect = CGRectInset (self.bounds, 20, 20);
    NSBezierPath *ovalPath = [NSBezierPath bezierPathWithOvalInRect: innerRect];

    [NSBezierPath setDefaultLineWidth: 1.0];

    [[NSColor greenColor] set];
    [ovalPath fill];

    [[NSColor blueColor] set];
    [ovalPath stroke];
    
} // drawSloppyContents


- (void) drawSloppily {
    [[NSColor whiteColor] setFill];
    [[NSColor blackColor] setStroke];
    [NSBezierPath setDefaultLineWidth: 5.0];
    
    [self drawSloppyBackground];
    [self drawSloppyContents];
    [self drawSloppyBorder];

} // drawSloppily


// --------------------------------------------------

- (void) drawNiceBackground {
    [NSGraphicsContext saveGraphicsState]; {
        [[NSColor whiteColor] setFill];
        NSRectFill (self.bounds);
    } [NSGraphicsContext restoreGraphicsState];
} // drawNiceBackground


- (void) drawNiceContents {
    [NSGraphicsContext saveGraphicsState]; {
        [NSBezierPath setDefaultLineWidth: 1.0];

        CGRect innerRect = CGRectInset (self.bounds, 20, 20);
        NSBezierPath *ovalPath = [NSBezierPath bezierPathWithOvalInRect: innerRect];

        [[NSColor greenColor] set];
        [ovalPath fill];

        [[NSColor blueColor] set];
        [ovalPath stroke];

    } [NSGraphicsContext restoreGraphicsState];
} // drawNiceContents


- (void) drawNiceBorder {
    [NSGraphicsContext saveGraphicsState]; {
        [[NSColor blackColor] setStroke];
        [NSBezierPath setDefaultLineWidth: 5.0];
        [[NSBezierPath bezierPathWithRect: self.bounds] stroke];
    } [NSGraphicsContext restoreGraphicsState];
} // drawNiceBorder


- (void) drawNicely {
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

