import SwiftUI
import Foundation

@main
struct Sphere_EmotionApp: App {
    @StateObject private var moodData = MoodData()
    
    @UIApplicationDelegateAdaptor(SphereEmotionsDelegate.self) var sphereEmotionsDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(moodData)
        }
    }
}

class SphereEmotionsDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NotificationCenter.default.post(name: Notification.Name("apnstoken_push"), object: nil, userInfo: [
            "apnstoken": tokenString
        ])
    }
    
    func requestNotificationPermission(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        UNUserNotificationCenter.current().delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let _ = error {
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
            }
        }
    }
    
    var deepLinkURL: URL? = nil
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        requestNotificationPermission(application)
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let pushData = userInfo["push_id"] as? String {
            UserDefaults.standard.set(pushData, forKey: "push_id")
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let pushData = userInfo["push_id"] as? String {
            UserDefaults.standard.set(pushData, forKey: "push_id")
        }
        completionHandler([.banner, .sound])
    }
    
}
