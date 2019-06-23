import Cocoa


class ArcEditingView: NSView {
    enum ControlPoint: Int {
        case pathStart
        case firstSegment
        case secondSegment
        case pathEnd
        
        case arcCenter
        case radiusHandle
        
        case count
    }
    
    @objc var radius: CGFloat {
        let center = controlPoints[.arcCenter]!
        let radiusHandle = controlPoints[.radiusHandle]!
        return CGFloat(hypot(Double(center.x - radiusHandle.x),
                             Double(center.y - radiusHandle.y)))
    }
    
    @objc var center: CGPoint {
        return controlPoints[.arcCenter]!
    }
    
    
    @objc var startAngle: CGFloat = 0 {
        didSet {
            needsDisplay = true
        }
    }
    @objc var endAngle: CGFloat = 0 {
        didSet {
            needsDisplay = true
        }
    }
    @objc var clockwise: Bool = true  {
        didSet {
            needsDisplay = true
        }
    }
    
    let boxSize = 4
    var trackingPoint: ControlPoint?
    var controlPoints = [ControlPoint: CGPoint]()
    
    private func commonInit(withSize size: CGSize) {
        let defaultRadius: CGFloat = 25.0
        let margin: CGFloat = 5.0
        let lineLength = size.width / 3.0
        
        startAngle = 3 * (π / 4.0)
        endAngle = π / 4.0
        clockwise = true
        
        let midX = size.width / 2.0
        let midY = size.height / 2.0
        
        let leftX = margin
        let rightX = size.width - margin
        
        controlPoints[.pathStart] = CGPoint(x: leftX, y: midY)
        controlPoints[.firstSegment] = CGPoint(x: leftX + lineLength,
                                               y: midY)
        controlPoints[.secondSegment] = CGPoint(x: rightX - lineLength,
                                                y: midY)
        controlPoints[.pathEnd] = CGPoint(x: rightX, y: midY)
        controlPoints[.arcCenter] = CGPoint(x: midX, y: midY)
        controlPoints[.radiusHandle] = CGPoint(x: midX, 
                                               y: midY - defaultRadius)
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
        path.addArc(center: controlPoints[.arcCenter]!,
                    radius: radius, 
                    startAngle: startAngle, 
                    endAngle: endAngle,
                    clockwise: clockwise)
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
                case .arcCenter:
                    color = NSColor.red
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
        
        let influenceOverspill: CGFloat = 20.0 // how many points beyond the circle
        
        context.protectGState {
            NSColor.lightGray.set()
            let pattern: [CGFloat] = [2.0, 2.0]
            context.setLineDash(phase: 0.0, lengths: pattern)
            
            let radius = Double(self.radius + influenceOverspill)
            
            let startAngleDouble = Double(startAngle) // I love you Swift.
            let endAngleDouble = Double(endAngle)
            
            let startAnglePoint = CGPoint(x: center.x + CGFloat(radius * cos(startAngleDouble)),
                                          y: center.y + CGFloat(radius * sin(startAngleDouble)))
            let endAnglePoint = CGPoint(x: center.x + CGFloat(radius * cos(endAngleDouble)),
                                        y: center.y + CGFloat(radius * sin(endAngleDouble)))
            
            let startAngleSegments = [center, startAnglePoint]
            let endAngleSegments = [center, endAnglePoint]
            
            context.strokeLineSegments(between: startAngleSegments)
            context.strokeLineSegments(between: endAngleSegments)
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




















