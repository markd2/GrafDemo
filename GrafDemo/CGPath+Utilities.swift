import Cocoa

private typealias CGPathDumpUtility = CGPath
extension CGPathDumpUtility {

    func dump() {
        self.apply(info: nil) { info, unsafeElement in
            let element = unsafeElement.pointee
            let points = element.points.pointee
            
            switch element.type {
            case .moveToPoint:
                print("moveto - \(points)")
            case .addLineToPoint:
                print("lineto - \(points)")
            case .addQuadCurveToPoint:
                print("quadCurveTo - \(points)")
            case .addCurveToPoint:
                print("curveTo - \(points)")
            case .closeSubpath:
                print("close - \(points)")
            }
        }
    }
    
}
