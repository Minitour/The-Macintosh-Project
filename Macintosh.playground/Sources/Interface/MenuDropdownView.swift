import Foundation
import UIKit

public protocol MenuDropDownDelegate{
    
    /// This function is called once the user clicks on one of the actions.
    ///
    /// - Parameters:
    ///   - menuDropDown: The menu dropdown view.
    ///   - index: The index that was selected.
    func menuDropDown(_ menuDropDown: MenuDropdownView, didSelectActionAtIndex index: Int)
}

public class MenuDropdownView: UIView{
    
    /// The height for each action
    static let actionHeight: CGFloat = 20.0
    
    /// Left padding
    static let left_padding: CGFloat = 10
    
    /// Rigth padding
    static let right_padding: CGFloat = 2
    
    /// The menu that contains the actions
    open var action: MenuAction?
    
    /// The delegate that the OSToolBar conforms to.
    open var delegate: MenuDropDownDelegate?
    
    /// The view that holds the buttons.
    var stackView: UIStackView!
    
    convenience init(action: MenuAction){
        var height: CGFloat = 0
        var width: CGFloat = 0
        action.subMenus?.forEach {
            ($0.type == .action) ? (height += MenuDropdownView.actionHeight) : (height += 1)
            let neededWidth = Utils.widthForView($0.title, font: SystemSettings.normalSizeFont, height: MenuDropdownView.actionHeight)
            width = max(width,neededWidth)
        }
        let rect = CGRect (x: 0, y: 0, width: MenuDropdownView.left_padding + width + MenuDropdownView.right_padding, height: height)
        self.init(frame: rect)
        self.action = action
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        backgroundColor = .white
        stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        self.addSubview(stackView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = self.bounds
        stackView.arrangedSubviews.forEach{ $0.removeFromSuperview()}
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.cornerRadius = 2
        
        for index in 0 ..< (action?.subMenus)!.count {
            let action = (self.action?.subMenus?[index])!
            let view = createObjectFor(action: action,index: index)
            
            let constraintHeight = action.type == .action ? MenuDropdownView.actionHeight : 1
            view.heightAnchor.constraint(equalToConstant: constraintHeight).isActive = true
            
            stackView.addArrangedSubview(view)
        }
    }
    
    func buttonResponder(sender: UIButton){
        delegate?.menuDropDown(self, didSelectActionAtIndex: sender.tag)
        action?.subMenus?[sender.tag].action?()
    }
    
    
    func createObjectFor(action: MenuAction,index: Int)->UIView{
        if action.type == .action {
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(action.title, for: [])
            button.titleLabel?.font = SystemSettings.normalSizeFont
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .highlighted)
            button.setTitleColor(.lightGray, for: .disabled)
            button.setBackgroundImage(UIImage(color: .clear),for: [])
            button.setBackgroundImage(UIImage(color: .black),for: .highlighted)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: MenuDropdownView.left_padding, bottom: 0, right: MenuDropdownView.right_padding)
            button.isEnabled = action.runtimeClosure != nil ? action.runtimeClosure!() : action.enabled
            button.addTarget(self, action: #selector(buttonResponder(sender:)), for: .touchUpInside)
            return button
        }
        let seperator = UIView()
        seperator.backgroundColor = .lightGray
        return seperator
    }
    
}
