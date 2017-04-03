/*:
 
 # The Macintosh Project
 
 Created By [Antonio Zaitoun](https://github.com/minitour)
 
 */

import UIKit
import AVFoundation
import PlaygroundSupport


/*:
 ### The Architecture and Infrastructure
 
 The system, is divided mainly into 3 separated parts: Core, User Interface, And Applications.
 
 As soon as the playground starts, the first thing that that the user sees is the `OSVerboseBoot`, which only shows up for a quick second, and is then quickly replaced with `OSWindow`, The main view that is always visable as long as the playground is running. Once the Verbose Boot is replaced with OSWindow, It will quickly load inside of it the `OSBootLoader`, which is a simple loading screen that lasts for 7 seconds. After those 7 seconds, the bootloader view is removed. Then the `OSToolBar` is loaded. The Tool Bar is in charge of the current actions the user has access to. It will always appear on top.
 
 All applications that are loaded are all custom classes that conform to the `MacApp` protocol. The MacApp protocol is what defines the system applications and is often used as a data source by most of the components. It provides data such as the application name, identifier,unique identifier, size and the application's view.
 
 After creating the applications, they are displayed using the following components: `OSApplicationWindow` and `DesktopApplication`, where the `Application Window` is the UI that displays the application's view,and the `Desktop Application` presents the icon of the application and a way to access it.
 Because the `OSWindow` conforms to both delegates: `DesktopAppDelegate` and `OSApplicationWindowDelegate`, It allows me deliver a great user experience by allowing the user to drag the applications around on the desktop, which also supports multi-layer presentations.
 
 - note:
 Something I would like to put an emphasis on is that all graphical assets (besides the Apple logo) are all created programatically during run time, which is why the resources directory is empty.
 
 
 - note:
 Another thing is, you may find that the project's interface lacks color, but that is because I try to deliver an experience that is close to the original oparating system that was developed back in 1984.
 */

//The screen resolution
let res = CGSize(width: SystemSettings.resolution.width, height: SystemSettings.resolution.height)

let verboseBootDuration = SystemSettings.verboseBootTime

let bootLoaderDuration = SystemSettings.bootLoaderTime

//The main view
let forground = UIView(frame: CGRect(origin: CGPoint.zero, size: res))
forground.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1) //The color of Xcode's background

//Set the forground as the live view
PlaygroundPage.current.liveView = forground
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 ### OS Window, ToolBar and BootWindow
 
 The `OS Window` is the view that holds everything together and is in-charge of the flow of the system.
 The `Tool Bar` is attachted to the OS Window and they both communicate using delegations.
 The `Boot Window` also known as the "Boot Loader" is also presented inside the OS Window, It is constructed of 2 phases: The verbose boot, which is usually the shortest, and the graphical boot loader, which displays a loading progress bar.
 
 All of the applications you see in the  menu are applications that are loaded from the `OSWindow` instance using one of the delegate functions.
 The rest of the menus in the Tool Bar are loaded from a `Finder` application instance that lives within the `OSWindow` instance.
 */
var window: OSWindow!
var toolBar: OSToolBar!
var bootloader: OSBootWindow!

/*:
  ### Creating the Verbose Boot
 The verbose boot is just a view that displays a squence of messages where the messages are added within an interval of the time specified for the verbose boot divided by the amount of messages.
 By doing so we get a DOS-Like booting screen.
*/
let verboseBoot = OSVerboseBoot(inWindow: forground.bounds)
verboseBoot.layer.cornerRadius = 5
verboseBoot.layer.masksToBounds = true
forground.addSubview(verboseBoot)
verboseBoot.loadBootWithDuration(verboseBootDuration) {
    
    //remove verbose view
    verboseBoot.removeFromSuperview()
    
    let audioId: SystemSoundID = {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "os_chime" as CFString!, "mp3" as CFString!, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }()
    
    AudioServicesPlaySystemSound(audioId)
    
    //load os window
    window = OSWindow(withRes: res)
    window.backgroundColor = .gray
    window.layer.cornerRadius = 5
    window.layer.masksToBounds = true
    
/*:
### Creating the Boot Loader
After the verbose boot is done loading, it's time to display the `OSBootWindow` which consists of a graphical user interface.
After it's finished the ToolBar is loaded and gets attached to the `OSWindow`.
*/
    bootloader = OSBootWindow(inWindow: window.bounds)
    bootloader.center = window.center
    window.addSubview(bootloader)
    bootloader.animateProgress(duration: bootLoaderDuration, oldValue: 0, newValue: 1) {
        
        
        //Dispose sound id
        AudioServicesDisposeSystemSoundID(audioId)
        
        //remove bootloader
        bootloader.removeFromSuperview()
        
        //load toolbar
        toolBar = OSToolBar(inWindow: window.bounds)
        
        //attach to os window
        toolBar.dataSource = window
        window.addSubview(toolBar)
        
        //update menu
        toolBar.requestApplicationMenuUpdate()
        
        //add logo
        toolBar.osMenuLogo = #imageLiteral(resourceName: "apple_logo.png")
        
/*:
### Adding the Desktop Applications:
At this point the oparating system has fully loaded and is ready to use. Here I load some of the custom desktop applications I created such as `Guide` and `About Me`. Those applications are created using an instance of a `DesktopApplication` which is created using an instance of `MacApp` and `OSWindow`.

To load the applications into the desktop I use the function ```.add(desktopApp: DesktopApplication)```
- example:
    `let myApplication = MyApplication(withIdentifier: "custom_application_identifier")`
         
    where MyApplication is a class that conforms to the MacApp protocol.
         
    `let app = DesktopApplication.make(app: myApplication, in: window)`
         
    where window is the currnet active OSWindow
         
    `window.add(desktopApp: app)`
*/
        let guideNotePad = HelpNotePad(withIdentifier: "Guide")
        let guideApp = DesktopApplication.make(app: guideNotePad, in: window)
        window.add(desktopApp: guideApp)
        
        let aboutmeNotePad = AboutMe(withIdentifier: "aboutme")
        aboutmeNotePad.windowTitle = "About Me"
        let aboutmeApp = DesktopApplication.make(app: aboutmeNotePad, in: window)
        window.add(desktopApp: aboutmeApp)
        
        window.didDoubleClick(guideApp)
        
        let paint = Picasso()
        let picasso = DesktopApplication.make(app: paint, in: window)
        window.add(desktopApp: picasso)
        
        
    }
    forground.addSubview(window)
}
