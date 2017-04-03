import Foundation
import UIKit

public class HelpNotePad: NotePad{
    
    
    override public init(withIdentifier id: String) {
        super.init(withIdentifier: id)

        identifier = "guide"
        
        windowTitle = "Guide"
        
        currentText = Array(repeating: "", count: 10)
        currentText[0] = "Welcome to Mac OS System 1!\n\nYou can click the curled page to navigate inside within the notepad.\n\nClick the upper triangle to move forward and the lower triangle to move backwards\n\n\nGo ahead and click it!\n↙ ↙ ↙"
        currentText[1] = "Did you notice that awesome animation? I did.\n\n Anyways moving on...\n\nYou can actually drag the applications around by grabbing them by the upper part of the panel.\n\n\n\nContinue to next page..."
        currentText[2] = "By clicking the  menu you will see a list of applications that you can use...\n\nGo ahead and open the Calculator app and tell me how much is 32x54?"
        currentText[3] = "Did you get 1728? well then good job! if you got something else then it means I failed at making a functioning calculator...\n\nAlright now go ahead and close the calculator by clicking the white empty square above it."
        currentText[4] = "You see those desktop applications? Did you know you can move them around by dragging them? You can also open them by double clicking them.\n\nGo ahead and open up the `About Me` application. In there you can find some background history about myself."
        currentText[5] = "Well that's it for the tutorial...\n\nYou are more than welcome to explore the OS :)\n\n\n\n\n\n\n\n ~Tony"
        currentText[9] = "Hey mate you got to page 10!\n\n\n\nClick the UPPER triangle (the curl) in order to move forward, and lower triangle in order to move backward."
        
        reloadData()
        (container as? NotePadView)?.textView.isEditable = false
        (container as? NotePadView)?.textView.isSelectable = false
        desktopIcon = UIImage.withBezierPath(HelpNotePad.iconAsPath(), size: CGSize(width: 65, height: 65))
    }
    
    
    static func iconAsPath()->[SpecificBezierPath]{
        
        var sbpa = [SpecificBezierPath]()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 60))
        path.addLine(to: CGPoint(x: 55, y: 60))
        path.addLine(to: CGPoint(x: 55, y: 65*0.2))
        path.addLine(to: CGPoint(x: 55 - 65*0.2, y: 0))
        path.lineWidth = 1
        path.close()
        
        sbpa.append(SpecificBezierPath(path: path, stroke: true, fill: true, strokeColor: .black, fillColor: .white))
        
        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: 55 - 65*0.2, y: 0))
        triangle.addLine(to: CGPoint(x: 55 - 65*0.2, y: 65*0.2))
        triangle.addLine(to: CGPoint(x: 55, y: 65*0.2))
        
        sbpa.append(SpecificBezierPath(path: triangle, stroke: true, fill: false, strokeColor: .black, fillColor: .clear))
        
        let space: CGFloat = 3
        for i in 0...4{
            let path = UIBezierPath(rect: CGRect(x: 35/2, y: CGFloat(i) * (space + 2) + 20, width: 30, height: 2))
            sbpa.append(SpecificBezierPath(path: path, stroke: false, fill: true, strokeColor: .clear, fillColor: .black))
        }
        
        return sbpa
    }
}
