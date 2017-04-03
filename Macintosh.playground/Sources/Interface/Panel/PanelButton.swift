import UIKit

public class PanelButton: UIButton{
    
    
    public override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        getInnerRectPath(rect).stroke()
        
        //UIColor.white.setFill()
        //UIBezierPath(rect: rect).fill()
    }
    
    func getInnerRectPath(_ rect: CGRect)->UIBezierPath{
        let lineWidth: CGFloat = 1
        let innerRect = CGRect(x: rect.origin.x + lineWidth,
                               y: rect.origin.y + lineWidth,
                               width: rect.width - lineWidth * 2,
                               height: rect.height - lineWidth * 2)
        
        let path = UIBezierPath(rect: innerRect)
        path.lineWidth = lineWidth
        return path
    }
}

