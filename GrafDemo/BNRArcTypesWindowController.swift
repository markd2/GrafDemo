import Cocoa

class BNRArcTypesWindowController: NSWindowController {

    @IBOutlet var arcEditingView: BNRArcEditingView!
    @IBOutlet var startAngleSlider: NSSlider!
    @IBOutlet var endAngleSlider: NSSlider!
    @IBOutlet var startAngleLabel: NSTextField!
    @IBOutlet var endAngleLabel: NSTextField!

    override func windowDidLoad() {
        super.windowDidLoad()
        startAngleSlider.floatValue = Float(arcEditingView.startAngle)
        endAngleSlider.floatValue = Float(arcEditingView.endAngle)
        updateSliderLabels()
    }
    
    private func updateSliderLabels() {
        let startStringValue = NSString(format: "%0.2f", arcEditingView.startAngle)
        let endStringValue = NSString(format: "%0.2f", arcEditingView.endAngle)

        startAngleLabel.stringValue = String(startStringValue)
        endAngleLabel.stringValue = String(endStringValue)
    }
    
    @IBAction func toggleArcClockwise(toggle: NSButton) {
        arcEditingView.clockwise = toggle.state == NSOnState
    }
    
    
    @IBAction func setStartAngle(slider: NSSlider) {
        arcEditingView.startAngle = CGFloat(slider.floatValue)
        updateSliderLabels()
    }
    
    @IBAction func setEndAngle(slider: NSSlider) {
        arcEditingView.endAngle = CGFloat(slider.floatValue)
        updateSliderLabels()
    }
}
