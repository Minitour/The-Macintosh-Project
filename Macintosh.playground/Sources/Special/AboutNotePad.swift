import Foundation
import UIKit

public class AboutMe: NotePad{
    
    
    
    override public func sizeForWindow() -> CGSize {
        let superSize = super.sizeForWindow()
        return CGSize(width: superSize.width * 2, height: superSize.height)
    }
    
    override public init(withIdentifier id: String) {
        super.init(withIdentifier: id)

        currentText = Array(repeating: "", count: 5)
        currentText[0] = "Hello friend,\n\nMy name is Antonio Zaitoun, but you can call me Tony...\n\nI'm currently 19 y.o and I am a student at the University Of Haifa, taking Information Systems."
        currentText[1] = "I decided to make this playground all about the original Mac OS System 1, mostly due to the limitations that were set, where we are not suppose to make any network activity. So I thought about this for a while and I finally said \"Why not just go back in time, to the age where the internet wasn't really a thing\"\n\nAnd so here we are..."
        currentText[2] = "I started my journey in the world of computer science back in high school, where they taught us C# and Java, and then they taught us how to develop native applications for Android.\n\nI fell in love with the concept of programing and developing, which was the point where I decided to learn mobile application development."
        currentText[3] = "After graduating from high school (I was 17 at the time) I took a course which taught me iOS and Android.\n\n Fast forward A year later and I started working at this company, and I was then also accepted to the university."
        currentText[4] = "I absolutely love creating and designing new things, especially when those things can help others.\n\nI hope you enjoy this little recreation of Mac OS System 1 in Swift, I had a blast working on it."
        
        reloadData()
        
        (container as? NotePadView)?.textView.isEditable = false
        (container as? NotePadView)?.textView.isSelectable = false
        desktopIcon = UIImage.withBezierPath(pathForIcon(), size: CGSize(width: 65, height: 65))
    }
    
    
    func pathForIcon()->[SpecificBezierPath]{
        var sbpa = [SpecificBezierPath]()
        
        let background = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 65, height: 65), cornerRadius: 5)
        sbpa.append(SpecificBezierPath(path: background, stroke: true, fill: true, strokeColor: .black, fillColor: .white))
        
        
        let facePath = MacintoshFaceView.getFacePathFor(rect: CGRect(x: 0, y: 0, width: 65, height: 65))
        sbpa.append(SpecificBezierPath(path: facePath, stroke: true, fill: false, strokeColor: .black, fillColor: .clear))
        
        
        return sbpa
    }
    
    
    
}
