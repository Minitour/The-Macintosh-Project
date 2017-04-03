import Foundation
import UIKit

public protocol MacApp {
    
    /// A unique application identifier
    var uniqueIdentifier: String {get}
    
    /// A type application identifier
    var identifier: String? {get}
    
    /// The application main view
    var container: UIView? {get set}
    
    /// The application tool bar actions
    var menuActions: [MenuAction]? {get set}
    
    /// The window title of the application
    var windowTitle: String? {get set}
    
    /// The content mode style use `light` to get a black panel and `default` for a normal one.
    var contentMode: ContentStyle {get}
    
    /// Can the application be dragged around.
    var shouldDragApplication: Bool {get}
    
    /// The icon of the application if it appears on the desktop.
    var desktopIcon: UIImage? {get set}
    
    /// Delegate function, called when container will start dragging.
    func macApp(_ applicationWindow: OSApplicationWindow, willStartDraggingContainer container: UIView)
    
    /// Delegate function, called when container has finished dragging.
    func macApp(_ applicationWindow: OSApplicationWindow, didFinishDraggingContainer container: UIView)
    
    /// Called after application has launched.
    func didLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow)
    
    /// Called before application is lanuched.
    func willLaunchApplication(in view: OSWindow,withApplicationWindow appWindow: OSApplicationWindow)
    
    /// Called when application is about to be terminated.
    func willTerminateApplication()
    
    /// Data Source function, returns the size of the container.
    func sizeForWindow()->CGSize
    
}

public enum ContentStyle {
    case light
    case `default`
}

//make optionals
public extension MacApp{
    
    public var shouldDragApplication: Bool{
        return true
    }
    
    public var desktopIcon: UIImage?{
        return UIImage()
    }
    
    public var contentMode: ContentStyle{
        return .default
    }
    
    public var identifier: String?{
        return nil
    }
    
    public var menuActions: [MenuAction]? {
        return nil
    }
    
    public func didLaunchApplication(in view: OSWindow, withApplicationWindow appWindow: OSApplicationWindow){}
    
    public func willLaunchApplication(in view: OSWindow,withApplicationWindow appWindow: OSApplicationWindow){}
    
    public func willTerminateApplication(){}
    
    public func macApp(_ applicationWindow: OSApplicationWindow, willStartDraggingContainer container: UIView){}
    
    public func macApp(_ applicationWindow: OSApplicationWindow, didFinishDraggingContainer container: UIView){}
}
