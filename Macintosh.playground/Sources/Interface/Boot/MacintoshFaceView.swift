import Foundation
import UIKit

public class MacintoshFaceView: UIView {
    
    open class func getFacePathFor(rect: CGRect)->UIBezierPath{
        let path = UIBezierPath()
        path.append(MacintoshFaceView.getHeadPath(rect))
        path.append(MacintoshFaceView.getMouthPath(rect))
        path.append(MacintoshFaceView.getLeftEyePath(rect))
        path.append(MacintoshFaceView.getRightEyePath(rect))
        path.append(MacintoshFaceView.getNosePath(rect))

        return path
    }
    
    override public func draw(_ rect: CGRect) {
        UIColor.black.set()
        UIColor.clear.setFill()
        MacintoshFaceView.getHeadPath(rect).stroke()
        MacintoshFaceView.getMouthPath(rect).stroke()
        MacintoshFaceView.getLeftEyePath(rect).stroke()
        MacintoshFaceView.getRightEyePath(rect).stroke()
        MacintoshFaceView.getNosePath(rect).stroke()
    }
    
    class func getHeadPath(_ rect: CGRect)->UIBezierPath{
        let height = rect.height
        let width = rect.width
        let spacingAspectRatio: CGFloat = 0.125
        let heightAspectRatio: CGFloat = 0.75
        let rect = CGRect(x: 0, y: height * spacingAspectRatio, width: width, height: height * heightAspectRatio)
        let path = UIBezierPath(rect: rect)
        return path
    }
    
    class func getMouthPath(_ rect: CGRect)->UIBezierPath{
        let height = rect.height
        let width = rect.width
        let headHeight = rect.height * 0.75
        
        let spaceHorizontal = width * 0.125
        let spaceVertical = height * 0.2 * 0.5
        let startPoint = CGPoint(x: spaceHorizontal, y: headHeight - spaceVertical)
        let endPoint  = CGPoint(x: width - spaceHorizontal, y: headHeight - spaceVertical)
        let controlPoint1 = CGPoint(x: startPoint.x + width / 3, y: startPoint.y + spaceVertical)
        let controlPoint2 = CGPoint(x: endPoint.x - width / 3, y: startPoint.y + spaceVertical)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        path.lineWidth = 3.0
        return path
    }
    
    class func getLeftEyePath(_ rect: CGRect)->UIBezierPath{
        let height = rect.height
        let width = rect.width
        
        let spaceHorizontal = width * 0.3
        let eyeHeight = height * 0.1
        let start = CGPoint(x: spaceHorizontal , y: height * 0.3)
        let end = CGPoint(x: start.x, y: start.y + eyeHeight)
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = 3.0
        return path
    }
    
    class func getRightEyePath(_ rect: CGRect)->UIBezierPath{
        let height = rect.height
        let width = rect.width
        
        let spaceHorizontal = width * 0.3
        let eyeHeight = height * 0.1
        let start = CGPoint(x: width - spaceHorizontal , y: height * 0.3)
        let end = CGPoint(x: start.x, y: start.y + eyeHeight)
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = 3.0
        return path
    }
    
    class func getNosePath(_ rect: CGRect)->UIBezierPath{
        let width = rect.width
        let headHeight = rect.height * 0.75
        
        let pt1 = CGPoint(x: rect.midX + width * 0.1, y: 0)
        let pt2 = CGPoint(x: rect.midX - width * 0.05, y: headHeight - width * 0.125 * 1.5)
        let pt3 = CGPoint(x: rect.midX + width * 0.05, y: pt2.y)
        let pt4 = CGPoint(x: pt1.x, y: rect.maxY)
        
        let ctrl1 = CGPoint(x: pt2.x, y:  abs(pt1.y - pt2.y)/2)
        let ctrl2 = CGPoint(x: rect.midX , y: headHeight)
        let path = UIBezierPath()
        path.move(to: pt1)
        path.addQuadCurve(to: pt2, controlPoint: ctrl1)
        path.addLine(to: pt2)
        path.addLine(to: pt3)
        path.addQuadCurve(to: pt4, controlPoint: ctrl2)
        path.addLine(to: pt4)
        path.lineWidth = 3.0
        return path
    }
    
}
