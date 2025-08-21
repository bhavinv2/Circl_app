import SwiftUI

@main
struct CirclApp: App {
    // 👇 This line wires in the delegate
    @UIApplicationDelegateAdaptor(PushNotificationManager.self) var pushManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppLaunchView()
                .onAppear {
                    // Start background message notification service
                    MessageNotificationService.shared.startBackgroundMessageChecking()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // App became active - ensure message checking is running
                print("🔔 App became active - starting background message service")
                MessageNotificationService.shared.startBackgroundMessageChecking()
            case .background:
                // App went to background - keep service running for better notifications
                print("🔔 App went to background - keeping service active")
                // Don't stop the service to allow notifications while backgrounded
                break
            case .inactive:
                // App became inactive - keep running
                break
            @unknown default:
                break
            }
        }
    }
}
