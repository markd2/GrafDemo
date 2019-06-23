import Cocoa


class ArcToPointEditingView: NSView {
    
    enum ControlPoint: Int {
        case pathStart
        case firstSegment
        case secondSegment
        case pathEnd
        
        case control1
        case control2
        case radiusHandle
        
        case count
    }
    
    var radius: CGFloat = 0
    var control1: CGPoint = CGPoint()
    var control2: CGPoint = CGPoint()
    
    let boxSize = 4
    var trackingPoint: ControlPoint?
    var controlPoints = [ControlPoint: CGPoint]()
    
    private func commonInit(withSize size: CGSize) {
        let defaultRadius: CGFloat = 25.0
        let margin: CGFloat = 5.0
        let lineLength = size.width / 3.0
        
        let midX = size.width / 2.0
        let midY = size.height / 2.0
        
        radius = defaultRadius
        control1 = CGPoint(x: 69, y: 163)
        control2 = CGPoint(x: 187, y: 61)
        
        let leftX = margin
        let rightX = size.width - margin
        
        controlPoints[.pathStart] = CGPoint(x: leftX, y: midY)
        controlPoints[.firstSegment] = CGPoint(x: leftX + lineLength, y: midY)
        controlPoints[.secondSegment] = CGPoint(x: rightX - lineLength, y: midY)
        controlPoints[.pathEnd] = CGPoint(x: rightX, y: midY)
        controlPoints[.control1] = control1
        controlPoints[.control2] = control2
        controlPoints[.radiusHandle] = CGPoint(x: midX, y: midY - defaultRadius)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        commonInit(withSize: frame.size)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(withSize: frame.size)
    }
    
    func drawPath() {
        let context = currentContext
        
        let path = CGMutablePath()
        
        path.move(to: controlPoints[.pathStart]!)
        path.addLine(to: controlPoints[.firstSegment]!)
        path.addArc(tangent1End: controlPoints[.control1]!,
                    tangent2End: controlPoints[.control2]!,
                    radius: radius)
        path.addLine(to: controlPoints[.secondSegment]!)
        path.addLine(to: controlPoints[.pathEnd]!)
        
        context.addPath(path)
        context.strokePath()
    }
    
    fileprivate func boxForPoint(_ point: CGPoint) -> CGRect {
        let BoxSize: CGFloat = 4.0
        let boxxy = CGRect(x: point.x - BoxSize / 2.0,
                           y: point.y - BoxSize / 2.0,
                           width: BoxSize, height: BoxSize)
        return boxxy
    }
    
    func drawControlPoints() {
        let context = currentContext
        
        context.protectGState {
            for (type, point) in controlPoints {
                let color: NSColor
                switch type {
                case .pathStart, .firstSegment, .secondSegment, .pathEnd:
                    color = NSColor.blue
                case .control1, .control2: 
                    color = NSColor.gray
                case .radiusHandle:
                    color = NSColor.orange
                default:
                    color = NSColor.magenta // it's a Magenta Alert
                }
                color.set()
                context.fill(boxForPoint(point))
            }
        }
    }
    
    // Need to dust off the trig book and figure out the proper places to draw
    // gray influence lines to beginning/ending angle
    func drawInfluenceLines() {
        let context = currentContext
        
        context.protectGState {
            NSColor.lightGray.set()
            let pattern: [CGFloat] = [2.0, 2.0]
            context.setLineDash(phase: 0.0, lengths: pattern)
            let midX = self.bounds.midX
            let midY = self.bounds.midY
            
            let radiusSegments: [CGPoint] = [CGPoint(x: midX, y: midY),
                                             controlPoints[.radiusHandle]!]
            context.strokeLineSegments(between: radiusSegments)
            
            let controlSegments: [CGPoint] = [controlPoints[.firstSegment]!,
                                              controlPoints[.control1]!,
                                              controlPoints[.control1]!,
                                              controlPoints[.control2]!]
            context.strokeLineSegments(between: controlSegments)
        }
    }
    
    override func draw(_ rect: NSRect) {
        NSColor.white.set()
        bounds.fill()
        NSColor.black.set()
        bounds.frame()
        
        drawInfluenceLines()
        drawPath()
        drawControlPoints()
    }
    
    override func mouseDown(with event: NSEvent) {
        trackingPoint = nil
        
        let localPoint = convert(event.locationInWindow, from: nil)
        
        for (type, point) in controlPoints {
            let box = boxForPoint(point).insetBy(dx: -10, dy: -10)
            
            if box.contains(localPoint) {
                trackingPoint = type
                break
            }
        }
    }
    
    private func dragTo(point: CGPoint) {
        guard let trackingIndex = trackingPoint else {
            return
        }
        
        if trackingIndex == .radiusHandle {
            let midX = bounds.midX
            let midY = bounds.midY
            radius = CGFloat(hypot(Double(midX - point.x), Double(midY - point.y)))
        }
        
        controlPoints[trackingIndex] = point
        
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        dragTo(point: localPoint)
    }
    
    override func mouseUp(with event: NSEvent) {
        trackingPoint = nil
    }
    
}




















