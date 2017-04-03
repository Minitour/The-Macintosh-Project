import Foundation
import UIKit

public protocol OSToolBarDataSource {
    
    /// The menu actions that will be displayed on the toolbar
    ///
    /// - Parameter toolBar: The toolbar instance
    /// - Returns: An array of MenuAction
    func menuActions(_ toolBar: OSToolBar)->[MenuAction]
    
    
    /// The menu which displays the OS actions. (mostly applications)
    ///
    /// - Parameter toolBar: The toolbar instance.
    /// - Returns: An array of MenuAction.
    func osMenuActions(_ toolBar: OSToolBar)->[MenuAction]
}

public class OSToolBar: UIView{
    
    /// The height of the tool bar
    static let height: CGFloat = 20.0
    
    /// The logo/icon that is displayed in the toolbar
    open var osMenuLogo: UIImage{
        set{
            osMenuButton?.setImage(newValue, for: [])
        }
        get{
            return (osMenuButton?.image(for: []))!
        }
    }
    
    /// The primary menu button.
    var osMenuButton: UIButton!
    
    /// The stack the holds the other menus
    var menuStackView: UIStackView!
    
    /// The current dropdown menu that is displayed.
    var currentDropDownMenu: MenuDropdownView?
    
    /// The seperator view
    var seperatorView: UIView!
    
    /// The data source which is implemented by the OSWindow
    open var dataSource: OSToolBarDataSource?
    
    convenience public init(inWindow window: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: window.width, height: OSToolBar.height)
        self.init(frame: rect)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Sorry m8 there is no coder here")
    }
    
    func setup(){
        self.backgroundColor = .white
        
        //setup os menu button
        osMenuButton = UIButton(type: .custom)
        osMenuButton.addTarget(self, action: #selector(didSelectOSMenu(sender:)), for: .touchUpInside)
        osMenuButton.imageView?.contentMode = .scaleAspectFit
        osMenuButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        addSubview(osMenuButton)
        
        //setup action menus
        menuStackView = UIStackView()
        menuStackView.axis = .horizontal
        menuStackView.alignment = .fill
        menuStackView.distribution = .fill
        menuStackView.spacing = 0
        menuStackView.isLayoutMarginsRelativeArrangement = true
        addSubview(menuStackView)
        
        seperatorView = UIView()
        seperatorView.backgroundColor = .black
        addSubview(seperatorView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let spacing: CGFloat = 10
        osMenuButton.frame = CGRect(x: spacing, y: 0, width: 30, height: OSToolBar.height)
        menuStackView.frame.origin.x = osMenuButton.bounds.width + spacing * 2
        seperatorView.frame = CGRect(x: 0, y: frame.maxY, width: bounds.size.width, height: 1)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        let spacing: CGFloat = 10
        let size = self.bounds.size
        menuStackView.frame = CGRect(x: osMenuButton.bounds.width + spacing, y: 0, width: size.width - size.width / 3, height: OSToolBar.height)
    }
    
    func didSelectOSMenu(sender: UIButton){
        showMenuDropDown(sender: sender, isPrimary: true)
    }
    
    func didSelectItemMenu(sender: UIButton){
        showMenuDropDown(sender: sender,isPrimary: false)
    }
    
    func showMenuDropDown(sender: UIButton,isPrimary primary: Bool){
        let id = sender.tag
        
        for view in menuStackView.arrangedSubviews{
            (view as! UIButton).isSelected = false
        }
        
        if let current = currentDropDownMenu{
            current.removeFromSuperview()
            if current.tag == id{
                currentDropDownMenu = nil
                return
            }
        }
        
        if primary{
            let action = MenuAction(title: "", action: nil, subMenus: dataSource?.osMenuActions(self))
            self.currentDropDownMenu = MenuDropdownView(action: action)
            self.currentDropDownMenu?.delegate = self
            self.currentDropDownMenu?.tag = id
            let senderRect = sender.convert(sender.bounds, to: self.superview)
            self.currentDropDownMenu?.frame.origin = senderRect.origin
            self.currentDropDownMenu?.frame.origin.y = (currentDropDownMenu?.frame.origin.y)! + OSToolBar.height
            self.superview?.insertSubview(self.currentDropDownMenu!, belowSubview: self)
            
        }else{
            if let action = dataSource?.menuActions(self)[id-1]{
                if let _ = action.subMenus {
                    sender.isSelected = true
                    self.currentDropDownMenu = MenuDropdownView(action: action)
                    self.currentDropDownMenu?.delegate = self
                    self.currentDropDownMenu?.tag = id
                    let senderRect = sender.convert(sender.bounds, to: self.superview)
                    self.currentDropDownMenu?.frame.origin = senderRect.origin
                    self.currentDropDownMenu?.frame.origin.y = (currentDropDownMenu?.frame.origin.y)! + OSToolBar.height
                    self.superview?.insertSubview(self.currentDropDownMenu!, belowSubview: self)
                }else if let funcAction = action.action{
                    funcAction()
                }
            }
        }
    }
    
    /// Request from the tool bar to close all open menus.
    open func requestCloseAllMenus(){
        for view in menuStackView.arrangedSubviews{
            (view as! UIButton).isSelected = false
        }
        
        if let current = currentDropDownMenu{
            current.removeFromSuperview()
            currentDropDownMenu = nil
        }
    }
    
    /// Request from the tool bar to refresh it's menus (if needed)
    open func requestApplicationMenuUpdate(){
        if let buttonStack = self.menuStackView{
            
            //remove old menu items
            buttonStack.subviews.forEach { $0.removeFromSuperview()}
            
            //add new items
            if let actions = dataSource?.menuActions(self){
                for i in 1...actions.count {
                    let button = createMenuButtonFrom(action: actions[i-1],index: i)
                    buttonStack.addArrangedSubview(button)
                }
            }
            var stackWidth:CGFloat = 0
            let spacing: CGFloat = 20
            for arrangedView in buttonStack.arrangedSubviews {
                let button = (arrangedView as! UIButton)
                let buttonNeededWidth = Utils.widthForView(button.title(for: [])!, font: (button.titleLabel?.font)!, height: OSToolBar.height)
                button.widthAnchor.constraint(equalToConstant: buttonNeededWidth + spacing).isActive = true
                stackWidth += buttonNeededWidth
            }
            buttonStack.bounds.size.width = stackWidth + CGFloat(buttonStack.arrangedSubviews.count) * spacing
            buttonStack.removeConstraints(buttonStack.constraints)
            buttonStack.layoutIfNeeded()
        }
    }
    
    func createMenuButtonFrom(action: MenuAction,index: Int)->UIButton{
        let button = UIButton(type: .custom)
        button.tag = index
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitle(action.title, for: [])
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .selected)
        button.setBackgroundImage(UIImage(color: .clear),for: [])
        button.setBackgroundImage(UIImage(color: .black),for: .highlighted)
        button.setBackgroundImage(UIImage(color: .black),for: .selected)
        button.addTarget(self, action: #selector(didSelectItemMenu(sender:)), for: .touchUpInside)
        button.titleLabel?.font = SystemSettings.normalSizeFont
        return button
    }
}


// MARK: - MenuDropDownDelegate
extension OSToolBar: MenuDropDownDelegate{
    
    public func menuDropDown(_ menuDropDown: MenuDropdownView, didSelectActionAtIndex index: Int) {
        requestCloseAllMenus()
    }
}

