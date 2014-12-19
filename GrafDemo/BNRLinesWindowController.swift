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

    @IBOutlet weak var lineWidthSlider: NSSlider!
    @IBOutlet weak var miterLimitSlider: NSSlider!
    @IBOutlet weak var endCapPopUp: NSPopUpButton!
    @IBOutlet weak var lineJoinPopUp: NSPopUpButton!

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
    }
    
    public func setupContext (context: CGContext!) {
        CGContextSetLineWidth (context, CGFloat(lineWidthSlider.doubleValue))
        CGContextSetMiterLimit (context, CGFloat(miterLimitSlider.doubleValue))
        CGContextSetLineCap (context, CGLineCap(UInt32(endCapPopUp.indexOfSelectedItem)))
        CGContextSetLineJoin (context, CGLineJoin(UInt32(lineJoinPopUp.indexOfSelectedItem)))
        
        if linePhaseBox.enabled {
            let phase = CGFloat(linePhaseSlider.doubleValue)
            let lengths: Array<CGFloat> = [ dash0Slider.cgfloatValue(), space0Slider.cgfloatValue(),
                dash1Slider.cgfloatValue(), space1Slider.cgfloatValue(),
                dash2Slider.cgfloatValue(), space2Slider.cgfloatValue() ]
            
            CGContextSetLineDash (context, phase, lengths, UInt(lengths.count))
        }
        
        NSColor.redColor().set()
    }

    public override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @IBAction func changeLineWidth (sender: NSSlider) {
        println(sender.integerValue)
        linesView.needsDisplay = true
    }

    @IBAction func changeMiterLimit (sender: NSSlider) {
        println(sender.integerValue)
        linesView.needsDisplay = true
    }

 
    @IBAction func changeEndCap (sender: NSPopUpButton) {
        println(sender.indexOfSelectedItem)
        linesView.needsDisplay = true
    }
    
 
    @IBAction func changeMiterJoin (sender: NSPopUpButton) {
        println(sender.indexOfSelectedItem)
        linesView.needsDisplay = true
    }
    

    @IBAction func changePhase (sender: NSSlider) {
        println(sender.integerValue)
        linesView.needsDisplay = true
    }
    
    @IBAction func changeDash (sender: NSSlider) {
        println(sender.integerValue)
        linesView.needsDisplay = true
    }
    
    @IBAction func changeSpace (sender: NSSlider) {
        println(sender.integerValue)
        linesView.needsDisplay = true
    }
    
}
