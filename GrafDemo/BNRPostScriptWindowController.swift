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
    
    @IBAction func draw(AnyObject) {
        var callbacks = CGPSConverterCallbacks()
        guard let converter = CGPSConverterCreate (nil, &callbacks, nil) else {
            return
        }


        let code = self.codeText.string

        let codeCString = (code as NSString!).UTF8String
        guard let provider = CGDataProviderCreateWithData (nil,
            codeCString, Int(strlen(codeCString)), nil) else {
                return
        }
        
        let data = NSMutableData()
        guard let consumer = CGDataConsumerCreateWithCFData (data) else {
            return
        }

        let converted = CGPSConverterConvert (converter, provider, consumer, nil)
        if !converted {
            print("boo")
        }
        
        let pdfDataProvider = CGDataProviderCreateWithCFData(data)
        let pdf = CGPDFDocumentCreateWithProvider(pdfDataProvider)
        self.pdfView.pdfDocument = pdf
    }
    
    
}
