import Foundation
import UIKit

public class Puzzle: MacApp{
    
    public var desktopIcon: UIImage?
    
    static let BOARD_SIZE:Int = 4
    
    var model: PuzzleDataModel
    
    lazy public var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    public var identifier: String? = "puzzle"
    
    public var contentMode: ContentStyle = .light
    
    public init(){
        model = PuzzleDataModel(size: Puzzle.BOARD_SIZE)
        let main = UIView()
        main.backgroundColor = UIColor.gray
        let puzzleView = PuzzelView(Puzzle.BOARD_SIZE)
        puzzleView.backgroundColor = .white
        main.addSubview(puzzleView)
        puzzleView.translatesAutoresizingMaskIntoConstraints = false
        puzzleView.delegate = self
        puzzleView.dataSource = self
        puzzleView.topAnchor.constraint(equalTo: main.topAnchor, constant: 4).isActive = true
        puzzleView.leftAnchor.constraint(equalTo: main.leftAnchor, constant: 4).isActive = true
        puzzleView.bottomAnchor.constraint(equalTo: main.bottomAnchor, constant: -4).isActive = true
        puzzleView.rightAnchor.constraint(equalTo: main.rightAnchor, constant: -4).isActive = true
        container = main
    }
    
    public var windowTitle: String? = "Puzzle"
    
    public func sizeForWindow() -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    public var menuActions: [MenuAction]?
    
    public var container: UIView?
    
    
    
}

extension Puzzle: PuzzleDelegate{
    public func puzzleView(_ puzzleView: PuzzelView, didSelectTileAt point: Point) {
        self.model.touch(at: point, inside: puzzleView)
    }
    
    
}

extension Puzzle: PuzzleDataSource{
    public func numbersForPuzzle() -> [[String]] {
        return self.model.numbers
    }
}

public struct Point{
    var x: Int = 0
    var y: Int = 0
    
    static func == (left: Point, right:Point)->Bool{
        return (left.x == right.x && left.y == right.x)
    }
}

public struct PuzzleDataModel{
    
    var boardSize: Int
    
    var numbers: [[String]]
    
    public init(size boardSize: Int) {
        self.boardSize = boardSize
        numbers = Array(repeating: Array(repeating: "0",count: boardSize), count: boardSize)
        generateNumbers()
    }
    
    public mutating func touch(at point: Point,inside puzzleView: PuzzelView?=nil){
        if isSlideNearSpace(point){
            //switch slides
            
            if let c = currentSpaceSlide(){
                numbers[c.x][c.y] = numbers[point.x][point.y]
                numbers[point.x][point.y] = ""
                puzzleView?.setNeedsDisplay()
            }
            
            let gameFinished = isGameFinished()
            //Todo:
            // display dialog to close game or restart game.
        }
    }
    
    public func isGameFinished()->Bool{
        var counter = 1
        for i in 0..<boardSize{
            for j in 0..<boardSize{
                let value = Int(numbers[i][j]) ?? (boardSize * boardSize)
                if value == counter {
                    counter += 1
                }else{
                    return false
                }
            }
        }
        return true
    }
    
    func currentSpaceSlide()->Point? {
        for i in 0..<boardSize{
            for j in 0..<boardSize{
                if numbers[i][j] == "" {
                    return Point(x: i, y: j)
                }
            }
        }
        return nil
    }
    
    func isSlideNearSpace(_ slide: Point)->Bool{
        //check up
        let up = ((slide.y + 1) < boardSize) && (numbers[slide.x][slide.y + 1] == "")
        //check down
        
        let down = ((slide.y - 1) >= 0) && (numbers[slide.x][slide.y - 1] == "")
        
        //check left
        
        let left = ((slide.x - 1) >= 0) && (numbers[slide.x - 1][slide.y] == "")
        
        //check right
        
        let right = ((slide.x + 1) < boardSize) && (numbers[slide.x + 1][slide.y] == "")
        
        return up || down || left || right
    }
    
    
    public mutating func generateNumbers(){
        
        //create array with size 16 that contains numbers from 0...15
        var array = Array(repeating: 0, count: boardSize * boardSize)
        
        for i in 1...(boardSize * boardSize - 1) {array[i] = i}
        
        var shuffledArray = [Int]()
        
        while !array.isEmpty {
            shuffledArray.append(array.remove(at: Int(arc4random_uniform(UInt32(array.count)))))
        }
        
        //convert 1 dim array to 2 dim array
        for i in 0..<boardSize {
            for j in 0..<boardSize{
                let value = shuffledArray.removeFirst()
                numbers[i][j] = value == 0 ? "" : "\(value)"
            }
        }
    }
}

public protocol PuzzleDataSource {
    
    func numbersForPuzzle()-> [[String]]
}

public protocol PuzzleDelegate{
    
    func puzzleView(_ puzzleView: PuzzelView, didSelectTileAt point: Point)
}

public class PuzzelView: UIView{
    
    var boardSize: Int
    
    var numbers: [[String]]{
        return dataSource!.numbersForPuzzle()
    }
    
    open var delegate: PuzzleDelegate?
    
    open var dataSource: PuzzleDataSource?
    
    convenience init(_ boardSize: Int){
        self.init(frame: CGRect.zero)
        self.boardSize = boardSize
        
    }
    
    override init(frame: CGRect) {
        self.boardSize = 4
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
    }
    
    var ratio: CGFloat{
        return CGFloat(1/Double(boardSize))
    }
    
    public override func draw(_ rect: CGRect) {
        UIColor.black.set()
        let borderPath = UIBezierPath(rect: rect)
        borderPath.lineWidth = 1
        borderPath.stroke()
        getLines(rect).forEach { $0.stroke()}
        let attributes: [String : Any] = [NSForegroundColorAttributeName: UIColor.black,
                          NSFontAttributeName: SystemSettings.notePadFont]
        let w = rect.width
        let h = rect.height
        for i in 0..<boardSize {
            for j in 0..<boardSize {
              let str = NSAttributedString(string: numbers[i][j], attributes: attributes)
                str.draw(at: CGPoint(x: CGFloat(i) * ratio * w + w * (ratio/2) - str.size().width/2,
                                     y: CGFloat(j) * ratio * h + h * (ratio/2) - str.size().height / 2))
                
                if str.string == "" {
                    let rect = CGRect(x: CGFloat(i) * ratio * w + 0.5 , y: CGFloat(j) * ratio * h + 0.5 , width: w * ratio - 1, height: h * ratio - 1)
                    let path = UIBezierPath(rect: rect)
                    #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1).setFill()
                    path.fill()
                }
            }
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer){
        let point = sender.location(in: self)
        let rectSize = CGSize(width: bounds.width * ratio, height: bounds.height * ratio)
        
        for i in 0..<boardSize{
            if (point.x < CGFloat(i+1) * rectSize.width) && (point.x > CGFloat(i) * rectSize.width){
                for j in 0..<boardSize{
                    if (point.y < CGFloat(j+1) * rectSize.height) && (point.y > CGFloat(j) * rectSize.height){
                        delegate?.puzzleView(self, didSelectTileAt: Point(x: i, y: j))
                    }
                }
            }
        }
    }
    
    private func getLines(_ rect: CGRect)-> [UIBezierPath]{
        
        var lines = [UIBezierPath]()
        
        let w = rect.width
        let h = rect.height
        for i in 1..<boardSize{
            let path = UIBezierPath()
            path.move(to: CGPoint(x: CGFloat(i) * ratio * w, y: 0))
            path.addLine(to: CGPoint(x:  CGFloat(i) * ratio * w, y: h))
            path.lineWidth = 1
            lines.append(path)
        }
        for i in 1..<boardSize{
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0 , y: CGFloat(i) * ratio * h))
            path.addLine(to: CGPoint(x:  w , y: CGFloat(i) * ratio * h))
            path.lineWidth = 1
            lines.append(path)
        }
        
        return lines
    }

}
