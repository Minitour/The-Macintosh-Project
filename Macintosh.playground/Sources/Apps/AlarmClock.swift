import Foundation
import UIKit

public class AlarmClock: MacApp{
    
    public var desktopIcon: UIImage?
    
    public var identifier: String? = "alarmclock"
    
    public var windowTitle: String? = "Clock"
    
    public var menuActions: [MenuAction]?

    public var container: UIView?

    lazy public var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    public func sizeForWindow() -> CGSize {
        return CGSize(width: 140, height: 0)
    }
    
    init() {
        container = UIView()
    }
    
    var window: OSApplicationWindow?
    
    var isActive = false
    
    public func willLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow) {
        isActive = true
    }
    
    public func willTerminateApplication() {
        isActive = false
    }
    
    public func didLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow) {
        
        if self.window == nil {
            self.window = appWindow
            self.window?.tabBar?.drawLines = false
            self.window?.tabBar?.title = Utils.getExtendTime()
            recusiveTimer()
        }else{
            self.window?.tabBar?.title = "lol"
        }
    }
    
    var timer: Timer!
    func recusiveTimer(){
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        timer = Timer(timeInterval: 1, repeats: false) { [weak self] (timer) in
            if self != nil{
                self!.window?.tabBar?.title = Utils.getExtendTime()
                if self!.isActive == false {return}
                self?.recusiveTimer()
            }
        }
        timer.fire()
    }
}
