import Cocoa

class LinesView : NSView {

     enum RenderMode: Int {
        case singlePath     // make one path manually and stroke it
        case addLines       // make one path via CGPathAddLines
        case multiplePaths  // one stroke per line segment
        case segments       // use CGContextStrokeLineSegments
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
    
    var renderMode: RenderMode = .singlePath {
        didSet {
            needsDisplay = true
        }
    }
    
    fileprivate var points: [CGPoint] = [
        CGPoint(x: 17, y: 400),
        CGPoint(x: 175, y: 20),
        CGPoint(x: 330, y: 275),
        CGPoint(x: 150, y: 371),
    ]
    
    fileprivate var draggedPointIndex: Int?
    

    fileprivate func drawNiceBackground() {
        let context = currentContext

        protectGState {
            context?.setFillColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White
            context?.fill (self.bounds)
        }
    }
    
    fileprivate func drawNiceBorder() {
        let context = currentContext
        
        protectGState {
            context?.setStrokeColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black
            context?.stroke (self.bounds)
        }
    }


    fileprivate func renderAsSinglePath() {
        let context = currentContext
        let path = CGMutablePath()
        
        path.move(to: points[0])
        
        for i in 1 ..< points.count {
            path.addLine(to: points[i])
        }
        
        context?.addPath (path)
        context?.strokePath ()
    }
    
    fileprivate func renderAsSinglePathByAddingLines() {
        let context = currentContext
        let path = CGMutablePath()
        
        path.addLines (between: self.points)
        context?.addPath (path)
        context?.strokePath ()
    }

     fileprivate func renderAsMultiplePaths() {
        let context = currentContext
        
        for i in 0 ..< points.count - 1 {
            let path = CGMutablePath()
            path.move (to: points[i])
            path.addLine (to: points[i + 1])
            
            context?.addPath (path)
            context?.strokePath ()
        }
    }

    fileprivate func renderAsSegments() {
        let context = currentContext
        
        var segments: [CGPoint] = []

        for i in 0 ..< points.count - 1 {
            segments += [points[i]]
            segments += [points[i + 1]]
        }

        // Strokes points 0->1 2->3 4->5
        context?.strokeLineSegments (between: segments)
    }

   fileprivate func renderPath() {
        switch renderMode {
        case .singlePath:
            renderAsSinglePath()
        case .addLines:
            renderAsSinglePathByAddingLines()
        case .multiplePaths:
            renderAsMultiplePaths()
        case .segments:
            renderAsSegments()
        }
    }


    // --------------------------------------------------
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let context = currentContext;
        
        drawNiceBackground()
        
        protectGState() {
            NSColor.green.set()
            
            if let hook = self.preRenderHook {
                hook(self, context!)
            }
            self.renderPath()
        }
        
        if (showLogicalPath) {
            context?.setStrokeColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White
            renderPath()
        }
        
        drawNiceBorder()
    }
    
    // Behave more like iOS, or most sane toolkits.
    override var isFlipped: Bool {
        return true
    }
    
    // Which point of the multi-segment line is close to the mouse point?
    fileprivate func pointIndexForMouse (_ mousePoint: CGPoint) -> Int? {
        let kClickTolerance: Float = 10.0
        var pointIndex: Int? = nil
        
        for (index, point) in points.enumerated() {
            let distance = hypotf(Float(mousePoint.x - point.x),
                Float(mousePoint.y - point.y))
            if distance < kClickTolerance {
                pointIndex = index
                break
            }
        }
        
        return pointIndex
    }
    
    override func mouseDown (with event: NSEvent) {
        let localPoint = self.convert(event.locationInWindow, from: nil)
        
        draggedPointIndex = self.pointIndexForMouse(localPoint)
        needsDisplay = true
    }
    
    override func mouseDragged (with event: NSEvent) {
        if let pointIndex = draggedPointIndex {
            let localPoint = self.convert(event.locationInWindow, from: nil)
            points[pointIndex] = localPoint
            needsDisplay = true
        }
    }
    
    override func mouseUp (with event: NSEvent) {
        draggedPointIndex = nil
    }
}

