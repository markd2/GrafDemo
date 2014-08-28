//
//  SimpleView.swift
//  GrafDemo
//
//  Created by Mark Dalrymple on 8/27/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Cocoa

class SimpleView: NSView {

    var beSloppy : Bool = false {
        willSet {
            needsDisplay = true
        }
    }
    
    // --------------------------------------------------

    func drawSloppily () {
        NSColor.whiteColor().setFill()
        NSColor.blackColor().setStroke()
        NSBezierPath.setDefaultLineWidth(5.0)
        
        drawSloppyBackground()
        drawSloppyContents()
        drawSloppyBorder()
    }
    
    func drawSloppyBackground() {
        NSBezierPath(rect: bounds).fill()
    }
    
    func drawSloppyContents() {
        let innerRect = CGRectInset(bounds, 20.0, 20.0)
        let ovalPath = NSBezierPath(ovalInRect: innerRect)
        NSBezierPath.setDefaultLineWidth(1.0)
        
        NSColor.greenColor().set()
        ovalPath.fill()
        
        NSColor.blueColor().set()
        ovalPath.stroke()
    }
    
    func drawSloppyBorder() {
        NSBezierPath(rect: bounds).stroke()
    }

    // --------------------------------------------------

    func drawNicely() {
        drawNiceBackground()
        drawNiceContents()
        drawNiceBorder()
    }
    
    func drawNiceBackground() {
        NSGraphicsContext.saveGraphicsState()
        NSColor.whiteColor().setFill()
        NSRectFill(bounds)
        NSGraphicsContext.restoreGraphicsState()
    }

    func drawNiceContents() {
        NSGraphicsContext.saveGraphicsState()
        
        NSBezierPath.setDefaultLineWidth(1.0)
        
        let innerRect = CGRectInset(bounds, 20.0, 20.0)
        let ovalPath = NSBezierPath(ovalInRect: innerRect)

        NSColor.greenColor().set()
        ovalPath.fill()
        
        NSColor.blueColor().set()
        ovalPath.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }

    func drawNiceBorder() {
        NSGraphicsContext.saveGraphicsState()
        NSColor.blackColor().setStroke()
        NSBezierPath.setDefaultLineWidth(5.0)
        NSBezierPath(rect: bounds).stroke()
        NSGraphicsContext.restoreGraphicsState()
    }



    // --------------------------------------------------

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        if beSloppy {
            drawSloppily()
        } else {
            drawNicely()
        }
        
    }
    
}
