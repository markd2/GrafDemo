import Cocoa

enum ControlPoint: Int {
    case pathStart
    case firstSegment
    case secondSegment
    case pathEnd
    
    case control1
    case control2
    case radiusHandle
    
    case count

    static func allPoints() -> [ControlPoint] {
        return [.pathStart, .firstSegment, .secondSegment, .pathEnd,
                .control1, .control2, .radiusHandle]
    }
}

class ArcToPointEditingView: NSView {
    var radius: CGFloat = 0
    var control1: CGPoint = CGPoint()
    var control2: CGPoint = CGPoint()
    
    let boxSize = 4
    var trackingPoint: ControlPoint?
    var controlPoints: [CGPoint] = Array<CGPoint>(repeating: CGPoint(), count: ControlPoint.count.rawValue)


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
    
        controlPoints[ControlPoint.pathStart.rawValue] = CGPoint(x: leftX, y: midY)
        controlPoints[ControlPoint.firstSegment.rawValue] = CGPoint(x: leftX + lineLength, y: midY)
        controlPoints[ControlPoint.secondSegment.rawValue] = CGPoint(x: rightX - lineLength, y: midY)
        controlPoints[ControlPoint.pathEnd.rawValue] = CGPoint(x: rightX, y: midY)
        controlPoints[ControlPoint.control1.rawValue] = control1
        controlPoints[ControlPoint.control2.rawValue] = control2
        controlPoints[ControlPoint.radiusHandle.rawValue] = CGPoint(x: midX, y: midY - defaultRadius)
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
        
        path.move(to: controlPoints[ControlPoint.pathStart.rawValue])
        path.addLine(to: controlPoints[ControlPoint.firstSegment.rawValue])
        path.addArc(tangent1End: controlPoints[ControlPoint.control1.rawValue], tangent2End: controlPoints[ControlPoint.control2.rawValue], radius: radius)
        path.addLine(to: controlPoints[ControlPoint.secondSegment.rawValue])
        path.addLine(to: controlPoints[ControlPoint.pathEnd.rawValue])

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
        
        protectGState {
            for controlPoint in ControlPoint.allPoints() {
                let color: NSColor
                switch controlPoint {
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
                let rect = boxForPoint(controlPoints[controlPoint.rawValue])
                context.fill(rect)
            }
        }
    }

    // Need to dust off the trig book and figure out the proper places to draw
    // gray influence lines to beginning/ending angle
    func drawInfluenceLines() {
        let context = currentContext
        
        protectGState {
            NSColor.lightGray.set()
            let pattern: [CGFloat] = [2.0, 2.0]
            context.setLineDash(phase: 0.0, lengths: pattern)
            let midX = self.bounds.midX
            let midY = self.bounds.midY
            
            let radiusSegments: [CGPoint] = [CGPoint(x: midX, y: midY),
                                             controlPoints[ControlPoint.radiusHandle.rawValue]]
            context.strokeLineSegments(between: radiusSegments)
            
            let controlSegments: [CGPoint] = [controlPoints[ControlPoint.firstSegment.rawValue],
                                              controlPoints[ControlPoint.control1.rawValue],
                                              controlPoints[ControlPoint.control1.rawValue],
                                              controlPoints[ControlPoint.control2.rawValue]]
            context.strokeLineSegments(between: controlSegments)
        }
    }

    override func draw(_ rect: NSRect) {
        NSColor.white.set()
        NSRectFill(bounds)
        NSColor.black.set()
        NSFrameRect(bounds)
        
        drawInfluenceLines()
        drawPath()
        drawControlPoints()
    }
}




















