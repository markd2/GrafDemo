import Cocoa

extension NSView {

    var currentContext : CGContext {
        let context = NSGraphicsContext.current()
        return context!.cgContext
    }
    
    func protectGState(_ drawStuff : () -> Void) {
        currentContext.saveGState ()
        drawStuff()
        currentContext.restoreGState ()
    }
}

