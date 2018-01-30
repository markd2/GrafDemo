import CoreGraphics

extension CGContext{

    func protectGState(_ drawStuff: () -> Void) {
        saveGState()
        drawStuff()
        restoreGState()
    }

}

