import Cocoa

enum ConvenienceType {
    case rect
    case oval
    case roundedRect
}


class ConvenienceView: NSView {

    var controlPoints: [CGPoint] = []
    
    var draggingIndex: Int?
    var type = ConvenienceType.rect
    
    
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
        return type == .roundedRect ? 3 : 2
    }
    
    func initialControlPoints() -> [CGPoint] {
        let insetBounds = bounds.insetBy(dx: 15.0, dy: 15.0)
        
        let topLeft = CGPoint(x: insetBounds.minX, y: insetBounds.minY)
        let bottomRight = CGPoint(x: insetBounds.maxX, y: insetBounds.maxY)
        
        if type == .roundedRect {
            let radius = CGPoint(x: topLeft.x + 15, y: topLeft.y + 15)
            return [topLeft, bottomRight, radius]
        } else {
            return [topLeft, bottomRight]
        }
    }
    

    func drawShape() {
        let topLeft = controlPoints[0]
        let bottomRight = controlPoints[1]
        
        let rect = CGRect(x: topLeft.x, y: topLeft.y,
                          width: bottomRight.x - topLeft.x,
                          height: bottomRight.y - topLeft.y)
   
        protectGState {
            // draw the influence lines
            NSColor.gray.set()
            let pattern: [CGFloat] = [ 1.0, 1.0 ]
            self.currentContext?.setLineDash(phase: 0.0, lengths: pattern)

            if type == .roundedRect {
                self.currentContext?.move(to: topLeft)
                self.currentContext?.addLine(to: controlPoints[2])
                currentContext?.strokePath()
            }

            if type == .roundedRect || type == .oval {
                currentContext?.stroke(rect)
            }
        }


        // draw the shape
        
        let path: CGPath
        
        switch type {
        case .rect:
            path = CGPath.init(rect: rect, transform: nil)
        case .oval:
            path = CGPath.init(ellipseIn: rect, transform: nil)
        case .roundedRect:
            let radiusPoint = controlPoints[2]
            let xdist = topLeft.x - radiusPoint.x
            let ydist = topLeft.y - radiusPoint.y
            var controlDistance = sqrt(xdist * xdist + ydist * ydist)
            controlDistance = min(controlDistance, rect.height / 2)
            controlDistance = min(controlDistance, rect.width / 2)

            path = CGPath.init(roundedRect: rect, 
                               cornerWidth: controlDistance, 
                               cornerHeight: controlDistance,
                               transform: nil)
        }
        NSColor.black.set()
        currentContext?.addPath(path)
        currentContext?.strokePath()
        
    }

    fileprivate let BoxSize: CGFloat = 8.0

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
        
        drawShape()
        drawControlPoints()
        
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




