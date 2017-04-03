import Foundation

public typealias ACTION = ()->Void

public struct MenuAction{
    
    /// The title of the menu item.
    var title: String
    
    /// The action that will be triggered once the menu is selected.
    var action: ACTION?
    
    /// The sub menus the menu has.
    var subMenus: [MenuAction]?
    
    /// The type of the menu (action/seperator)
    var type: MenuType = .action
    
    /// Is the action menu enabled or disabled
    var enabled: Bool
    
    /// Closure that is triggered every time the menu actions is about to be displayed.
    var runtimeClosure: ((Void)->Bool)?
    
    /// Primary Initalizer
    ///
    /// - Parameters:
    ///   - title: The title of the menu item.
    ///   - action: The action that will be triggered once the menu is selected.
    ///   - subMenus: The sub menus the menu has.
    ///   - type: The type of the menu (action/seperator)
    ///   - enabled: Is the action menu enabled or disabled
    ///   - runtimeClosure: Closure that is triggered every time the menu actions is about to be displayed.
    init(title: String="",
         action: ACTION?=nil,
         subMenus: [MenuAction]?=nil,
         type: MenuType = .action,
         enabled: Bool = true,
         runtimeClosure: ((Void)->Bool)?=nil) {
        self.title = title
        self.action = action
        self.subMenus = subMenus
        self.type = type
        self.enabled = enabled
        self.runtimeClosure = runtimeClosure
    }
}

public enum MenuType{
    case action
    case seperator
}
