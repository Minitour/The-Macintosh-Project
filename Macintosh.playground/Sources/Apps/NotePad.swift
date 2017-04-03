import Foundation
import UIKit



public class NotePad: MacApp{

    public var desktopIcon: UIImage?
    
    public var identifier: String? = "notepad"
    
    public var windowTitle: String? = "Note Pad"
    
    public var menuActions: [MenuAction]? = nil
    
    public var currentText: [String]
    
    lazy public var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    public var notesCount:Int {
        return currentText.count
    }
    
    public init(withIdentifier id: String = "notepad"){
        identifier = id
        currentText = Array(repeating: "", count: 8)
        currentText[0] = "Hello world"
        container = NotePadView()
        container?.backgroundColor = .clear
        (container as? NotePadView)?.delegate = self
        (container as? NotePadView)?.dataSource = self
    }
    
    public var container: UIView?
    
    public func reloadData(){
        (container as? NotePadView)?.updateInterface()
    }
    
    public func willTerminateApplication() {
        
    }
    
    public func willLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow) {
        
    }
    
    public func didLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow) {
        
    }
    
    public func sizeForWindow() -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
}

extension NotePad: NotePadDelegate{
    public func notePad(_ notepad: NotePadView, didChangeText text: String, atIndex index: Int) {
        self.currentText[index] = text
    }
    
    public func notePad(_ notepad: NotePadView, didChangePageTo index: Int) {
        
    }
}

extension NotePad: NotePadDataSource{
    public func notePad(_ notepad: NotePadView, textForPageAtIndex index: Int) -> String? {
        return currentText[index]
    }
    
    public func numberOfNotes(_ notepad: NotePadView) -> Int {
        return notesCount
    }
}

public protocol NotePadDelegate {
    
    /// Delegate Function, called when user changes pages.
    ///
    /// - Parameters:
    ///   - notepad: The notepad view.
    ///   - index: The new page which the notepad switched to.
    func notePad(_ notepad: NotePadView,didChangePageTo index: Int)
    
    
    /// Delegaet Function, called when user types in the notepad.
    ///
    /// - Parameters:
    ///   - notepad: The notepad view.
    ///   - text: The new text.
    ///   - index: The page at which the user typed.
    func notePad(_ notepad: NotePadView, didChangeText text: String, atIndex index: Int)
}

public protocol NotePadDataSource {
    
    
    /// Data Source Function, used to determine the amount of pages the notepad contains.
    ///
    /// - Parameter notepad: The notepad view.
    /// - Returns: The number of pages for the notepad.
    func numberOfNotes(_ notepad: NotePadView)->Int
    
    
    /// Data Source Function, used to determine the text for a certain page.
    ///
    /// - Parameters:
    ///   - notepad: The notepad view.
    ///   - index: The index for which we want to specify the text.
    /// - Returns: A String that will be set on the notepad at a certain page.
    func notePad(_ notepad: NotePadView,textForPageAtIndex index: Int)->String?
}

public class NotePadView: UIView{
    
    /// The textview which displays the text.
    var textView: UITextView!
    
    /// The label which displays the current page.
    var pageLabel: UILabel!
    
    /// The delegate of the notepad.
    open var delegate: NotePadDelegate?
    
    /// The data source of the notepad.
    open var dataSource: NotePadDataSource?{ didSet{updateInterface()}}
    
    open var pageCurlAnimationDuration: TimeInterval = 0.1
    
    /// The current page of the notepad.
    private (set) open var currentPage: Int = 0
    
    /// The aspect ratio which determines the page curl section size
    let pageCurlRatio: CGFloat = 0.1
    
    /// Computed variable to get the page count.
    var pageCount: Int {
        return dataSource?.numberOfNotes(self) ?? 0
    }
    
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
    
    override public func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        getLines(rect).forEach { $0.stroke()}
    }
    
    func getLines(_ rect: CGRect)->[UIBezierPath]{
        
        var arrayOfLines = [UIBezierPath]()
        
        let space: CGFloat = 2
        let startingPoint = rect.height - 2
        
        for i in 0...1{
            
            let y = startingPoint - space * CGFloat(i)
            let startX = rect.minX
            let endX = rect.maxX
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: startX, y: y))
            path.addLine(to: CGPoint(x: endX, y: y))
            path.lineWidth = 1
            arrayOfLines.append(path)
        }
        
        let specialPath = UIBezierPath()
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = rect.width * pageCurlRatio
        specialPath.move(to: CGPoint(x: rect.maxX, y: specialY))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        specialPath.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize ,y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        specialPath.lineWidth = 1
        
        arrayOfLines.append(specialPath)
        
        return arrayOfLines
        
    }
    
    
    /// Primary setup function of the view.
    func setup(){
        layer.masksToBounds = true
        textView = UITextView()
        textView.font = SystemSettings.notePadFont
        textView.tintColor = .black
        textView.backgroundColor = .clear
        textView.delegate = self
        
        addSubview(textView)
        
        pageLabel = UILabel()
        pageLabel.font = SystemSettings.notePadFont
        addSubview(pageLabel)
        
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: pageLabel.topAnchor, constant: -8).isActive = true
        textView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
    }
    
    override public func didMoveToSuperview() {
        //setup bottom anchor when view is moved to superview. This is done here because in the setup the view frame size is still 0.
        pageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(frame.size.width * pageCurlRatio)/2).isActive = true
    }
    
    /// Handle Tap is a targer function that handles the tap gesture recognizer that is set on the view.
    ///
    /// - Parameter sender: The Tap Gesture Recognizer
    func handleTap(sender: UITapGestureRecognizer){
        
        //declare function that checks if point is within 3 points
        func isPointInTriangle(point: CGPoint,
                               a:CGPoint,
                               b:CGPoint,
                               c:CGPoint)->Bool{
            let as_x: CGFloat = point.x - a.x
            let as_y: CGFloat = point.y - a.y
            let s_ab: Bool = (b.x-a.x) * as_y - (b.y-a.y) * as_x > 0
            if((c.x - a.x) * as_y - (c.y - a.y) * as_x > 0) == s_ab {return false}
            if((c.x - b.x) * (point.y - b.y) - (c.y - b.y) * (point.x - b.x) > 0) != s_ab {return false}
            return true
        }
        //touch location
        let point = sender.location(in: self)
        
        //declare the area rect of the page curl
        let scaleSize = self.bounds.width * pageCurlRatio
        let areaOfSelection = CGRect(x: 0,
                                     y: self.bounds.maxY - scaleSize - 6,
                                     width: scaleSize,
                                     height: scaleSize)
        
        //check if touch point is on page curl
        if areaOfSelection.contains(point){
            
            let startScale: CGAffineTransform
            let endScale: CGAffineTransform
            let startCenter: CGPoint
            let endCenter: CGPoint
            let forward: Bool
            let oldIndex = currentPage
            
            //check if touch point is in the lower triangle or the upper triangle
            if isPointInTriangle(point: point,
                              a: CGPoint(x: areaOfSelection.minX,y:areaOfSelection.minY),
                              b: CGPoint(x: areaOfSelection.minX,y:areaOfSelection.maxY),
                              c: CGPoint(x: areaOfSelection.maxX,y:areaOfSelection.maxY)){
                //go backward
                goBackward()
                startScale = CGAffineTransform(scaleX: 0.1, y: 0.1)
                endScale = .identity
                startCenter = CGPoint(x: self.bounds.maxX, y: self.bounds.minY)
                endCenter = self.center
                forward = false
            }else{
                //go forward
                goForward()
                startScale = CGAffineTransform(scaleX: 0.9, y: 0.9)
                endScale = CGAffineTransform(scaleX: 0.1, y: 0.1)
                startCenter = self.center
                endCenter = CGPoint(x: self.bounds.maxX, y: self.bounds.minY)
                forward = true
            }
            
            //animate page curl
            let view = DummyNotePad(frame: self.frame)
            view.textView.frame = textView.frame
            view.pageLabel.frame = pageLabel.frame
            view.textView.text = dataSource?.notePad(self, textForPageAtIndex: (forward ? oldIndex : currentPage))
            view.textView.isEditable = false
            view.pageLabel.text = "\((forward ? oldIndex : currentPage) + 1)"
            view.backgroundColor = .white
            self.addSubview(view)
            view.center = startCenter
            view.transform = startScale
            UIView.animate(withDuration: pageCurlAnimationDuration, animations: {
                view.center = endCenter
                view.transform = endScale
            }, completion: {(complete) in
                
                if !forward{
                    self.updateInterface()
                    self.delegate?.notePad(self, didChangePageTo: self.currentPage)
                }
                view.removeFromSuperview()
            })
            if forward {
                self.updateInterface()
                self.delegate?.notePad(self, didChangePageTo: self.currentPage)
            }
        }
    }
    
    /// This function updates the interface, it updates the current page label and the current display text.
    open func updateInterface(){
        self.pageLabel.text = "\(currentPage+1)"
        self.textView.text = dataSource?.notePad(self, textForPageAtIndex: currentPage) ?? ""
    }
    
    /// Function updates the current page to move forward. If the next page is "greater" than the amount of pages in the notepad then the current page will be set to 0.
    func goForward(){
        if currentPage + 1 > pageCount - 1{
            currentPage = 0
        }else{
            currentPage += 1
        }
    }
    
    /// Function updates the current page to move backward. If the next page is "less" than 0 (negative value), then the current page will be set to the max amount of pages.
    func goBackward(){
        if currentPage - 1 < 0 {
            currentPage = pageCount - 1
        }else{
            currentPage -= 1
        }
    }
    
}

class DummyNotePad: UIView{
    
    /// The textview which displays the text.
    open var textView: UITextView!
    
    /// The label which displays the current page.
    open var pageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = getShapePath(frame).cgPath
        layer.mask = borderLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        backgroundColor = .red
        textView = UITextView()
        textView = UITextView()
        textView.font = SystemSettings.notePadFont
        textView.tintColor = .black
        textView.backgroundColor = .clear
        addSubview(textView)
        
        pageLabel = UILabel()
        pageLabel.font = SystemSettings.notePadFont
        addSubview(pageLabel)
    }
    
    override func draw(_ rect: CGRect) {
        
        UIColor.white.setFill()
        getShapePath(rect).fill()
        
        UIColor.black.setStroke()
        getLine(rect).stroke()
        
        let space: CGFloat = 2
        let startingPoint = rect.height - 2
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = rect.width * pageCurlRatio
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0,y:0))
        path.addLine(to: CGPoint(x: 0 ,y: specialY - curlSize))
        path.lineWidth = 1
        path.stroke()
    }
    
    let pageCurlRatio: CGFloat = 0.3
    let space: CGFloat = 2
    
    //get the path of the shape needed
    func getShapePath(_ rect: CGRect)-> UIBezierPath{
        let startingPoint = rect.height - 2
        let shapePath = UIBezierPath()
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = rect.width * pageCurlRatio
        shapePath.move(to: CGPoint(x: rect.maxX, y: specialY))
        shapePath.addLine(to: CGPoint(x: curlSize, y: specialY))
        shapePath.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        shapePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        shapePath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        shapePath.close()
        
        return shapePath
    }
    
    //get the lines to draw
    func getLine(_ rect: CGRect)->UIBezierPath{
        
        let startingPoint = rect.height - 2
        let specialPath = UIBezierPath()
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = rect.width * pageCurlRatio
        specialPath.move(to: CGPoint(x: rect.maxX, y: specialY))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        specialPath.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize ,y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        specialPath.lineWidth = 1
        return specialPath
        
    }
}

extension NotePadView: UITextViewDelegate{
    public func textViewDidChange(_ textView: UITextView) {
        self.delegate?.notePad(self, didChangeText: textView.text, atIndex: currentPage)
    }
}
