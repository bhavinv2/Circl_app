import Foundation
import UIKit
import UserNotifications


var pushDidLaunch: Bool = false

class PushNotificationManager: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("🚀 PushNotificationManager launched!")
        pushDidLaunch = true

        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Push permission denied: \(String(describing: error))")
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📲 Device Token: \(token)")

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        if userId != 0 {
            sendDeviceTokenToBackend(token: token)
        } else {
            print("⚠️ user_id not yet available. Will try again shortly...")

            // Retry sending the token after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let delayedUserId = UserDefaults.standard.integer(forKey: "user_id")
                if delayedUserId != 0 {
                    sendDeviceTokenToBackend(token: token)
                    print("✅ Token sent after delay with user_id: \(delayedUserId)")
                } else {
                    print("❌ Still no user_id. Token not sent.")
                }
            }
        }

    }

    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    // ✅ Show push notification banner while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        print("🔔 Push received with title: \(content.title), body: \(content.body)")
        print("🔎 Full payload: \(notification.request.content.userInfo)")

        // Show it as banner + play sound
        completionHandler([.banner, .sound])
    }

}


func sendDeviceTokenToBackend(token: String) {
    guard let url = URL(string: "https://circlapp.online/api/notifications/register-token/") else { return }

    let userId = UserDefaults.standard.integer(forKey: "user_id")

    let payload: [String: Any] = [
        "token": token,
        "user_id": userId,
        "is_production": true
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
    } catch {
        print("❌ Error creating request body: \(error)")
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ Failed to send token: \(error)")
        } else {
            print("✅ Token sent to backend")
        }
    }.resume()
}
