import SwiftUI
import Foundation

struct PageMessages: View {
    
    @State private var messages: [Message] = [] // Messages array
    @State private var newMessageText = "" // For message input
    @State private var searchText: String = "" // Search bar input
    @State private var suggestedUsers: [NetworkUser] = []
    @State private var refreshToggle = false // ✅ Forces UI refresh
    @State private var showChatPopup = false
    @State private var showDirectMessages: Bool = true
    @State private var userCirclChannels: [Channel] = [] // ← You'll fill this later via API

    @State private var selectedUser: NetworkUser? = nil
    @State private var groupedMessages: [Int: [Message]] = [:]
    @State private var showChatPage = false

    @State private var timer: Timer?
    @State private var selectedProfile: FullProfile? = nil
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

    @State private var myNetwork: [NetworkUser] = [] // ✅ Correct type
    
    // User profile data for header
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var userMessages: [MessageModel] = [] // Separate from main messages
    @AppStorage("user_id") private var userId: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    headerSection
             
                    searchBarSection
                    scrollableSection
                }

                ZStack(alignment: .bottomTrailing) {
                    if showMenu {
                        // 🧼 Tap-to-dismiss layer
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showMenu = false
                                }
                            }
                            .zIndex(0)
                    }

                    VStack(alignment: .trailing, spacing: 8) {
                        if showMenu {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Welcome to your resources")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray5))

                                NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "person.2.fill", title: "Connect and Network")
                                }
                                NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
                                }
                                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
                                }
                                NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "briefcase.fill", title: "Professional Services")
                                }
                                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "envelope.fill", title: "Messages", badgeCount: unreadMessageCount)
                                }
                                NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                                }
                                NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "person.3.fill", title: "The Circl Exchange")
                                }

                                Divider()

                                NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true))
 {
                                    MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .frame(width: 250)
                            .transition(.scale.combined(with: .opacity))
                        }

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showMenu.toggle()
                                rotationAngle += 360 // spin the logo
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "004aad"))
                                    .frame(width: 60, height: 60)

                                Image("CirclLogoButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .rotationEffect(.degrees(rotationAngle))
                            }
                        }
                        .shadow(radius: 4)
                        .padding(.bottom, 33)

                    }
                    .padding(.trailing, 20)
                    .zIndex(1)
                
                }


            }

            .edgesIgnoringSafeArea(.bottom)

            .onAppear {
                fetchNetworkUsers()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    fetchMessages()
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { _ in
                    fetchMessages()
                }
                
                // Load user profile and messages
                loadUserData()
            }
            .onDisappear {
                DispatchQueue.main.async {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        Text("Circl.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                }
                
                Spacer()
                
                ProfileHeaderView(
                    userFirstName: $userFirstName,
                    userProfileImageURL: $userProfileImageURL,
                    unreadMessageCount: $unreadMessageCount
                )
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color(hex: "004aad"))
        }
    }
    
    
    
    var searchBarSection: some View {
        VStack {
            HStack {
                TextField("Search for users in your network...", text: $searchText, onEditingChanged: { isEditing in
                    if isEditing {
                        filterUsers()
                    }
                })
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        suggestedUsers = [] // ✅ Clear dropdown if search text is empty
                    } else {
                        filterUsers()
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .font(.system(size: 16))

                NavigationLink(
                    destination: selectedUser.map { user in
                        ChatView(
                            user: user,
                            messages: groupedMessages[user.id, default: []],
                            myNetwork: $myNetwork,
                            onSendMessage: { newMessage in
                                self.groupedMessages[user.id, default: []].append(newMessage)
                                self.refreshToggle.toggle()
                            }
                        )
                        .onDisappear {
                            searchText = "" // ✅ Clears search bar when returning from chat
                            selectedUser = nil
                        }
                    },
                    isActive: $showChatPage
                ) {
                    Button(action: {
                        if selectedUser != nil {
                            showChatPage = true // ✅ Trigger Navigation
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            if !suggestedUsers.isEmpty && !searchText.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(suggestedUsers, id: \.id) { user in
                            Text(user.name)
                                .font(.headline)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                                .onTapGesture {
                                    selectedUser = user
                                    searchText = user.name
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        suggestedUsers.removeAll() // ✅ Clears dropdown immediately
                                    }
                                }
                        }
                    }
                    
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                }
                .dismissKeyboardOnScroll()
                
                .frame(height: 150)
            }
            
        }
        .padding(.top, 15)
        
    }

    var scrollableSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Sort conversations by most recent message timestamp
                ForEach(Array(groupedMessages.keys).sorted(by: { userId1, userId2 in
                    let messages1 = groupedMessages[userId1] ?? []
                    let messages2 = groupedMessages[userId2] ?? []
                    
                    let lastMessage1 = messages1.last?.timestamp ?? ""
                    let lastMessage2 = messages2.last?.timestamp ?? ""
                    
                    return lastMessage1 > lastMessage2 // Sort descending (newest first)
                }), id: \.self) { userId in
                    if let messages = groupedMessages[userId], let user = myNetwork.first(where: { $0.id == userId }) {
                        let myId = UserDefaults.standard.integer(forKey: "user_id")
                        let hasUnread = messages.contains { message in
                            message.receiver_id == myId &&
                            !message.is_read &&
                            message.sender_id != myId
                        }
                        
                        NavigationLink(
                            destination: ChatView(
                                user: user,
                                messages: messages,
                                myNetwork: $myNetwork,
                                onSendMessage: { newMessage in
                                    self.groupedMessages[userId, default: []].append(newMessage)
                                    self.refreshToggle.toggle()
                                }
                            )
                            .onAppear {
                                markMessagesAsRead(senderId: user.id)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    fetchMessages()
                                }
                            }
                        ) {
                            HStack(spacing: 15) {
                                // Profile image code
                                Button(action: {
                                    fetchUserProfile(userId: user.id) { profile in
                                        if let profile = profile,
                                           let window = UIApplication.shared.windows.first {
                                            let profileView = DynamicProfilePreview(profileData: profile, isInNetwork: true)
                                            window.rootViewController?.present(UIHostingController(rootView: profileView), animated: true)
                                        }
                                    }
                                }) {
                                    if let imageURL = user.profileImage,
                                       let url = URL(string: imageURL) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } else {
                                                Image("default_image")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            }
                                        }
                                        .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                    } else {
                                        Image("default_image")
                                            .resizable()
                                            .frame(width: 55, height: 55)
                                            .clipShape(Circle())
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    let lastMessage = messages.last
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(lastMessage?.content ?? "")
                                            .font(.system(size: 14, weight: hasUnread ? .bold : .regular))
                                            .foregroundColor(hasUnread ? .primary : .gray)
                                            .lineLimit(1)
                                        
                                        if hasUnread {
                                            let myId = UserDefaults.standard.integer(forKey: "user_id")
                                            let unreadCount = messages.filter {
                                                $0.receiver_id == myId && !$0.is_read && $0.sender_id != myId
                                            }.count

                                            if unreadCount > 0 {
                                                Text("\(unreadCount) message\(unreadCount == 1 ? "" : "s") unread")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }

                                }
                                
                                Spacer()
                                
                                VStack {
                                    if let lastMessage = messages.last {
                                        Text(lastMessage.displayTime)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                }
            }
            .padding()
        }
        .dismissKeyboardOnScroll()
    }



    private func filterUsers() {
        print("🔍 Searching for: \(searchText)")

        if searchText.isEmpty {
            suggestedUsers = []
        } else {
            suggestedUsers = myNetwork.filter { user in
                let isMatch = user.name.lowercased().contains(searchText.lowercased())
                return isMatch
            }
        }
        
        refreshToggle.toggle() // ✅ Forces UI update
    }

    private func navigateToChat(user: NetworkUser) {
        if let existingMessages = groupedMessages[user.id] {
            let chatView = ChatView(
                user: user,
                messages: existingMessages,
                myNetwork: $myNetwork,
                onSendMessage: { newMessage in
                    self.groupedMessages[user.id, default: []].append(newMessage)
                    self.refreshToggle.toggle()
                }
            )
            navigateTo(chatView)
        } else {
            let chatView = ChatView(
                user: user,
                messages: [],
                myNetwork: $myNetwork,
                onSendMessage: { newMessage in
                    self.groupedMessages[user.id, default: []].append(newMessage)
                    self.refreshToggle.toggle()
                }
            )
            navigateTo(chatView)
        }
    }

    func navigateTo<Destination: View>(_ destination: Destination) {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        keyWindow?.rootViewController?
            .present(UIHostingController(rootView: destination), animated: true, completion: nil)
    }

    func fetchNetworkUsers() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "https://circlapp.online/api/users/get_network/\(userId)/") else {
            print("❌ Invalid URL")
            return
        }

        print("📡 Fetching network from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            if let data = data {
                do {
                    let friends = try JSONDecoder().decode([NetworkUser].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.myNetwork = friends
                        print("✅ Network Updated: \(self.myNetwork.map { "\($0.name) (\($0.id))" })")
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }

    func fetchMessages() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        guard let url = URL(string: "https://circlapp.online/api/users/get_messages/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: [Message]].self, from: data)
                    DispatchQueue.main.async {
                        let allMessages = response["messages"] ?? []
                        print("=== MESSAGES DEBUG ===")
                        allMessages.forEach { message in
                            print("Message \(message.id): From \(message.sender_id) to \(message.receiver_id), Read: \(message.is_read), Content: \(message.content)")
                        }
                        print("=====================")
                        self.groupedMessages = Dictionary(grouping: allMessages) { $0.sender_id == userId ? $0.receiver_id : $0.sender_id }
                    }
                } catch {
                    print("Error decoding messages:", error)
                }
            }
        }.resume()
    }
    
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
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
                print("❌ Request failed:", error)
                completion(nil)
                return
            }

            if let data = data {
                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                    return
                } else {
                    print("❌ Failed to decode JSON")
                }
            }
            completion(nil)
        }.resume()
    }

    private func sendMessage(content: String, recipient: NetworkUser) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let newMessage = Message(
            id: UUID().hashValue,
            sender_id: senderId,
            receiver_id: recipient.id,
            content: content,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            is_read: false
        )

        DispatchQueue.main.async {
            if self.groupedMessages[recipient.id] == nil {
                self.groupedMessages[recipient.id] = []
            }
            self.groupedMessages[recipient.id]?.append(newMessage)
            self.refreshToggle.toggle()
        }

        let messageData: [String: Any] = [
            "sender_id": senderId,
            "receiver_id": recipient.id,
            "content": content
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageData) else { return }

        guard let url = URL(string: "https://circlapp.online/api/users/send_message/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 201 {
                    print("❌ Failed to send message")
                }
            }
        }.resume()
    }
    
    func markMessagesAsRead(senderId: Int) {
        guard let myId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        print("Marking messages as read from \(senderId) to \(myId)")

        guard let url = URL(string: "https://circlapp.online/api/users/mark_messages_read/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["sender_id": senderId, "receiver_id": myId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("Mark as read response: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Mark as read error: \(error)")
            }
        }.resume()
    }
    
    // MARK: - User Profile Functions
    func loadUserData() {
        fetchCurrentUserProfile()
        loadUserMessages()
    }
    
    func fetchCurrentUserProfile() {
        guard userId > 0 else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
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
    
    func loadUserMessages() {
        guard userId > 0 else { return }
        
        guard let url = URL(string: "https://circlapp.online/api/messages/user_messages/\(userId)/") else { return }
        
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
                    self.userMessages = allMessages
                    self.calculateUnreadMessageCount()
                }
            } catch {
                print("Error decoding messages:", error)
            }
        }.resume()
    }
    
    func calculateUnreadMessageCount() {
        guard userId > 0 else { return }
        
        let unreadMessages = userMessages.filter { message in
            message.receiver_id == userId && !message.is_read && message.sender_id != userId
        }
        
        unreadMessageCount = unreadMessages.count
    }
}

struct ChatPopup: View {
    let user: NetworkUser
    @Binding var isPresented: Bool
    @State private var messageText: String = ""

    var onSendMessage: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Chat with \(user.name)")
                    .font(.headline)
                    .padding()
                
                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
                .padding()
            }

            Spacer()

            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !messageText.isEmpty {
                    onSendMessage(messageText)
                    messageText = ""
                    isPresented = false
                }
            }) {
                Text("Send")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
        .frame(width: 300, height: 250)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct Message: Identifiable, Codable, Equatable {
    let id: Int
    let sender_id: Int
    let receiver_id: Int
    let content: String
    let timestamp: String
    let is_read: Bool
    
    var displayTime: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // for full precision

        // Try parsing timestamp string
        guard let date = formatter.date(from: timestamp) ??
                         ISO8601DateFormatter().date(from: timestamp.components(separatedBy: ".").first ?? "") else {
            return "just now"
        }

        let secondsAgo = Int(Date().timeIntervalSince(date))

        switch secondsAgo {
        case ..<10: return "just now"
        case 10..<60: return "\(secondsAgo) seconds"
        case 60..<3600:
            let minutes = secondsAgo / 60
            return minutes == 1 ? "1 minute" : "\(minutes) minutes"
        case 3600..<86400:
            let hours = secondsAgo / 3600
            return hours == 1 ? "1 hour" : "\(hours) hours"
        case 86400..<2592000:
            let days = secondsAgo / 86400
            return days == 1 ? "1 day" : "\(days) days"
        default:
            let months = secondsAgo / 2592000
            return months == 1 ? "1 month" : "\(months) months"
        }
    }
}

struct NetworkUser: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let email: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case profileImage = "profileImage" // 👈 match backend key
    }
}

struct ChatBox: View {
    let user: NetworkUser
    let messages: [Message]

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if let window = UIApplication.shared.windows.first {
                        let profileView = DynamicProfilePreview(
                            profileData: FullProfile(
                                user_id: user.id,
                                profile_image: nil,
                                first_name: user.name.components(separatedBy: " ").first ?? "",
                                last_name: user.name.components(separatedBy: " ").last ?? "",
                                email: "",
                                main_usage: nil,
                                industry_interest: nil,
                                title: nil,
                                bio: nil,
                                birthday: nil,
                                education_level: nil,
                                institution_attended: nil,
                                certificates: nil,
                                years_of_experience: nil,
                                personality_type: nil,
                                locations: nil,
                                achievements: nil,
                                skillsets: nil,
                                availability: nil,
                                clubs: nil,
                                hobbies: nil,
                                connections_count: nil,
                                circs: nil,
                                entrepreneurial_history: ""

                            ),
                            isInNetwork: true
                        )

                        window.rootViewController?.present(UIHostingController(rootView: profileView), animated: true)
                    }
                }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text(messages.last?.content ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(messages.last?.timestamp ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
        }
        .padding(.bottom, 10)
    }
}

struct ChatView: View {
    let user: NetworkUser
    let messages: [Message]
    @Binding var myNetwork: [NetworkUser]
    var onSendMessage: (Message) -> Void
    @State private var lastMessageId: Int?

    @State private var messageText: String = ""
    @State private var chatMessages: [Message] = []
    @State private var scrollTarget: Int? = nil
    @State private var isFirstAppearance = true
    @Environment(\.presentationMode) var presentationMode

    private var headerBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Back")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Text(user.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            // to balance layout
            Spacer().frame(width: 60)
        }
        .padding(.horizontal)
        .padding(.vertical, 25)
        .background(Color(hex: "004aad"))
    }


    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(chatMessages) { message in
                            messageView(for: message)
                                .id(message.id)
                        }

                        // ✅ Anchor at bottom that always gets rendered
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding()
                    .onChange(of: chatMessages) { _ in
                        // Scroll to bottom *after* messages are rendered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    chatMessages = messages

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }



            messageInputView
        }
        .navigationBarTitleDisplayMode(.inline)

        .navigationBarBackButtonHidden(true) // optional, hides back button but keeps swipe

        .onDisappear {
            isFirstAppearance = true
        }
    }



    @ViewBuilder
    private func messageView(for message: Message) -> some View {
        let isCurrentUser = message.sender_id == UserDefaults.standard.integer(forKey: "user_id")

        HStack(alignment: .top) {
            if !isCurrentUser {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.gray)
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if isCurrentUser { Spacer() }

                    Button(action: {
                        print("Tapped username: \(isCurrentUser ? "You" : user.name)")
                    }) {
                        HStack(spacing: 4) {
                            Text(isCurrentUser ? "You" : user.name)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if !isCurrentUser { Spacer() }
                }

                Text(message.content)
                    .padding(10)
                    .background(isCurrentUser ? Color(hex: "004aad") : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(12)

                Text(message.displayTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isCurrentUser ? .trailing : .leading)

            if isCurrentUser {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }


    private var messageInputView: some View {
            HStack(spacing: 10) {
                TextField("Type a message...", text: $messageText)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .font(.system(size: 16))

                Button(action: sendMessageAction) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }

    private func sendMessageAction() {
            guard !messageText.isEmpty else { return }
            sendMessage(content: messageText, recipient: user)
            messageText = ""
        }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        guard !chatMessages.isEmpty else { return }
        let lastId = chatMessages.last?.id
        
        // Debug print to verify we have messages and an ID
        print("Attempting to scroll to message with ID: \(lastId ?? -1)")
        
        if animated {
            withAnimation {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }

    private func sendMessage(content: String, recipient: NetworkUser) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let newMessage = Message(
            id: UUID().hashValue,
            sender_id: senderId,
            receiver_id: recipient.id,
            content: content,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            is_read: false
        )

        chatMessages.append(newMessage)
        onSendMessage(newMessage)

        let messageData: [String: Any] = [
            "sender_id": senderId,
            "receiver_id": recipient.id,
            "content": content
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageData),
              let url = URL(string: "https://circlapp.online/api/users/send_message/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 201 {
                    print("❌ Failed to send message")
                }
            }
        }.resume()
    }
}

#Preview {
    PageMessages()
}
