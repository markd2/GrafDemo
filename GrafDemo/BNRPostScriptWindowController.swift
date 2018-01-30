//
//  BNRPostScriptWindowController.swift
//  GrafDemo
//
//  Created by Mark Dalrymple on 7/6/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import Cocoa

let initialText = "" +
"/ComicSansMS findfont\n" +
"40 scalefont\n" +
"setfont\n" +
"\n" +
"20 50 translate\n" +
"30 rotate\n" +
"2.5 1 scale\n" +
"\n" +
"newpath\n" +
"0 0 moveto\n" +
"(Bork) true charpath\n" +
"0.9 setgray\n" +
"fill\n" +
"\n" +
"newpath\n" +
"0 0 moveto\n" +
"(Bork) true charpath\n" +
"0.3 setgray\n" +
"1 setlinewidth\n" +
"stroke\n"



class BNRPostScriptWindowController: NSWindowController {
    
    @IBOutlet var codeText : NSTextView!
    @IBOutlet var pdfView : PDFView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.codeText.string = initialText
    }
    
    @IBAction func draw(_: AnyObject) {
        var callbacks = CGPSConverterCallbacks()
        guard let converter = CGPSConverter(info: nil, callbacks: &callbacks, options: nil) else {
            return
        }
        
        guard let codeData = self.codeText.string?.data(using: .utf8),
            let provider = CGDataProvider(data: codeData as CFData) else {
                return
        }
        
        let nsdata = NSMutableData(data:  codeData)
        
        guard let consumer = CGDataConsumer(data: nsdata as CFMutableData) else {
            return
        }
        
        let converted = converter.convert(provider, consumer: consumer, options: nil)
        if !converted {
            print("Could not convert postscript text")
        }
        
        let pdfDataProvider = CGDataProvider(data: nsdata)
        let pdf = CGPDFDocument(pdfDataProvider!)
        self.pdfView.pdfDocument = pdf
    }
    
}
