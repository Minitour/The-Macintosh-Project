import UIKit


public protocol OSApplicationWindowDelegate{
    
    /// Delegate function called when window is about to be dragged.
    ///
    /// - Parameters:
    ///   - applicationWindow: The current application window.
    ///   - container: The application's view.
    func applicationWindow(_ applicationWindow: OSApplicationWindow, willStartDraggingContainer container: UIView)
    
    
    /// Delegate function called when window has finished dragging
    ///
    /// - Parameters:
    ///   - applicationWindow: The current application window.
    ///   - container: The application's view.
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didFinishDraggingContainer container: UIView)
    
    
    /// Delegate function, called when users taps the panel of the OSApplicationWindow.
    ///
    /// - Parameters:
    ///   - applicationWindow: The current application window.
    ///   - panel: The window panel view instance that was tapped.
    ///   - point: The location of the tap.
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didTapWindowPanel panel: WindowPanel,atPoint point: CGPoint)
    
    
    /// Delegate function, called when user clicks the "close" button in the panel.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - panel: The window panel view instance which holds the button that was clicked.
    func applicationWindow(_ application: OSApplicationWindow, didCloseWindowWithPanel panel: WindowPanel)
    
    
    /// Delegate function, called after user has finished dragging. note that `point` parameter is an `inout`. This is to allow the class which conforms to this delegate the option to modify the point incase the point that was given isn't good.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - point: The panel which the user dragged with.
    /// - Returns: return true to allow the movment of the window to the point, and false to ignore the movment.
    func applicationWindow(_ application: OSApplicationWindow, canMoveToPoint point: inout CGPoint)->Bool
    
}

public class OSApplicationWindow: UIView{
    
    fileprivate var lastLocation = CGPoint(x: 0, y: 0)
    
    open var windowOrigin: MacAppDesktopView?
    
    open var delegate: OSApplicationWindowDelegate?
    
    open var dataSource: MacApp?{
        didSet{
            tabBar?.contentStyle = dataSource?.contentMode
            tabBar?.requestContentStyleUpdate()
            windowTitle = dataSource?.windowTitle
            backgroundColor = dataSource?.contentMode ?? .default == .default ? .white : .black
        }
    }
    
    open var container: UIView?
    
    open var windowTitle: String?{
        set{
            tabBar?.title = newValue
        }get{
            return tabBar?.title
        }
    }
    
    open var containerSize: CGSize?{
            return dataSource?.sizeForWindow()
    }
    
    fileprivate (set) open var tabBar: WindowPanel?{
        didSet{
            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
            tabBar?.addGestureRecognizer(gestureRecognizer)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            tabBar?.addGestureRecognizer(tapGesture)
        }
    }
    
    fileprivate var transitionWindowFrame: MovingWindow?
    
    public convenience init(delegate: OSApplicationWindowDelegate,dataSource: MacApp){
        self.init()
        self.delegate = delegate
        self.dataSource = dataSource
        tabBar?.contentStyle = self.dataSource?.contentMode
        tabBar?.requestContentStyleUpdate()
        windowTitle = self.dataSource?.windowTitle
        backgroundColor = self.dataSource?.contentMode ?? .default == .default ? .white : .black
    }
    
    public convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(sender: UITapGestureRecognizer){
        delegate?.applicationWindow(self, didTapWindowPanel: tabBar!, atPoint: sender.location(in: tabBar))
    }
    
    func handlePan(sender: UIPanGestureRecognizer){

        if dataSource?.shouldDragApplication == false{
            return
        }
        
        let translation = sender.translation(in: self.superview!)
        
        switch sender.state{
        case .began:
            transitionWindowFrame?.isHidden = false
            transitionWindowFrame?.frame = CGRect(origin: CGPoint(x: 0 , y: 0), size: bounds.size)
            transitionWindowFrame?.lastLocation = (self.transitionWindowFrame?.center)!
            delegate?.applicationWindow(self, willStartDraggingContainer: container!)
            dataSource?.macApp(self, willStartDraggingContainer: container!)
            break
        case .ended:
            transitionWindowFrame?.isHidden = true
            var point = convert(transitionWindowFrame!.center, to: superview!)
            if delegate?.applicationWindow(self, canMoveToPoint: &point) ?? true{
                self.center = point
            }
            delegate?.applicationWindow(self, didFinishDraggingContainer: container!)
            dataSource?.macApp(self, didFinishDraggingContainer: container!)
            return
        default:
            break
        }
        
        let point = CGPoint(x: (transitionWindowFrame?.lastLocation.x)! + translation.x , y: (transitionWindowFrame?.lastLocation.y)! + translation.y)
        transitionWindowFrame?.layer.shadowOpacity = 0
        transitionWindowFrame?.center = point
    }
    
    func setup(){
        backgroundColor = .white
        tabBar = WindowPanel()
        
        tabBar?.backgroundColor = .clear
        tabBar?.delegate = self
        addSubview(tabBar!)
        
        container = UIView()
        container?.backgroundColor = .clear
        addSubview(container!)
        
        transitionWindowFrame = MovingWindow()
        transitionWindowFrame?.isHidden = true
        transitionWindowFrame?.backgroundColor = .clear
        addSubview(transitionWindowFrame!)
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 2
        
        transitionWindowFrame?.bounds = CGRect(origin: CGPoint(x: 0 , y: 0), size: bounds.size)
        frame.size = CGSize(width: containerSize?.width ?? 0, height: (containerSize?.height ?? 0) + CGFloat(20))
        tabBar?.frame = CGRect(x: 0, y: 0, width: containerSize?.width ?? 0, height: 20)
        container?.frame = CGRect(x: 0, y: tabBar?.bounds.size.height ?? 20, width: containerSize?.width ?? 0, height: containerSize?.height ?? 0)
        
    }
    
    public override func didMoveToSuperview() {
        tabBar?.frame = CGRect(x: 0, y: 0, width: containerSize?.width ?? 0, height: 20)
        tabBar?.setNeedsDisplay()
        container?.frame = CGRect(x: 0, y: tabBar?.bounds.size.height ?? 20, width: containerSize?.width ?? 0, height: containerSize?.height ?? 0)
        frame.size = CGSize(width: containerSize?.width ?? 0, height: (containerSize?.height ?? 0 ) + CGFloat(20))
        
        if let view = dataSource?.container{
            view.frame = container!.bounds
            container!.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: container!.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: container!.bottomAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: container!.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: container!.rightAnchor).isActive = true
        }
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.center
        super.touchesBegan(touches, with: event)
    }
    
    open func close(){
        self.dataSource?.willTerminateApplication()
        self.delegate?.applicationWindow(self, didCloseWindowWithPanel: tabBar!)
        self.removeFromSuperview()
    }
    
    
}


public class MovingWindow: UIView{
    
    var lastLocation = CGPoint(x: 0, y: 0)
    
    open var borderColor: UIColor = .gray
    
    override public func draw(_ rect: CGRect) {
        borderColor.setStroke()
        let path = UIBezierPath(rect: rect)
        path.lineWidth = 4
        path.stroke()
    }
}


extension OSApplicationWindow: WindowPanelDelegate{
    public func didSelectCloseMenu(_ windowPanel: WindowPanel, panelButton button: PanelButton) {
        self.dataSource?.willTerminateApplication()
        self.delegate?.applicationWindow(self, didCloseWindowWithPanel: windowPanel)
        self.removeFromSuperview()
    }
}
