import Cocoa


enum ChunkType {
    case MoveTo(point: CGPoint)
    case LineTo(point: CGPoint)
    case CurveTo(point: CGPoint, control1: CGPoint, control2: CGPoint)
    case QuadCurveTo(point: CGPoint, control: CGPoint)
    case Close
    case Arc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    case ArcToPoint(control1: CGPoint, control2: CGPoint, radius: CGFloat)
    case RelativeArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, deltaAngle: CGFloat)
    
    func prettyName() -> String {
        switch self {
        case .MoveTo: return "Move To"
        case .LineTo: return "Line To"
        case .CurveTo: return "Curve To"
        case .QuadCurveTo: return "Quad Curve To"
        case .Close: return "Close"
        case .Arc: return "Arc"
        case .ArcToPoint: return "Arc To Point"
        case .RelativeArc: return "Relative Arc"
        }
    }
    
    func controlPoints() -> [CGPoint] {
        switch self {
            case .MoveTo(let point): return [point]
            case .LineTo(let point): return [point]
            case .CurveTo(let point, let control1, let control2): return [point, control1, control2]
            case .QuadCurveTo(let point, let control): return [point, control]
            case .Close: return []
            case .Arc(let center, _, _, _, _): return [center]
            case .ArcToPoint(let control1, let control2, _): return [control1, control2]
            case .RelativeArc(let center, _, _, _): return [center]
        }
    }
    
    func controlColor() -> NSColor {
        switch self {
            case .MoveTo: return NSColor.yellowColor()
            case .LineTo: return NSColor.greenColor()
            case .CurveTo: return NSColor.blueColor()
            case .QuadCurveTo: return NSColor.orangeColor()
            case .Close: return NSColor.purpleColor()
            case .Arc: return NSColor.redColor()
            case .ArcToPoint: return NSColor.lightGrayColor()
            case .RelativeArc: return NSColor.magentaColor()
        }
    }
    
    func appendToPath(path: CGMutablePath) {
        switch self {
        case .MoveTo(let point):
            CGPathMoveToPoint(path, nil, point.x, point.y)
            
        case .LineTo(let point):
            CGPathAddLineToPoint(path, nil, point.x, point.y)
            
        case .CurveTo(let point, let control1, let control2):
            CGPathAddCurveToPoint(path, nil, control1.x, control1.y, control2.x, control2.y, point.x, point.y)
            
        case .QuadCurveTo(let point, let control):
            CGPathAddQuadCurveToPoint(path, nil, control.x, control.y, point.x, point.y)
            
        case .Close:
            CGPathCloseSubpath(path)
        
        case .Arc(let center, let radius, let startAngle, let endAngle, let clockwise):
            CGPathAddArc(path, nil, center.x, center.y, radius, startAngle, endAngle, clockwise)
            
        case ArcToPoint(let control1, let control2, let radius):
            CGPathAddArcToPoint(path, nil, control1.x, control1.y, control2.x, control2.y, radius)

        case RelativeArc(let center, let radius, let startAngle, let deltaAngle):
            CGPathAddRelativeArc(path, nil, center.x, center.y, radius, startAngle, deltaAngle)
        }
    }
    
    func chunkLikeMeButWithDifferentPoint(newPoint: CGPoint, atElementIndex: Int) -> ChunkType {
        switch self {
        case .MoveTo:
            precondition(atElementIndex == 0)
            return .MoveTo(point: newPoint)
            
        case .LineTo:
            precondition(atElementIndex == 0)
            return .LineTo(point: newPoint)
            
        case .CurveTo(var point, var control1, var control2):
            precondition(atElementIndex >= 0 && atElementIndex <= 2)
            if (atElementIndex == 0) { point = newPoint }
            if (atElementIndex == 1) { control1 = newPoint }
            if (atElementIndex == 2) { control2 = newPoint }
            return .CurveTo(point: point, control1: control1, control2: control2)

        case .QuadCurveTo(var point, var control):
            precondition (atElementIndex == 0 || atElementIndex == 1)
            if (atElementIndex == 0) { point = newPoint }
            if (atElementIndex == 1) { control = newPoint }
            return .QuadCurveTo(point: point, control: control)
            
        case .Close:
            return .Close
            
        case .Arc(_, let radius, let startAngle, let endAngle, let clockwise):
            precondition (atElementIndex == 0)
            return .Arc(center: newPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            
        case .ArcToPoint(var control1, var control2, let radius):
            precondition (atElementIndex == 0 || atElementIndex == 1)
            if (atElementIndex == 0) { control1 = newPoint }
            if (atElementIndex == 1) { control2 = newPoint }
            return .ArcToPoint(control1: control1, control2: control2, radius: radius)
            
        case .RelativeArc(_, let radius, let startAngle, let deltaAngle):
            precondition (atElementIndex == 0)
            return .RelativeArc(center: newPoint, radius: radius,
                startAngle: startAngle, deltaAngle: deltaAngle)
        }
    }
}



class PathSamplerView: NSView {
    var chunks : [ChunkType] = []  // Love ya, Brian
    private let BoxSize: CGFloat = 10.0

    private var trackingChunk: ChunkType?
    private var trackingChunkIndex: Int?
    private var trackingChunkElementIndex: Int?
    
    
    @IBAction func dumpChunks(_: AnyObject?) {
        for chunk in chunks {
            Swift.print("\(chunk.prettyName()) - \(chunk.controlPoints())")
        }
    }
    

    private func boxForPoint(point: CGPoint) -> CGRect {
        let boxxy = CGRect(x: point.x - BoxSize / 2.0,
            y: point.y - BoxSize / 2.0,
            width: BoxSize, height: BoxSize)
        return boxxy
    }
    
    private func drawBoxAt(point: CGPoint, color: NSColor) {
        let rect = boxForPoint(point);
        
        protectGState {
            CGContextAddRect(self.currentContext, rect)
            color.set()
            CGContextFillPath(self.currentContext)
        }
    }
    
    
    private func drawBackground() {
        let rect = bounds

        protectGState {
            CGContextAddRect(self.currentContext, rect)
            NSColor.whiteColor().set()
            CGContextFillPath(self.currentContext)
        }
    }
    
    
    func addChunk(chunk: ChunkType) {
        chunks.append(chunk)
        needsDisplay = true
    }
    
    
    func buildPath() -> CGMutablePath {
        let path = CGPathCreateMutable()
        
        chunks.map { $0.appendToPath(path) }

        return path
    }
    

    func drawPath() {
         let path = buildPath()
        
        protectGState {
            CGContextAddPath(self.currentContext, path)
            CGContextStrokePath(self.currentContext)
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
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        drawBackground()
        protectGState {
            self.drawControlPoints()
        }
        drawPath()
    }
    
    
    private func startDrag(chunk: ChunkType, _ chunkIndex: Int, _ controlPointIndex: Int) {
        trackingChunk = chunk
        trackingChunkIndex = chunkIndex
        trackingChunkElementIndex = controlPointIndex
    }
    
    
    private func updateDragWithPoint(point: CGPoint) {
        guard let trackingChunk = self.trackingChunk,
            let trackingChunkElementIndex = self.trackingChunkElementIndex,
            let trackingChunkIndex = self.trackingChunkIndex else { return }
        
        let newChunk = trackingChunk.chunkLikeMeButWithDifferentPoint(point,
            atElementIndex: trackingChunkElementIndex)
        chunks[trackingChunkIndex] = newChunk
        self.needsDisplay = true
    }
    
    
    override func mouseDown (event: NSEvent) {
        let localPoint = self.convertPoint(event.locationInWindow, fromView: nil)
        
        for (chunkIndex, chunk) in chunks.enumerate() {
            for (controlPointIndex, controlPoint) in chunk.controlPoints().enumerate() {
                let box = boxForPoint(controlPoint)
                if (CGRectContainsPoint(box, localPoint)) {
                    startDrag(chunk, chunkIndex, controlPointIndex)
                }
            }
        }
    }
    
    override func mouseDragged (event: NSEvent) {
        let localPoint = self.convertPoint(event.locationInWindow, fromView: nil)
        updateDragWithPoint(localPoint)
    }
    
    
    override func mouseUp (event: NSEvent) {
        trackingChunk = nil
        trackingChunkIndex = nil
        trackingChunkElementIndex = nil
    }
    
    
    func addSamplePath() {
        let π = CGFloat(Darwin.M_PI)

        addChunk(.MoveTo(point: CGPoint(x: 134, y: 313)))
        addChunk(.LineTo(point: CGPoint(x: 125, y: 261)))

        addChunk(.RelativeArc(center: CGPoint(x: 55, y: 230.0), radius: 25,
            startAngle: π / 2, deltaAngle: π))

        addChunk(.CurveTo(point: CGPoint(x: 59, y: 50),
            control1: CGPoint(x: 71, y: 157),
            control2: CGPoint(x: 13, y: 107)))
        addChunk(.QuadCurveTo(point: CGPoint(x: 169, y: 23),
            control: CGPoint(x: 107, y: 91)))

        addChunk(.LineTo(point: CGPoint(x: 223, y: 95)))
        
        addChunk(.ArcToPoint(control1: CGPoint(x: 268, y: 81),
            control2: CGPoint(x:210, y: 140), radius: 40))

        addChunk(.LineTo(point: CGPoint(x: 232, y: 270)))
        
        addChunk(.Arc(center: CGPoint(x: 180, y: 301), radius: 30.0, startAngle: 0.0,
            endAngle: π, clockwise: false))
        addChunk(.Close)
    }
}
