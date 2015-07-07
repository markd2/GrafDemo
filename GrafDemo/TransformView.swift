import Cocoa

class TransformView: NSView {

    // TODO(markd 2015-07-07) this common stuff could use a nice refactoring.
    private func drawBackground() {
        let rect = bounds

        protectGState {
            CGContextAddRect(self.currentContext, rect)
            NSColor.whiteColor().set()
            CGContextFillPath(self.currentContext)
        }
    }
    
    
    private func drawBorder() {
        let context = currentContext
        
        protectGState {
            NSColor.blackColor().set()
            CGContextStrokeRect (context, self.bounds)
        }
    }
    
    


    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        drawBackground()
        drawBorder()
    }
    
}
