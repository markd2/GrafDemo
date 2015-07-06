#import "BNRArcToPointEditingView.h"
#import "BNRUtilities.h"

typedef enum {
    kPathStart = 0,
    kFirstSegment,
    kSecondSegment,
    kPathEnd,
    
    kControl1,
    kControl2,
    kRadiusHandle,

    kControlPointCount

} ControlPointIndex;

static const CGFloat kBoxSize = 10.0;
static const NSInteger kNotTrackingIndex = -1;

@interface BNRArcToPointEditingView()
@property (assign) NSInteger trackingIndex;

@end // extension

@implementation BNRArcToPointEditingView {
    CGPoint _controlPoints[kControlPointCount];
}
@synthesize control1 = _control1;
@synthesize control2 = _control2;


- (void) commonInitWithSize: (CGSize) size {
    self.trackingIndex = kNotTrackingIndex;

    static const CGFloat kDefaultRadius = 25.0;
    static const CGFloat kMargin = 5.0;
    CGFloat kLineLength = size.width / 3.0;

    CGFloat midX = size.width / 2.0;
    CGFloat midY = size.height / 2.0;

    _radius = kDefaultRadius;
    _control1 = (CGPoint) { 69, 163 };
    _control2 = (CGPoint) { 187, 61 };

    CGFloat leftX = kMargin;
    CGFloat rightX = size.width - kMargin;

    _controlPoints[kPathStart] = (CGPoint) { leftX, midY};
    _controlPoints[kFirstSegment] = (CGPoint) { leftX + kLineLength, midY };
    _controlPoints[kSecondSegment] = (CGPoint) { rightX - kLineLength, midY };
    _controlPoints[kPathEnd] = (CGPoint) { rightX, midY };

    _controlPoints[kControl1] = _control1;
    _controlPoints[kControl2] = _control2;
    _controlPoints[kRadiusHandle] = (CGPoint) { midX, midY - kDefaultRadius };

} // commonInit


- (instancetype) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        [self commonInitWithSize: frame.size];
    }
    return self;
} // initWithCoder



// Turd methods just to get a setNeedsDisplay, and we can't 'send super' to the
// compiler's generated version of proper setters :-(

- (CGPoint) control1 {
    return _controlPoints[kControl1];
} // center


- (void) setControl1: (CGPoint) control1 {
    _controlPoints[kControl1] = control1;
    [self setNeedsDisplay: YES];
} // setCenter


- (CGPoint) control2 {
    return _controlPoints[kControl2];
} // center


- (void) setControl2: (CGPoint) control2 {
    _controlPoints[kControl2] = control2;
    [self setNeedsDisplay: YES];
} // setCenter

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
    CGPathAddArcToPoint (path, nil, self.control1.x, self.control1.y, 
                         self.control2.x, self.control2.y, self.radius);

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

            case kControl1:
            case kControl2:
                color = NSColor.grayColor;
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

    CGContextSaveGState (context); {
        [NSColor.lightGrayColor set];
        CGFloat pattern[] = { 2.0, 2.0 };
        CGContextSetLineDash (context, 0.0, pattern, sizeof(pattern) / sizeof(*pattern));

        CGRect bounds = self.bounds;

        CGFloat midX = CGRectGetMidX(bounds);
        CGFloat midY = CGRectGetMidY(bounds);
        
        CGPoint radiusSegments[2] = { (CGPoint){ midX, midY}, 
                                      _controlPoints[kRadiusHandle] };
        CGContextStrokeLineSegments (context, radiusSegments, 2);

        CGPoint controlSegments[4] =
            { _controlPoints[kFirstSegment], _controlPoints[kControl1],
              _controlPoints[kControl1], _controlPoints[kControl2] };
        CGContextStrokeLineSegments (context, controlSegments, 4);

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

    if (self.trackingIndex == kRadiusHandle) {
        CGRect bounds = self.bounds;

        CGFloat midX = CGRectGetMidX(bounds);
        CGFloat midY = CGRectGetMidY(bounds);
        
        self.radius = hypotf(midX - point.x, midY - point.y);
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


@end // BNRArcToPointEditingView
