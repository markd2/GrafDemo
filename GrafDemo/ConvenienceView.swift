import Cocoa

class ConvenienceView: NSView {

    var controlPoints: [CGPoint] = []
    
    var draggingIndex: Int?
    
    
    func auxiliaryPoints() -> [CGPoint] {
        // given the set of CGPoints, return array of points of non-interactive
        // control handles
        
        let topLeft = controlPoints[0]
        let bottomRight = controlPoints[1]

        let bottomLeft = CGPoint(x: topLeft.x, y: bottomRight.y)
        let topRight = CGPoint(x: bottomRight.x, y: topLeft.y)
        
        return [bottomLeft, topRight]
    }
    
    func controlPointsCount() -> Int {
        // How many control points there are
        return 3
    }
    
    func initialControlPoints() -> [CGPoint] {
        let insetBounds = bounds.insetBy(dx: 15.0, dy: 15.0)
        
        let topLeft = CGPoint(x: insetBounds.minX, y: insetBounds.minY)
        let bottomRight = CGPoint(x: insetBounds.maxX, y: insetBounds.maxY)
        let radius = CGPoint(x: topLeft.x + 15, y: topLeft.y + 15)
        
        return [topLeft, bottomRight, radius]
    }
    
    func drawShape() {
    
    }

    fileprivate let BoxSize: CGFloat = 10.0

    fileprivate func boxForPoint(_ point: CGPoint) -> CGRect {
        let boxxy = CGRect(x: point.x - BoxSize / 2.0,
                           y: point.y - BoxSize / 2.0,
                           width: BoxSize, height: BoxSize)
        return boxxy
    }


    fileprivate func drawBoxAt(_ point: CGPoint, color: NSColor, filled: Bool = true) {
        let rect = boxForPoint(point);
        
        protectGState {
            self.currentContext?.addRect(rect)
            color.set()
            
            if filled {
                self.currentContext?.fillPath()
            } else {
                self.currentContext?.strokePath()
            }
        }
    }


    func drawControlPoints() {
        for point in controlPoints {
            drawBoxAt(point, color: NSColor.blue)
        }
        
        for point in auxiliaryPoints() {
            drawBoxAt(point, color: NSColor.black, filled: false)
        }
    }


    override func draw(_ dirtyRect: NSRect) {
        if controlPoints.count == 0 {
            controlPoints = initialControlPoints()
        }
        super.draw(dirtyRect)
        
        NSColor.white.set()
        NSRectFill(bounds)
        
        drawControlPoints()
        drawShape()
        
        NSColor.black.set()
        NSFrameRect(bounds)
    }

    // Behave more like iOS, or most sane toolkits.
    override var isFlipped: Bool {
        return true
    }
}


extension ConvenienceView {
    override func mouseDown (with event: NSEvent) {
        let localPoint = self.convert(event.locationInWindow, from: nil)
        
        for (index, point) in controlPoints.enumerated() {
            let box = boxForPoint(point)
            if box.contains(localPoint) {
                draggingIndex = index
                break
            }
        }
    }
    
    override func mouseDragged (with event: NSEvent) {
        guard let index = draggingIndex else { return }
        
        let localPoint = self.convert(event.locationInWindow, from: nil)
        
        controlPoints[index] = localPoint
        needsDisplay = true
    }
    
    
    override func mouseUp (with event: NSEvent) {
        draggingIndex = nil
    }
}




