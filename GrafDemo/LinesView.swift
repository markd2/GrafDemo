import Cocoa

class LinesView : NSView {

    var preRenderHook: ((LinesView, CGContext) -> ())?
    
    enum RenderMode {
        case SinglePath
        case AddLines
        case MultiplePaths
        case Segments
    }

    var renderMode: RenderMode = .SinglePath
    
    // TODO(markd 12/24/2014) - extract somewhere sane
    private var currentContext : CGContext? {
        get {
            // The 10.10 SDK provdes a CGContext on NSGraphicsContext, but
            // that's not available to folks running 10.9, so perform this
            // violence to get a context via a void*.
            // iOS can use UIGraphicsGetCurrentContext.
            
            let unsafeContextPointer = NSGraphicsContext.currentContext()?.graphicsPort
            
            if let contextPointer = unsafeContextPointer {
                let opaquePointer = COpaquePointer(contextPointer)
                let context: CGContextRef = Unmanaged.fromOpaque(opaquePointer).takeUnretainedValue()
                return context
            } else {
                return nil
            }
        }
    }
    private func saveGState(drawStuff: () -> ()) -> () {
        CGContextSaveGState (currentContext)
        drawStuff()
        CGContextRestoreGState (currentContext)
    }

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
        
        let points: Array<CGPoint> = [
            CGPoint(x: 17, y: 400),
            CGPoint(x: 175, y: 20),
            CGPoint(x: 330, y: 275),
            CGPoint(x: 150, y: 371),
          ]
    
        let path = CGPathCreateMutable()
 
        CGPathMoveToPoint (path, nil, points[0].x, points[0].y);
    
        for var i = 1; i < points.count; i++ {
            CGPathAddLineToPoint (path, nil, points[i].x, points[i].y)
        }
        
        CGContextAddPath (context, path)
        CGContextStrokePath (context)

    }

    private func renderPath() {
        switch renderMode {
        case .SinglePath:
            renderAsSinglePath()
        case .AddLines:
            println("ook")
        case .MultiplePaths:
            println("ook")
        case .Segments:
            println("ook")
        }
    }


    // --------------------------------------------------
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        let context = currentContext;
        
        drawNiceBackground()
        
        saveGState() {
            NSColor.blueColor().set()
            
            if let hook = self.preRenderHook {
                hook(self, context!)
            }
            self.renderPath()
        }
        
        CGContextSetRGBStrokeColor (context, 1.0, 1.0, 1.0, 1.0) // White
        renderPath()
        
        drawNiceBorder()
    }
    
    /* override */ func isFlipped() -> Bool {
        return true
    }
}