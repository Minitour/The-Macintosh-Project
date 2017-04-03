import Foundation
import UIKit

public class KeyCaps: MacApp{
    
    public var desktopIcon: UIImage?
    
    public var identifier: String? = "keycaps"
    
    public var windowTitle: String? = "Key Caps"
    
    public var menuActions: [MenuAction]?
    
    public var container: UIView?
    
    lazy public var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    public func sizeForWindow() -> CGSize {
        return CGSize(width: 450, height: 200)
    }
    
    public init(){
        container = KeyCapsView()
    }
}

public class KeyCapsView: UIView{
    var keys: [[String]] = [
       [ "`","1","2","3","4","5","6","7","8","9","0","-","="],
       ["q","w","e","r","t","y","u","i","o","p","[","]","\\"],
       ["a","s","d","f","g","h","j","k","l",";","'"],
       ["z","x","c","v","b","n","m",",",".","/"]]
    
    
    var inputField: UITextField!
    var primaryStack: UIStackView!
    var buttons: [UIButton]!
    var spaceButton: UIButton!
    var deleteButton: UIButton!
    
    convenience public init() {
        self.init(frame: CGRect.zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        setupButtons()
        primaryStack = UIStackView()
        inputField = UITextField()
        inputField.backgroundColor = .white
        inputField.layer.borderColor = UIColor.black.cgColor
        inputField.layer.borderWidth = 2
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        inputField.leftViewMode = .always
        inputField.tintColor = .black
        inputField.font = SystemSettings.normalSizeFont
        inputField.addTarget(self, action: #selector(didTextChange(textField:)), for: .editingChanged)
        addSubview(inputField)
        addSubview(primaryStack)
        
        let row1size = keys[0].count
        let row2size = keys[1].count
        let row3size = keys[2].count
        let row4size = keys[3].count
        
        //setup first stack
        let firstStack = UIStackView()
        firstStack.axis = .horizontal
        for i in 0..<row1size{
            firstStack.addArrangedSubview(buttons[i])
            if firstStack.arrangedSubviews.count > 1 {
                firstStack.arrangedSubviews.last!.widthAnchor.constraint(equalTo: firstStack.arrangedSubviews[0].widthAnchor, multiplier: 1.0).isActive = true
            }
        }
        deleteButton = createGenericButton()
        deleteButton.addTarget(self, action: #selector(didTapDelete(sender:)), for: .touchUpInside)
        firstStack.addArrangedSubview(deleteButton)
        firstStack.arrangedSubviews.first?.widthAnchor.constraint(equalTo: firstStack.widthAnchor, multiplier: 0.07).isActive = true

        //setup second stack
        let secondStack = UIStackView()
        secondStack.axis = .horizontal
        secondStack.addArrangedSubview(ButtonLikeView())
        for i in row1size..<(row1size+row2size){
            secondStack.addArrangedSubview(buttons[i])
            if secondStack.arrangedSubviews.count > 2 {
                secondStack.arrangedSubviews.last!.widthAnchor.constraint(equalTo: secondStack.arrangedSubviews[1].widthAnchor, multiplier: 1.0).isActive = true
            }
        }
        secondStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: secondStack.widthAnchor, multiplier: 0.07).isActive = true
        
        //setup third stack
        let thirdStack = UIStackView()
        thirdStack.axis = .horizontal
        thirdStack.addArrangedSubview(ButtonLikeView())
        for i in (row1size + row2size)..<(row1size+row2size+row3size){
            thirdStack.addArrangedSubview(buttons[i])
            if thirdStack.arrangedSubviews.count > 2 {
                thirdStack.arrangedSubviews.last!.widthAnchor.constraint(equalTo: thirdStack.arrangedSubviews[1].widthAnchor, multiplier: 1.0).isActive = true
            }
        }
        thirdStack.addArrangedSubview(ButtonLikeView())
        thirdStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: thirdStack.widthAnchor, multiplier: 0.07).isActive = true
        thirdStack.arrangedSubviews.last?.widthAnchor.constraint(equalTo: thirdStack.arrangedSubviews[0].widthAnchor, multiplier: 1.0).isActive = true

        //setup forth stack
        let forthStack = UIStackView()
        forthStack.axis = .horizontal
        forthStack.addArrangedSubview(ButtonLikeView())
        for i in (row1size + row2size + row3size)..<(row1size+row2size+row3size+row4size){
            forthStack.addArrangedSubview(buttons[i])
            if forthStack.arrangedSubviews.count > 2 {
                forthStack.arrangedSubviews.last!.widthAnchor.constraint(equalTo: forthStack.arrangedSubviews[1].widthAnchor, multiplier: 1.0).isActive = true
            }
        }
        forthStack.addArrangedSubview(ButtonLikeView())
        forthStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: forthStack.widthAnchor, multiplier: 0.07).isActive = true
        forthStack.arrangedSubviews.last?.widthAnchor.constraint(equalTo: forthStack.arrangedSubviews[0].widthAnchor, multiplier: 1.0).isActive = true
        
        //setup fifth stack
        let fifthStack = UIStackView()
        spaceButton = createGenericButton()
        spaceButton.addTarget(self, action: #selector(didTapSpace(sender:)), for: .touchUpInside)
        fifthStack.axis = .horizontal
        fifthStack.addArrangedSubview(UIView())         //0
        fifthStack.addArrangedSubview(ButtonLikeView()) //1
        fifthStack.addArrangedSubview(ButtonLikeView()) //2
        fifthStack.addArrangedSubview(spaceButton)      //3
        fifthStack.addArrangedSubview(ButtonLikeView()) //4
        fifthStack.addArrangedSubview(ButtonLikeView()) //5
        fifthStack.addArrangedSubview(UIView())         //6
        
        fifthStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: fifthStack.arrangedSubviews[1].widthAnchor, multiplier: 1.0).isActive = true
        fifthStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: fifthStack.widthAnchor, multiplier: 0.07).isActive = true
        fifthStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: fifthStack.arrangedSubviews[6].widthAnchor, multiplier: 1.0).isActive = true
        fifthStack.arrangedSubviews[1].widthAnchor.constraint(equalTo: fifthStack.arrangedSubviews[5].widthAnchor, multiplier: 1.0).isActive = true
        fifthStack.arrangedSubviews[2].widthAnchor.constraint(equalTo: fifthStack.arrangedSubviews[4].widthAnchor, multiplier: 1.0).isActive = true
        fifthStack.arrangedSubviews[3].widthAnchor.constraint(equalTo: fifthStack.widthAnchor, multiplier: 0.5).isActive = true
        
        //setup primary stack
        primaryStack.axis = .vertical
        primaryStack.distribution = .fillEqually
        primaryStack.addArrangedSubview(firstStack)
        primaryStack.addArrangedSubview(secondStack)
        primaryStack.addArrangedSubview(thirdStack)
        primaryStack.addArrangedSubview(forthStack)
        primaryStack.addArrangedSubview(fifthStack)
        
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        inputField.rightAnchor.constraint(equalTo: rightAnchor, constant: -50).isActive = true
        inputField.leftAnchor.constraint(equalTo: leftAnchor, constant: 50).isActive = true
        inputField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        primaryStack.translatesAutoresizingMaskIntoConstraints = false
        primaryStack.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 10).isActive = true
        primaryStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        primaryStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        primaryStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
    }
    
    func didTapKey(sender: UIButton){
        inputField.text = "\(inputField.text!)\(sender.titleLabel!.text!)"
    }
    
    func didTapDelete(sender: UIButton){
        
        if inputField.text?.characters.count == 0 {
            return
        }
        
        var text: String = inputField.text!
        text.characters.removeLast()
        inputField.text = text
    }
    
    func didTapSpace(sender: UIButton){
        inputField.text = "\(inputField.text!) "
    }
    
    
    func setupButtons(){
        buttons = [UIButton]()
        for array in keys{
            for char in array{
                let button = createGenericButton()
                button.setTitle("\(char)", for: [])
                buttons.append(button)
                button.addTarget(self, action: #selector(didTapKey(sender:)), for: .touchUpInside)
            }
        }
    }
    
    func createGenericButton()->UIButton{
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setBackgroundImage(UIImage(color: .white),for: [])
        button.setBackgroundImage(UIImage(color: .black),for: .highlighted)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = SystemSettings.normalSizeFont
        return button
    }
    
    class ButtonLikeView: UIView{
        
        convenience init(){
            self.init(frame: CGRect.zero)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        func setup(){
            self.backgroundColor = .white
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 1
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
    
    var lastCharCount = 0
    
    func buttonForText(_ text: String)->UIButton?{
        
        var count: Int = 0
        for array in keys{
            for item in array{
                if item == text{
                    return buttons[count]
                }
                count += 1
            }
        }
        return nil
    }
    
    let textChangeAnimationDuration: TimeInterval = 0.7
    
    func didTextChange(textField: UITextField){
        if textField.text!.characters.count > lastCharCount{
            //adding new text
            let newChar = String(textField.text!.characters.last!)
            
            if newChar == " " {
                spaceButton.isHighlighted = true
                UIView.animate(withDuration: textChangeAnimationDuration, animations: {
                }, completion: { (completion) in
                    self.spaceButton.isHighlighted = false
                })
            }else if let button = buttonForText(newChar){
                button.isHighlighted = true
                UIView.animate(withDuration: textChangeAnimationDuration, animations: {
                }, completion: { (completion) in
                    button.isHighlighted = false
                })
            }
        }else{
            //deleted chars
            deleteButton.isHighlighted = true
            UIView.animate(withDuration: textChangeAnimationDuration, animations: {
            }, completion: { (completion) in
                self.deleteButton.isHighlighted = false
            })
        }
        
        lastCharCount = textField.text!.characters.count
    }
    
}

