import SwiftUI

var pendingDeepLinkCircleId: Int?

// MARK: - Invite Join Status (for popups)
final class InviteJoinStatus: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""

    func show(title: String, message: String) {
        DispatchQueue.main.async {
            self.title = title
            self.message = message
            self.isShowing = true
        }
    }
}

@main
struct CirclApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationManager.self) var pushManager
    @StateObject var appState = AppState()
    @StateObject private var profilePreview = ProfilePreviewCoordinator(fetcher: ProfileService())
    @StateObject private var inviteJoinStatus = InviteJoinStatus()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootSwitcher()
                .id(appState.isLoggedIn)   // 🔥 force rebuild on login/logout
                .environmentObject(appState)
                .environmentObject(profilePreview)

                .onAppear {
                    MessageNotificationService.shared.startBackgroundMessageChecking()
                }
                .alert(inviteJoinStatus.title, isPresented: $inviteJoinStatus.isShowing) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(inviteJoinStatus.message)
                }

                .onOpenURL { url in
                    print("📥 [Root] Received URL:", url.absoluteString)

                    // ✅ 1. Handle custom scheme: circl://invite/<token>
                    if url.scheme == "circl" {
                        print("🔗 [Scheme] circl:// detected")

                        let host = url.host ?? ""              // "invite"
                        let token = url.lastPathComponent      // "<TOKEN>"

                        print("🏷️ Host =", host)
                        print("🏷️ Token =", token)

                        if host == "invite" && token.count > 3 {
                            print("🎯 Handling scheme invite token:", token)
                            Task {
                                await resolveInviteTokenAndJoin(token: token, inviteJoinStatus: inviteJoinStatus)
                            }
                        } else {
                            inviteJoinStatus.show(title: "Invite Link Invalid", message: "This invite link doesn't look valid.")
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
                        Task { await joinCircleFromDeepLink(circleId, inviteJoinStatus: inviteJoinStatus) }
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

func joinCircleFromDeepLink(_ circleId: Int, inviteJoinStatus: InviteJoinStatus? = nil) async {
    print("🔥 Joining circle from deep link:", circleId)

    guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
        print("⚠️ No user_id — storing pending deep link circle:", circleId)
        pendingDeepLinkCircleId = circleId
        inviteJoinStatus?.show(title: "Log In Required", message: "Please log in to accept the circle invite.")
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
        let (data, response) = try await URLSession.shared.data(for: request)
        let bodyText = String(data: data, encoding: .utf8) ?? ""
        print("JOIN RESULT:", bodyText)

        if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
            inviteJoinStatus?.show(title: "Joined Circle", message: "You're in! The circle has been added to your Circles list.")
        } else {
            inviteJoinStatus?.show(title: "Invite Failed", message: bodyText.isEmpty ? "Could not join the circle. Please try again." : bodyText)
        }
    } catch {
        print("ERROR JOINING CIRCLE:", error)
        inviteJoinStatus?.show(title: "Invite Failed", message: "Network error while joining the circle. Please try again.")
    }
}

// -------------------------------------------------------------
// MARK: - RESOLVE TOKEN
// -------------------------------------------------------------

func resolveInviteTokenAndJoin(token: String, inviteJoinStatus: InviteJoinStatus? = nil) async {
    print("🔎 Resolving invite token:", token)

    guard let url = URL(string: "https://circlapp.online/circles/resolve_invite/\(token)/") else {
        print("❌ Bad URL")
        inviteJoinStatus?.show(title: "Invite Failed", message: "Invalid invite URL.")
        return
    }

    do {
        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            inviteJoinStatus?.show(title: "Invite Failed", message: bodyText.isEmpty ? "Could not verify invite. Please try again." : bodyText)
            return
        }

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let circleId = json["circle_id"] as? Int {

            print("✅ Token resolved. Circle ID =", circleId)
            await joinCircleFromDeepLink(circleId, inviteJoinStatus: inviteJoinStatus)

        } else {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            inviteJoinStatus?.show(title: "Invite Failed", message: bodyText.isEmpty ? "Invalid invite response." : bodyText)
            print("❌ Invalid JSON:", bodyText)
        }
    } catch {
        inviteJoinStatus?.show(title: "Invite Failed", message: "Network error while resolving invite. Please try again.")
        print("❌ Network error:", error)
    }
}

// MARK: - Previews

private struct InvitePopupPreviewHarness: View {
    @StateObject private var status = InviteJoinStatus()

    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Tap for pop-up:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Button {
                    status.show(title: "Joined Circle", message: "You're in! The circle has been added to your Circles list.")
                } label: {
                    Text("Show Success Popup")
                        .underline()
                }

                Button {
                    status.show(title: "Invite Failed", message: "Could not join the circle. Please try again.")
                } label: {
                    Text("Show Failure Popup")
                        .underline()
                }
            }
            .padding()
            .alert(status.title, isPresented: $status.isShowing) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(status.message)
            }
        }
    }
}

#Preview("Invite Popup Preview") {
    InvitePopupPreviewHarness()
}
