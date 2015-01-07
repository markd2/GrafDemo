import Cocoa

class LinesView : NSView {

     enum RenderMode: Int {
        case SinglePath     // make one path manually and stroke it
        case AddLines       // make one path via CGPathAddLines
        case MultiplePaths  // one stroke per line segment
        case Segments       // use CGContextStrokeLineSegments
    }
    
   var preRenderHook: ((LinesView, CGContext) -> ())? {
        didSet {
            needsDisplay = true
        }
    }

    var showLogicalPath: Bool = true {
        didSet {
            needsDisplay = true
        }
    }
    
    var renderMode: RenderMode = .SinglePath {
        didSet {
            needsDisplay = true
        }
    }
    
    private var points: [CGPoint] = [
        CGPoint(x: 17, y: 400),
        CGPoint(x: 175, y: 20),
        CGPoint(x: 330, y: 275),
        CGPoint(x: 150, y: 371),
    ]
    
    private var draggedPointIndex: Int?
    

    private func drawNiceBackground() {
        let context = currentContext

        saveGState {
            CGContextSetRGBFillColor (context, 1.0, 1.0, 1.0, 1.0) // White
            CGContextFillRect (context, self.bounds)
        }
    }
    
    private func drawNiceBorder() {
        let context = currentContext
        
        saveGState {
            CGContextSetRGBStrokeColor (context, 0.0, 0.0, 0.0, 1.0) // Black
            CGContextStrokeRect (context, self.bounds)
        }
    }


    private func renderAsSinglePath() {
        let context = currentContext
        let path = CGPathCreateMutable()
 
        CGPathMoveToPoint (path, nil, points[0].x, points[0].y);
    
        for var i = 1; i < points.count; i++ {
            CGPathAddLineToPoint (path, nil, points[i].x, points[i].y)
        }
        
        CGContextAddPath (context, path)
        CGContextStrokePath (context)
    }
    
    private func renderAsSinglePathByAddingLines() {
        let context = currentContext
        let path = CGPathCreateMutable()
        
        CGPathAddLines (path, nil, self.points, UInt(self.points.count))
        CGContextAddPath (context, path)
        CGContextStrokePath (context)
    }

     private func renderAsMultiplePaths() {
        let context = currentContext
        
        for i in 0 ..< points.count - 1 {
            let path = CGPathCreateMutable()
            CGPathMoveToPoint (path, nil, points[i].x, points[i].y)
            CGPathAddLineToPoint (path, nil, points[i + 1].x, points[i + 1].y)
            
            CGContextAddPath (context, path)
            CGContextStrokePath (context)
        }
    }

    private func renderAsSegments() {
        let context = currentContext
        
        var segments: [CGPoint] = []
        
        for i in 0 ..< points.count - 1 {
            segments += [points[i]]
            segments += [points[i + 1]]
        }
        
        // Strokes points 0->1 2->3 4->5
        CGContextStrokeLineSegments (context, segments, UInt(segments.count))
    }

   private func renderPath() {
        switch renderMode {
        case .SinglePath:
            renderAsSinglePath()
        case .AddLines:
            renderAsSinglePathByAddingLines()
        case .MultiplePaths:
            renderAsMultiplePaths()
        case .Segments:
            renderAsSegments()
        }
    }


    // --------------------------------------------------
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        let context = currentContext;
        
        drawNiceBackground()
        
        saveGState() {
            NSColor.greenColor().set()
            
            if let hook = self.preRenderHook {
                hook(self, context!)
            }
            self.renderPath()
        }
        
        if (showLogicalPath) {
            CGContextSetRGBStrokeColor (context, 1.0, 1.0, 1.0, 1.0) // White
            renderPath()
        }
        
        drawNiceBorder()
    }
    
    // Behave more like iOS, or most sane toolkits.
    /* override */ func isFlipped() -> Bool {
        return true
    }
    
    // Which point of the multi-segment line is close to the mouse point?
    private func pointIndexForMouse (mousePoint: CGPoint) -> Int? {
        let kClickTolerance: Float = 10.0
        var pointIndex: Int? = nil
        
        for (index, point) in enumerate(points) {
            let distance = hypotf(Float(mousePoint.x - point.x),
                Float(mousePoint.y - point.y))
            if distance < kClickTolerance {
                pointIndex = index
                break
            }
        }
        
        return pointIndex
    }
    
    override func mouseDown (event: NSEvent) {
        let localPoint = self.convertPoint(event.locationInWindow, fromView: nil)
        
        draggedPointIndex = self.pointIndexForMouse(localPoint)
        needsDisplay = true
    }
    
    override func mouseDragged (event: NSEvent) {
        if let pointIndex = draggedPointIndex {
            let localPoint = self.convertPoint(event.locationInWindow, fromView: nil)
            points[pointIndex] = localPoint
            needsDisplay = true
        }
    }
    
    override func mouseUp (event: NSEvent) {
        draggedPointIndex = nil
    }
}

