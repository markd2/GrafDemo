import Cocoa

class SimpleView: NSView {

    // Should drawing be sloppy with graphic saves and restores?
    var beSloppy : Bool = false {
        willSet {
            needsDisplay = true
        }
    }
    
    private var currentContext : CGContext {
        get {
            // The 10.10 SDK provdes a CGContext on NSGraphicsContext, but
            // that's not available to folks running 10.9, so perform this
            // violence to get a context via a void*.
            // iOS can use UIGraphicsGetCurrentContext.
            let contextPointer = NSGraphicsContext.currentContext().graphicsPort
            let context = unsafeBitCast(contextPointer, CGContextRef.self)
            return context
        }
    }
    
    private func saveGState(drawStuff: () -> ()) -> () {
        CGContextSaveGState (self.currentContext)
        drawStuff()
        CGContextRestoreGState (self.currentContext)
    }

    // --------------------------------------------------

    func drawSloppily () {
        NSColor.whiteColor().setFill()
        NSColor.blackColor().setStroke()
        CGContextSetLineWidth (currentContext, 3.0);
        
        drawSloppyBackground()
        drawSloppyContents()
        drawSloppyBorder()
    }
    
    func drawSloppyBackground() {
        CGContextFillRect (currentContext, bounds)
    }
    
    func drawSloppyContents() {
        let innerRect = CGRectInset(bounds, 20.0, 20.0)
        
        CGContextSetLineWidth (currentContext, 6.0);

        NSColor.greenColor().set()
        CGContextFillEllipseInRect (currentContext, innerRect);

        NSColor.blueColor().set()
        CGContextStrokeEllipseInRect (currentContext, innerRect);
    }
    
    func drawSloppyBorder() {
        CGContextStrokeRect (currentContext, self.bounds);
    }

    // --------------------------------------------------

    func drawNicely () {
        NSColor.whiteColor().setFill()
        NSColor.blackColor().setStroke()
        CGContextSetLineWidth (currentContext, 3.0);
        
        drawNiceBackground()
        drawNiceContents()
        drawNiceBorder()
    }
    
    func drawNiceBackground() {
        saveGState {
            CGContextFillRect (self.currentContext, self.bounds)
        }
    }
    
    func drawNiceContents() {
        saveGState {
            let innerRect = CGRectInset(self.bounds, 20.0, 20.0)
            
            CGContextSetLineWidth (self.currentContext, 6.0);
            
            NSColor.greenColor().set()
            CGContextFillEllipseInRect (self.currentContext, innerRect);
            
            NSColor.blueColor().set()
            CGContextStrokeEllipseInRect (self.currentContext, innerRect);
        }
    }
    
    func drawNiceBorder() {
        saveGState {
            CGContextStrokeRect (self.currentContext, self.bounds);
        }
    }


    // --------------------------------------------------

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        if beSloppy {
            drawSloppily()
        } else {
            drawNicely()
        }
        
    }
    
}
