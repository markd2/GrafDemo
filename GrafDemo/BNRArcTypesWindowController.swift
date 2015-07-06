import Cocoa

class BNRArcTypesWindowController: NSWindowController {

    @IBOutlet var arcEditingView: BNRArcEditingView!
    @IBOutlet var startAngleSlider: NSSlider!
    @IBOutlet var endAngleSlider: NSSlider!

    override func windowDidLoad() {
        super.windowDidLoad()
        startAngleSlider.floatValue = Float(arcEditingView.startAngle)
        endAngleSlider.floatValue = Float(arcEditingView.endAngle)
    }
    
    @IBAction func toggleArcClockwise(toggle: NSButton) {
        arcEditingView.clockwise = toggle.state == NSOnState
    }
    
    
    @IBAction func setStartAngle(slider: NSSlider) {
        arcEditingView.startAngle = CGFloat(slider.floatValue)
    }
    
    @IBAction func setEndAngle(slider: NSSlider) {
        arcEditingView.endAngle = CGFloat(slider.floatValue)
    }
}
