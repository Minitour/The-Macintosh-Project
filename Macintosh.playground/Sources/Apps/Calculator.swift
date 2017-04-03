import Foundation
import UIKit

public class Calculator: MacApp{
    
    public var desktopIcon: UIImage?
    
    public var identifier: String? = "calculator"
    
    public var windowTitle: String? = "Calculator"

    public var menuActions: [MenuAction]? = nil
    
    public var contentMode: ContentStyle = .light

    lazy public var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    var calculatorView: CalculatorView!
    
    public init(){
        calculatorView = CalculatorView()
        calculatorView.delegate = self
        calculatorView.layer.cornerRadius = 2
        calculatorView.layer.masksToBounds = true
        
        let main = UIView()
        main.backgroundColor = .clear
        main.addSubview(calculatorView)
        calculatorView.translatesAutoresizingMaskIntoConstraints = false
        calculatorView.topAnchor.constraint(equalTo: main.topAnchor, constant: 2).isActive = true
        calculatorView.leftAnchor.constraint(equalTo: main.leftAnchor, constant: 2).isActive = true
        calculatorView.bottomAnchor.constraint(equalTo: main.bottomAnchor, constant: -2).isActive = true
        calculatorView.rightAnchor.constraint(equalTo: main.rightAnchor, constant: -2).isActive = true
        container = main
    }
    
    public var container: UIView?
    
    public func willTerminateApplication() {
        
    }
    
    public func willLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow) {
        
    }
    
    public func sizeForWindow() -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    var hasDot: Bool = false
    var pendingNumberAfterDot: Bool = false
    
    var accumulator: Double?
    
    var pendingOperation: PendingOperation?
    
    var operations: [String : Operation] = [
        "E" : Operation.constant(M_E),
        "*" : Operation.operation { $0 * $1 },
        "/" : Operation.operation { $1 == 0 ? 0 : $0 / $1 },
        "+" : Operation.operation { $0 + $1 },
        "-" : Operation.operation { $0 - $1 },
        "=" : Operation.equals,
        "C" : Operation.clear,
        "." : Operation.dot
    ]
    
    enum Operation{
        case constant(Double)
        case operation((Double,Double)->Double)
        case equals
        case clear
        case dot
    }
    
    struct PendingOperation{
        let function: (Double,Double)->Double
        let first: Double
        
        func perform(with operand: Double)->Double{
            return function(first, operand)
        }
    }
}

extension Calculator: CalculatorDelegate{
    
    public func calculatorView(_ calculatorView: CalculatorView, didClickNumber number: String) {
        
        let size: Int = calculatorView.resultText?.characters.count ?? 0
        if size < 16{
            calculatorView.resultText = (calculatorView.resultText ?? "") + number
            let calcText = calculatorView.resultText!
            let value: Double? = Double(calcText)
            self.accumulator = value
            if pendingNumberAfterDot == true {pendingNumberAfterDot = false}
        }
        
        
    }
    
    public func calculatorView(_ calculatorView: CalculatorView, didClickOperator operation: String){
        if let op = self.operations[operation]{
            switch op {
            case .clear:
                accumulator = nil
                calculatorView.resultText = ""
                break
            case .dot:
                if !hasDot{
                    calculatorView.resultText = (calculatorView.resultText ?? "") + "."
                    hasDot = true
                    pendingNumberAfterDot = true
                }
                break
            case .equals:
                if pendingOperation != nil && accumulator != nil && pendingNumberAfterDot == false{
                    
                    accumulator = pendingOperation!.perform(with: accumulator!)
                    pendingOperation = nil
                    
                    let isDouble = accumulator!.truncatingRemainder(dividingBy: 1) != 0
                    var result = "\(accumulator!)"
                    
                    let size: Int = result.characters.count
                    
                    if !isDouble {
                        result.characters.removeLast()
                        result.characters.removeLast()
                    }
                    
                    if size >= 20{
                        
                        result = accumulator!.scientificStyle
                    }
                    
                    calculatorView.resultText = result
                }
                break
            case .constant(let value):
                self.accumulator = value
                calculatorView.resultText = "\(accumulator!)"
                break
            case .operation(let function):
                if let accum = accumulator , pendingNumberAfterDot == false{
                    pendingOperation = PendingOperation(function: function, first: accum)
                    accumulator = nil
                    calculatorView.resultText = ""
                }
                break
            }
        }
    }
    
}

public protocol CalculatorDelegate{
    
    func calculatorView(_ calculatorView: CalculatorView, didClickNumber number: String)
    
    func calculatorView(_ calculatorView: CalculatorView, didClickOperator operation: String)
}

public class CalculatorView: UIView{
    
    open var resultText: String?{
        get{
            return resultLabel?.text
        }set{
            resultLabel?.text = newValue
        }
    }
    
    open var delegate: CalculatorDelegate?
    
    var resultLabel: PaddingLabel!
    
    // 10 buttons
    var numberButtons: [UIButton]!
    
    // 8 action buttons
    var actionButtons: [UIButton]!
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        
        let spacing: CGFloat = 6
        
        resultLabel = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5))
        resultLabel.font = SystemSettings.notePadFont
        resultLabel.backgroundColor = .white
        resultLabel.layer.cornerRadius = 2
        resultLabel.layer.borderWidth = 1
        resultLabel.layer.borderColor = UIColor.black.cgColor
        resultLabel.textAlignment = .right
        numberButtons = [UIButton]()
        
        setupNumericButtons()
        
        actionButtons = [UIButton]()
        
        setupOperators()
        
        //create parent stack
        let parentStack = UIStackView()
        parentStack.axis = .vertical
        parentStack.spacing = spacing
        
        parentStack.addArrangedSubview(resultLabel)
    
        //create buttons holder
        let buttonsHolder = UIStackView()
        buttonsHolder.axis = .horizontal
        buttonsHolder.spacing = spacing
        
        parentStack.addArrangedSubview(buttonsHolder)
        
        //add constraints to [buttons holder]
        parentStack.arrangedSubviews[1]
            .heightAnchor.constraint(equalTo: parentStack.arrangedSubviews[0].heightAnchor, multiplier: 5.5).isActive = true
        
        //create left stack
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = spacing
        
        //create right stack
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.spacing = spacing
        
        //added [left] and [right] stack to [buttons holder]
        buttonsHolder.addArrangedSubview(leftStackView)
        buttonsHolder.addArrangedSubview(rightStackView)
        
        buttonsHolder.arrangedSubviews[0]
            .widthAnchor.constraint(equalTo: buttonsHolder.arrangedSubviews[1].widthAnchor, multiplier: 3.0).isActive = true
        
        
        //setup [left] stack arranged subviews
        let topLeftStackView = UIStackView(arrangedSubviews: [actionButtons[0],actionButtons[1],actionButtons[2]])
        topLeftStackView.axis = .horizontal
        topLeftStackView.distribution = .fillEqually
        topLeftStackView.spacing = spacing
        leftStackView.addArrangedSubview(topLeftStackView)
        for i in (0...2).reversed(){
            
            //c = current
            let c = i * 3
            let tempStack = UIStackView(arrangedSubviews: [numberButtons[c+1],numberButtons[c+2],numberButtons[c+3]])
            tempStack.spacing = spacing
            tempStack.axis = .horizontal
            tempStack.distribution = .fillEqually
            leftStackView.addArrangedSubview(tempStack)
        }
        
        
        let bottomLeftStackView = UIStackView(arrangedSubviews: [numberButtons[0],actionButtons[7]])
        
        //add width constraint
        bottomLeftStackView.arrangedSubviews[0]
            .widthAnchor.constraint(equalTo: bottomLeftStackView.arrangedSubviews[1].widthAnchor, multiplier: 2.0).isActive = true
        
        
        bottomLeftStackView.axis = .horizontal
        bottomLeftStackView.spacing = spacing
        leftStackView.addArrangedSubview(bottomLeftStackView)
        
        //setup [right] stack arranged subviews
        rightStackView.addArrangedSubview(actionButtons[3])
        rightStackView.addArrangedSubview(actionButtons[4])
        rightStackView.addArrangedSubview(actionButtons[5])
        rightStackView.addArrangedSubview(actionButtons[6])
        
        //add constraints
        rightStackView.arrangedSubviews[1]
            .heightAnchor.constraint(equalTo: rightStackView.arrangedSubviews[0].heightAnchor, multiplier: 1.0).isActive = true
        rightStackView.arrangedSubviews[2]
            .heightAnchor.constraint(equalTo: rightStackView.arrangedSubviews[0].heightAnchor, multiplier: 1.0).isActive = true
        rightStackView.arrangedSubviews[3]
            .heightAnchor.constraint(equalTo: rightStackView.arrangedSubviews[0].heightAnchor, multiplier: 2.0).isActive = true
        
        addSubview(parentStack)
        parentStack.translatesAutoresizingMaskIntoConstraints = false
        parentStack.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        parentStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        parentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        parentStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        
    }
    
    func setupOperators(){
        actionButtons.removeAll()
        let oprations = ["C", // 0
                         "E", // 1
                         "=", // 2
                         "*", // 3
                         "/", // 4
                         "-", // 5
                         "+", // 6
                         "."] // 7
        
        for opration in oprations{
            let button = createGenericButton()
            button.setTitle(opration, for: [])
            button.addTarget(self, action: #selector(handleOpration(sender:)), for: .touchUpInside)
            actionButtons.append(button)
        }
    }
    
    func setupNumericButtons(){
        numberButtons.removeAll()
        for i in 0...9{
            let button = createGenericButton()
            button.setTitle("\(i)", for: [])
            button.addTarget(self, action: #selector(handleNumeric(sender:)), for: .touchUpInside)
            numberButtons.append(button)
        }
    }
    
    public override func didMoveToSuperview() {
        numberButtons.forEach { (button) in
            for view in button.subviews{
                if view is UIImageView{
                    (view as! UIImageView).layer.cornerRadius = 2
                    (view as! UIImageView).layer.masksToBounds = true
                }
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
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 0
        button.titleLabel?.font = SystemSettings.notePadFont
        
        return button
    }
    
    func handleOpration(sender: UIButton){
        delegate?.calculatorView(self, didClickOperator: (sender.titleLabel?.text)!)
    }
    
    func handleNumeric(sender: UIButton){
        delegate?.calculatorView(self, didClickNumber: (sender.titleLabel?.text)!)
    }
}

class PaddingLabel: UILabel {
    
    let padding: UIEdgeInsets
    
    // Create a new PaddingLabel instance programamtically with the desired insets
    required init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) {
        self.padding = padding
        super.init(frame: CGRect.zero)
    }
    
    // Create a new PaddingLabel instance programamtically with default insets
    override init(frame: CGRect) {
        padding = UIEdgeInsets.zero // set desired insets value according to your needs
        super.init(frame: frame)
    }
    
    // Create a new PaddingLabel instance from Storyboard with default insets
    required init?(coder aDecoder: NSCoder) {
        padding = UIEdgeInsets.zero // set desired insets value according to your needs
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    // Override `intrinsicContentSize` property for Auto layout code
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
    // Override `sizeThatFits(_:)` method for Springs & Struts code
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let heigth = superSizeThatFits.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
}

extension Double {
    struct Number {
        static var formatter = NumberFormatter()
    }
    var scientificStyle: String {
        Number.formatter.numberStyle = .scientific
        Number.formatter.positiveFormat = "0.###E+0"
        Number.formatter.exponentSymbol = "e"
        return Number.formatter.string(from: NSNumber(value: self)) ?? description
    }
}
