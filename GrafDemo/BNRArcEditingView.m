#import "BNRArcEditingView.h"
#import "BNRUtilities.h"

typedef enum {
    kPathStart = 0,
    kFirstSegment,
    kSecondSegment,
    kPathEnd,

    kArcCenter,
    kRadiusHandle,

    kControlPointCount

} ControlPointIndex;

static const CGFloat kBoxSize = 4.0;
static const NSInteger kNotTrackingIndex = -1;

@interface BNRArcEditingView()
@property (assign) NSInteger trackingIndex;

@end // extension

@implementation BNRArcEditingView {
    CGPoint _controlPoints[kControlPointCount];
}
@synthesize clockwise = _clockwise;
@synthesize startAngle = _startAngle;
@synthesize endAngle = _endAngle;


- (void) commonInitWithSize: (CGSize) size {
    self.trackingIndex = kNotTrackingIndex;

    static const CGFloat kDefaultRadius = 25.0;
    static const CGFloat kMargin = 5.0;
    CGFloat kLineLength = size.width / 3.0;

    _startAngle = 3 * (M_PI / 4.0);
    _endAngle = M_PI / 4.0;
    _clockwise = YES;

    CGFloat midX = size.width / 2.0;
    CGFloat midY = size.height / 2.0;

    CGFloat leftX = kMargin;
    CGFloat rightX = size.width - kMargin;

    _controlPoints[kPathStart] = (CGPoint) { leftX, midY};
    _controlPoints[kFirstSegment] = (CGPoint) { leftX + kLineLength, midY };
    _controlPoints[kSecondSegment] = (CGPoint) { rightX - kLineLength, midY };
    _controlPoints[kPathEnd] = (CGPoint) { rightX, midY };

    _controlPoints[kArcCenter] = (CGPoint) { midX, midY, };
    _controlPoints[kRadiusHandle] = (CGPoint) { midX, midY - kDefaultRadius };

} // commonInit


- (instancetype) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        [self commonInitWithSize: frame.size];
    }
    return self;
} // initWithCoder


- (CGFloat) radius {
    CGFloat radius = hypotf(_controlPoints[kArcCenter].x - _controlPoints[kRadiusHandle].x,
                            _controlPoints[kArcCenter].y - _controlPoints[kRadiusHandle].y);
    return radius;
} // radius


- (void) setRadius: (CGFloat) radius {
    assert(!"too lazy to actually implement this");
} // radius


// Turd methods just to get a setNeedsDisplay, and we can't 'send super' to the
// compiler's generated version of proper setters :-(
- (CGPoint) center {
    return _controlPoints[kArcCenter];
} // center


- (void) setCenter: (CGPoint) center {
    _controlPoints[kArcCenter] = center;
    [self setNeedsDisplay: YES];
} // setCenter


- (BOOL) clockwise {
    return _clockwise;
} // clockwise


- (void) setClockwise: (BOOL) clockwise {
    _clockwise = clockwise;
    [self setNeedsDisplay: YES];
} // setClockwise


- (CGFloat) startAngle {
    return _startAngle;
} // startAngle


- (void) setStartAngle: (CGFloat) startAngle {
    _startAngle = startAngle;
    [self setNeedsDisplay: YES];
} // setStartAngle

- (CGFloat) endAngle {
    return _endAngle;
} // endAngle


- (void) setEndAngle: (CGFloat) endAngle {
    _endAngle = endAngle;
    [self setNeedsDisplay: YES];
} // setEndAngle

// Drawing

- (void) drawPath {
    CGContextRef context = CurrentContext ();
    CGMutablePathRef path = CGPathCreateMutable ();
    
    CGPathMoveToPoint (path, nil, 
                       _controlPoints[kPathStart].x,
                       _controlPoints[kPathStart].y);
    CGPathAddLineToPoint (path, nil,
                          _controlPoints[kFirstSegment].x,
                          _controlPoints[kFirstSegment].y);
    CGPathAddArc (path, nil, self.center.x, self.center.y, self.radius,
                  self.startAngle, self.endAngle, self.clockwise);

    CGPathAddLineToPoint (path, nil,
                          _controlPoints[kSecondSegment].x,
                          _controlPoints[kSecondSegment].y);
    CGPathAddLineToPoint (path, nil,
                          _controlPoints[kPathEnd].x,
                          _controlPoints[kPathEnd].y);

    CGContextAddPath (context, path);
    CGContextStrokePath (context);

    CGPathRelease (path);

} // drawPath


- (CGRect) boxAtPoint: (CGPoint) point {
    CGRect rect = (CGRect) { point.x - kBoxSize / 2.0,
                             point.y - kBoxSize / 2.0,
                             kBoxSize, kBoxSize };
    return rect;
} // boxAtPont


- (void) drawControlPoints {
    CGContextRef context = CurrentContext();

    CGContextSaveGState (context); {
        for (ControlPointIndex i = 0; i < kControlPointCount; i++) {
            NSColor *color = NSColor.blackColor;
            switch (i) {
            case kPathStart:
            case kFirstSegment:
            case kSecondSegment:
            case kPathEnd:
                color = NSColor.blueColor;
                break;
                
            case kArcCenter:
                color = NSColor.redColor;
                break;
                
            case kRadiusHandle:
                color = NSColor.orangeColor;
                break;
                
            default:
                color = NSColor.magentaColor; // It's a Magenta Alert
            }
            
            [color set];
            CGRect rect = [self boxAtPoint: _controlPoints[i]];
            CGContextAddRect (context, rect);
            CGContextFillPath (context);
        }
    } CGContextRestoreGState (context);

} // drawControlPoints


// Need to dust off the trig book and figure out the proper places to draw
// gray influence lines to beginning/ending angle
- (void) drawInfluenceLines {
    CGContextRef context = CurrentContext();

    static const CGFloat kInfluenceOverspill = 20.0; // how many points beyond the circle

    CGContextSaveGState (context); {
        [NSColor.lightGrayColor set];
        CGFloat pattern[] = { 2.0, 2.0 };
        CGContextSetLineDash (context, 0.0, pattern, sizeof(pattern) / sizeof(*pattern));

        CGFloat radius = self.radius + kInfluenceOverspill;
        
        CGPoint startAnglePoint =
            (CGPoint) { self.center.x + radius * cos(self.startAngle),
                        self.center.y + radius * sin(self.startAngle) };
        CGPoint endAnglePoint =
            (CGPoint) { self.center.x + radius * cos(self.endAngle),
                        self.center.y + radius * sin(self.endAngle) };

        CGPoint startAngleSegments[2] = { self.center, startAnglePoint };
        CGPoint endAngleSegments[2] = { self.center, endAnglePoint };

        CGContextStrokeLineSegments (context, startAngleSegments, 2);
        CGContextStrokeLineSegments (context, endAngleSegments, 2);

    } CGContextRestoreGState (context);

} // drawInfluenceLines


- (void) drawRect: (NSRect) dirtyRect {
    CGRect bounds = self.bounds;

    [NSColor.whiteColor set];
    NSRectFill (bounds);

    [NSColor.blackColor set];
    NSFrameRect (bounds);

    [self drawInfluenceLines];
    [self drawPath];
    [self drawControlPoints];

} // drawRect


- (void) startDragWithControlPointIndex: (ControlPointIndex) index {
    self.trackingIndex = index;
} // startDragWithControlPointIndex


- (void) dragToNewPoint: (CGPoint) point {

    // Pull the radius handle along with the center.
    if (self.trackingIndex == kArcCenter) {
        CGPoint center = _controlPoints[kArcCenter];
        CGPoint radius = _controlPoints[kRadiusHandle];
        
        CGFloat deltaX = radius.x - center.x;
        CGFloat deltaY = radius.y - center.y;

        CGPoint newRadius = (CGPoint){ point.x + deltaX,
                                       point.y + deltaY };
        _controlPoints[kRadiusHandle] = newRadius;
    }

    _controlPoints[self.trackingIndex] = point;

    [self setNeedsDisplay: YES];
} // dragToNewPoint


- (void) stopDrag {
    self.trackingIndex = kNotTrackingIndex;
    [self setNeedsDisplay: YES];
} // stopDrag


- (void) mouseDown: (NSEvent *) event {
    self.trackingIndex = kNotTrackingIndex;

    CGPoint localPoint = [self convertPoint: event.locationInWindow  fromView: nil];

    for (NSInteger i = 0; i < kControlPointCount; i++) {
        CGRect box = [self boxAtPoint: _controlPoints[i]];
        box = CGRectInset(box, -10.0, -10.0);
        if (CGRectContainsPoint(box, localPoint)) {
            [self startDragWithControlPointIndex: (ControlPointIndex)i];
            break;
        }
    }

} // mouseDown


- (void) mouseDragged: (NSEvent *) event {
    if (self.trackingIndex == kNotTrackingIndex) return;

    CGPoint localPoint = [self convertPoint: event.locationInWindow  fromView: nil];
    [self dragToNewPoint: localPoint];

} // mouseDragged


- (void) mouseUp: (NSEvent *) event {
    if (self.trackingIndex == kNotTrackingIndex) return;

    [self stopDrag];
} // mouseUp


@end // BNRArcEditingView
