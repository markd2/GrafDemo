import Cocoa

extension NSView {

    var currentContext : CGContext? {
        get {
            // The 10.10 SDK provdes a CGContext on NSGraphicsContext, but
            // that's not available to folks running 10.9, so perform this
            // violence to get a context via a void*.
            // iOS can use UIGraphicsGetCurrentContext.
            
            let unsafeContextPointer = NSGraphicsContext.current()?.graphicsPort
            
            if let contextPointer = unsafeContextPointer {
                let opaquePointer = OpaquePointer(contextPointer)
                let context: CGContext = Unmanaged.fromOpaque(opaquePointer).takeUnretainedValue()
                return context
            } else {
                return nil
            }
        }
    }
    
    func protectGState(_ drawStuff: () -> Void) {
        currentContext?.saveGState ()
        drawStuff()
        currentContext?.restoreGState ()
    }
}

