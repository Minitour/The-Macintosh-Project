import Foundation
import UIKit

public struct SystemSettings{
    public static var normalSizeFont: UIFont = {
        
        var font = UIFont(name: "Menlo-Regular", size: 13)!
        return font
    }()
    
    public static var notePadFont: UIFont = {
        var font = UIFont(name: "Menlo-Regular", size: 10)!
        return font
    }()
    
    public static var verboseBootTime: TimeInterval = 1
    
    public static var bootLoaderTime: TimeInterval = 7
    
    public struct resolution {
        public static var width: CGFloat = 600
        
        public static var height: CGFloat = 400
    }
}
