import Cocoa

let π = CGFloat(Double.pi)

enum ChunkType {
    case moveTo(point: CGPoint)
    case lineTo(point: CGPoint)
    case curveTo(point: CGPoint, control1: CGPoint, control2: CGPoint)
    case quadCurveTo(point: CGPoint, control: CGPoint)
    case close
    case arc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    case arcToPoint(control1: CGPoint, control2: CGPoint, radius: CGFloat)
    case relativeArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, deltaAngle: CGFloat)
    
    func prettyName() -> String {
        switch self {
        case .moveTo: return "Move To"
        case .lineTo: return "Line To"
        case .curveTo: return "Curve To"
        case .quadCurveTo: return "Quad Curve To"
        case .close: return "Close"
        case .arc: return "Arc"
        case .arcToPoint: return "Arc To Point"
        case .relativeArc: return "Relative Arc"
        }
    }
    
    func controlPoints() -> [CGPoint] {
        switch self {
            case .moveTo(let point): return [point]
            case .lineTo(let point): return [point]
            case .curveTo(let point, let control1, let control2): return [point, control1, control2]
            case .quadCurveTo(let point, let control): return [point, control]
            case .close: return []
            case .arc(let center, _, _, _, _): return [center]
            case .arcToPoint(let control1, let control2, _): return [control1, control2]
            case .relativeArc(let center, _, _, _): return [center]
        }
    }
    
    func controlColor() -> NSColor {
        switch self {
            case .moveTo: return NSColor.yellow
            case .lineTo: return NSColor.green
            case .curveTo: return NSColor.blue
            case .quadCurveTo: return NSColor.orange
            case .close: return NSColor.purple
            case .arc: return NSColor.red
            case .arcToPoint: return NSColor.lightGray
            case .relativeArc: return NSColor.magenta
        }
    }
    
    func appendToPath(_ path: CGMutablePath) {
        switch self {
        case .moveTo(let point):
            path.move(to: point)
            
        case .lineTo(let point):
            path.addLine(to: point)
            
        case .curveTo(let point, let control1, let control2):
            path.addCurve(to: point, control1: control1, control2: control2)
                        
        case .quadCurveTo(let point, let control):
            path.addQuadCurve(to: point, control: control)
            
        case .close:
            path.closeSubpath()
        
        case .arc(let center, let radius, let startAngle, let endAngle, let clockwise):
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            
        case .arcToPoint(let control1, let control2, let radius):
            path.addArc(tangent1End: control1, tangent2End: control2, radius: radius)

        case .relativeArc(let center, let radius, let startAngle, let deltaAngle):
            path.addRelativeArc(center: center, radius: radius, startAngle: startAngle, delta: deltaAngle)
        }
    }
    
    func chunkLikeMeButWithDifferentPoint(_ newPoint: CGPoint, atElementIndex: Int) -> ChunkType {
        switch self {
        case .moveTo:
            precondition(atElementIndex == 0)
            return .moveTo(point: newPoint)
            
        case .lineTo:
            precondition(atElementIndex == 0)
            return .lineTo(point: newPoint)
            
        case .curveTo(var point, var control1, var control2):
            precondition(atElementIndex >= 0 && atElementIndex <= 2)
            if (atElementIndex == 0) { point = newPoint }
            if (atElementIndex == 1) { control1 = newPoint }
            if (atElementIndex == 2) { control2 = newPoint }
            return .curveTo(point: point, control1: control1, control2: control2)

        case .quadCurveTo(var point, var control):
            precondition (atElementIndex == 0 || atElementIndex == 1)
            if (atElementIndex == 0) { point = newPoint }
            if (atElementIndex == 1) { control = newPoint }
            return .quadCurveTo(point: point, control: control)
            
        case .close:
            return .close
            
        case .arc(_, let radius, let startAngle, let endAngle, let clockwise):
            precondition (atElementIndex == 0)
            return .arc(center: newPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            
        case .arcToPoint(var control1, var control2, let radius):
            precondition (atElementIndex == 0 || atElementIndex == 1)
            if (atElementIndex == 0) { control1 = newPoint }
            if (atElementIndex == 1) { control2 = newPoint }
            return .arcToPoint(control1: control1, control2: control2, radius: radius)
            
        case .relativeArc(_, let radius, let startAngle, let deltaAngle):
            precondition (atElementIndex == 0)
            return .relativeArc(center: newPoint, radius: radius,
                startAngle: startAngle, deltaAngle: deltaAngle)
        }
    }
}



class PathSamplerView: NSView {
    var chunks : [ChunkType] = []  // Love ya, Brian
    fileprivate let BoxSize: CGFloat = 6.0

    fileprivate var trackingChunk: ChunkType?
    fileprivate var trackingChunkIndex: Int?
    fileprivate var trackingChunkElementIndex: Int?
    
    
    @IBAction func dumpChunks(_: AnyObject?) {
        for chunk in chunks {
            Swift.print("\(chunk.prettyName()) - \(chunk.controlPoints())")
        }
    }
    
    
    fileprivate func boxForPoint(_ point: CGPoint) -> CGRect {
        let boxxy = CGRect(x: point.x - BoxSize / 2.0,
                           y: point.y - BoxSize / 2.0,
                           width: BoxSize, height: BoxSize)
        return boxxy
    }
    
    fileprivate func drawBoxAt(_ point: CGPoint, color: NSColor) {
        let rect = boxForPoint(point);

        protectGState {
            currentContext.addRect(rect)
            color.set()
            currentContext.fillPath()
        }
    }
    
    
    fileprivate func drawBackground() {
        let rect = bounds

        protectGState {
            currentContext.addRect(rect)
            NSColor.white.set()
            currentContext.fillPath()
        }
    }
    
    
    fileprivate func drawBorder() {
        let context = currentContext
        
        protectGState {
            NSColor.black.set()
            context.stroke (bounds)
        }
    }
    
    
    func addChunk(_ chunk: ChunkType) {
        chunks.append(chunk)
        needsDisplay = true
    }
    
    
    func buildPath() -> CGMutablePath {
        let path = CGMutablePath()
        
        _ = chunks.map { $0.appendToPath(path) }
        
        return path
    }
    
    
    func drawPath() {
        let path = buildPath()
        
        protectGState {
            currentContext.addPath(path)
            currentContext.strokePath()
        }
    }
    
    func drawControlPoints() {
        for chunk in chunks {
            for controlPoint in chunk.controlPoints() {
                let color = chunk.controlColor()
                drawBoxAt(controlPoint, color: color)
            }
        }
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawBackground()
        protectGState {
            drawControlPoints()
        }
        drawPath()
        drawBorder()
    }
    
    
    fileprivate func startDrag(_ chunk: ChunkType, _ chunkIndex: Int, _ controlPointIndex: Int) {
        trackingChunk = chunk
        trackingChunkIndex = chunkIndex
        trackingChunkElementIndex = controlPointIndex
    }
    
    
    fileprivate func updateDragWithPoint(_ point: CGPoint) {
        guard let trackingChunk = trackingChunk,
            let trackingChunkElementIndex = trackingChunkElementIndex,
            let trackingChunkIndex = trackingChunkIndex else { return }
        
        let newChunk = trackingChunk.chunkLikeMeButWithDifferentPoint(point,
            atElementIndex: trackingChunkElementIndex)
        chunks[trackingChunkIndex] = newChunk
        needsDisplay = true
    }
    
    
    override func mouseDown (with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        
        for (chunkIndex, chunk) in chunks.enumerated() {
            for (controlPointIndex, controlPoint) in chunk.controlPoints().enumerated() {
                let box = boxForPoint(controlPoint).insetBy(dx: -10.0, dy: -10.0)
                if (box.contains(localPoint)) {
                    startDrag(chunk, chunkIndex, controlPointIndex)
                }
            }
        }
    }
    
    override func mouseDragged (with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        updateDragWithPoint(localPoint)
    }
    
    
    override func mouseUp (with event: NSEvent) {
        trackingChunk = nil
        trackingChunkIndex = nil
        trackingChunkElementIndex = nil
    }
    
    
    func addSamplePath() {

        addChunk(.moveTo(point: CGPoint(x: 184, y: 363)))
        addChunk(.lineTo(point: CGPoint(x: 175, y: 311)))

        addChunk(.relativeArc(center: CGPoint(x: 105, y: 280.0), radius: 25,
            startAngle: π / 2, deltaAngle: π))

        addChunk(.curveTo(point: CGPoint(x: 109, y: 100),
            control1: CGPoint(x: 121, y: 207),
            control2: CGPoint(x: 63, y: 157)))
        addChunk(.quadCurveTo(point: CGPoint(x: 219, y: 73),
            control: CGPoint(x: 157, y: 141)))

        addChunk(.lineTo(point: CGPoint(x: 273, y: 145)))
        
        addChunk(.arcToPoint(control1: CGPoint(x: 318, y: 131),
            control2: CGPoint(x:260, y: 190), radius: 40))

        addChunk(.lineTo(point: CGPoint(x: 282, y: 320)))
        
        addChunk(.arc(center: CGPoint(x: 230, y: 351), radius: 30.0, startAngle: 0.0,
            endAngle: π, clockwise: false))
        addChunk(.close)
    }
}
