import Cocoa

extension NSView {
    var currentContext: CGContext {
        let context = NSGraphicsContext.current
        return context!.cgContext
    }
}

