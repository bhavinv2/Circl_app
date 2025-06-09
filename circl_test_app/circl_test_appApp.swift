import SwiftUI

@main
struct CirclApp: App {
    // 👇 This line wires in the delegate
    @UIApplicationDelegateAdaptor(PushNotificationManager.self) var pushManager

    var body: some Scene {
        WindowGroup {
            Page1()
        }
    }
}
