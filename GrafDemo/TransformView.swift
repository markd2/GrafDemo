import Cocoa

class TransformView: NSView {

    private let kBig: CGFloat = 10000
    private var useContextTransforms = false
    
    private var animationTimer: NSTimer!
    
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


    func reset() {
        translation = CGPoint()
        rotation = 0
        scale = CGSize(width: 1.0, height: 1.0)
    }

    // TODO(markd 2015-07-07) this common stuff could use a nice refactoring.
    private func drawBackground() {
        let rect = bounds

        protectGState {
            CGContextAddRect(self.currentContext, rect)
            NSColor.whiteColor().set()
            CGContextFillPath(self.currentContext)
        }
    }
    
    
    private func drawBorder() {
        let context = currentContext
        
        protectGState {
            NSColor.blackColor().set()
            CGContextStrokeRect (context, self.bounds)
        }
    }
    
    private func drawGridLinesWithStride(stride: CGFloat, withLabels: Bool, context: CGContextRef) {
        let font = NSFont.systemFontOfSize(10.0)

        let darkGray = NSColor.darkGrayColor().colorWithAlphaComponent(0.3)

        let textAttributes: [String : AnyObject] = [ NSFontAttributeName : font,
            NSForegroundColorAttributeName: darkGray]
        
        // draw vertical lines
        for var x = CGRectGetMinX(bounds) - kBig; x < kBig; x += stride {
            let start = CGPoint(x: x + 0.25, y: -kBig)
            let end = CGPoint(x: x + 0.25, y: kBig )
            CGContextMoveToPoint (context, start.x, start.y)
            CGContextAddLineToPoint (context, end.x, end.y)
            CGContextStrokePath (context)
            
            if (withLabels) {
                var textOrigin = CGPoint(x: x + 0.25, y: CGRectGetMinY(bounds) + 0.25)
                textOrigin.x += 2.0
                let label = NSString(format: "%d", Int(x))
                label.drawAtPoint(textOrigin,  withAttributes: textAttributes)
            }
        }
        
        // draw horizontal lines
        for var y = CGRectGetMinY(bounds) - kBig; y < kBig; y += stride {
            let start = CGPoint(x: -kBig, y: y + 0.25)
            let end = CGPoint(x: kBig, y: y + 0.25)
            CGContextMoveToPoint (context, start.x, start.y)
            CGContextAddLineToPoint (context, end.x, end.y)
            CGContextStrokePath (context)
            
            if (withLabels) {
                var textOrigin = CGPoint(x: CGRectGetMinX(bounds) + 0.25, y: y + 0.25)
                textOrigin.x += 3.0
                
                let label = NSString(format: "%d", Int(y))
                label.drawAtPoint(textOrigin,  withAttributes: textAttributes)
            }
        }
        
    }
    
    private func drawGrid() {
        let context = currentContext!
        
        protectGState {
            CGContextSetLineWidth (context, 0.5)
            
            let lightGray = NSColor.lightGrayColor().colorWithAlphaComponent(0.3)
            let darkGray = NSColor.darkGrayColor().colorWithAlphaComponent(0.3)

            
            // Light grid lines every 10 points
            
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
            
            let start = CGPoint (x: CGRectGetMinX(bounds) + 0.25, y: CGRectGetMinY(bounds))
            let horizontalEnd = CGPoint (x: CGRectGetMaxX(bounds) + 0.25, y: CGRectGetMinY(bounds))
            let verticalEnd = CGPoint (x: CGRectGetMinX(bounds) + 0.25, y: CGRectGetMaxY(bounds))
            
            CGContextSetLineWidth (context, 2.0)
            NSColor.blackColor().setStroke()
            CGContextMoveToPoint (context, -self.kBig, start.y)
            CGContextAddLineToPoint (context, self.kBig, horizontalEnd.y)
            
            CGContextMoveToPoint (context, start.x, -self.kBig)
            CGContextAddLineToPoint (context, verticalEnd.x, self.kBig)
            
            CGContextStrokePath (context)
        }
    }
    
    private func applyTransforms() {
        
        if useContextTransforms {
            CGContextTranslateCTM(currentContext, translation.x, translation.y)
            CGContextRotateCTM(currentContext, rotation)
            CGContextScaleCTM(currentContext, scale.width, scale.height)
            
        } else { // use matrix transforms
            let identity = CGAffineTransformIdentity
            let shiftingCenter = CGAffineTransformTranslate(identity, translation.x, translation.y)
            let rotating = CGAffineTransformRotate(shiftingCenter, self.rotation)
            let scaling = CGAffineTransformScale(rotating, scale.width, scale.height)
            
            // makes experimentation a little easier - just set to the transform you want to apply
            // to see how it looks
            let lastTransform = scaling
            
            CGContextConcatCTM(currentContext, lastTransform)
        }
        
    }
    
    private func drawPath() {
        let hat = RanchLogoPath()
        let flipTransform = NSAffineTransform()
        flipTransform.translateXBy(0.0, yBy: 300.0)
        flipTransform.scaleXBy(2.0, yBy: -2.0)
        hat.transformUsingAffineTransform(flipTransform)
        
        NSColor.orangeColor().set()
        hat.fill()
        
        NSColor.blackColor().set()
        hat.stroke()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        drawBackground()
        protectGState() {
            self.applyTransforms()
            self.drawGrid()
            self.drawPath()
        }
        drawBorder()
    }
    
    override var flipped : Bool{
        return true
    }
    
    func tick(timer: NSTimer) {
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
    
    
    func translationAnimator(from from: CGPoint, to: CGPoint) -> () -> Bool {
        translation = from

        let steps: CGFloat = 50
        
        let delta = CGPoint(x: (to.x - from.x) / steps,
            y: (to.y - from.y) / steps)
        
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
    
    
    func rotationAnimator(from from: CGFloat, to: CGFloat) -> () -> Bool {
        rotation = from

        let steps: CGFloat = 15
        
        let delta = (to - from) / steps
        
        return {
            self.rotation += delta
            
            if self.rotation > to {
                return true
            } else {
                return false
            }
        }
    }
    

    func scaleAnimator(from from: CGSize, to: CGSize) -> () -> Bool {
        scale = from

        let steps: CGFloat = 50
        
        let delta = CGSize(width: (to.width - from.width) / steps,
            height: (to.height - from.height) / steps)
        
        return {
            self.scale.width += delta.width
            self.scale.height += delta.height
            
            self.needsDisplay = true
            
            // this is insufficient, if from.width == to.width
            if self.scale.height > to.height {
                return true
            } else {
                return false
            }
        }
    }
    
    
    func startAnimation() {
        // The worst possible way to animate, but I'm in a hurry right now prior
        // to cocoaconf/columbus. ++md 2015-07-07
        
        animationFunction = translationAnimator(from: CGPoint(), to: CGPoint(x: 200, y: 100))
        animationFunction = rotationAnimator(from: 0, to: π / 6)
        animationFunction = scaleAnimator(from: CGSize(width: 1.0, height: 1.0),
            to: CGSize(width: 0.75, height: 1.5))

        animationTimer = NSTimer.scheduledTimerWithTimeInterval(1 / 30, target: self, selector: "tick:", userInfo: nil, repeats: true)
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
        
        Swift.print("OOK")
    }
    
    override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        Swift.print("flonk \(event)")
        return super.actionForLayer(layer, forKey: event)
    }
    
    */
}
