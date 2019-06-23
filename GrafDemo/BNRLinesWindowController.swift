import Cocoa

open class BNRLinesWindowController: NSWindowController {
    @IBOutlet weak var linesView: BNRLinesView!
    @IBOutlet weak var swiftLinesView: LinesView!
    
    // Line Attributes box
    @IBOutlet weak var lineWidthSlider: NSSlider!
    @IBOutlet weak var miterLimitSlider: NSSlider!
    @IBOutlet weak var endCapPopUp: NSPopUpButton!
    @IBOutlet weak var lineJoinPopUp: NSPopUpButton!
    @IBOutlet weak var renderModePopUp: NSPopUpButton!
    @IBOutlet weak var lineAlphaCheckbox : NSButton!

    // Line phase box
    @IBOutlet weak var linePhaseBox: BNRCheckboxBox!
    @IBOutlet weak var linePhaseSlider: NSSlider!
    @IBOutlet weak var dash0Slider: NSSlider!
    @IBOutlet weak var space0Slider: NSSlider!
    @IBOutlet weak var dash1Slider: NSSlider!
    @IBOutlet weak var space1Slider: NSSlider!
    @IBOutlet weak var dash2Slider: NSSlider!
    @IBOutlet weak var space2Slider: NSSlider!
    
    open override func awakeFromNib() {
        linesView.preRenderHook = {
            linesView, cgContext in
            self.setupContext(cgContext)
        }
        
        swiftLinesView.preRenderHook = {
            linesView, cgContext in
            self.setupContext(cgContext)
        }
        
        linePhaseBox.target = self
        linePhaseBox.action = #selector(BNRLinesWindowController.refreshViews(_:))
        linePhaseBox.isEnabled = false
    }
    
    // Called by the line view prior to constructing and stroking the example path
    open func setupContext(_ context: CGContext!) {
        context.setLineWidth(CGFloat(lineWidthSlider.floatValue))
        context.setMiterLimit(CGFloat(miterLimitSlider.floatValue))
        context.setLineCap(CGLineCap(rawValue: Int32(endCapPopUp.indexOfSelectedItem))!)
        context.setLineJoin(CGLineJoin(rawValue: Int32(lineJoinPopUp.indexOfSelectedItem))!)
        
        if self.lineAlphaCheckbox.state == NSControl.StateValue.on {
            NSColor.blue.withAlphaComponent(0.50).set()
        } else {
            NSColor.blue.set()
        }
        
        if linePhaseBox.isEnabled {
            let phase = CGFloat(linePhaseSlider.floatValue)
            let lengths = [
                dash0Slider.floatValue, space0Slider.floatValue,
                dash1Slider.floatValue, space1Slider.floatValue,
                dash2Slider.floatValue, space2Slider.floatValue
            ].map { CGFloat($0) }
            
            context.setLineDash(phase: phase, lengths: lengths)
        }
    }

    // A change was made to a control that affects what the render hook uses.
    // Don't care what the control was, just cause a redraw to happen.
    @IBAction func refreshViews(_ smarf: NSControl) {
        linesView.needsDisplay = true
        swiftLinesView.needsDisplay = true
    }
    
    // Two of the checkboxes actually change the lines view configuration.
    @IBAction func toggleShowLogicalPath(_ sender: NSButton) {
        linesView.showLogicalPath = (sender.state == NSControl.StateValue.on)
        swiftLinesView.showLogicalPath = (sender.state == NSControl.StateValue.on)
    }
    
    @IBAction func changeRenderMode(_ sender: NSPopUpButton) {
        linesView.renderMode = BNRLinesViewRenderMode(rawValue: sender.indexOfSelectedItem)!
        swiftLinesView.renderMode = LinesView.RenderMode(rawValue: sender.indexOfSelectedItem)!
    }
}
