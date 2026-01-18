import Foundation
import UIKit
import UserNotifications

var pushDidLaunch: Bool = false

class PushNotificationManager: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        print("🚀 PushNotificationManager launched!")

        pushDidLaunch = true

        // Push Notification setup
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Push permission denied.")
            }
        }

        return true
    }
    
    // ---------------------------------------------------------
    // MARK: UNIVERSAL LINKS (Cold start AND background)
    // ---------------------------------------------------------
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {

            print("📥 Cold Start Universal Link Received:", url.absoluteString)

            // 👉 Use the unified handler
            handleUniversalLink(url)
        }

        return true
    }


    // Handle push token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📲 Device Token:", token)

        UserDefaults.standard.set(token, forKey: "pending_push_token")

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        if userId != 0 {
            sendDeviceTokenToBackend(token: token)
        } else {
            print("⚠️ user_id not available, will retry later.")
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register:", error)
    }

    // Show notifications while app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.banner, .sound])
    }
}


// SEND PUSH TOKEN TO BACKEND
func sendDeviceTokenToBackend(token: String) {
    guard let url = URL(string: "\(baseURL)notifications/register-token/") else { return }

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
        print("❌ Error creating request body:", error)
        return
    }

    URLSession.shared.dataTask(with: request) { _, _, error in
        if let error = error {
            print("❌ Failed to send token:", error)
        } else {
            print("✅ Token sent to backend")
        }
    }.resume()
}


// ---------------------------------------------------------
// MARK: - UNIVERSAL LINK HANDLER (NEVER DIES)
// ---------------------------------------------------------
extension PushNotificationManager {

    func handleUniversalLink(_ url: URL) {
        print("📥 [Delegate] Universal Link:", url.absoluteString)

        let comps = url.pathComponents
        if comps.contains("invite"), let token = comps.last {
            Task { await resolveInviteTokenAndJoin(token: token) }
        }
    }
}
