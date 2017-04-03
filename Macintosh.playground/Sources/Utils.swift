import Foundation
import UIKit

public class Utils{
    
    class func widthForView(_ text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.textAlignment = .center
        label.sizeToFit()
        return label.frame.width
    }
    
    class func heightForView(_ text:String, font:UIFont, width:CGFloat,numberOfLines: Int = 1) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.textAlignment = .center
        label.sizeToFit()
        return label.frame.height
    }
    
    class func getCurrentTime()->String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: Date())
    }
    
    class func getExtendTime()->String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        return timeFormatter.string(from: Date())
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

public struct SpecificBezierPath{
    var path:UIBezierPath
    var stroke: Bool
    var fill: Bool
    var strokeColor: UIColor = .black
    var fillColor: UIColor = .clear
}

extension UIImage {
    
    public static func withBezierPath(_ paths: [SpecificBezierPath],
                                      size: CGSize,
                                      scale: CGFloat = UIScreen.main.scale)->UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        for item in paths{
            if item.fill {
                item.fillColor.setFill()
                item.path.fill()
            }
            if item.stroke {
                item.strokeColor.setStroke()
                item.path.stroke()
            }
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public extension CGSize{
    public static func + (left: CGSize, right: CGSize)->CGSize{
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }
}
