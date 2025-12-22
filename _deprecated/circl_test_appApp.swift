import SwiftUI
import Branch

@main
struct CirclApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationManager.self) var pushManager
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // ✅ CocoaPods Branch uses launchOptions in initSession
        Branch.getInstance().initSession(launchOptions: nil) { params, error in
            if let params = params as? [String: Any] {
                print("🔗 Branch session opened with params:", params)

                NotificationCenter.default.post(
                    name: Notification.Name("BranchDeepLinkOpened"),
                    object: nil,
                    userInfo: params
                )
            } else if let error = error {
                print("❌ Branch initSession error:", error.localizedDescription)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AppLaunchView()
                .onAppear {
                    MessageNotificationService.shared.startBackgroundMessageChecking()
                }
                .onOpenURL { url in
                    print("🔗 onOpenURL fired:", url)
                    // ✅ CocoaPods Branch uses handleDeepLink(_:)
                    Branch.getInstance().handleDeepLink(url)
                }
                .onReceive(
                    NotificationCenter.default.publisher(for: Notification.Name("BranchDeepLinkOpened"))
                ) { notification in
                    handleDeepLink(notification)
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                MessageNotificationService.shared.startBackgroundMessageChecking()
            case .background, .inactive:
                break
            @unknown default:
                break
            }
        }
    }

    // MARK: - Auto Join Handler
    func handleDeepLink(_ notification: Notification) {
        guard let data = notification.userInfo else { return }

        if let circleId = data["circle_id"] as? String,
           let cid = Int(circleId) {
            print("🎉 Auto-join triggered for circle:", cid)
            joinCircle(circleId: cid)
        } else {
            print("ℹ️ No circle_id found in Branch params:", notification.userInfo ?? [:])
        }
    }

    // MARK: - Join Circle API
    func joinCircle(circleId: Int) {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user logged in, cannot auto-join")
            return
        }

        guard let url = URL(string: "\(API.baseURL)/api/circles/join_circle/") else {
            print("❌ Invalid join_circle URL")
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circleId,
            "via_invite": true
        ]

        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error {
                print("❌ join_circle failed:", error.localizedDescription)
                return
            }
            print("✅ Successfully auto-joined circle:", circleId)

            NotificationCenter.default.post(
                name: Notification.Name("NavigateToCircle"),
                object: nil,
                userInfo: ["circle_id": circleId]
            )
        }.resume()
    }
}
