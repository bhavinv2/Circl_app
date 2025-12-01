import SwiftUI
import AVKit
import AVFoundation
import Foundation

struct BlockedUser: Identifiable, Hashable {
    let id: Int
    let name: String
}

// MARK: - Main View
struct PageSettings: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutAlert = false
    @State private var isLogoutConfirmed = false
    @State private var isAnimating = false
    @EnvironmentObject var appState: AppState

    // Easter egg variables
    @State private var settingsClickCount = 0
    @State private var showEasterEggVideo = false
    @State private var player: AVPlayer?

    private var animatedBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "001a3d"),
                    Color(hex: "004aad"),
                    Color(hex: "0066ff"),
                    Color(hex: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // First flowing layer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hex: "0066ff").opacity(0.2),
                    Color.clear,
                    Color(hex: "004aad").opacity(0.15),
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? -0.3 : 1.3,
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 1.0 : 0.0,
                    y: 1.0
                )
            )
            
            // Second flowing layer (opposite direction)
            LinearGradient(
                colors: [
                    Color(hex: "002d5a").opacity(0.1),
                    Color.clear,
                    Color(hex: "0066ff").opacity(0.18),
                    Color.clear,
                    Color(hex: "001a3d").opacity(0.12)
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 1.2 : -0.2,
                    y: 0.3
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 0.1 : 0.9,
                    y: 0.7
                )
            )
            
            // Third subtle wave layer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.clear,
                    Color(hex: "0066ff").opacity(0.1),
                    Color.clear,
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 0.2 : 0.8,
                    y: isAnimating ? 0.0 : 1.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 0.9 : 0.1,
                    y: isAnimating ? 1.0 : 0.0
                )
            )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            // Header - matching home page style exactly
            VStack(spacing: 0) {
                HStack {
                    // Left side - Back Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Center - Settings Title (Easter Egg!)
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .onTapGesture {
                            settingsClickCount += 1
                            
                            // Add haptic feedback for fun
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            // Reset counter after 5 seconds of no clicking
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                if settingsClickCount < 10 {
                                    settingsClickCount = 0
                                }
                            }
                            
                            // Activate easter egg after 10 clicks
                            if settingsClickCount >= 10 {
                                triggerEasterEgg()
                            }
                        }
                    
                    Spacer()
                    
                    // Right side - Empty spacer to center the title
                    Spacer()
                        .frame(width: 24) // Match the width of the back button
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 8)
            }
            .padding(.top, 50) // Add safe area padding for status bar and notch
            .background(Color(hex: "004aad"))
            .ignoresSafeArea(edges: .top)

            // Content with modern cards
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Account Settings Section
                    VStack(spacing: 12) {
                        sectionHeader(title: "Account Settings", icon: "person.circle.fill")
                        
                        VStack(spacing: 8) {
                            settingsOption(title: "Become a Mentor", iconName: "graduationcap.fill", destination: BecomeMentorPage())
                            settingsOption(title: "Change Password", iconName: "lock.fill", destination: ChangePasswordPage())
                            settingsOption(title: "Blocked Users", iconName: "person.crop.circle.badge.xmark", destination: BlockedUsersPage())
                            settingsOption(title: "Delete Account", iconName: "trash.fill", destination: DeleteAccountPage(), isDestructive: true)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                    // Feedback & Suggestions Section
                    VStack(spacing: 12) {
                        sectionHeader(title: "Feedback & Suggestions", icon: "lightbulb.fill")
                        
                        VStack(spacing: 8) {
                            settingsOption(title: "Suggest a Feature", iconName: "lightbulb.fill", destination: SuggestFeaturePage())
                            settingsOption(title: "Report a Problem", iconName: "exclamationmark.triangle.fill", destination: ReportProblemPage())
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                    // Legal & Policies Section
                    VStack(spacing: 12) {
                        sectionHeader(title: "Legal & Policies", icon: "doc.text.fill")
                        
                        VStack(spacing: 8) {
                            settingsOption(title: "Terms of Service", iconName: "doc.text.fill", destination: TermsOfServicePage())
                            settingsOption(title: "Privacy Policy", iconName: "hand.raised.fill", destination: PrivacyPolicyPage())
                            settingsOption(title: "Community Guidelines", iconName: "person.2.fill", destination: CommunityGuidelinesPage())
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                    // Tutorial & Help Section
                    VStack(spacing: 12) {
                        sectionHeader(title: "Tutorial & Help", icon: "questionmark.circle.fill")
                        
                        VStack(spacing: 8) {
                            TutorialSettingsView()
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                    // Help & Support Section
                    VStack(spacing: 12) {
                        sectionHeader(title: "Help & Support", icon: "headphones")
                        
                        VStack(spacing: 8) {
                            settingsOption(title: "Contact Support", iconName: "headphones", destination: ContactSupportPage())
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                    // Logout Button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Logout")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemGray6))
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Log out of your account?"),
                message: Text("You'll need to sign in again to access your account."),
                primaryButton: .destructive(Text("Log Out")) {
                    logoutUser()
                },
                secondaryButton: .cancel()
            )
        }
        }
        .fullScreenCover(isPresented: $showEasterEggVideo) {
            EasterEggVideoPlayer(player: player)
                .onDisappear {
                    // Reset player and counter when video is closed
                    player?.pause()
                    player?.seek(to: .zero)
                    player = nil // Reset the player completely
                    settingsClickCount = 0 // Reset click count after video
                }
        }
    }
    
    // MARK: - Easter Egg Functions
    private func triggerEasterEgg() {
        // Reset any existing player first
        player?.pause()
        player = nil
        
        // Try multiple approaches to find the video
        var videoURL: URL?
        
        // Method 1: Try the copied file in main bundle
        videoURL = Bundle.main.url(forResource: "ssstik.io_1753048469521", withExtension: "mp4")
        
        // Method 2: Try without extension
        if videoURL == nil {
            videoURL = Bundle.main.url(forResource: "ssstik.io_1753048469521", withExtension: nil)
        }
        
        // Method 3: Try NSDataAsset for Assets.xcassets
        if videoURL == nil {
            if let asset = NSDataAsset(name: "myamazingceo") {
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent("easter_egg_video_\(Date().timeIntervalSince1970).mp4")
                
                do {
                    try asset.data.write(to: tempFileURL)
                    videoURL = tempFileURL
                } catch {
                    print("❌ Could not write asset to temp file: \(error)")
                }
            }
        }
        
        // If we found a video URL, create a fresh player
        if let url = videoURL {
            print("🎬 Creating fresh player with URL: \(url)")
            
            // Create a completely new player instance
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            // Configure audio session for video playback
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
                print("🎬 Audio session configured for video playback")
            } catch {
                print("⚠️ Could not configure audio session: \(error)")
            }
            
            // Set up player properties
            if let configuredPlayer = player {
                configuredPlayer.volume = 1.0
                configuredPlayer.actionAtItemEnd = .pause // Change to pause instead of none
                print("🎬 Fresh player configured successfully")
            }
            
            showEasterEggVideo = true
            
            // Add celebration haptic feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            print("🎉 Easter egg activated! Playing CEO video from: \(url.lastPathComponent)")
        } else {
            print("❌ Could not find video file anywhere!")
            
            // Debug: List available files
            if let resourcePath = Bundle.main.resourcePath {
                print("📂 Bundle resources:")
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    for file in files.filter({ $0.contains("ssstik") || $0.contains("mp4") || $0.contains("video") }) {
                        print("  - \(file)")
                    }
                } catch {
                    print("  Could not list files: \(error)")
                }
            }
            
            // Show a fallback message instead
            showEasterEggVideo = true // This will show the player with no content, but at least the message
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "004aad"))
            
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }

    // MARK: - Settings Option
    private func settingsOption(title: String, iconName: String, destination: some View, isDestructive: Bool = false) -> some View {
        NavigationLink(destination:
            destination
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
        ) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: isDestructive ? 
                                    [Color.red.opacity(0.8), Color.red] :
                                    [Color(hex: "004aad"), Color(hex: "0066ff")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if isDestructive {
                        Text("This action cannot be undone")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Logout Functionality
    func logoutUser() {
        print("🔓 Logging out user…")

        // Clear stored session data
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")

        // 🔥 Tell the entire app to switch to Page1
        appState.isLoggedIn = false
    }



    // MARK: - Circle Button (Optional, unused)
    struct CustomCircleButton: View {
        let iconName: String
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color(hex: "004aad"))
                    .frame(width: 60, height: 60)
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Placeholder Pages for Navigation
struct BecomeMentorPage: View {
    @State private var name = ""
    @State private var industry = ""
    @State private var reason = ""
    @State private var isSubmitted = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(hex: "004aad"))
                    
                    Text("Mentor Application")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Share your expertise and help fellow entrepreneurs grow")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Form Card
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your full name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Industry")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("e.g., Technology, Finance, Healthcare", text: $industry)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why do you want to become a mentor?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextEditor(text: $reason)
                            .frame(height: 120)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .font(.system(size: 16))
                    }

                    Button(action: {
                        submitMentorApplication()
                    }) {
                        HStack {
                            if isSubmitted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(isSubmitted ? "Application Submitted!" : "Submit Application")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isSubmitted ? 
                                    [Color.green, Color.green.opacity(0.8)] :
                                    [Color(hex: "004aad"), Color(hex: "0066ff")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(name.isEmpty || industry.isEmpty || reason.isEmpty)
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)

                    if isSubmitted {
                        Text("We'll review your application and get back to you within 2-3 business days.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.systemGray6))
        .navigationTitle("Become a Mentor")
        .navigationBarTitleDisplayMode(.inline)
    }

    func submitMentorApplication() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "name": name,
            "industry": industry,
            "reason": reason
        ]

        guard let url = URL(string: "\(baseURL)users/apply_mentor/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitted = true
                name = ""
                industry = ""
                reason = ""
            }
        }.resume()
    }
}

struct BlockedUsersPage: View {
    @State private var blockedUsers: [BlockedUser] = []

    @State private var message: String = ""

    var body: some View {
        VStack {
            Text("Blocked Users")
                .font(.title)
                .bold()
                .padding(.top)

            if blockedUsers.isEmpty {
                Text("You haven’t blocked anyone.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(blockedUsers) { user in
                        HStack {
                            Text(user.name)
                            Spacer()
                            Button("Unblock") {
                                unblock(userId: user.id)
                            }
                            .foregroundColor(.red)
                        }
                    }

                }
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.green)
                    .padding()
            }

            Spacer()
        }
        .onAppear(perform: fetchBlockedUsers)
        .padding()
    }

    func fetchBlockedUsers() {
        guard let url = URL(string: "\(baseURL)users/get_blocked_users/"),
              let token = UserDefaults.standard.string(forKey: "auth_token") else { return }

        var request = URLRequest(url: url)
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let result = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let users = result.compactMap { dict -> BlockedUser? in
                    guard let id = dict["id"] as? Int,
                          let name = dict["name"] as? String else { return nil }
                    return BlockedUser(id: id, name: name)
                }

                DispatchQueue.main.async {
                    self.blockedUsers = users
                }
            }

        }.resume()
    }

    func unblock(userId: Int) {
        guard let url = URL(string: "\(baseURL)users/unblock_user/"),
              let token = UserDefaults.standard.string(forKey: "auth_token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        let payload = ["blocked_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.message = "User unblocked!"
                self.fetchBlockedUsers()
            }
        }.resume()
    }
}



struct ChangePasswordPage: View {
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var isSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(hex: "004aad"))
                    
                    Text("Change Password")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Keep your account secure with a strong password")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Form Card
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your current password", text: $oldPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your new password", text: $newPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm New Password")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        SecureField("Confirm your new password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }

                    Button(action: changePassword) {
                        Text("Update Password")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)

                    if !message.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(isSuccess ? .green : .red)
                            
                            Text(message)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isSuccess ? .green : .red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background((isSuccess ? Color.green : Color.red).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.systemGray6))
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    func changePassword() {
        guard !oldPassword.isEmpty, !newPassword.isEmpty, newPassword == confirmPassword else {
            message = "Please fill all fields and make sure new passwords match."
            isSuccess = false
            return
        }

        guard let url = URL(string: "\(baseURL)users/change_password/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let payload = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = response["status"] as? String {
                        message = status
                        isSuccess = true
                        oldPassword = ""
                        newPassword = ""
                        confirmPassword = ""
                    } else if let errorMsg = response["error"] as? String {
                        message = errorMsg
                        isSuccess = false
                    }
                } else {
                    message = "Unexpected error occurred."
                    isSuccess = false
                }
            }
        }.resume()
    }
}


struct DeleteAccountPage: View {
    @State private var reason = ""
    @State private var message = ""
    @State private var isSubmitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Why do you want to delete your account?")
                .font(.headline)

            TextEditor(text: $reason)
                .frame(height: 150)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

            Button(action: submitDeleteRequest) {
                Text("Request to Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }

            if isSubmitted {
                Text(message)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
    }

    func submitDeleteRequest() {
        guard let url = URL(string: "\(baseURL)users/request_delete_account/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let payload = ["reason": reason]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitted = true
                message = "Your request has been submitted."
                reason = ""
            }
        }.resume()
    }
}


struct SuggestFeaturePage: View {
    @State private var featureSuggestion = ""
    @State private var isSubmitted = false
    @State private var successMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Suggest a Feature")
                .font(.title)
                .bold()

            Text("We value your suggestions! Please provide details of the feature you'd like to see.")
                .font(.body)
                .foregroundColor(.gray)

            TextEditor(text: $featureSuggestion)
                .frame(height: 150)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            Button(action: submitFeatureSuggestion) {
                Text("Submit Suggestion")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            if isSubmitted {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }

    func submitFeatureSuggestion() {
        // Ensure feature suggestion is not empty
        guard !featureSuggestion.isEmpty else {
            successMessage = "Please provide a suggestion before submitting."
            return
        }

        // Prepare the data to send
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "feedback_type": "feature_suggestion",
            "feedback_content": featureSuggestion
        ]

        // Send to backend (create a new table `app_feedback`)
        guard let url = URL(string: "\(baseURL)users/submit_feedback/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    successMessage = "Error: \(error.localizedDescription)"
                } else {
                    successMessage = "Thank you for your suggestion!"
                    isSubmitted = true
                    featureSuggestion = ""  // Clear the field
                }
            }
        }.resume()
    }
}

struct ReportProblemPage: View {
    @State private var problemReport = ""
    @State private var isSubmitted = false
    @State private var successMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Report a Problem")
                .font(.title)
                .bold()

            Text("Please describe the issue you encountered.")
                .font(.body)
                .foregroundColor(.gray)

            TextEditor(text: $problemReport)
                .frame(height: 150)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            Button(action: submitProblemReport) {
                Text("Submit Report")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }

            if isSubmitted {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }

    func submitProblemReport() {
        // Ensure problem report is not empty
        guard !problemReport.isEmpty else {
            successMessage = "Please provide a description of the problem."
            return
        }

        // Prepare the data to send
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "feedback_type": "problem_report",
            "feedback_content": problemReport
        ]

        // Send to backend (create a new table `app_feedback`)
        guard let url = URL(string: "\(baseURL)users/submit_feedback/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    successMessage = "Error: \(error.localizedDescription)"
                } else {
                    successMessage = "Thank you for reporting the problem!"
                    isSubmitted = true
                    problemReport = ""  // Clear the field
                }
            }
        }.resume()
    }
}

struct TermsOfServicePage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("A. Terms & Conditions")
                    .font(.title)
                    .foregroundColor(Color(hex: "004aad"))

                Text("Effective Date: March 30, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("""
Welcome to Circl International Inc. (“Circl,” “we,” “us,” or “our”). By accessing or using our platform, you agree to abide by these Terms & Conditions. If you do not agree, please do not use our platform.

1. Use of the Platform
You must be at least 18 years old to use Circl.
You are responsible for all activity under your account.
Misuse of the platform, including spamming, harassment, or unauthorized access, will result in suspension or termination.

2. Intellectual Property
Circl owns all platform content, trademarks, and proprietary materials.
Users retain ownership of their content but grant Circl a license to use it for platform functionality.

3. Modification of Terms
Circl reserves the right to update these Terms & Conditions at any time. Users will be notified of significant changes.

4. Limitation of Liability
Circl is not responsible for business outcomes, financial losses, or damages resulting from platform use.
We provide the platform “as is” without warranties of any kind.

5. Governing Law
These Terms & Conditions are governed by the laws of the State of Texas, USA.

6. Termination
We reserve the right to terminate accounts violating these terms.
""")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Terms & Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("B. Privacy Policy")
                    .font(.title)
                    .foregroundColor(Color(hex: "004aad"))

                Text("Effective Date: March 30, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("""
Circl International Inc. values your privacy. This Privacy Policy explains how we collect, use, and protect your data.

1. Information We Collect
Personal data (e.g., name, email, business details).
Usage data (e.g., interactions with the platform).

2. How We Use Your Data
To provide and improve our platform.
To personalize user experience and offer relevant business connections.

3. Data Sharing & Security
We do not sell user data.
Third-party service providers may access data for platform functionality.
We implement security measures but cannot guarantee absolute protection.

4. Data Retention Policy
User data is retained for as long as necessary to provide services and comply with legal obligations.

5. User Rights
You may request data access, modification, or deletion.

C. Competition Clause
Effective Date: March 30, 2025
Circl International Inc. fosters a collaborative entrepreneurial environment. We support businesses on our platform, including those that may compete with each other.

1. Fair Use Policy
Users may engage in competition but must not engage in unethical practices such as data scraping, user poaching, or misleading promotions.

2. Platform Protection
Users may not use Circl to undermine the platform’s integrity or to create a directly competing service using Circl’s proprietary features.

3. Reporting & Enforcement
Violations may result in suspension or legal action.
""")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommunityGuidelinesPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("D. Community Guidelines")
                    .font(.title)
                    .foregroundColor(Color(hex: "004aad"))

                Text("Effective Date: March 30, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("""
To maintain a productive environment, Circl International Inc. enforces the following guidelines:

1. Respectful Communication
No harassment, discrimination, or hate speech.
Constructive discussions are encouraged.

2. Business Ethics
No fraudulent activities, scams, or misinformation.
Respect confidentiality and intellectual property.

3. User-Generated Content Policy
Users are responsible for the content they post.
Circl reserves the right to remove content that violates policies.
Users grant Circl a non-exclusive license to use content posted on the platform for operational purposes.

4. Enforcement
Violations may result in content removal, account suspension, or permanent bans.

5. Dispute Resolution & Liability Disclaimer
Effective Date: March 30, 2025

E. Dispute Resolution
Disputes will be resolved through arbitration in the State of Texas, USA.
Users waive the right to class-action lawsuits.

2. Limitation of Liability
Circl is not responsible for user interactions, business decisions, or losses.
Users agree to indemnify Circl against legal claims arising from platform use.

3. Refund & Subscription Policy
If paid services are introduced, refund policies will be clearly stated at the time of purchase.

By using Circl, you agree to these terms. For inquiries, contact join@circlinternational.com.
""")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Community Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactSupportPage: View {
    @State private var name = ""
    @State private var email = ""
    @State private var question = ""
    @State private var isSubmitted = false
    @State private var successMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "headphones")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color(hex: "004aad"))
                    
                    Text("Contact Support")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("We're here to help! Send us your questions or feedback.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Form Card
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your full name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("your.email@example.com", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How can we help?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextEditor(text: $question)
                            .frame(height: 120)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .font(.system(size: 16))
                    }

                    Button(action: {
                        isSubmitted = true
                        successMessage = "Thank you for contacting us! We'll get back to you within 24 hours."
                        // Clear form
                        name = ""
                        email = ""
                        question = ""
                    }) {
                        HStack {
                            if isSubmitted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(isSubmitted ? "Message Sent!" : "Send Message")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isSubmitted ? 
                                    [Color.green, Color.green.opacity(0.8)] :
                                    [Color(hex: "004aad"), Color(hex: "0066ff")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(name.isEmpty || email.isEmpty || question.isEmpty)
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)

                    if isSubmitted {
                        Text(successMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                // Additional Resources Card
                VStack(spacing: 16) {
                    Text("Other Ways to Reach Us")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Link(destination: URL(string: "https://www.circlinternational.com/contact-circl")!) {
                        HStack {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "004aad"))
                            
                            Text("Visit our Contact Page")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "004aad").opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.systemGray6))
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Easter Egg Video Player
struct EasterEggVideoPlayer: View {
    let player: AVPlayer?
    @Environment(\.presentationMode) var presentationMode
    @State private var isPlayerReady = false
    @State private var playerStatus = "Initializing..."
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        print("🎬 VideoPlayer appeared")
                        
                        // Log current item info
                        if let currentItem = player.currentItem {
                            print("🎬 Current item: \(currentItem)")
                            print("🎬 Asset: \(currentItem.asset)")
                            
                            // Check if asset is playable
                            let asset = currentItem.asset
                            asset.loadValuesAsynchronously(forKeys: ["playable", "duration"]) {
                                DispatchQueue.main.async {
                                    var error: NSError?
                                    let playableStatus = asset.statusOfValue(forKey: "playable", error: &error)
                                    let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
                                    
                                    print("🎬 Playable status: \(playableStatus.rawValue)")
                                    print("🎬 Duration status: \(durationStatus.rawValue)")
                                    
                                    if playableStatus == .loaded {
                                        print("🎬 Asset is playable: \(asset.isPlayable)")
                                        print("🎬 Asset duration: \(asset.duration)")
                                        playerStatus = "Ready to play"
                                    }
                                    
                                    if let error = error {
                                        print("❌ Asset loading error: \(error)")
                                        playerStatus = "Error: \(error.localizedDescription)"
                                    }
                                }
                            }
                        }
                        
                        // Configure player for better playback
                        player.volume = 1.0
                        player.actionAtItemEnd = .none
                        
                        // Start playing with a delay to ensure everything is loaded
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            print("🎬 Attempting to start playback...")
                            player.play()
                            isPlayerReady = true
                            
                            // Check player rate after attempting to play
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                print("🎬 Player rate after play(): \(player.rate)")
                                print("🎬 Player status: \(player.status.rawValue)")
                                print("🎬 Player error: \(player.error?.localizedDescription ?? "none")")
                                
                                if player.rate == 0 {
                                    playerStatus = "Video failed to play"
                                } else {
                                    playerStatus = "Playing"
                                }
                            }
                        }
                    }
                    .onDisappear {
                        player.pause()
                        player.seek(to: .zero)
                    }
            } else {
                // Fallback content when video isn't available
                VStack(spacing: 20) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("🎉 Easter Egg Activated! 🎉")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You found the secret!")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Video temporarily unavailable")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            // Debug status overlay (can be removed later)
            VStack {
                HStack {
                    Text(playerStatus)
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                }
                .padding(.top, 60)
                Spacer()
            }
            
            // Loading indicator while player is setting up
            if !isPlayerReady && player != nil {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Loading video...")
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
            
            // Close button in top-right corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Fun easter egg message at the bottom
            VStack {
                Spacer()
                Text("🎉 You found the secret! 🎉")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .padding()
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
    }
}


struct PageSettings_Previews: PreviewProvider {
    static var previews: some View {
        PageSettings()
    }
}
