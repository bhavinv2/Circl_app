import SwiftUI
import Foundation

struct PageCircleMessages: View {
    let channel: Channel
    let circleName: String
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme // Auto-detect dark/light mode
    @State private var allChannelsInCircle: [Channel] = []
    @State private var showMembersPopup = false
    struct Member: Identifiable, Decodable, Hashable {
        let id: Int
        let full_name: String
        let profile_image: String?
        let user_id: Int
    }
    @State private var navigateToMembers = false
    @State private var navigateBackToCircles = false

    @State private var members: [Member] = []
    @State private var selectedMember: Member?
    @State private var showProfilePreview = false

    @State private var showLeaveConfirmation = false


    @State private var newMessage: String = ""
    @AppStorage("user_id") private var userId: Int = 0
    @State private var messages: [ChatMessage] = []


    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

    @State private var showCircleMenu = false
    @State private var showCategoryMenu = false
    @State private var currentChannel: Channel


    init(channel: Channel, circleName: String) {
        self.channel = channel
        self.circleName = circleName
        _currentChannel = State(initialValue: channel)
    }





    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                header
                messagesScrollView
                inputBar
            }
            .zIndex(0)

            // Tap-out background
            if showMenu || showCircleMenu || showCategoryMenu {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                            showCircleMenu = false
                            showCategoryMenu = false
                        }
                    }
                    .zIndex(1)
            }

            if showCircleMenu {
                circleMenu
                    .zIndex(2)
            }

            if showCategoryMenu {
                categoryMenu
                    .zIndex(2)
            }

            if showMenu {
                hammerMenu
                    .zIndex(2)
            }
        }
        NavigationLink(
            destination: MemberListPage(circleName: circleName, circleId: channel.circleId),
            isActive: $navigateToMembers
        ) {
            EmptyView()
        }
        
        NavigationLink(
            destination: PageCircles().navigationBarBackButtonHidden(true),
            isActive: $navigateBackToCircles
        ) {
            EmptyView()
        }


        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchMessages()
            fetchChannelsInCircle()
            fetchMembers()
        }

        
        
        .alert("Leave Circle?", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                leaveCircle()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this circle? You will be removed from all its channels.")
        }

        

    }
    
    

    private var header: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Back")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                    )
                }

                Spacer(minLength: 6)

                // Circle name with dropdown
                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(circleName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Button(action: {
                            withAnimation(.spring()) {
                                closeOtherMenus(except: &showCircleMenu)
                            }
                        }) {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .rotationEffect(.degrees(showCircleMenu ? 180 : 0))
                                .scaleEffect(showCircleMenu ? 1.05 : 1.0)
                        }
                    }

                    // Channel selector row
                    HStack(spacing: 12) {
                        // Premium channel selector - now with button action
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                                closeOtherMenus(except: &showCategoryMenu)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "number.circle.fill")
                                    .foregroundColor(Color(hex: "004aad"))
                                    .font(.system(size: 12))

                                Text(currentChannel.name)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .lineLimit(1)

                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .rotationEffect(.degrees(showCategoryMenu ? 180 : 0))
                                    .animation(.interpolatingSpring(stiffness: 400, damping: 25), value: showCategoryMenu)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white)
                            .cornerRadius(14)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Member count
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.circle")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                            Text("\(members.count)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        // Online indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Online")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }

                Spacer(minLength: 6)

                // Settings button
                Button(action: {
                    withAnimation {
                        closeOtherMenus(except: &showMenu)
                    }
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(showMenu ? 90 : 0))
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color(hex: "004aad"))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "004aad"), 
                        Color(hex: "0052cc")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(edges: .top)
            )
        }
    }

    // MARK: - Messages View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    func fetchMembers() {
        guard let url = URL(string: "\(baseURL)circles/members/\(channel.circleId)/") else { return }


        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load members:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                DispatchQueue.main.async {
                    self.members = decoded
                }
            } catch {
                print("❌ Failed to decode members:", error)
            }
        }.resume()
    }

    func fetchMessages() {
        let urlString = "\(baseURL)circles/get_messages/\(currentChannel.id)/?user_id=\(userId)"

        print("📡 Fetching from: \(urlString)")

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load messages:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([RawChatMessage].self, from: data)
                DispatchQueue.main.async {
                    messages = decoded.map { raw in
                        ChatMessage(
                            id: raw.id,
                            sender: raw.sender,
                            content: raw.content,
                            isCurrentUser: raw.isCurrentUser,
                            timestamp: Self.dateFormatter.date(from: raw.timestamp) ?? Date()
                        )
                    }
                }
            } catch {
                print("❌ Failed to decode messages:", error)
            }
        }.resume()
    }

    
    func fetchChannelsInCircle() {
        guard let url = URL(string: "\(baseURL)circles/get_channels/\(channel.circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load channels:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Channel].self, from: data)
                DispatchQueue.main.async {
                    allChannelsInCircle = decoded
                }
            } catch {
                print("❌ Failed to decode channels for this circle:", error)
            }
        }.resume()
    }



    // MARK: - Input Bar
    private var inputBar: some View {
        HStack {
            TextField("Message \(currentChannel.name)...", text: $newMessage)

                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)

            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .font(.title2)
                    .foregroundColor(newMessage.isEmpty ? .gray : Color(hex: "004aad"))
            }
            .disabled(newMessage.isEmpty)
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - Circle Menu
    private var circleMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            GroupMenuItem(icon: "info.circle.fill", title: "About This Circle")
            GroupMenuItem(icon: "person.crop.circle.badge.plus", title: "Invite Network")
            Button(action: {
                navigateToMembers = true
            }) {

                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(Color(hex: "004aad"))
                        .frame(width: 24)
                    Text("Members List")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())


            GroupMenuItem(icon: "pin.fill", title: "Pinned Messages")
            GroupMenuItem(icon: "folder.fill", title: "Group Files")
            GroupMenuItem(icon: "bell.fill", title: "Notification Settings")

            Divider()

            Button(action: {
                leaveCircle()
            }) {
                Button(action: {
                    leaveCircle()
                }) {
                    Button(action: {
                        showLeaveConfirmation = true
                    }) {
                        GroupMenuItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Leave Circle", isDestructive: true)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
                .buttonStyle(PlainButtonStyle())

            }
            .buttonStyle(PlainButtonStyle())

        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
        .frame(width: 250)
        .padding(.leading, 16)
        .offset(y: 80)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Hammer Menu with Navigation
    private var hammerMenu: some View {
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
                MenuItem(icon: "envelope.fill", title: "Messages")
            }
            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
            }
            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
            }
            Divider()
            NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true)) {
                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
        .frame(width: 250)
        .padding(.trailing, 20)
        .offset(y: 80)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - Category Menu
    private var categoryMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Channels")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 4)

            ForEach(allChannelsInCircle) { ch in
                channelRow(ch, notifications: 0)
            }

            Divider()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
        .frame(width: 250)
        .padding(.leading, 16)
        .offset(y: 80)
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    // MARK: - Helper Methods
    private func channelRow(_ channel: Channel, notifications: Int) -> some View {
        Button(action: {
            withAnimation {
                currentChannel = channel
                showCategoryMenu = false
                fetchMessages()
                fetchMembers() // ✅ add this line to refresh member count
            }
        }) {

            HStack {
                Text(channel.name)
                    .foregroundColor(.primary)

                Spacer()

                if notifications > 0 {
                    Text("\(notifications)")
                        .font(.caption2)
                        .padding(6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func leaveCircle() {
        guard let url = URL(string: "\(baseURL)circles/leave_circle/") else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": channel.circleId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                navigateBackToCircles = true
            }
        }.resume()
    }


    
    


    private func sendMessage() {
        print("🚀 sendMessage called with:", newMessage)

        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let messageData: [String: Any] = [
            "user_id": userId,
            "channel_id": currentChannel.id,

            "content": newMessage
        ]

        let urlString = "\(baseURL)circles/send_message/"
        print("📤 Sending POST to:", urlString)
        print("📦 Payload:", messageData)

        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("📝 POST response error:", error as Any)
            if let http = response as? HTTPURLResponse {
                print("📶 HTTP status code:", http.statusCode)
            }
            if let data = data, let str = String(data: data, encoding: .utf8) {
                print("📬 Response body:", str)
            }

            DispatchQueue.main.async {
                fetchMessages()
                newMessage = ""
            }
        }.resume()
    }



    private func closeOtherMenus(except menu: inout Bool) {
        showMenu = false
        showCircleMenu = false
        showCategoryMenu = false
        menu.toggle()
    }
}

// MARK: - Models & Components

struct ChatMessage: Identifiable {
    let id: Int
    let sender: String
    let content: String
    let isCurrentUser: Bool
    let timestamp: Date

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct RawChatMessage: Decodable {
    let id: Int
    let sender: String
    let content: String
    let isCurrentUser: Bool
    let timestamp: String
}

extension PageCircleMessages {
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm" // match your backend format
        return df
    }()
}


struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top) {
            if !message.isCurrentUser {
                profileSection
            }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if message.isCurrentUser { Spacer() }

                    Button(action: {
                        viewProfile(for: message.sender)
                    }) {
                        HStack(spacing: 4) {
                            Text(message.sender)
                                .font(.caption)
                                .foregroundColor(.gray)

                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if !message.isCurrentUser { Spacer() }
                }

                if let attributed = try? AttributedString(markdown: message.content) {
                    Text(attributed)
                        .padding(10)
                        .background(message.isCurrentUser ? Color(hex: "004aad") : Color(.systemGray5))
                        .foregroundColor(message.isCurrentUser ? .white : .black)
                        .cornerRadius(12)
                } else {
                    Text(message.content)
                        .padding(10)
                        .background(message.isCurrentUser ? Color(hex: "004aad") : Color(.systemGray5))
                        .foregroundColor(message.isCurrentUser ? .white : .black)
                        .cornerRadius(12)
                }


                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isCurrentUser ? .trailing : .leading)

            if message.isCurrentUser {
                profileSection
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
    }

    private var profileSection: some View {
        Button(action: {
            viewProfile(for: message.sender)
        }) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(.gray)
        }
    }

    private func viewProfile(for username: String) {
        print("Viewing profile for \(username)")
    }
}

struct MenuItem3: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "004aad"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct GroupMenuItem: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : Color(hex: "004aad"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}


// MARK: - Color Extension

// MARK: - Color Extension removed (using ColorExtensions.swift instead)

struct PageCircleMessages_Previews: PreviewProvider {
    static var previews: some View {
        PageCircleMessages(
            channel: Channel(
                id: 1,
                name: "#Welcome",
                circleId: 1
            )
,
            circleName: "Lean Startup-ists" // ✅ Just add this line
        )
    }
}
