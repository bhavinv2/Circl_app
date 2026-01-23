import SwiftUI

var pendingDeepLinkCircleId: Int?

@main
struct CirclApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationManager.self) var pushManager
    @StateObject var appState = AppState()
    @StateObject private var profilePreview = ProfilePreviewCoordinator(fetcher: ProfileService())
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootSwitcher()
                .environmentObject(appState)
                .environmentObject(profilePreview)
                .onAppear {
                    MessageNotificationService.shared.startBackgroundMessageChecking()
                }

                .onOpenURL { url in
                    print("📥 [Root] Received URL:", url.absoluteString)

                    // ✅ 1. Handle custom scheme: circl://invite/<token>
                    // ✅ 1. Handle custom scheme: circl://invite/<token>
                    if url.scheme == "circl" {
                        print("🔗 [Scheme] circl:// detected")

                        // Extract host and path properly
                        let host = url.host ?? ""              // "invite"
                        let token = url.lastPathComponent      // "<TOKEN>"

                        print("🏷️ Host =", host)
                        print("🏷️ Token =", token)

                        if host == "invite" && token.count > 3 {
                            print("🎯 Handling scheme invite token:", token)
                            Task {
                                await resolveInviteTokenAndJoin(token: token)
                            }
                        } else {
                            print("❌ Invalid circl:// format")
                        }
                        return
                    }


                    // ✅ 2. Handle universal links https://circlapp.online/invite/<token>/
                    print("🌐 [Universal] Passing to pushManager")
                    pushManager.handleUniversalLink(url)
                }


                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DeepLinkJoinCircle"))) { notif in
                    if let info = notif.userInfo,
                       let circleId = info["circle_id"] as? Int {
                        Task { await joinCircleFromDeepLink(circleId) }
                    }
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("🔔 App active")
                MessageNotificationService.shared.startBackgroundMessageChecking()
            }
        }
    }
}


// -------------------------------------------------------------
// MARK: - JOIN CIRCLE
// -------------------------------------------------------------

func joinCircleFromDeepLink(_ circleId: Int) async {
    print("🔥 Joining circle from deep link:", circleId)

    guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
        print("⚠️ No user_id — storing pending deep link circle:", circleId)
        pendingDeepLinkCircleId = circleId
        return
    }

    guard let url = URL(string: "\(baseURL)circles/join_circle/") else { return }

    let payload: [String: Any] = [
        "circle_id": circleId,
        "user_id": userId,
        "via_invite": true
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        print("JOIN RESULT:", String(data: data, encoding: .utf8) ?? "")
    } catch {
        print("ERROR JOINING CIRCLE:", error)
    }
}


// -------------------------------------------------------------
// MARK: - RESOLVE TOKEN
// -------------------------------------------------------------

func resolveInviteTokenAndJoin(token: String) async { // TODO: Create pop-up to notify that the invite has failed or succeeded
    print("🔎 Resolving invite token:", token)

    guard let url = URL(string: "https://circlapp.online/circles/resolve_invite/\(token)/") else {
        print("❌ Bad URL")
        return
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let circleId = json["circle_id"] as? Int {

            print("✅ Token resolved. Circle ID =", circleId)
            await joinCircleFromDeepLink(circleId)

        } else {
            print("❌ Invalid JSON:", String(data: data, encoding: .utf8) ?? "")
        }
    } catch {
        print("❌ Network error:", error)
    }
}
