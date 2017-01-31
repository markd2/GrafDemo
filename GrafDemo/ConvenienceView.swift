import Cocoa

class ConvenienceView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.white.set()
        NSRectFill(bounds)
        NSColor.black.set()
        NSFrameRect(bounds)
    }
    
}
