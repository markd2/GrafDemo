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
        
        currentContext?.setStrokeColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black
        currentContext?.setFillColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White
        
        currentContext?.setLineWidth (3.0)
        
        drawSloppyBackground()
        drawSloppyContents()
        drawSloppyBorder()
    }
    
    func drawSloppyBackground() {
        currentContext?.fill (bounds)
    }
    
    func drawSloppyContents() {
        let innerRect = bounds.insetBy(dx: 20.0, dy: 20.0)
        if innerRect.isEmpty {
            return
        }
        
        currentContext?.setFillColor (red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) // Green
        currentContext?.fillEllipse (in: innerRect)
        
        currentContext?.setStrokeColor (red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0) // Blue
        currentContext?.setLineWidth (6.0)
        currentContext?.strokeEllipse (in: innerRect)
    }
    
    func drawSloppyBorder() {
        currentContext?.stroke (self.bounds)
    }
    
    // --------------------------------------------------
    
    func drawNicely () {
        currentContext?.setStrokeColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black
        currentContext?.setFillColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White
        currentContext?.setLineWidth (3.0)
        
        drawNiceBackground()
        drawNiceContents()
        drawNiceBorder()
    }
    
    func drawNiceBackground() {
        protectGState {
            self.currentContext?.fill (self.bounds)
        }
    }
    
    func drawNiceContents() {
        let innerRect = self.bounds.insetBy(dx: 20.0, dy: 20.0)
        
        if innerRect.isEmpty {
            return
        }
        
        protectGState {
            self.currentContext?.setFillColor (red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) // Green
            self.currentContext?.fillEllipse (in: innerRect)
            
            self.currentContext?.setStrokeColor (red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0) // Blue
            self.currentContext?.setLineWidth (6.0)
            self.currentContext?.strokeEllipse (in: innerRect)
        }
    }
    
    func drawNiceBorder() {
        protectGState {
            self.currentContext?.stroke (self.bounds)
        }
    }
    
    
    // --------------------------------------------------
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if beSloppy {
            drawSloppily()
        } else {
            drawNicely()
        }
        
    }
    
}
