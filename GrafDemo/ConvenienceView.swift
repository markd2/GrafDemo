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
    
    
    var controlRect: CGRect {
        let topLeft = controlPoints[0]
        let bottomRight = controlPoints[1]
        
        let rect = CGRect(x: topLeft.x, y: topLeft.y,
                          width: bottomRight.x - topLeft.x,
                          height: bottomRight.y - topLeft.y)
        return rect
    }
    
    var controlDistance: CGFloat {
        guard type == .roundedRect else { return 0 }

        let topLeft = controlPoints[0]
        let radiusPoint = controlPoints[2]
        
        let xdist = topLeft.x - radiusPoint.x
        let ydist = topLeft.y - radiusPoint.y
        var controlDistance = sqrt(xdist * xdist + ydist * ydist)
        
        let rect = controlRect
        
        controlDistance = min(controlDistance, rect.height / 2)
        controlDistance = min(controlDistance, rect.width / 2)

        return controlDistance
    }
    

    func drawShape() {
   
        // draw the influence lines
        protectGState {
            NSColor.gray.set()
            let pattern: [CGFloat] = [ 1.0, 1.0 ]
            currentContext.setLineDash(phase: 0.0, lengths: pattern)

            if type == .roundedRect {
                let topLeft = controlPoints[0]
                
                currentContext.move(to: topLeft)
                currentContext.addLine(to: controlPoints[2])
                
                currentContext.strokePath()
            }
            
            if type == .roundedRect || type == .oval {
                currentContext.stroke(controlRect)
            }
        }


        // draw the shape
        
        let path: CGPath
        
        switch type {
        case .rect:
            path = CGPath(rect: controlRect, transform: nil)
        case .oval:
            path = CGPath(ellipseIn: controlRect, transform: nil)
        case .roundedRect:
            path = CGPath(roundedRect: controlRect, 
                          cornerWidth: controlDistance, 
                          cornerHeight: controlDistance,
                          transform: nil)
        }

        protectGState {
            NSColor.black.set()
            currentContext.addPath(path)
            currentContext.strokePath()
        }
    }

    fileprivate func boxForPoint(_ point: CGPoint) -> CGRect {
        let BoxSize: CGFloat = 4.0
        let boxxy = CGRect(x: point.x - BoxSize / 2.0,
                           y: point.y - BoxSize / 2.0,
                           width: BoxSize, height: BoxSize)
        return boxxy
    }


    fileprivate func drawBoxAt(_ point: CGPoint, color: NSColor, filled: Bool = true) {
        let rect = boxForPoint(point);
        
        protectGState {
            color.set()
            
            if filled {
                currentContext.addEllipse(in: rect)
                currentContext.fillPath()
            } else {
                currentContext.addRect(rect)
                currentContext.strokePath()
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
        let localPoint = convert(event.locationInWindow, from: nil)
        
        for (index, point) in controlPoints.enumerated() {
            let box = boxForPoint(point).insetBy(dx: -10.0, dy: -10.0)
            if box.contains(localPoint) {
                draggingIndex = index
                break
            }
        }
    }
    
    override func mouseDragged (with event: NSEvent) {
        guard let index = draggingIndex else { return }
        
        let localPoint = convert(event.locationInWindow, from: nil)
        
        controlPoints[index] = localPoint
        needsDisplay = true
    }
    
    
    override func mouseUp (with event: NSEvent) {
        draggingIndex = nil
    }
}




