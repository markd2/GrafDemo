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
        currentContext?.stroke (bounds)
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
            currentContext?.fill (bounds)
        }
    }
    
    func drawNiceContents() {
        let innerRect = bounds.insetBy(dx: 20.0, dy: 20.0)
        
        if innerRect.isEmpty {
            return
        }
        
        protectGState {
            currentContext?.setFillColor (red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) // Green
            currentContext?.fillEllipse (in: innerRect)
            
            currentContext?.setStrokeColor (red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0) // Blue
            currentContext?.setLineWidth (6.0)
            currentContext?.strokeEllipse (in: innerRect)
        }
    }
    
    func drawNiceBorder() {
        protectGState {
            currentContext?.stroke (bounds)
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
