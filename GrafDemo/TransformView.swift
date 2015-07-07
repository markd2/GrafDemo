import Cocoa

class TransformView: NSView {

    private let kBig:CGFloat = 1000

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
    
    private func drawGridLinesWithStride(stride: CGFloat, withLabels: Bool, context: CGContextRef) {
        let font = NSFont.systemFontOfSize(10.0)

        let darkGray = NSColor.darkGrayColor().colorWithAlphaComponent(0.3)

        let textAttributes: [String : AnyObject] = [ NSFontAttributeName : font,
            NSForegroundColorAttributeName: darkGray]
        
        // draw vertical lines
        for var x = CGRectGetMinX(bounds) - kBig; x < kBig; x += stride {
            let start = CGPoint(x: x + 0.25, y: -kBig)
            let end = CGPoint(x: x + 0.25, y: kBig )
            CGContextMoveToPoint (context, start.x, start.y)
            CGContextAddLineToPoint (context, end.x, end.y)
            CGContextStrokePath (context)
            
            if (withLabels) {
                var textOrigin = CGPoint(x: x + 0.25, y: CGRectGetMinY(bounds) + 0.25)
                textOrigin.x += 2.0
                let label = NSString(format: "%d", Int(x))
                label.drawAtPoint(textOrigin,  withAttributes: textAttributes)
            }
        }
        
        // draw horizontal lines
        for var y = CGRectGetMinY(bounds) - kBig; y < kBig; y += stride {
            let start = CGPoint(x: -kBig, y: y + 0.25)
            let end = CGPoint(x: kBig, y: y + 0.25)
            CGContextMoveToPoint (context, start.x, start.y)
            CGContextAddLineToPoint (context, end.x, end.y)
            CGContextStrokePath (context)
            
            if (withLabels) {
                var textOrigin = CGPoint(x: CGRectGetMinX(bounds) + 0.25, y: y + 0.25)
                textOrigin.x += 3.0
                
                let label = NSString(format: "%d", Int(y))
                label.drawAtPoint(textOrigin,  withAttributes: textAttributes)
            }
        }
        
    }
    
    private func drawGrid() {
        let context = currentContext!
        
        protectGState {
            CGContextSetLineWidth (context, 0.5)
            
            let lightGray = NSColor.lightGrayColor().colorWithAlphaComponent(0.3)
            let darkGray = NSColor.darkGrayColor().colorWithAlphaComponent(0.3)

            
            // Light grid lines every 10 points
            lightGray.setStroke()
            self.drawGridLinesWithStride(10, withLabels: false, context: context)
            
            // darker gray lines every 100 points
            darkGray.setStroke()
            self.drawGridLinesWithStride(100, withLabels: true, context: context)
            
            // black lines on cartesian axes
            // P.S. "AND MY AXE" -- Gimli
            let bounds = self.bounds
            
            let start = CGPoint (x: CGRectGetMinX(bounds) + 0.25, y: CGRectGetMinY(bounds))
            let horizontalEnd = CGPoint (x: CGRectGetMaxX(bounds) + 0.25, y: CGRectGetMinY(bounds))
            let verticalEnd = CGPoint (x: CGRectGetMinX(bounds) + 0.25, y: CGRectGetMaxY(bounds))
            
            CGContextSetLineWidth (context, 2.0)
            NSColor.blackColor().setStroke()
            CGContextMoveToPoint (context, -self.kBig, start.y)
            CGContextAddLineToPoint (context, self.kBig, horizontalEnd.y)
            
            CGContextMoveToPoint (context, start.x, -self.kBig)
            CGContextAddLineToPoint (context, verticalEnd.x, self.kBig)
            
            CGContextStrokePath (context)
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        drawBackground()
        drawGrid()
        drawBorder()
    }
    
    override var flipped : Bool{
        return true
    }
}
