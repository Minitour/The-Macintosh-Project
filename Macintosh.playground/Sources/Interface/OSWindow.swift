import Foundation
import UIKit

public class OSWindow: UIView{
    
    var applicationIdentifiers: [String : OSApplicationWindow] = [:]
    
    //Other apps
    var activeApplications: [MacApp]!
    
    var desktopApplications: [DesktopApplication]!
    
    //The finder app
    lazy var rootApplication: MacApp = { [weak self] in
        let finder = Finder()
        finder.window = self
        return finder
    }()
    
    var toolBar: OSToolBar?{
        get{
            for view in subviews{
                if view is OSToolBar{
                    return view as? OSToolBar
                }
            }
            return nil
        }
    }
    
    convenience public init(withRes res: CGSize) {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: res)
        self.init(frame: rect)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Sorry m8 there is no coder here")
    }
    
    func setup(){
        activeApplications = [MacApp]()
        desktopApplications = [DesktopApplication]()
    }
    
    
    /// The applications that appear when clicking the  menu.
    lazy var osMenus: [MenuAction]  = {
        var menus = [MenuAction]()
        menus.append(MenuAction(title: "About the Finder...", action: {
            let newApplicationWindow = self.createApplication(from: self.rootApplication)
            self.loadApplication(newApplicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(type: .seperator))
        
        menus.append(MenuAction(title: "Alarm Clock", action: {
            let applicationWindow = self.createApplication(from: AlarmClock())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(title: "Calculator", action: {
            let applicationWindow = self.createApplication(from: Calculator())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(title: "Control Panel", enabled: false))
        
        menus.append(MenuAction(title: "Key Caps", action: {
            let applicationWindow = self.createApplication(from: KeyCaps())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(title: "Note Pad", action: {
            let applicationWindow = self.createApplication(from: NotePad())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(title: "Puzzle", action: {
            let applicationWindow = self.createApplication(from: Puzzle())
            self.loadApplication(applicationWindow)
            
        }, subMenus: nil))
        
        menus.append(MenuAction(title: "Scrapbook", enabled: false))
        
        return menus
    }()
    
    /// A helper function that creates an instance of OSApplicationWindow using an instance of a MacApp. Note however that if the app exists in memory then it will return it.
    func createApplication(from app: MacApp)->OSApplicationWindow{
        let applicationWindow = OSApplicationWindow()
        applicationWindow.backgroundColor = .white
        applicationWindow.delegate = self
        applicationWindow.dataSource = app
        
        let nApp: OSApplicationWindow = applicationIdentifiers[(applicationWindow.dataSource?.identifier ??
            (applicationWindow.dataSource?.uniqueIdentifier ?? ""))] ?? applicationWindow
        
        return nApp
    }
    
    
    /// Checks if application `MacApp` exists in memory.
    ///
    /// - Parameter app: The app that contains an identifier which we want to check.
    /// - Returns: true if the app exists, else false.
    func doesApplicationExistInMemory(app: MacApp)->Bool{
        if let _ = applicationIdentifiers[(app.identifier ??
            (app.uniqueIdentifier ))]{
            return true
        }else{
            return false
        }
    }
    
    
    /// Load an OSApplicationWindow
    ///
    /// - Parameter app: The OSApplicationWindow which we want to load into the OSWindow.
    open func loadApplication(_ app: OSApplicationWindow){
        loadApplication(app, under: toolBar!)
    }
    
    
    /// Load an OSApplicationWindow under a certain toolbar.
    ///
    /// - Parameters:
    ///   - app: The OSApplicationWindow which we want to load into the OSWindow.
    ///   - toolbar: The toolbar which we are loading the application under.
    open func loadApplication(_ app: OSApplicationWindow,under toolbar: OSToolBar){
        
        let nApp: OSApplicationWindow = applicationIdentifiers[(app.dataSource?.identifier ?? (app.dataSource?.uniqueIdentifier ?? ""))] ?? app
        nApp.dataSource?.willLaunchApplication(in: self, withApplicationWindow: app)
        
        if let identifier: String = app.dataSource?.identifier{
            
            //check if unique id exists already
            if let applicationWindow = self.applicationIdentifiers[identifier]{
                
                //check if window is already subview
                if applicationWindow.isDescendant(of: self){
                    //bring to front
                    bringAppToFront(applicationWindow)
                    return
                }else{
                    //add subview
                    toolbar.requestCloseAllMenus()
                    addAppAsSubView(applicationWindow)
                }
            }else{
                //add application to UI and IDs
                applicationIdentifiers[identifier] = app
                toolbar.requestCloseAllMenus()
                addAppAsSubView(app)
            }
        }else{
            //add application to ui without adding unique id
            toolbar.requestCloseAllMenus()
            addAppAsSubView(app)
        }
        
        nApp.dataSource?.didLaunchApplication(in: self, withApplicationWindow: nApp)
    }
    
    func addAppAsSubView(_ application: OSApplicationWindow){
        insertSubview(application, belowSubview: toolBar!)
        activeApplications.append(application.dataSource!)
        if application.frame.origin == CGPoint.zero {
            application.center = center
        }
        application.layoutIfNeeded()
        
    }
    
    func bringAppToFront(_ application: OSApplicationWindow){
        
        let id: String = application.dataSource!.uniqueIdentifier
        var i = 0
        for app in activeApplications{
            if app.uniqueIdentifier == id {
                activeApplications.append(activeApplications.remove(at: i))
                break
            }
            i += 1
        }
        bringSubview(toFront: application)
        bringSubview(toFront: toolBar!)
    }
    
    
    /// The `close` function is a function that is used to terminate a certain application.
    ///
    /// - Parameter app: The app which we want to terminate.
    open func close(app: MacApp){
        if let nApp: OSApplicationWindow = applicationIdentifiers[(app.identifier ?? (app.uniqueIdentifier))]{            
            nApp.close()
        }else{
        }
    }
    
    
    /// The `add` function allows us to load desktop applications. The placement of the applications will be set automatically based on already existing applications on the desktop.
    ///
    /// - Parameter app: The application which we want to display on the desktop.
    open func add(desktopApp app: DesktopApplication){
        
        let space: CGFloat = 5
        
        let initalHeight: CGFloat = OSToolBar.height + space
        let initalWidth: CGFloat = SystemSettings.resolution.width - MacAppDesktopView.width - space * 2
        
        var heightCounter: CGFloat = initalHeight
        var widthCounter: CGFloat = initalWidth
        
        for i in 0..<desktopApplications.count{
            let app = desktopApplications[i]
            let height = app.view.frame.height + space * 2
            if heightCounter + height > SystemSettings.resolution.height{
                //reset height to initial value
                heightCounter = initalHeight
                
                //move left
                widthCounter -= MacAppDesktopView.width
            }else{
                heightCounter += height
            }
            
        }
        
        app.view.frame.origin = CGPoint(x: widthCounter, y: heightCounter)
        insertSubview(app.view, at: 0)
        desktopApplications.append(app)
    }
}

// MARK: - OSToolBarDataSource
extension OSWindow: OSToolBarDataSource{
    public func osMenuActions(_ toolBar: OSToolBar) -> [MenuAction] {
        return self.osMenus
    }

    public func menuActions(_ toolBar: OSToolBar) -> [MenuAction] {
        let topApp: MacApp = /*activeApplications.count > 1 ? activeApplications[activeApplications.count - 1] :*/ rootApplication
        return topApp.menuActions!
    }
}

// MARK: - OSApplicationWindowDelegate
extension OSWindow: OSApplicationWindowDelegate{
    
    public func applicationWindow(_ applicationWindow: OSApplicationWindow, didTapWindowPanel panel: WindowPanel, atPoint point: CGPoint) {
        self.toolBar?.requestCloseAllMenus()
        bringAppToFront(applicationWindow)
    }

    public func applicationWindow(_ application: OSApplicationWindow, canMoveToPoint point: inout CGPoint) -> Bool {
        let halfHeight = application.bounds.midY
        let osHeight = self.bounds.height
        if point.y < OSToolBar.height + halfHeight {
            point.y = OSToolBar.height + halfHeight
            return true
        } else if point.y > osHeight + halfHeight - OSToolBar.height{
            point.y = osHeight + halfHeight - OSToolBar.height
            return true
        }
        
        return true
    }

    public func applicationWindow(_ applicationWindow: OSApplicationWindow, willStartDraggingContainer container: UIView){
        self.toolBar?.requestCloseAllMenus()
        bringAppToFront(applicationWindow)
    }
    
    public func applicationWindow(_ applicationWindow: OSApplicationWindow, didFinishDraggingContainer container: UIView){
        
    }
    
    public func applicationWindow(_ application: OSApplicationWindow, didCloseWindowWithPanel panel: WindowPanel){
        
        var i = 0
        for app in activeApplications{
            if app.uniqueIdentifier == application.dataSource?.uniqueIdentifier{
                activeApplications.remove(at: i)
                break
            }
            i += 1
        }
        
        if let identifier: String = application.dataSource?.identifier{
            switch identifier{
                case "calculator":
                    self.applicationIdentifiers[identifier] = nil
                break
                
                case "alarmclock":
                    self.applicationIdentifiers[identifier] = nil
            default:
                break
            }
        }else if let uniqueId: String = application.dataSource?.uniqueIdentifier{
            //no identifier, try unique identifier
            self.applicationIdentifiers[uniqueId] = nil
            
        }
        
        //check origin and animate it
        if let origin = application.windowOrigin?.center{
            //create a frame/border window with the same size of the application view
            let transitionWindowFrame = MovingWindow()
            transitionWindowFrame.backgroundColor = .clear
            transitionWindowFrame.borderColor = .lightGray
            transitionWindowFrame.frame = application.frame
            
            //add the frame to the os window
            addSubview(transitionWindowFrame)
            
            //animate it with affine scale transformation and by changing it's center to the origin
            UIView.animate(withDuration: 0.2, animations: {
                transitionWindowFrame.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                transitionWindowFrame.center = origin
                
            },
            //uppon animation end, remove the frame from super view
            completion: { (completion) in
                transitionWindowFrame.removeFromSuperview()
            })
            
            
        }
        
    }
}

// MARK: - DesktopAppDelegate
extension OSWindow: DesktopAppDelegate{
    
    public func didFinishDragging(_ application: DesktopApplication) {
        
    }

    public func willStartDragging(_ application: DesktopApplication) {
        self.toolBar?.requestCloseAllMenus()
    }

    public func didDoubleClick(_ application: DesktopApplication) {
        
        toolBar?.requestCloseAllMenus()
        
        let applicationWindow = self.createApplication(from: application.app!)
        
        if applicationWindow.isDescendant(of: self){
            
            //bring it to front
            bringAppToFront(applicationWindow)
            return
        }
        
        applicationWindow.windowOrigin = application.view
        
        //create border window
        let transitionWindowFrame = MovingWindow()
        transitionWindowFrame.backgroundColor = .clear
        transitionWindowFrame.borderColor = .lightGray
        
        let doesExist = doesApplicationExistInMemory(app: application.app!)
        
        if doesExist{
            transitionWindowFrame.frame = applicationWindow.frame
        }else{
            transitionWindowFrame.frame = CGRect(x: 0,
                                                 y: 0,
                                                 width: application.app!.sizeForWindow().width,
                                                 height: application.app!.sizeForWindow().height + 20)
        }
        
        //set it's center to match application.center
        transitionWindowFrame.center = application.view.center
        
        //add affine scale transformation of 0.1
        transitionWindowFrame.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        addSubview(transitionWindowFrame)
        
        //animate it to origin of the application with
        UIView.animate(withDuration: 0.2, animations: {
            if doesExist{
               transitionWindowFrame.center = applicationWindow.center
            }else{
                transitionWindowFrame.center = self.center
            }
            
            transitionWindowFrame.transform = .identity
        }) { (completion) in
            transitionWindowFrame.removeFromSuperview()
            self.loadApplication(applicationWindow)
        }
        
        
        
    }
}

