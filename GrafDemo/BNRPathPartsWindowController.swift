import Cocoa

class BNRPathPartsWindowController: NSWindowController {
    @IBOutlet var rectView: ConvenienceView!
    @IBOutlet var ovalView: ConvenienceView!
    @IBOutlet var roundedRectView: ConvenienceView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        rectView.type = .rect
        ovalView.type = .oval
        roundedRectView.type = .roundedRect
    }
    
}
