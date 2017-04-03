import Foundation
import UIKit

public class OSBootWindow: UIView{
    
    var messageLabel: UILabel!
    var titleLabel: UILabel!
    var innerView : UIView!
    var macOsFace: MacintoshFaceView!
    var progressView: ProgressBarView!
    
    open func animateProgress(duration: TimeInterval,oldValue oValue: CGFloat, newValue nValue: CGFloat, completion: (()->Void)?){
        progressView.animateProgress(duration: duration, oldValue: oValue, newValue: nValue, completion: completion)
    }
    
    public var progress: CGFloat = 0.0{
        didSet{
            if let progressView = progressView {
                let newProgress = min(1, max(progress,0))
                progressView.progress = newProgress
            }
        }
    }
    
    public var progressAnimationDuration: TimeInterval{
        set{
            progressView.animationDuration = newValue
        }get{
            return progressView.animationDuration
        }
    }
    
    convenience public init(inWindow window: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: window.width * 0.6, height: window.height * 0.6)
        self.init(frame: rect)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("No coder needed since we are in a playground :P")
    }
    
    func setup(){
        self.backgroundColor = .white
        innerView = UIView()
        addSubview(innerView)
        macOsFace = MacintoshFaceView()
        macOsFace.backgroundColor = .clear
        innerView.addSubview(macOsFace)
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Marion-Regular", size: 50)
        titleLabel.text = "MacOS"
        innerView.addSubview(titleLabel)
        progressView = ProgressBarView()
        progressView.progress = progress
        addSubview(progressView)
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
        messageLabel.text = "Starting up..."
        messageLabel.sizeToFit()
        addSubview(messageLabel)
        
    }
    
    override public func layoutSubviews() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
        layer.cornerRadius = 2
        
        //Setup inner window
        innerView.frame = CGRect(x: 0, y: 0, width: bounds.width * 0.7, height: bounds.height * 0.6)
        innerView.center = center
        innerView.frame.origin.y = innerView.frame.origin.y - bounds.height * 0.1
        innerView.layer.borderColor = UIColor.black.cgColor
        innerView.layer.borderWidth = 1.5
        let size = innerView.bounds.size.height / 2
        
        //Setup Macintosh Logo
        macOsFace.frame = CGRect(x: 0, y: 0, width: size * 0.9, height: size)
        macOsFace.frame.origin.x = (innerView.bounds.width - macOsFace.bounds.size.width) / 2
        macOsFace.frame.origin.y = innerView.bounds.size.height * 0.1
        
        //Setup title Label
        titleLabel.frame = CGRect(x: 0, y: 0, width: innerView.bounds.size.width, height: size)
        titleLabel.frame.origin.x = (innerView.bounds.width - titleLabel.bounds.size.width) / 2
        titleLabel.frame.origin.y = innerView.bounds.size.height * 0.55
        titleLabel.textAlignment = .center
        
        //Setup progressView
        progressView.frame = CGRect(x: 0, y: 0, width: innerView.bounds.width * 0.7, height: size/4.5)
        progressView.backgroundColor = .clear
        progressView.layer.borderWidth = 1.5
        progressView.layer.borderColor = UIColor.black.cgColor
        progressView.frame.origin.x = (bounds.width - progressView.bounds.size.width) / 2
        progressView.frame.origin.y = bounds.size.height * 0.85
        
        //Setup message label
        messageLabel.center = center
        messageLabel.frame.origin.y = progressView.frame.origin.y - size/3
        
        
        
    }
}
