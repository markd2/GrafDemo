import Cocoa

class BNRPathPartsWindowController: NSWindowController {
    @IBOutlet var rectView: ConvenienceView!
    @IBOutlet var ovalView: ConvenienceView!
    @IBOutlet var roundedRectView: ConvenienceView!
    
    @IBOutlet var lineToView: PathChunksView!
    @IBOutlet var quadCurveView: PathChunksView!
    @IBOutlet var bezierCurveView: PathChunksView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        rectView.type = .rect
        ovalView.type = .oval
        roundedRectView.type = .roundedRect
        
        lineToView.type = .lineTo
        quadCurveView.type = .quadCurve
        bezierCurveView.type = .bezierCurve
    }
    
}
