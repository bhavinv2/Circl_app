import SwiftUI
import Foundation
// MARK: - Shared Header Component
struct ProfileHeaderView: View {
    @Binding var userFirstName: String
    @Binding var userProfileImageURL: String
    @Binding var unreadMessageCount: Int
    @AppStorage("user_id") private var userId: Int = 0
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            HStack(spacing: 10) {
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .resizable()
                            .frame(width: 50, height: 40)
                            .foregroundColor(.white)
                        
                        // Notification badge - positioned more precisely
                        if unreadMessageCount > 0 {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 18, height: 18)
                                
                                Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                    .font(.system(size: 9, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.5)
                                    .allowsTightening(false)
                                    .lineLimit(1)
                            }
                            .offset(x: 20, y: -15)
                        }
                    }
                }

                NavigationLink(destination: ProfileHubPage(initialTab: .profile).navigationBarBackButtonHidden(true)) {
                    if !userProfileImageURL.isEmpty {
                        AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                            switch phase {
                            case .empty:
                                // Loading state
                                ProgressView()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            case .success(let image):
                                // Successfully loaded image
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                            case .failure(_):
                                // Failed to load, show default
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            @unknown default:
                                // Fallback
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.bottom, 5)
            
            // Welcome message with improved styling
            if !userFirstName.isEmpty {
                VStack(spacing: 2) {
                    Text("Welcome back,")
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                        .allowsTightening(false)
                        .lineLimit(1)
                        .kerning(0.1)
                    
                    Text("\(userFirstName)!")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .allowsTightening(false)
                        .lineLimit(1)
                        .kerning(0.2)
                }
                .multilineTextAlignment(.trailing)
            }
        }
    }
}

// MARK: - User Data Manager
class UserDataManager: ObservableObject {
    @Published var userFirstName: String = ""
    @Published var userProfileImageURL: String = ""
    @Published var unreadMessageCount: Int = 0
    @Published var messages: [MessageModel] = []
    
    @AppStorage("user_id") private var userId: Int = 0
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        fetchCurrentUserProfile()
        loadMessages()
    }
    
    func fetchCurrentUserProfile() {
        guard userId > 0 else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "\(baseURL)users/profile/\(userId)/"
        print("🌐 Fetching current user profile from:", urlString)

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(FullProfile.self, from: data)
                DispatchQueue.main.async {
                    // Update profile image URL
                    if let profileImage = decoded.profile_image, !profileImage.isEmpty {
                        self.userProfileImageURL = profileImage
                        print("✅ Profile image loaded: \(profileImage)")
                    } else {
                        self.userProfileImageURL = ""
                        print("❌ No profile image found for current user")
                    }
                    
                    // Update user name info
                    self.userFirstName = decoded.first_name
                }
            } catch {
                print("❌ Failed to decode current user profile:", error)
            }
        }.resume()
    }
    
    func loadMessages() {
        guard userId > 0 else { return }
        
        guard let url = URL(string: "\(baseURL)messages/user_messages/\(userId)/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode([String: [MessageModel]].self, from: data)
                DispatchQueue.main.async {
                    let allMessages = response["messages"] ?? []
                    self.messages = allMessages
                    self.calculateUnreadMessageCount()
                }
            } catch {
                print("Error decoding messages:", error)
            }
        }.resume()
    }
    
    func calculateUnreadMessageCount() {
        guard userId > 0 else { return }
        
        let unreadMessages = messages.filter { message in
            message.receiver_id == userId && !message.is_read && message.sender_id != userId
        }
        
        unreadMessageCount = unreadMessages.count
    }
}
