import SwiftUI
import Foundation


struct PageMessages: View {
    
    @State private var messages: [Message] = [] // Messages array
    @State private var newMessageText = "" // For message input
    @State private var searchText: String = "" // Search bar input
    @State private var suggestedUsers: [NetworkUser] = []
    @State private var refreshToggle = false // ✅ Forces UI refresh
    @State private var showChatPopup = false

    @State private var selectedUser: NetworkUser? = nil
    @State private var groupedMessages: [Int: [Message]] = [:]
    @State private var showChatPage = false

    @State private var timer: Timer?
    @State private var selectedProfile: FullProfile? = nil

    
    @State private var myNetwork: [NetworkUser] = [] // ✅ Correct type
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                tabNavigation
                searchBarSection
                scrollableSection
                footerSection // ✅ Add the footer section here
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchNetworkUsers()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    fetchMessages()
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { _ in
                    fetchMessages()
                }
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
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                            Text("Filter")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    VStack {
                        HStack(spacing: 10) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 50, height: 40)
                                .foregroundColor(.white)
                            
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }
    }
    
    var tabNavigation: some View {
        HStack(spacing: 10) {
            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                Text("Messages")
                    .font(.system(size: 12))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                Text("Circles")
                    .font(.system(size: 12))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: PageInvites().navigationBarBackButtonHidden(true)) {
                Text("Friends")
                    .font(.system(size: 12))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    var searchBarSection: some View {
        VStack {
            HStack {
                TextField("Search users in your network...", text: $searchText, onEditingChanged: { isEditing in
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
                .textFieldStyle(RoundedBorderTextFieldStyle())

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
                
                .frame(height: 150)
            }
            
        }
        
    }

    var scrollableSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(groupedMessages.keys), id: \.self) { userId in
                    if let messages = groupedMessages[userId], let user = myNetwork.first(where: { $0.id == userId }) {
                        NavigationLink(destination: ChatView(user: user, messages: messages, myNetwork: $myNetwork, onSendMessage: { newMessage in
                            self.groupedMessages[userId, default: []].append(newMessage)
                            self.refreshToggle.toggle()
                        })) {
                            HStack {
                                Button(action: {
                                    if let window = UIApplication.shared.windows.first {
                                        let profileView = DynamicProfilePreview(profileData: FullProfile(
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
                                            connections_count: nil
                                        ))
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
                    }
                }
            }
            .padding()
        }
    }

    private var footerSection: some View {
        HStack(spacing: 15) {
            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
            }

            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "briefcase.fill")
            }

            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "captions.bubble.fill")
            }

            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "building.columns.fill")
            }

            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "newspaper")
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
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

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get_network/\(userId)/") else {
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

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get_messages/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: [Message]].self, from: data)
                    DispatchQueue.main.async {
                        let allMessages = response["messages"] ?? []
                        self.groupedMessages = Dictionary(grouping: allMessages) { $0.sender_id == userId ? $0.receiver_id : $0.sender_id }
                    }
                } catch {
                    print("Error decoding messages:", error)
                }
            }
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

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/send_message/") else { return }

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

struct ChatPopup: View {
    let user: NetworkUser
    @Binding var isPresented: Bool
    @State private var messageText: String = ""

    var onSendMessage: (String) -> Void

    var body: some View {
        VStack {
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

struct Message: Identifiable, Codable {
    let id: Int
    let sender_id: Int
    let receiver_id: Int
    let content: String
    let timestamp: String
    let is_read: Bool
}

struct NetworkUser: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let email: String
}

struct ChatBox: View {
    let user: NetworkUser
    let messages: [Message]

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if let window = UIApplication.shared.windows.first {
                        let profileView = DynamicProfilePreview(profileData: FullProfile(
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
                            connections_count: nil
                        ))
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
    
    @State private var messageText: String = ""
    @State private var chatMessages: [Message] = []

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(chatMessages) { message in
                        HStack {
                            if message.sender_id == UserDefaults.standard.integer(forKey: "user_id") {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .trailing)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }

            HStack(spacing: 15) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                
                Button(action: {
                    if !messageText.isEmpty {
                        sendMessage(content: messageText, recipient: user)
                        messageText = ""
                    }
                }) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
            .padding()
        }
        .navigationBarTitle(user.name, displayMode: .inline)
        .onAppear {
            chatMessages = messages
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

        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageData) else { return }

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/send_message/") else { return }

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

extension Color {
    static func fromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        return Color(red: Double((rgb >> 16) & 0xFF) / 255.0, green: Double((rgb >> 8) & 0xFF) / 255.0, blue: Double(rgb & 0xFF) / 255.0)
    }
}

#Preview {
    PageMessages()
}
