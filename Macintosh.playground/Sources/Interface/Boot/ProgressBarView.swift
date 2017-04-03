import Foundation
import UIKit
import QuartzCore

public class ProgressBarView: UIView{
    
    public var animationDuration: TimeInterval = 1
    
    public var progress: CGFloat = 0.5
    
    public var completion: (()->Void)?
    
    var progressLayer: CAShapeLayer!
    
    override public init(frame: CGRect){
        super.init(frame: frame)
        let linePath = getPathForProgress(frame,progress: progress)
        progressLayer = CAShapeLayer()
        progressLayer.bounds = linePath.bounds
        progressLayer.position = layer.position
        progressLayer.path = linePath.cgPath
        progressLayer.fillColor = UIColor.black.cgColor
        
        layer.addSublayer(progressLayer)
    }
    
    required public init?(coder aDecoder: NSCoder){
        fatalError()
    }
    
    open func animateProgress(duration: TimeInterval,oldValue oValue: CGFloat, newValue nValue: CGFloat, completion: (()->Void)?){
        let startShape = getPathForProgress(bounds, progress: oValue).cgPath
        let endShape = getPathForProgress(bounds, progress: nValue).cgPath
        self.completion = completion
        progressLayer.path = startShape
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = endShape
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        progressLayer.add(animation, forKey: animation.keyPath)
    }
    
    func getPathForProgress(_ rect: CGRect,progress: CGFloat)-> UIBezierPath{
        let prog = CGRect(x: 0, y: 0, width: rect.width * progress, height: rect.height)
        let path = UIBezierPath(rect: prog)
        return path
    }
        
}

extension ProgressBarView: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag{
            self.completion?()
        }
    }
    
}
