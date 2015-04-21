//
//  BNRLinesWindowController.swift
//  GrafDemo
//
//  Created by Mark Dalrymple on 12/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Cocoa

extension NSSlider {
    func cgfloatValue() -> CGFloat {
        return CGFloat(self.doubleValue)
    }
}

public class BNRLinesWindowController: NSWindowController {
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
    
    public override func awakeFromNib() {
        linesView.preRenderHook = {
            linesView, cgContext in
            self.setupContext(cgContext)
        }
        
        swiftLinesView.preRenderHook = {
            linesView, cgContext in
            self.setupContext(cgContext)
        }
        
        linePhaseBox.target = self
        linePhaseBox.action = "refreshViews:"
        linePhaseBox.enabled = false
    }
    
    // Called by the line view prior to constructing and stroking the example path
    public func setupContext (context: CGContext!) {
        CGContextSetLineWidth (context, lineWidthSlider.cgfloatValue())
        CGContextSetMiterLimit (context, miterLimitSlider.cgfloatValue())
        CGContextSetLineCap (context, CGLineCap(UInt32(endCapPopUp.indexOfSelectedItem)))
        CGContextSetLineJoin (context, CGLineJoin(UInt32(lineJoinPopUp.indexOfSelectedItem)))
        
        if self.lineAlphaCheckbox.state == NSOnState {
            NSColor.blueColor().colorWithAlphaComponent(0.50).set()
        } else {
            NSColor.blueColor().set()
        }
        
        if linePhaseBox.enabled {
            let phase = linePhaseSlider.cgfloatValue()
            let lengths: [CGFloat] = [
                dash0Slider.cgfloatValue(), space0Slider.cgfloatValue(),
                dash1Slider.cgfloatValue(), space1Slider.cgfloatValue(),
                dash2Slider.cgfloatValue(), space2Slider.cgfloatValue()
            ]
            
            CGContextSetLineDash (context, phase, lengths, lengths.count)
        }
    }

    // A change was made to a control that affects what the render hook uses.
    // Don't care what the control was, just cause a redraw to happen.
    @IBAction func refreshViews(smarf: NSControl) {
        linesView.needsDisplay = true
        swiftLinesView.needsDisplay = true
    }
    
    // Two of the checkboxes actually change the lines view configuration.
    @IBAction func toggleShowLogicalPath (sender: NSButton) {
        linesView.showLogicalPath = (sender.state == NSOnState)
        swiftLinesView.showLogicalPath = (sender.state == NSOnState)
    }
    
    @IBAction func changeRenderMode (sender: NSPopUpButton) {
        linesView.renderMode = BNRLinesViewRenderMode(rawValue: sender.indexOfSelectedItem)!
        swiftLinesView.renderMode = LinesView.RenderMode(rawValue: sender.indexOfSelectedItem)!
    }
}
