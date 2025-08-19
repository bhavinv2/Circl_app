import SwiftUI

struct PageCircleMessages: View {
    let channel: Channel
    let circleName: String
    let circleData: CircleData?  // Add this to get admin/moderator info
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

    // Fullscreen image preview
    @State private var showFullscreenImage = false
    @State private var fullscreenImageURL: String?

    // Admin/Moderator detection
    @State private var isUserAdmin: Bool = false
    @State private var isUserModerator: Bool = false
    
    // Admin functionality states
    @State private var showDashboardToggle = false
    @State private var showCreateCategory = false
    @State private var showCreateChannel = false
    @State private var newCategoryName = ""
    @State private var newChannelName = ""
    @State private var selectedCategoryForChannel: ChannelCategory? = nil


    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

    @State private var showCircleMenu = false
    @State private var showCategoryMenu = false
    @State private var currentChannel: Channel


    init(channel: Channel, circleName: String, circleData: CircleData? = nil) {
        self.channel = channel
        self.circleName = circleName
        self.circleData = circleData
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
            
            // Fullscreen image overlay
            if showFullscreenImage, let imageURL = fullscreenImageURL {
                fullscreenImageView(imageURL: imageURL)
                    .zIndex(3)
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
            checkAdminStatus()
        }

        
        
        .alert("Leave Circle?", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                leaveCircle()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this circle? You will be removed from all its channels.")
        }
        
        // MARK: - Admin Dialogs
        .sheet(isPresented: $showDashboardToggle) {
            DashboardSettingsView(circleId: channel.circleId, onClose: {
                showDashboardToggle = false
            })
        }
        .sheet(isPresented: $showCreateCategory) {
            CreateCategoryView(circleId: channel.circleId, onClose: {
                showCreateCategory = false
                fetchChannelsInCircle()
            })
        }
        .sheet(isPresented: $showCreateChannel) {
            CreateChannelView(circleId: channel.circleId, categories: channelCategories, onClose: {
                showCreateChannel = false
                fetchChannelsInCircle()
            })
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
                        ChatBubble(message: message) { imageURL in
                            fullscreenImageURL = imageURL
                            withAnimation {
                                showFullscreenImage = true
                            }
                        }
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
        guard let url = URL(string: "https://circlapp.online/api/circles/members/\(channel.circleId)/") else { return }


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

    func checkAdminStatus() {
        // First, check if we have circle data with admin/moderator info
        if let circle = circleData {
            isUserAdmin = (userId == circle.creatorId)
            isUserModerator = circle.isModerator
            print("🔐 Using CircleData: isAdmin=\(isUserAdmin), isModerator=\(isUserModerator)")
            return
        }
        
        // Fallback to API check if no circle data available
        guard let url = URL(string: "\(baseURL)circles/check_admin_status/\(channel.circleId)/\(userId)/") else { 
            print("❌ Invalid URL for admin status check")
            return 
        }
        
        print("🔍 Checking admin status at: \(url)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Failed to check admin status:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Admin status check HTTP status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received from admin status check")
                return
            }
            
            print("📥 Admin status raw response: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do {
                if let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.isUserAdmin = response["is_creator"] as? Bool ?? false
                        self.isUserModerator = response["is_moderator"] as? Bool ?? false
                        print("🔐 Admin Status: isAdmin=\(self.isUserAdmin), isModerator=\(self.isUserModerator)")
                    }
                } else {
                    print("❌ Could not parse JSON response")
                }
            } catch {
                print("❌ Failed to decode admin status:", error)
            }
        }.resume()
    }

    func fetchMessages() {
        let urlString = "https://circlapp.online/api/circles/get_messages/\(currentChannel.id)/?user_id=\(userId)"

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
        guard let url = URL(string: "https://circlapp.online/api/circles/get_channels/\(channel.circleId)/") else { return }

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
<<<<<<< Updated upstream:circl_test_app/PageCircleMessages.swift
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
=======
        VStack(spacing: 0) {
            // Media preview section
            if selectedImage != nil || selectedVideoURL != nil {
                HStack {
                    // Media preview
                    if let image = selectedImage {
                        HStack(spacing: 8) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Photo")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Ready to send")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedImage = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    if let videoURL = selectedVideoURL {
                        HStack(spacing: 8) {
                            // Video thumbnail placeholder
                            ZStack {
                                Rectangle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Video")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Ready to send")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedVideoURL = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            
            // Text input and buttons
            HStack(spacing: 8) {
                // + button to open media picker
                Button(action: {
                    showingMediaPicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "004aad"))
                }

                // Message text field
                TextField("Message \(currentChannel.name)...", text: $newMessage)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)

                // Send button
                Button(action: {
                    sendMessageWithMedia()
                }) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                        .font(.title2)
                        .foregroundColor(
                            newMessage.isEmpty && selectedImage == nil && selectedVideoURL == nil
                            ? .gray
                            : Color(hex: "004aad")
                        )
                }
                .disabled(newMessage.isEmpty && selectedImage == nil && selectedVideoURL == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
>>>>>>> Stashed changes:circl_test_app/circles/PageCircleMessages.swift
        }
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

            // TEMPORARY DEBUG: Manual admin toggle for testing
            Divider()
            Button(action: {
                isUserAdmin.toggle()
                print("🔧 Manual admin toggle: isAdmin=\(isUserAdmin)")
            }) {
                HStack {
                    Image(systemName: "wrench.fill")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    VStack(alignment: .leading) {
                        Text("Toggle Admin (Debug)")
                            .foregroundColor(.orange)
                        Text("Admin: \(isUserAdmin ? "YES" : "NO") | Mod: \(isUserModerator ? "YES" : "NO")")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(isUserAdmin ? "ON" : "OFF")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            // MARK: - ADMIN OPTIONS
            if isUserAdmin || isUserModerator {
                Divider()
                
                Text("Circle Management")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Dashboard Toggle
                Button(action: {
                    showDashboardToggle = true
                }) {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(width: 24)
                        Text("Dashboard Settings")
                            .foregroundColor(.primary)
                        Spacer()
                        if isUserAdmin {
                            Text("ADMIN")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.red)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Create Category
                Button(action: {
                    showCreateCategory = true
                }) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(width: 24)
                        Text("Create Category")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Create Channel
                Button(action: {
                    showCreateChannel = true
                }) {
                    HStack {
                        Image(systemName: "number.circle.fill")
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(width: 24)
                        Text("Create Channel")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }

            Divider()

            Button(action: {
                showLeaveConfirmation = true
            }) {
                GroupMenuItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Leave Circle", isDestructive: true)
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
        guard let url = URL(string: "https://circlapp.online/api/circles/leave_circle/") else { return }

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

        let urlString = "https://circlapp.online/api/circles/send_message/"
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
    
    // MARK: - Fullscreen Image View
    private func fullscreenImageView(imageURL: String) -> some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showFullscreenImage = false
                        fullscreenImageURL = nil
                    }
                }
            
            VStack {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFullscreenImage = false
                            fullscreenImageURL = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Full-size image
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    case .failure(_):
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            Text("Failed to load image")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                .frame(maxHeight: UIScreen.main.bounds.height - 200)
                
                Spacer()
            }
        }
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
<<<<<<< Updated upstream:circl_test_app/PageCircleMessages.swift
=======
    let onImageTap: (String) -> Void  // Add callback for image tap
    
    init(message: ChatMessage, onImageTap: @escaping (String) -> Void = { _ in }) {
        self.message = message
        self.onImageTap = onImageTap
        print("🧾 Rendering message:", message.content, "| media:", message.mediaURL ?? "none")
    }

>>>>>>> Stashed changes:circl_test_app/circles/PageCircleMessages.swift

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

<<<<<<< Updated upstream:circl_test_app/PageCircleMessages.swift
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
=======
                // Message bubble
                VStack(alignment: .leading, spacing: 8) {
                    // ✅ Render text if present
                    if let attributed = try? AttributedString(markdown: message.content), !message.content.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text(attributed)
                            .foregroundColor(message.isCurrentUser ? .white : .black)
                    }

                    // ✅ Render media if present
                    if let mediaURL = message.mediaURL, let url = URL(string: mediaURL) {
                        if mediaURL.contains(".mov") || mediaURL.contains(".mp4") || mediaURL.contains("/video") {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(width: 250, height: 200)
                                .cornerRadius(10)
                        } else {
                            Button(action: {
                                onImageTap(mediaURL)
                            }) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(width: 200, height: 200)
                                    case .success(let image):
                                        image.resizable().scaledToFill().frame(width: 200, height: 200).clipped().cornerRadius(10)
                                    case .failure(_):
                                        Image(systemName: "photo.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
>>>>>>> Stashed changes:circl_test_app/circles/PageCircleMessages.swift
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
            ),
            circleName: "Lean Startup-ists",
            circleData: nil
        )
    }
}
<<<<<<< Updated upstream:circl_test_app/PageCircleMessages.swift
=======

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - Admin Dialog Views

struct DashboardSettingsView: View {
    let circleId: Int
    let onClose: () -> Void
    @State private var hasDashboard: Bool = false
    @State private var isLoading: Bool = true
    @AppStorage("user_id") private var userId: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading dashboard settings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dashboard Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Enable or disable the dashboard feature for this circle. The dashboard provides analytics and management tools for circle administrators.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Dashboard Status")
                                    .font(.headline)
                                Text(hasDashboard ? "Enabled" : "Disabled")
                                    .font(.subheadline)
                                    .foregroundColor(hasDashboard ? .green : .red)
                            }
                            
                            Spacer()
                            
                            Toggle("Enable Dashboard", isOn: $hasDashboard)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        Button(action: {
                            saveDashboardSetting()
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "004aad"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { onClose() }
            )
        }
        .onAppear {
            loadDashboardStatus()
        }
    }
    
    func loadDashboardStatus() {
        guard let url = URL(string: "\(baseURL)circles/dashboard_status/\(circleId)/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load dashboard status:", error?.localizedDescription ?? "unknown")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                if let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.hasDashboard = response["has_dashboard"] as? Bool ?? false
                        self.isLoading = false
                    }
                }
            } catch {
                print("❌ Failed to decode dashboard status:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    func saveDashboardSetting() {
        guard let url = URL(string: "\(baseURL)circles/update_dashboard/") else { return }
        
        let payload: [String: Any] = [
            "circle_id": circleId,
            "user_id": userId,
            "has_dashboard": hasDashboard
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    onClose()
                } else {
                    print("❌ Failed to update dashboard setting:", error?.localizedDescription ?? "unknown")
                }
            }
        }.resume()
    }
}

struct CreateCategoryView: View {
    let circleId: Int
    let onClose: () -> Void
    @State private var categoryName: String = ""
    @AppStorage("user_id") private var userId: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Create New Category")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Categories help organize channels in your circle. For example: 'General', 'Projects', 'Resources'.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category Name")
                            .font(.headline)
                        
                        TextField("Enter category name...", text: $categoryName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 4)
                    }
                    
                    Button(action: {
                        createCategory()
                    }) {
                        Text("Create Category")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(categoryName.isEmpty ? Color.gray : Color(hex: "004aad"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(categoryName.isEmpty)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { onClose() }
            )
        }
    }
    
    func createCategory() {
        guard let url = URL(string: "\(baseURL)circles/create_category/") else { return }
        
        let payload: [String: Any] = [
            "circle_id": circleId,
            "user_id": userId,
            "name": categoryName
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    onClose()
                } else {
                    print("❌ Failed to create category:", error?.localizedDescription ?? "unknown")
                }
            }
        }.resume()
    }
}

struct CreateChannelView: View {
    let circleId: Int
    let categories: [ChannelCategory]
    let onClose: () -> Void
    @State private var channelName: String = ""
    @State private var selectedCategory: ChannelCategory? = nil
    @State private var isModeratorOnly: Bool = false
    @AppStorage("user_id") private var userId: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Create New Channel")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Channels are where conversations happen within your circle.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Channel Name")
                            .font(.headline)
                        
                        TextField("Enter channel name...", text: $channelName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                        
                        Menu {
                            ForEach(categories) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory?.name ?? "Select Category")
                                    .foregroundColor(selectedCategory == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Moderator Only")
                                .font(.headline)
                            Text("Only moderators and admins can see this channel")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isModeratorOnly)
                    }
                    
                    Button(action: {
                        createChannel()
                    }) {
                        Text("Create Channel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((channelName.isEmpty || selectedCategory == nil) ? Color.gray : Color(hex: "004aad"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(channelName.isEmpty || selectedCategory == nil)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Channel")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { onClose() }
            )
        }
    }
    
    func createChannel() {
        guard let url = URL(string: "\(baseURL)circles/create_channel/"),
              let category = selectedCategory else { return }
        
        let payload: [String: Any] = [
            "circle_id": circleId,
            "category_id": category.id ?? 0,
            "user_id": userId,
            "name": channelName,
            "is_moderator_only": isModeratorOnly
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    onClose()
                } else {
                    print("❌ Failed to create channel:", error?.localizedDescription ?? "unknown")
                }
            }
        }.resume()
    }
}

>>>>>>> Stashed changes:circl_test_app/circles/PageCircleMessages.swift
