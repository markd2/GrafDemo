import Cocoa


class PDFView: NSView {

    var pdfDocument : CGPDFDocumentRef? {
        willSet {
            needsDisplay = true
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        NSColor.whiteColor().set()
        NSRectFill(bounds)
        
        if let pdf = pdfDocument {
            let page1 = CGPDFDocumentGetPage(pdf, 1)
 
            CGContextDrawPDFPage (currentContext, page1)
        }
        
        NSColor.blackColor().set()
        NSFrameRect(bounds)
    }
}

