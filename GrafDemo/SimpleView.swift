import Cocoa

class SimpleView: NSView {
    
    // Should drawing be sloppy with graphic saves and restores?
    var beSloppy : Bool = false {
        willSet {
            needsDisplay = true
        }
    }
        
    // --------------------------------------------------
    
    func drawSloppily () {
        
        CGContextSetRGBStrokeColor (currentContext, 0.0, 0.0, 0.0, 1.0) // Black
        CGContextSetRGBFillColor (currentContext, 1.0, 1.0, 1.0, 1.0) // White
        
        CGContextSetLineWidth (currentContext, 3.0)
        
        drawSloppyBackground()
        drawSloppyContents()
        drawSloppyBorder()
    }
    
    func drawSloppyBackground() {
        CGContextFillRect (currentContext, bounds)
    }
    
    func drawSloppyContents() {
        let innerRect = CGRectInset(bounds, 20.0, 20.0)
        if CGRectIsEmpty(innerRect) {
            return
        }
        
        CGContextSetRGBFillColor (currentContext, 0.0, 1.0, 0.0, 1.0) // Green
        CGContextFillEllipseInRect (currentContext, innerRect)
        
        CGContextSetRGBStrokeColor (currentContext, 0.0, 0.0, 1.0, 1.0) // Blue
        CGContextSetLineWidth (currentContext, 6.0)
        CGContextStrokeEllipseInRect (currentContext, innerRect)
    }
    
    func drawSloppyBorder() {
        CGContextStrokeRect (currentContext, self.bounds)
    }
    
    // --------------------------------------------------
    
    func drawNicely () {
        CGContextSetRGBStrokeColor (currentContext, 0.0, 0.0, 0.0, 1.0) // Black
        CGContextSetRGBFillColor (currentContext, 1.0, 1.0, 1.0, 1.0) // White
        CGContextSetLineWidth (currentContext, 3.0)
        
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
        let innerRect = CGRectInset(self.bounds, 20.0, 20.0)
        
        if CGRectIsEmpty(innerRect) {
            return
        }
        
        saveGState {
            CGContextSetRGBFillColor (self.currentContext, 0.0, 1.0, 0.0, 1.0) // Green
            CGContextFillEllipseInRect (self.currentContext, innerRect)
            
            CGContextSetRGBStrokeColor (self.currentContext, 0.0, 0.0, 1.0, 1.0) // Blue
            CGContextSetLineWidth (self.currentContext, 6.0)
            CGContextStrokeEllipseInRect (self.currentContext, innerRect)
        }
    }
    
    func drawNiceBorder() {
        saveGState {
            CGContextStrokeRect (self.currentContext, self.bounds)
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
