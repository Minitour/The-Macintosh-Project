import UIKit


public protocol WindowPanelDelegate{
    
    func didSelectCloseMenu(_ windowPanel: WindowPanel, panelButton button: PanelButton)
}


public class WindowPanel: UIView{
    
    open var title: String?{
        get{
            return titleLabel.text
        }set{
            titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var titleLabel: UILabel!
    
    var closeButton: PanelButton!
    
    open var delegate: WindowPanelDelegate?
    
    open var contentStyle: ContentStyle?
    
    open var drawLines: Bool = true {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override public init(frame: CGRect){
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        let style = contentStyle ?? .default
        
        titleLabel = UILabel()
        titleLabel.textColor = style == .default ? .black : .white
        titleLabel.backgroundColor = style == .default ? .white : .black
        titleLabel.text = "Title Label"
        titleLabel.textAlignment = .center
        titleLabel.font = SystemSettings.normalSizeFont
        
        addSubview(titleLabel)
        
        closeButton = PanelButton(type: .custom)
        closeButton.addTarget(self, action: #selector(buttonResponder(sender:)), for: .touchUpInside)
        //closeButton.setBackgroundImage(UIImage(color: .white), for: [])
        closeButton.setBackgroundImage(UIImage(color: style == .default ? .black : .white), for: .highlighted)
        closeButton.backgroundColor = style == .default ? .white : .black
        
        addSubview(closeButton)
        
    }
    
    open func requestContentStyleUpdate(){
        let style = contentStyle ?? .default
        titleLabel.textColor = style == .default ? .black : .white
        titleLabel.backgroundColor = style == .default ? .white : .black
        closeButton.setBackgroundImage(UIImage(color: style == .default ? .black : .white), for: .highlighted)
        closeButton.backgroundColor = style == .default ? .white : .black
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    override public func layoutSubviews() {
        let buttonSize:CGFloat = 10.0//bounds.height * 0.8
        closeButton.frame = CGRect(x: 10, y: (bounds.height - buttonSize)/2, width: buttonSize, height: buttonSize)
        closeButton.layer.borderColor = (UIColor.white).cgColor
        closeButton.layer.borderWidth = 1
        
        let titleWidth = Utils.widthForView(title!, font: titleLabel.font, height: bounds.size.height * 0.9) + 10
        titleLabel.frame = CGRect(x: (bounds.width - titleWidth)/2, y: 0, width: titleWidth, height: bounds.size.height * 0.9)
    }
    
    
    override public func draw(_ rect: CGRect) {
        
        if contentStyle ?? .default == .default{
            UIColor.black.set()
            if drawLines {
              getLines(rect).forEach { $0.stroke()}  
            }
        }
    }
    
    func buttonResponder(sender: PanelButton){
        delegate?.didSelectCloseMenu(self, panelButton: sender)
    }
    
    func getLines(_ rect: CGRect)->[UIBezierPath]{
        
        var arrayOfLines = [UIBezierPath]()
        
        let space: CGFloat = 2
        let sideSpace: CGFloat = 1
        let startingPoint: CGFloat = (rect.height - space * 5) / 2
        
        for i in 0...5 {
            let path = UIBezierPath()
            let posY: CGFloat = CGFloat(i) * space + startingPoint
            let startX: CGFloat = self.bounds.minX + sideSpace
            let endX: CGFloat = self.bounds.maxX - sideSpace
            
            path.move(to: CGPoint(x: startX, y: posY))
            path.addLine(to: CGPoint(x: endX, y: posY))
            path.lineWidth = 1
            
            arrayOfLines.append(path)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.lineWidth = 1
        arrayOfLines.append(path)
        
        return arrayOfLines
        
    }
    
}

