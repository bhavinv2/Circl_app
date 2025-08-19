import SwiftUI
import Foundation
import AVKit

struct PageCircleMessages: View {
    let channel: Channel
    let circleName: String
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme // Auto-detect dark/light mode
    @State private var channelCategories: [ChannelCategory] = []
    @State private var selectedCategory: ChannelCategory? = nil
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

    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var showingMediaPicker = false
    
    @State private var showingFullImage = false
    @State private var fullImageURL: String?

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

                // NEW: Channel buttons row
                if let selected = selectedCategory {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selected.channels) { ch in
                                Button(action: {
                                    withAnimation {
                                        currentChannel = ch
                                        fetchMessages()
                                        fetchMembers()
                                    }
                                }) {
                                    Text(ch.name)
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(currentChannel.id == ch.id ? Color.white : Color.white.opacity(0.2))
                                        .foregroundColor(currentChannel.id == ch.id ? Color(hex: "004aad") : .white)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                        .padding(.top, 4)
                    }
                    .background(Color(hex: "004aad")) // Same blue as header
                }

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

                                Text(selectedCategory?.name ?? "Select")

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
                        ChatBubble(message: message, showingFullImage: $showingFullImage, fullImageURL: $fullImageURL)
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

    func fetchMessages() {
        let urlString = "https://circlapp.online/api/circles/get_messages/\(currentChannel.id)/?user_id=\(userId)"

        print("📡 Fetching messages from: \(urlString)")
        print("📊 Channel ID: \(currentChannel.id), User ID: \(userId)")

        guard let url = URL(string: urlString) else {
            print("❌ Failed to create fetch URL")
            return
        }

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
                            timestamp: Self.dateFormatter.date(from: raw.timestamp) ?? Date(),
                            mediaURL: raw.media_url  // ✅ Add this line exactly here
                        )
                    }


                }
            } catch {
                print("❌ Failed to decode messages:", error)
            }
        }.resume()
    }

    func fetchChannelsInCircle() {
        guard let url = URL(string: "https://circlapp.online/api/circles/get_categories/\(channel.circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load categories:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([ChannelCategory].self, from: data)
                DispatchQueue.main.async {
                    channelCategories = decoded
                    if selectedCategory == nil {
                        selectedCategory = decoded.first
                    }
                }
            } catch {
                print("❌ Failed to decode categories:", error)
            }
        }.resume()
    }



        // MARK: - Input Bar
    private var inputBar: some View {
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
                    if selectedImage != nil || selectedVideoURL != nil {
                        sendMessageWithMedia()
                    } else {
                        sendMessage()
                    }
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
        }
        .background(Color.white)
        .sheet(isPresented: $showingMediaPicker) {
            MediaPicker(image: $selectedImage, videoURL: $selectedVideoURL)
        }
        .sheet(isPresented: $showingFullImage) {
            FullImageViewer(imageURL: fullImageURL)
        }
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
            Text("Select Category")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom, 4)

            ForEach(channelCategories) { cat in
                Button(action: {
                    withAnimation {
                        selectedCategory = cat
                        showCategoryMenu = false

                        // ✅ Automatically switch to the first channel in this category
                        if let first = cat.channels.first {
                            currentChannel = first
                            fetchMessages()
                            fetchMembers()
                        }
                    }
                }) {
                    HStack {
                        Text(cat.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCategory?.id == cat.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "004aad"))
                        }
                    }
                    .padding(.vertical, 6)
                }

                .buttonStyle(PlainButtonStyle())
            }

            Divider()

           
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
        .frame(width: 270)
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
        print("🔴 sendMessage() called with message: '\(newMessage)'")
        print("🔴 userId: \(userId), channelId: \(currentChannel.id)")
        
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("🔴 Message is empty, returning")
            return
        }

        guard let url = URL(string: "https://circlapp.online/api/circles/send_message/") else {
            print("🔴 Failed to create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Try as form data instead of JSON
        let bodyString = "user_id=\(userId)&channel_id=\(currentChannel.id)&content=\(newMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        print("🔴 About to send POST request to: \(url)")
        print("🔴 Body: \(bodyString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("🔴 Response received - Error: \(error?.localizedDescription ?? "none")")
            if let httpResponse = response as? HTTPURLResponse {
                print("🔴 HTTP Status: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("🔴 Server Response: \(responseString)")
            }
            
            DispatchQueue.main.async {
                print("🔴 Clearing message and refreshing")
                self.newMessage = ""
                self.fetchMessages()
            }
        }.resume()
        
        print("🔴 Request sent!")
    }

    func sendMessageWithMedia() {
        print("🔴 sendMessageWithMedia() called")
        print("🔴 Message: '\(newMessage)', HasImage: \(selectedImage != nil), HasVideo: \(selectedVideoURL != nil)")
        
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty || selectedImage != nil || selectedVideoURL != nil else {
            print("🔴 No content to send in media message")
            return
        }
        
        guard let url = URL(string: "https://circlapp.online/api/circles/send_message/") else {
            print("🔴 Failed to create media URL")
            return
        }

        print("🔴 About to send media POST to: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let fields: [String: String] = [
            "user_id": "\(userId)",
            "channel_id": "\(currentChannel.id)",
            "content": newMessage
        ]

        print("🔴 Adding form fields: \(fields)")
        for (key, value) in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.75) {
            print("🔴 Adding image data: \(imageData.count) bytes")
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"media\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        if let videoURL = selectedVideoURL,
           let videoData = try? Data(contentsOf: videoURL) {
            print("🔴 Adding video data: \(videoData.count) bytes")
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"media\"; filename=\"video.mov\"\r\n")
            body.append("Content-Type: video/quicktime\r\n\r\n")
            body.append(videoData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        print("🔴 Sending media request with body size: \(body.count) bytes")

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("🔴 Media response received - Error: \(error?.localizedDescription ?? "none")")
            if let httpResponse = response as? HTTPURLResponse {
                print("🔴 Media HTTP Status: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("🔴 Media Server Response: \(responseString)")
            }
            
            DispatchQueue.main.async {
                print("🔴 Clearing media and refreshing")
                self.newMessage = ""
                self.selectedImage = nil
                self.selectedVideoURL = nil
                self.fetchMessages()
            }
        }.resume()
        
        print("🔴 Media request sent!")
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
    let mediaURL: String?  // ✅ Add this

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
    let media_url: String?  // ✅ add this
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
    @Binding var showingFullImage: Bool
    @Binding var fullImageURL: String?
    
    init(message: ChatMessage, showingFullImage: Binding<Bool>, fullImageURL: Binding<String?>) {
        self.message = message
        self._showingFullImage = showingFullImage
        self._fullImageURL = fullImageURL
    }


    var body: some View {
        HStack(alignment: .top) {
            if !message.isCurrentUser {
                profileSection
            }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Sender name
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
                            .onTapGesture {
                                fullImageURL = mediaURL
                                showingFullImage = true
                            }
                        }
                    }
                }
                .padding(10)
                .background(message.isCurrentUser ? Color(hex: "004aad") : Color(.systemGray5))
                .cornerRadius(12)

                // Timestamp
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

struct FullImageViewer: View {
    let imageURL: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let imageURL = imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipped()
                        case .failure(_):
                            VStack {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text("Failed to load image")
                                    .foregroundColor(.white)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text("No image to display")
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

