import Cocoa

extension NSView {

    var currentContext : CGContext? {
        get {
            // 10.9 doesn't have a reasonable call for getting the current context
            // that doesn't require jumping through ever-changing opaque pointers.
            
            let context = NSGraphicsContext.current()

            return context?.cgContext
        }
    }
    
    func protectGState(_ drawStuff : () -> Void) {
        currentContext?.saveGState ()
        drawStuff()
        currentContext?.restoreGState ()
    }
}

