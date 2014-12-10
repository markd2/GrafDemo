//
//  BNRLinesWindowController.swift
//  GrafDemo
//
//  Created by Mark Dalrymple on 12/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Cocoa

public class BNRLinesWindowController: NSWindowController {

    @IBOutlet weak var lineWidthlider: NSSlider!
    @IBOutlet weak var miterLimitSlider: NSSlider!
    @IBOutlet weak var endCapPopUp: NSPopUpButton!
    @IBOutlet weak var miterLimitPopUp: NSPopUpButton!

    @IBOutlet weak var linePhaseBox: BNRCheckboxBox!
    @IBOutlet weak var linePhaseSlider: NSSlider!
    @IBOutlet weak var dash0Slider: NSSlider!
    @IBOutlet weak var space0Slider: NSSlider!
    @IBOutlet weak var dash1Slider: NSSlider!
    @IBOutlet weak var space1Slider: NSSlider!
    @IBOutlet weak var dash2Slider: NSSlider!
    @IBOutlet weak var space2Slider: NSSlider!

    public override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @IBAction func changeLineWidth (sender: NSSlider) {
        println(sender.integerValue)
    }

    @IBAction func changeMiterLimit (sender: NSSlider) {
        println(sender.integerValue)
    }

 
    @IBAction func changeEndCap (sender: NSPopUpButton) {
        println(sender.indexOfSelectedItem)
    }
    
 
    @IBAction func changeMiterJoin (sender: NSPopUpButton) {
        println(sender.indexOfSelectedItem)
    }
    

    @IBAction func changePhase (sender: NSSlider) {
        println(sender.integerValue)
    }
    
    @IBAction func changeDash (sender: NSSlider) {
        println(sender.integerValue)
    }
    
    @IBAction func changeSpace (sender: NSSlider) {
        println(sender.integerValue)
    }
    
}
