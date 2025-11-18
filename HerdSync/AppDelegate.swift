import UIKit
import AppsFlyerLib

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppsFlyerLib.shared().appsFlyerDevKey = "bMEwQXA4L9iVAMwTFxmW3m"
        AppsFlyerLib.shared().appleAppID = "6755443297"
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 5)
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }
}

