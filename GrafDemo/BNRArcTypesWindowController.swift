import Cocoa

class BNRArcTypesWindowController: NSWindowController {

    @IBOutlet var arcEditingView: BNRArcEditingView!

    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
    @IBAction func toggleArcClockwise(toggle: NSButton) {
        self.arcEditingView.clockwise = toggle.state == NSOnState
    }
    
}
