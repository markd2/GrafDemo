import Cocoa

class TransformView: NSView {

    private let kBig: CGFloat = 10000
    private let animationSteps: CGFloat = 15
    private var useContextTransforms = false
    
    private var animationTimer: Timer!
    
    private var translation = CGPoint() {
        didSet {
            needsDisplay = true
        }
    }
    
    private var rotation: CGFloat = 0 {
        didSet {
            needsDisplay = true
        }
    }
    
    private var scale = CGSize(width: 1.0, height: 1.0) {
        didSet {
            needsDisplay = true
        }
    }
    
    private var animationFunction: (() -> Bool)?  // returns true when finished

    // until get a fancy UI
    var shouldTranslate = true
    var shouldRotate = true
    var shouldScale = true

    func reset() {
        translation = CGPoint()
        rotation = 0
        scale = CGSize(width: 1.0, height: 1.0)
    }

    // TODO(markd 2015-07-07) this common stuff could use a nice refactoring.
    private func drawBackground() {
        let rect = bounds

        protectGState {
            self.currentContext?.addRect(rect)
            NSColor.white().set()
            self.currentContext?.fillPath()
        }
    }
    
    
    private func drawBorder() {
        let context = currentContext
        
        protectGState {
            NSColor.black().set()
            context?.stroke (self.bounds)
        }
    }
    
    private func drawGridLinesWithStride(_ strideLength: CGFloat, withLabels: Bool, context: CGContext) {
        let font = NSFont.systemFont(ofSize: 10.0)

        let darkGray = NSColor.darkGray().withAlphaComponent(0.3)

        let textAttributes: [String : AnyObject] = [ NSFontAttributeName : font,
            NSForegroundColorAttributeName: darkGray]

        // draw vertical lines
        for x in stride(from: bounds.midX - kBig, to: kBig, by: strideLength) {
            let start = CGPoint(x: x + 0.25, y: -kBig)
            let end = CGPoint(x: x + 0.25, y: kBig )
            context.moveTo (x: start.x, y: start.y)
            context.addLineTo (x: end.x, y: end.y)
            context.strokePath ()
            
            if (withLabels) {
                var textOrigin = CGPoint(x: x + 0.25, y: bounds.minY + 0.25)
                textOrigin.x += 2.0
                let label = NSString(format: "%d", Int(x))
                label.draw(at: textOrigin,  withAttributes: textAttributes)
            }
        }
        
        // draw horizontal lines
        for y in stride(from: bounds.minY - kBig, to: kBig, by: strideLength) {
            let start = CGPoint(x: -kBig, y: y + 0.25)
            let end = CGPoint(x: kBig, y: y + 0.25)
            context.moveTo (x: start.x, y: start.y)
            context.addLineTo (x: end.x, y: end.y)
            context.strokePath ()

            if (withLabels) {
                var textOrigin = CGPoint(x: bounds.minX + 0.25, y: y + 0.25)
                textOrigin.x += 3.0
                
                let label = NSString(format: "%d", Int(y))
                label.draw(at: textOrigin,  withAttributes: textAttributes)
            }
        }
    }
    
    private func drawGrid() {
        let context = currentContext!
        
        protectGState {
            context.setLineWidth (0.5)
            
            let lightGray = NSColor.lightGray().withAlphaComponent(0.3)
            let darkGray = NSColor.darkGray().withAlphaComponent(0.3)

            
            // Light grid lines every 10 points
            
            // Performance hack - if the transform has a rotation, speed of drawing
            // plummets, so hide the inner lines when animating.
            if self.animationFunction == nil {
                lightGray.setStroke()
                self.drawGridLinesWithStride(10, withLabels: false, context: context)
            }
            
            // darker gray lines every 100 points
            darkGray.setStroke()
            self.drawGridLinesWithStride(100, withLabels: true, context: context)
            
            // black lines on cartesian axes
            // P.S. "AND MY AXE" -- Gimli
            let bounds = self.bounds
            
            let start = CGPoint (x: bounds.minX + 0.25, y: bounds.minY)
            let horizontalEnd = CGPoint (x: bounds.maxX + 0.25, y: bounds.minY)
            let verticalEnd = CGPoint (x: bounds.minX + 0.25, y: bounds.maxY)
            
            context.setLineWidth (2.0)
            NSColor.black().setStroke()
            context.moveTo (x: -self.kBig, y: start.y)
            context.addLineTo (x: self.kBig, y: horizontalEnd.y)
            
            context.moveTo (x: start.x, y: -self.kBig)
            context.addLineTo (x: verticalEnd.x, y: self.kBig)
            
            context.strokePath ()
        }
    }
    
    private func applyTransforms() {
        
        if useContextTransforms {
            currentContext?.translate(x: translation.x, y: translation.y)
            currentContext?.rotate(byAngle: rotation)
            currentContext?.scale(x: scale.width, y: scale.height)
            
        } else { // use matrix transforms
            let identity = CGAffineTransform.identity
            let shiftingCenter = identity.translateBy(x: translation.x, y: translation.y)
            let rotating = shiftingCenter.rotate(self.rotation)
            let scaling = rotating.scaleBy(x: scale.width, y: scale.height)
            
            // makes experimentation a little easier - just set to the transform you want to apply
            // to see how it looks
            let lastTransform = scaling
            
            currentContext?.concatCTM(lastTransform)
        }
        
    }
    
    private func drawPath() {
        guard let hat = RanchLogoPath() else { return }

        var flipTransform = AffineTransform.identity
        let bounds = hat.bounds
        flipTransform.translate(x: 0.0, y: bounds.height * 4)
        flipTransform.scale(x: 2.0, y: -2.0)
        hat.transform(using: flipTransform)

        NSColor.orange().set()
        hat.fill()
        
        NSColor.black().set()
        hat.stroke()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawBackground()
        protectGState() {
            self.applyTransforms()
            self.drawGrid()
            self.drawPath()
        }
        drawBorder()
    }
    
    override var isFlipped : Bool{
        return true
    }
    
    func tick(_ timer: Timer) {
        guard let animator = animationFunction else {
            return
        }
        if animator() {
            self.animationTimer.invalidate()
            self.animationTimer = nil
            animationFunction = nil
            self.needsDisplay = true
        }
    }
    
    
    func translationAnimator(from: CGPoint, to: CGPoint) -> () -> Bool {
        translation = from

        let delta = CGPoint(x: (to.x - from.x) / animationSteps,
            y: (to.y - from.y) / animationSteps)
        
        return {
            self.translation.x += delta.x
            self.translation.y += delta.y
            
            self.needsDisplay = true

            // this is insufficient, if from.x == to.x
            if self.translation.x > to.x {
                return true
            } else {
                return false
            }
        }
    }
    
    
    func rotationAnimator(from: CGFloat, to: CGFloat) -> () -> Bool {
        rotation = from
        
        let delta = (to - from) / animationSteps
        
        return {
            self.rotation += delta
            
            if self.rotation > to {
                return true
            } else {
                return false
            }
        }
    }
    

    func scaleAnimator(from: CGSize, to: CGSize) -> () -> Bool {
        scale = from

        let delta = CGSize(width: (to.width - from.width) / animationSteps,
            height: (to.height - from.height) / animationSteps)
        
        return {
            self.scale.width += delta.width
            self.scale.height += delta.height
            
            self.needsDisplay = true
            
            // this is insufficient, if from.height == to.height
            if self.scale.width > to.width {
                return true
            } else {
                return false
            }
        }
    }
    
    func compositeAnimator(_ animations: [ () -> Bool ]) -> () -> Bool {
        guard var currentAnimation = animations.first else {
            return {
                return true // no animations, so we're done
            }
        }
        
        var animatorIndex = 0
        
        return {
            if currentAnimation() {
                // move to the next one
                animatorIndex += 1

                // run out?
                if animatorIndex >= animations.count {
                    return true
                }
                
                // otherwise, tick over
                currentAnimation = animations[animatorIndex]
                return false // not done
            } else {
                return false // not done
            }
        }
    }
    
    
    func startAnimation() {
        // The worst possible way to animate, but I'm in a hurry right now prior
        // to cocoaconf/columbus. ++md 2015-07-07
        
        let translateFrom = CGPoint()
        let translateTo = CGPoint(x: 200, y: 100)
        let translator = translationAnimator(from: translateFrom, to: translateTo)
        
        let rotator = rotationAnimator(from: 0.0, to: rotation + π / 12)
        
        let scaleFrom = CGSize(width: 1.0, height: 1.0)
        let scaleTo = CGSize(width: 1.5, height: 0.75)
        let scaler = scaleAnimator(from: scaleFrom, to: scaleTo)
        
        var things: [(() -> Bool)] = []

        if shouldTranslate {
            things += [translator]
        }
        if shouldRotate {
            things += [rotator]
        }
        if shouldScale {
            things += [scaler]
        }
        
        animationFunction = compositeAnimator(things)

        animationTimer = Timer.scheduledTimer(timeInterval: 1 / 30, target: self, selector: #selector(TransformView.tick(_:)), userInfo: nil, repeats: true)
    }
    
    
/*
    For now giving up on core animation since I don't have a layer subclass.

    func startAnimation() {
        let anim = CABasicAnimation()
        anim.keyPath = "translateX"
        anim.fromValue = 0
        anim.toValue = 100
        anim.repeatCount = 1
        anim.duration = 3
        layer!.style = [ "translateX" : 0 ]
        layer!.addAnimation(anim, forKey: "translateX")
        
        Swift.print ("blah \(layer!.style)")
    
    /*
        let translateAnimation = CAKeyframeAnimation(keyPath: "translateX")
        translateAnimation.values = [ 200 ]
        translateAnimation.keyTimes = [ 100 ]
        translateAnimation.duration = 2.0
        translateAnimation.additive = true
        layer?.addAnimation(translateAnimation, forKey: "translate X")
      */  
    }
    
    override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        Swift.print("flonk \(event)")
        return super.actionForLayer(layer, forKey: event)
    }
    
    */
}
