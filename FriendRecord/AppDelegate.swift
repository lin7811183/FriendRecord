import UIKit
import IQKeyboardManagerSwift

protocol MyAppDelegate {
    func updateManagerRecordData()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var loadDataArray :[Record]!
    var userPhotoArray :[String]!
    
    var mydelegate :MyAppDelegate!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Home : \(NSHomeDirectory())")
        
        //open Notice.
        let settings = UIUserNotificationSettings(types: UIUserNotificationType.alert, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        //UIApplicationBackgroundFetchIntervalMinimum
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        IQKeyboardManager.shared.enable = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        var finished = false
        var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0);
        bgTask = application.beginBackgroundTask(withName:"MyBackgroundTask", expirationHandler: {() -> Void in
            // Time is up.
            if bgTask != UIBackgroundTaskIdentifier.invalid {
                // Do something to stop our background task or the app will be killed
                finished = true
            }
        })
        
        // Perform your background task here
        print("The task has started")
        while !finished {
            print("Not finished")
            // when done, set finished to true
            // If that doesn't happen in time, the expiration handler will do it for us
            self.downLoadRecordPen()
            print("Finished")
            finished = true
            break
        }
        
        // Indicate that it is complete
        application.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Application UIBackgroundFetchResult.
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        print("Complete");
        completionHandler(UIBackgroundFetchResult.newData)
        self.downLoadRecordPen()
    }
    
    //MARK: func - DownLoad Record Pen.
    func downLoadRecordPen() {
        //Test
        //Post PHP(check user login data).
        if let url = URL(string: "http://34.80.138.241:81/FriendRecord/RecordPen/Load_Record_Pen.php") {
            
            var request = URLRequest(url: url)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, respones, error) in
                if let e = error {
                    print("uesr login check data URL Session error: \(e)")
                    return
                }
                guard let jsonData = data else {
                    return
                }
                //let reCode = String(data: data!, encoding: .utf8)
                //print(reCode!)
                let decoder = JSONDecoder()
                do {
                    self.loadDataArray = try decoder.decode([Record].self, from: jsonData)//[Note].self 取得Note陣列的型態
                    Manager.recordData = self.loadDataArray
                    print("Manager.recordData.count:\(Manager.recordData.count)")
                    
                    self.mydelegate.updateManagerRecordData()
                    
                } catch {
                    print("error while parsing json \(error)")
                }
            }
            task.resume()
        }
    }
}
