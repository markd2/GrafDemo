import Cocoa

class BNRArcTypesWindowController: NSWindowController {

    @IBOutlet var arcEditingView: BNRArcEditingView!
    
    @IBOutlet var startAngleSlider: NSSlider!
    @IBOutlet var endAngleSlider: NSSlider!
    @IBOutlet var startAngleLabel: NSTextField!
    @IBOutlet var endAngleLabel: NSTextField!
    
    @IBOutlet var relativeArcEditingView: BNRRelativeArcEditingView!

    @IBOutlet var raStartAngleSlider: NSSlider!  // ra for relative angle controls
    @IBOutlet var raRelativeAngleSlider: NSSlider!
    @IBOutlet var raStartAngleLabel: NSTextField!
    @IBOutlet var raRelativeAngleLabel: NSTextField!
    
    

    override func windowDidLoad() {
        super.windowDidLoad()
        startAngleSlider.floatValue = Float(arcEditingView.startAngle)
        endAngleSlider.floatValue = Float(arcEditingView.endAngle)
        
        raStartAngleSlider.floatValue = Float(relativeArcEditingView.startAngle)
        raRelativeAngleSlider.floatValue = Float(relativeArcEditingView.deltaAngle)
        
        
        updateSliderLabels()
    }
    
    private func updateSliderLabels() {
        let startStringValue = NSString(format: "%0.2f", arcEditingView.startAngle)
        let endStringValue = NSString(format: "%0.2f", arcEditingView.endAngle)

        startAngleLabel.stringValue = String(startStringValue)
        endAngleLabel.stringValue = String(endStringValue)


        let relativeStartStringValue = NSString(format: "%0.2f", relativeArcEditingView.startAngle)
        let relativeDeltaStringValue = NSString(format: "%0.2f", relativeArcEditingView.deltaAngle)

        raStartAngleLabel.stringValue = String(relativeStartStringValue)
        raRelativeAngleLabel.stringValue = String(relativeDeltaStringValue)
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

    @IBAction func setRelativeStartAngle(slider: NSSlider) {
        relativeArcEditingView.startAngle = CGFloat(slider.floatValue)
        updateSliderLabels()
    }
    
    @IBAction func setRelativeDeltaAngle(slider: NSSlider) {
        relativeArcEditingView.deltaAngle = CGFloat(slider.floatValue)
        updateSliderLabels()
    }
}
