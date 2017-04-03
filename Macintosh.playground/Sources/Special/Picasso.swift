import Foundation
import UIKit

public class Picasso: MacApp{
    
    /// The application main view
    public var container: UIView? = PaintView()
    
    public var desktopIcon: UIImage?
    
    public var identifier: String? = "picasso"
    
    public var windowTitle: String? = "Picasso"
    
    public var menuActions: [MenuAction]? = nil
    
    public var contentMode: ContentStyle = .default
    
    lazy public var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    /// Data Source function, returns the size of the container.
    public func sizeForWindow() -> CGSize {
        return CGSize(width: 364, height: 205)
    }
    
    public func clear(){
        (container as? PaintView)?.clear()
    }
    
    public func undo(){
        let paintView = (container as? PaintView)
        paintView?.didSelectUndo(sender: (paintView?.undoButton)!)
    }
    
    public init(){
        desktopIcon = UIImage.withBezierPath(pathForIcon(), size: CGSize(width: 65, height: 65))
    }
    
    func pathForIcon()->[SpecificBezierPath]{
        var sbpa = [SpecificBezierPath]()
        
        let size = MacAppDesktopView.width
        
        let radius = size/2.5
        
        let path = UIBezierPath(arcCenter: CGPoint(x: size/2,y: size/2), radius: radius, startAngle: 0.523599, endAngle: 5.75959, clockwise: true)
        let length: CGFloat = sin(1.0472) * radius
        path.addQuadCurve(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + length), controlPoint: CGPoint(x: size/2 + size / 8, y: size/2))
        path.close()
        sbpa.append(SpecificBezierPath(path: path, stroke: true, fill: true, strokeColor: .black, fillColor: .black))
        
        let objectSize = size/7
        let object1 = UIBezierPath(roundedRect: CGRect(x: size/2 + size / 10, y: size/4.2, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object1, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object2 = UIBezierPath(roundedRect: CGRect(x: size/2 - size / 8, y: size/2 - size / 3, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object2, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object3 = UIBezierPath(roundedRect: CGRect(x: size/2 - size / 3, y: size/2 - size / 8, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object3, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object4 = UIBezierPath(roundedRect: CGRect(x: size/2 - size / 4, y: size/2 + size/7, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object4, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object5 = UIBezierPath(roundedRect: CGRect(x: size/2 + size / 10, y: size/2 + size/10, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object5, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        return sbpa
    }
}


public class PaintView: UIView{
    
    var canvas: CanvasView!
    
    var colorsView: UIStackView!
    
    var colors: [UIColor] = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1),#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),#colorLiteral(red: 1, green: 0.3005838394, blue: 0.2565174997, alpha: 1),#colorLiteral(red: 1, green: 0.4863265157, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.8288275599, blue: 0, alpha: 1),#colorLiteral(red: 0.4497856498, green: 0.9784941077, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 0.8252056837, blue: 0.664467752, alpha: 1),#colorLiteral(red: 0, green: 0.8362106681, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.3225687146, blue: 1, alpha: 1),#colorLiteral(red: 0.482165277, green: 0.1738786995, blue: 0.8384277225, alpha: 1),#colorLiteral(red: 0.8474548459, green: 0.2363488376, blue: 1, alpha: 1)]
    
    var undoButton: UIButton!
    
    var brushSizeStackView: UIStackView!
    
    open func clear(){
        canvas?.clear()
        undoButton?.isEnabled = false
    }
    
    convenience public init(){
        self.init(frame: CGRect.zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        let settingsView = UIView()
        undoButton = UIButton(type: .system)
        undoButton.tintColor = .black
        undoButton.setTitle("Undo", for: [])
        undoButton.titleLabel?.font = SystemSettings.normalSizeFont
        undoButton.addTarget(self, action: #selector(didSelectUndo(sender:)), for: .touchUpInside)
        undoButton.isEnabled = false
        
        canvas = CanvasView()
        canvas.delegate = self
        canvas.backgroundColor = .clear
        
        colorsView = UIStackView()
        colorsView.axis = .vertical
        colorsView.distribution = .fillEqually
        
        brushSizeStackView = UIStackView()
        brushSizeStackView.axis = .horizontal
        brushSizeStackView.distribution = .fillEqually
        
        addSubview(canvas)
        addSubview(colorsView)
        addSubview(settingsView)
        
        colorsView.translatesAutoresizingMaskIntoConstraints = false
        colorsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        colorsView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        colorsView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.05).isActive = true
        
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.heightAnchor.constraint(equalTo: colorsView.widthAnchor, multiplier: 1.0).isActive = true
        settingsView.rightAnchor.constraint(equalTo: colorsView.leftAnchor).isActive = true
        settingsView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        settingsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        settingsView.addSubview(undoButton)
        settingsView.addSubview(brushSizeStackView)
        
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.topAnchor.constraint(equalTo: settingsView.topAnchor,constant: 4).isActive = true
        undoButton.leftAnchor.constraint(equalTo: settingsView.leftAnchor).isActive = true
        undoButton.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor,constant: -4).isActive = true
        undoButton.widthAnchor.constraint(equalTo: settingsView.widthAnchor, multiplier: 0.5).isActive = true
        
        brushSizeStackView.translatesAutoresizingMaskIntoConstraints = false
        brushSizeStackView.leftAnchor.constraint(equalTo: undoButton.rightAnchor).isActive = true
        brushSizeStackView.topAnchor.constraint(equalTo: settingsView.topAnchor).isActive = true
        brushSizeStackView.rightAnchor.constraint(equalTo: settingsView.rightAnchor).isActive = true
        brushSizeStackView.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor).isActive = true
        
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        canvas.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvas.bottomAnchor.constraint(equalTo: settingsView.topAnchor).isActive = true
        canvas.rightAnchor.constraint(equalTo: colorsView.leftAnchor).isActive = true
        
        for i in 0..<colors.count{
            let button = createColorButton(withColor: colors[i])
            button.tag = i
            button.addTarget(self, action: #selector(didSelectColor(sender:)), for: .touchUpInside)
            colorsView.addArrangedSubview(button)
        }
        
        let sizes: [CGFloat] = [2,3,4,5]
        let actualSizes = [3,5,8,12]
        for i in 0..<4{
            let button = createBrushSizeButton(withSize: sizes[i])
            button.addTarget(self, action: #selector(didSelectBrushSize(sender:)), for: .touchUpInside)
            button.tag = actualSizes[i]
            brushSizeStackView.addArrangedSubview(button)
        }
        
        (colorsView.arrangedSubviews.first as? UIButton)?.isSelected = true
        (brushSizeStackView.arrangedSubviews.first as? UIButton)?.isSelected = true
    }
    
    func didSelectBrushSize(sender: UIButton){
        
        brushSizeStackView.arrangedSubviews.forEach {
            if $0 is UIButton{
                let button = $0 as! UIButton
                button.isSelected = false
            }
        }
        
        sender.isSelected = true
        let size = CGFloat(sender.tag)
        canvas.lineWidth = size
    }
    
    func didSelectColor(sender: UIButton){
        colorsView.arrangedSubviews.forEach {
            if $0 is UIButton{
                let button = $0 as! UIButton
                button.isSelected = false
            }
        }
        
        sender.isSelected = true
        
        canvas.currentColor = colors[sender.tag]
    }
    
    func didSelectUndo(sender: UIButton){
        canvas.undo()
        if !canvas.canUndo{
            sender.isEnabled = false
        }
    }
    
    func createColorButton(withColor color: UIColor)->UIButton{
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 10, height: 10), cornerRadius: 2)
        path.lineWidth = 0.4
        let sbp = SpecificBezierPath(path: path, stroke: true, fill: true, strokeColor: .black, fillColor: color)
        let image = UIImage.withBezierPath([sbp], size: CGSize(width: 10, height: 10))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: [])
        button.setBackgroundImage(UIImage(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1996291893)), for: .selected)
        
        return button
    }
    
    func createBrushSizeButton(withSize size: CGFloat)-> UIButton{
        //2,3,4,5
        let path = UIBezierPath(roundedRect: CGRect(x: (10-size)/2, y: (10-size)/2, width: size, height: size), cornerRadius: size/2)
        let sbp = SpecificBezierPath(path: path, stroke: false, fill: true, strokeColor: .black, fillColor: .black)
        let image = UIImage.withBezierPath([sbp], size: CGSize(width: 10, height: 10))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: [])
        button.setBackgroundImage(UIImage(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1996291893)), for: .selected)
        
        return button
    }
}

extension PaintView: CanvasDelegate{
    public func didDrawIn(_ canvasView: CanvasView){
        undoButton?.isEnabled = true
    }
}

public protocol CanvasDelegate{
    func didDrawIn(_ canvasView: CanvasView)
}

public class CanvasView: UIView{
    
    struct CustomPath{
        var color: UIColor
        var width: CGFloat
        var path: UIBezierPath
    }
    
    open var currentColor: UIColor = .black
    
    open var lineWidth: CGFloat = 3
    
    open var delegate: CanvasDelegate?
    
    open var canUndo: Bool{
        return paths.count > 0
    }
    
    open func clear(){
        paths.removeAll()
        setNeedsDisplay()
    }
    
    open func undo(){
        if paths.count > 0 {
            paths.removeLast()
            setNeedsDisplay()
        }
    }
    
    private var currentPath: UIBezierPath!
    private var paths = [CustomPath]()
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPath = UIBezierPath()
        currentPath.lineWidth = lineWidth
        currentPath.move(to: touches.first!.location(in: self))
        paths.append(CustomPath(color: currentColor, width: lineWidth, path: currentPath))
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPath.addLine(to: touches.first!.location(in: self))
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didDrawIn(self)
    }
    
    
    public override func draw(_ rect: CGRect) {
        for customPath in paths{
            customPath.color.setStroke()
            customPath.path.stroke()
        }
    }
}
