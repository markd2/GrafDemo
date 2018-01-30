import Cocoa

// TODO(markd, 1/31/2017) - combine this and ConvenienceView (and maybe Arc views), since
// they have handle-dragging similarities


enum ChunkViewType {  // Still love ya, Brian
    case lineTo
    case quadCurve
    case bezierCurve
}



class PathChunksView: NSView {

    var controlPoints: [CGPoint] = []
    
    var draggingIndex: Int?
    var type = ChunkViewType.bezierCurve
    
    
    func controlPointsCount() -> Int {
        // How many control points there are
        
        switch type {
        case .lineTo: return 3
        case .quadCurve: return 3
        case .bezierCurve: return 4
        }
    }
    
    func initialControlPoints() -> [CGPoint] {
        let insetBounds = bounds.insetBy(dx: 15.0, dy: 15.0)
        
        let topLeft = CGPoint(x: insetBounds.minX, y: insetBounds.minY)
        let bottomRight = CGPoint(x: insetBounds.maxX, y: insetBounds.maxY)
        let topRight = CGPoint(x: insetBounds.maxX, y: insetBounds.minY)
        let bottomLeft = CGPoint(x: insetBounds.minX, y: insetBounds.maxY)
        
        let midLeft = CGPoint(x: insetBounds.minX, y: insetBounds.midY)
        let midRight = CGPoint(x: insetBounds.maxX, y: insetBounds.midY)
        
        let midTop = CGPoint(x: insetBounds.midX, y: insetBounds.minY)
        let midBottom = CGPoint(x: insetBounds.midX, y: insetBounds.maxY)
        
        switch type {
        case .lineTo: return [ bottomLeft, midTop, bottomRight ]
        case .quadCurve: return [ topLeft, midBottom, topRight ]
        case .bezierCurve: return [ midBottom, midTop, midLeft, midRight ]
        }
    }


    fileprivate let BoxSize: CGFloat = 4.0
    
    fileprivate func boxForPoint(_ point: CGPoint) -> CGRect {
        let boxxy = CGRect(x: point.x - BoxSize / 2.0,
                           y: point.y - BoxSize / 2.0,
                           width: BoxSize, height: BoxSize)
        return boxxy
    }
    
    
    fileprivate func drawBoxAt(_ point: CGPoint, color: NSColor, filled: Bool = true) {
        let rect = boxForPoint(point);
        let context = currentContext
        
        protectGState {
            context.addEllipse(in: rect)
            color.set()
            
            if filled {
                context.fillPath()
            } else {
                context.strokePath()
            }
        }
    }
    
    
    func drawControlPoints() {
        for point in controlPoints {
            drawBoxAt(point, color: NSColor.blue)
        }
    }
    
    
    func drawShape() {
        // draw the influence lines
        let context = currentContext
        
        protectGState {
            NSColor.gray.set()
            let pattern: [CGFloat] = [ 1.0, 1.0 ]
            context.setLineDash(phase: 0.0, lengths: pattern)
            
            if type == .quadCurve {
                context.move(to: controlPoints[0])
                context.addLine(to: controlPoints[2])
                context.addLine(to: controlPoints[1])
          
                context.strokePath()
            } else if type == .bezierCurve {
                context.move(to: controlPoints[0])
                context.addLine(to: controlPoints[2])
                context.addLine(to: controlPoints[3])
                context.addLine(to: controlPoints[1])

                context.strokePath()
            }
        }
        
        
        // draw the shape
        
        protectGState {
            switch type {
            case .lineTo:
                context.move(to: controlPoints[0])
                context.addLine(to: controlPoints[1])
                context.addLine(to: controlPoints[2])
                
            case .quadCurve:
                context.move(to: controlPoints[0])
                context.addQuadCurve(to: controlPoints[1], control: controlPoints[2])
                
            case .bezierCurve:
                context.move(to: controlPoints[0])
                context.addCurve(to: controlPoints[1], 
                                 control1: controlPoints[2], control2: controlPoints[3])
            }
            
            NSColor.black.set()
            context.strokePath()
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


// Cargo-culted from ConvenienceView
extension PathChunksView {
    override func mouseDown(with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        
        for (index, point) in controlPoints.enumerated() {
            let box = boxForPoint(point).insetBy(dx: -10.0, dy: -10.0)
            
            if box.contains(localPoint) {
                draggingIndex = index
                break
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let index = draggingIndex else { return }
        
        let localPoint = convert(event.locationInWindow, from: nil)
        
        controlPoints[index] = localPoint
        needsDisplay = true
    }
    
    
    override func mouseUp(with event: NSEvent) {
        draggingIndex = nil
    }
}

