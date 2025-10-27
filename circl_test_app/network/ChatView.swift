import SwiftUI
import Foundation

struct ChatView: View {
    let user: NetworkUser
    @State private var messageText = ""
    @State private var messages: [NetworkChatMessage] = []
    @State private var isTyping = false
<<<<<<< Updated upstream
=======
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var showingMediaPicker = false
    @State private var showingOptionsMenu = false
    @State private var showMediaMenu = false
    @State private var showProfileSheet = false
    @State private var selectedProfile: FullProfile?
>>>>>>> Stashed changes
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Messages
            messagesSection
            
            // Input bar
            inputSection
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.all, edges: [.top, .bottom])
        .navigationBarHidden(true)
        .onAppear {
            loadDummyMessages()
        }
        .sheet(isPresented: $showProfileSheet) {
            if let profile = selectedProfile {
                DynamicProfilePreview(
                    profileData: profile,
                    isInNetwork: true // Assuming they're in network if they're chatting
                )
            }
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Back button (compact)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
<<<<<<< Updated upstream
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
=======
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Profile picture - tappable
                Button(action: {
                    print("👤 Tapped header profile for: \(user.name)")
                    if let userId = Int(user.id) {
                        fetchUserProfile(userId: userId) { profile in
                            if let profile = profile {
                                selectedProfile = profile
                                showProfileSheet = true
                            }
                        }
                    }
                }) {
                    AsyncImage(url: URL(string: user.profile_image ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        default:
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                
                // User info - tappable
                Button(action: {
                    print("👤 Tapped header user info for: \(user.name)")
                    if let userId = Int(user.id) {
                        fetchUserProfile(userId: userId) { profile in
                            if let profile = profile {
                                selectedProfile = profile
                                showProfileSheet = true
                            }
                        }
                    }
                }) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(user.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Position (placeholder for now)
                        Text("CEO")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Company name
                        Text(user.company)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
>>>>>>> Stashed changes
                Spacer()
                
                // Center - Tappable user info section (expanded to take most space)
                Button(action: {
                    // Navigate to user profile
                    // You can add navigation to user profile here
                }) {
                    HStack(spacing: 12) {
                        // User avatar
                        AsyncImage(url: URL(string: user.profile_image ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            default:
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        
                        // User info
                        VStack(spacing: 2) {
                            Text(user.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(user.isOnline ? Color.green : Color.gray)
                                    .frame(width: 8, height: 8)
                                
                                Text(user.isOnline ? "Online" : "Offline")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                // Right side - Info button (compact)
                Button(action: {
                    // Handle more options (call, video, info, etc.)
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            .padding(.top, 10)
        }
        .padding(.top, 50) // Add safe area padding for status bar and notch
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "004aad"),
                    Color(hex: "004aad").opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
<<<<<<< Updated upstream
    // MARK: - Messages Section
    var messagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        NetworkChatBubble(message: message)
=======
    // MARK: - Helper for grouping messages by date
    private var groupedMessages: [(String, [NetworkChatMessage])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: messages) { message in
            calendar.startOfDay(for: message.timestamp)
        }
        
        return grouped.sorted { $0.key < $1.key }.map { (date, messages) in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let dateString = formatter.string(from: date).uppercased()
            return (dateString, messages.sorted { $0.timestamp < $1.timestamp })
        }
    }
    
    // MARK: - Helper to determine if message should show timestamp
    private func shouldShowTimestamp(for message: NetworkChatMessage, in messages: [NetworkChatMessage]) -> Bool {
        guard let currentIndex = messages.firstIndex(where: { $0.id == message.id }) else { return true }
        
        // Always show timestamp for the last message
        if currentIndex == messages.count - 1 { return true }
        
        let nextMessage = messages[currentIndex + 1]
        
        // Show timestamp if next message is from different sender
        if message.isFromCurrentUser != nextMessage.isFromCurrentUser { return true }
        
        // Show timestamp if there's a significant time gap (more than 5 minutes)
        let timeDifference = nextMessage.timestamp.timeIntervalSince(message.timestamp)
        if timeDifference > 300 { return true } // 5 minutes = 300 seconds
        
        return false
    }
    
    // MARK: - Helper to determine if message should show profile info (name/picture)
    private func shouldShowProfileInfo(for message: NetworkChatMessage, in messages: [NetworkChatMessage]) -> Bool {
        guard let currentIndex = messages.firstIndex(where: { $0.id == message.id }) else { return true }
        
        // Always show profile info for the first message
        if currentIndex == 0 { return true }
        
        let previousMessage = messages[currentIndex - 1]
        
        // Show profile info if previous message is from different sender
        if message.isFromCurrentUser != previousMessage.isFromCurrentUser { return true }
        
        // Show profile info if there's a significant time gap (more than 5 minutes)
        let timeDifference = message.timestamp.timeIntervalSince(previousMessage.timestamp)
        if timeDifference > 300 { return true } // 5 minutes = 300 seconds
        
        return false
    }
    
    // MARK: - Helper to determine if message is in a cluster (consecutive messages from same sender)
    private func isInMessageCluster(for message: NetworkChatMessage, in messages: [NetworkChatMessage]) -> Bool {
        guard let currentIndex = messages.firstIndex(where: { $0.id == message.id }) else { return false }
        
        // Check if previous message is from same sender and within time threshold
        if currentIndex > 0 {
            let previousMessage = messages[currentIndex - 1]
            if message.isFromCurrentUser == previousMessage.isFromCurrentUser {
                let timeDifference = message.timestamp.timeIntervalSince(previousMessage.timestamp)
                if timeDifference <= 300 { return true } // 5 minutes = 300 seconds
            }
        }
        
        return false
    }
    
    // MARK: - LinkedIn Messages Section
    var linkedinMessagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(groupedMessages.enumerated()), id: \.offset) { index, group in
                        let (dateString, messagesForDate) = group
                        
                        // Date separator
                        HStack {
                            Spacer()
                            Text(dateString)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Messages for this date
                        ForEach(messagesForDate) { message in
                            LinkedInMessageBubble(
                                message: message, 
                                user: user, 
                                showTimestamp: shouldShowTimestamp(for: message, in: messagesForDate),
                                showProfileInfo: shouldShowProfileInfo(for: message, in: messagesForDate),
                                isInCluster: isInMessageCluster(for: message, in: messagesForDate),
                                onTapProfile: {
                                    print("👤 Tapped profile for: \(user.name)")
                                    // Convert String id back to Int for API call
                                    if let userId = Int(user.id) {
                                        fetchUserProfile(userId: userId) { profile in
                                            if let profile = profile {
                                                selectedProfile = profile
                                                showProfileSheet = true
                                            }
                                        }
                                    }
                                }
                            )
>>>>>>> Stashed changes
                            .id(message.id)
                        }
                    }
                    
                    // Typing indicator
                    if isTyping {
                        TypingIndicator()
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .onChange(of: messages.count) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Input Section
    var inputSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
<<<<<<< Updated upstream
                // Attachment button
                Button(action: {
                    // Handle attachment
=======
                // Blue plus button (opens media menu)
                Button(action: {
                    showMediaMenu = true
>>>>>>> Stashed changes
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "004aad"))
                }
                .actionSheet(isPresented: $showMediaMenu) {
                    ActionSheet(
                        title: Text("Choose Media Source"),
                        buttons: [
                            .default(Text("Camera")) {
                                // Open camera - you'll need to modify MediaPicker to support camera
                                showingMediaPicker = true
                            },
                            .default(Text("Photo Library")) {
                                // Open photo library 
                                showingMediaPicker = true
                            },
                            .cancel()
                        ]
                    )
                }
                
                // Text input
<<<<<<< Updated upstream
                HStack(spacing: 8) {
                    TextField("Type a message...", text: $messageText)
                        .font(.system(size: 16))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    // Send button
                    Button(action: sendMessage) {
                        ZStack {
                            Circle()
                                .fill(messageText.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "004aad"))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(messageText.isEmpty)
                    .animation(.easeInOut(duration: 0.2), value: messageText.isEmpty)
=======
                TextField("Write a message...", text: $messageText, axis: .vertical)
                    .font(.system(size: 16))
                    .lineLimit(1...5)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .frame(minHeight: 44)
                
                // Send button
                Button(action: {
                    if selectedImage != nil || selectedVideoURL != nil {
                        sendMessageWithMedia()
                    } else {
                        sendMessage()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(hex: "004aad"))
                        )
>>>>>>> Stashed changes
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 20) // Add space above home indicator
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helper Functions
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = NetworkChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromCurrentUser: true,
            timestamp: Date(),
            isRead: true
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(newMessage)
        }
        
        messageText = ""
        
        // Simulate typing response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                isTyping = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isTyping = false
                    simulateResponse()
                }
            }
        }
    }
    
    private func simulateResponse() {
        let responses = [
            "That sounds great!",
            "I'd love to discuss this further.",
            "When would be a good time to meet?",
            "Thanks for reaching out!",
            "Let me know your thoughts.",
            "I'm excited about this opportunity."
        ]
        
        let responseMessage = NetworkChatMessage(
            id: UUID().uuidString,
            content: responses.randomElement() ?? "Thanks for your message!",
            isFromCurrentUser: false,
            timestamp: Date(),
            isRead: true
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(responseMessage)
        }
    }
    
    private func loadDummyMessages() {
        let dummyMessages = [
            // First cluster - Sarah's opening messages (2 hours ago)
            NetworkChatMessage(
                id: "1",
                content: "Hey! Great to connect with you.",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: true
            ),
            
            // My response cluster (2 hours ago - quick response)
            NetworkChatMessage(
                id: "2",
                content: "Thanks! I'm excited to explore potential collaboration opportunities.",
                isFromCurrentUser: true,
<<<<<<< Updated upstream
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: true
=======
                timestamp: Calendar.current.date(byAdding: .minute, value: -118, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: nil,
                mediaURL: nil
>>>>>>> Stashed changes
            ),
            
            // Sarah's second cluster - multiple messages (1 hour ago)
            NetworkChatMessage(
                id: "3",
                content: "I saw your presentation on AI in product development. Really impressive work!",
                isFromCurrentUser: false,
<<<<<<< Updated upstream
                timestamp: Calendar.current.date(byAdding: .minute, value: -90, to: Date()) ?? Date(),
                isRead: true
=======
                timestamp: Calendar.current.date(byAdding: .minute, value: -65, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: user.name,
                mediaURL: nil
>>>>>>> Stashed changes
            ),
            NetworkChatMessage(
                id: "3a",
                content: "The part about machine learning optimization was particularly insightful",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .minute, value: -64, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: user.name,
                mediaURL: nil
            ),
            
            // My response cluster (1 hour ago - quick response)
            NetworkChatMessage(
                id: "4",
                content: "Thank you! I'd love to hear about what you're working on as well.",
                isFromCurrentUser: true,
<<<<<<< Updated upstream
                timestamp: Calendar.current.date(byAdding: .minute, value: -85, to: Date()) ?? Date(),
                isRead: true
=======
                timestamp: Calendar.current.date(byAdding: .minute, value: -63, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: nil,
                mediaURL: nil
>>>>>>> Stashed changes
            ),
            
            // Sarah's final cluster (30 minutes ago)
            NetworkChatMessage(
                id: "5",
                content: "We're building some exciting fintech solutions. Would you be interested in a quick call this week to discuss potential synergies?",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                isRead: true
            )
        ]
        
        self.messages = dummyMessages
    }
<<<<<<< Updated upstream
=======
    
    private func loadRealMessages(_ realMessages: [Message]) {
        print("🔄 Converting \(realMessages.count) messages for chat with \(user.name)")
        
        // Convert Message objects to NetworkChatMessage objects
        let convertedMessages = realMessages.map { message in
            // Parse timestamp string to Date with multiple formats
            let timestamp: Date
            print("🕐 Parsing timestamp: '\(message.timestamp)' for message: '\(message.content.prefix(30))...'")
            
            let iso8601Formatter = ISO8601DateFormatter()
            
            // Try different ISO8601 variations
            if let date = iso8601Formatter.date(from: message.timestamp) {
                timestamp = date
                let timeDiff = Date().timeIntervalSince(date)
                print("✅ Parsed ISO8601 timestamp: \(message.timestamp) -> \(date) (time ago: \(Int(timeDiff))s)")
            } else {
                // Try with fractional seconds
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = iso8601Formatter.date(from: message.timestamp) {
                    timestamp = date
                    let timeDiff = Date().timeIntervalSince(date)
                    print("✅ Parsed ISO8601 with fractional seconds: \(message.timestamp) -> \(date) (time ago: \(Int(timeDiff))s)")
                } else {
                    // Try basic format
                    let basicFormatter = DateFormatter()
                    basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    if let date = basicFormatter.date(from: message.timestamp) {
                        timestamp = date
                        let timeDiff = Date().timeIntervalSince(date)
                        print("✅ Parsed basic format: \(message.timestamp) -> \(date) (time ago: \(Int(timeDiff))s)")
                    } else {
                        // Try without 'T' separator
                        basicFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = basicFormatter.date(from: message.timestamp) {
                            timestamp = date
                            let timeDiff = Date().timeIntervalSince(date)
                            print("✅ Parsed simple format: \(message.timestamp) -> \(date) (time ago: \(Int(timeDiff))s)")
                        } else {
                            timestamp = Date()
                            print("❌ Failed to parse timestamp: '\(message.timestamp)', using current time")
                        }
                    }
                }
            }
            
            let isFromCurrentUser = message.sender_id == currentUserId
            let senderName = isFromCurrentUser ? nil : user.name // Use actual user name for non-current user messages
            
            print("📨 Message: '\(message.content.prefix(30))...' from \(message.sender_id) (current user: \(currentUserId)) -> isFromCurrentUser: \(isFromCurrentUser), senderName: \(senderName ?? "You")")
            
            return NetworkChatMessage(
                id: message.id,
                content: message.content,
                isFromCurrentUser: isFromCurrentUser,
                timestamp: timestamp,
                isRead: message.is_read,
                actualSenderName: senderName,
                mediaURL: nil // Real messages from server would include media_url field
            )
        }
        
        // Sort messages by timestamp (oldest first)
        self.messages = convertedMessages.sorted { $0.timestamp < $1.timestamp }
        
        print("✅ Loaded \(self.messages.count) real messages for chat with \(user.name)")
        print("📋 Messages preview: \(self.messages.map { "\($0.senderName): \($0.content.prefix(20))... (\($0.formattedTime))" })")
    }
    
    // MARK: - Keyboard Handling
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.height
                // Subtract safe area bottom inset to avoid double padding
                let safeAreaBottom = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
                self.keyboardHeight = keyboardHeight - safeAreaBottom
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Options Menu
    var optionsMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Report User
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingOptionsMenu = false
                }
                reportUser()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .frame(width: 20)
                    
                    Text("Report User")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .padding(.horizontal, 16)
            
            // Block User
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingOptionsMenu = false
                }
                blockUser()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .frame(width: 20)
                    
                    Text("Block User")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        ))
    }
    
    // MARK: - User Actions (Placeholder functions)
    private func reportUser() {
        // TODO: Implement report user functionality
        print("🚨 Report user: \(user.name)")
    }
    
    private func blockUser() {
        // TODO: Implement block user functionality  
        print("🚫 Block user: \(user.name)")
    }
    
    private func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/profile/\(userId)/") else {
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
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let profile = try JSONDecoder().decode(FullProfile.self, from: data)
                DispatchQueue.main.async {
                    completion(profile)
                }
            } catch {
                print("Error decoding profile: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

}

// MARK: - LinkedIn Supporting Views

struct LinkedInMessageBubble: View {
    let message: NetworkChatMessage
    let user: NetworkUser
    let showTimestamp: Bool
    let showProfileInfo: Bool
    let isInCluster: Bool
    let onTapProfile: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !message.isFromCurrentUser {
                // Profile picture for other user (left side) - conditional and tappable
                if showProfileInfo {
                    Button(action: onTapProfile) {
                        AsyncImage(url: URL(string: user.profile_image ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            default:
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                } else {
                    // Spacer to maintain alignment when no profile picture
                    Spacer()
                        .frame(width: 36, height: 36)
                }
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Sender name (only show for other users and when showProfileInfo is true) - tappable
                if !message.isFromCurrentUser && showProfileInfo {
                    HStack(spacing: 4) {
                        Button(action: onTapProfile) {
                            Text(message.senderName)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                // Message content
                VStack(alignment: .leading, spacing: 8) {
                    // Text content (only if not empty)
                    if !message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(message.content)
                            .font(.system(size: 16))
                            .foregroundColor(message.isFromCurrentUser ? .white : .black)
                    }
                    
                    // Media content (if present)
                    if let localImage = message.localImage {
                        // Display local image
                        Image(uiImage: localImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(10)
                    } else if let localVideoURL = message.localVideoURL {
                        // Display local video thumbnail
                        ZStack {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 200, height: 150)
                                .cornerRadius(10)
                            
                            VStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                Text("Video")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    } else if let mediaURL = message.mediaURL, let url = URL(string: mediaURL) {
                        if mediaURL.contains(".mov") || mediaURL.contains(".mp4") || mediaURL.contains("/video") {
                            // Video content
                            ZStack {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle()
                                            .fill(Color(.systemGray4))
                                            .frame(width: 200, height: 150)
                                            .overlay(
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                            )
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 150)
                                            .clipped()
                                    case .failure(_):
                                        Rectangle()
                                            .fill(Color(.systemGray4))
                                            .frame(width: 200, height: 150)
                                            .overlay(
                                                Image(systemName: "video.slash.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.gray)
                                            )
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .shadow(radius: 4)
                            }
                            .cornerRadius(10)
                        } else {
                            // Image content
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color(.systemGray6))
                                        .frame(width: 200, height: 200)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        )
                                        .cornerRadius(10)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipped()
                                        .cornerRadius(10)
                                case .failure(_):
                                    Rectangle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 200, height: 200)
                                        .overlay(
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.gray)
                                        )
                                        .cornerRadius(10)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .onTapGesture {
                                // Could add full-screen image viewer here
                            }
                        }
                    }
                }
                .padding(10)
                .background(message.isFromCurrentUser ? Color(hex: "004aad") : Color(.systemGray5))
                .cornerRadius(12)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isFromCurrentUser ? .trailing : .leading)
                
                // Timestamp (conditional)
                if showTimestamp {
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            

        }
        .frame(maxWidth: .infinity, alignment: message.isFromCurrentUser ? .trailing : .leading)
        .padding(.horizontal, 4)
        .padding(.top, isInCluster ? 2 : 8) // Tighter spacing for clustered messages
    }
}

struct LinkedInTypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile picture
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // Sender name
                Text("Typing...")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                // Typing dots
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.secondary.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .offset(y: animationOffset)
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animationOffset
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .padding(.horizontal, 4)
        .onAppear {
            animationOffset = -4
        }
    }
>>>>>>> Stashed changes
}

// MARK: - Supporting Views

struct NetworkChatBubble: View {
    let message: NetworkChatMessage
    let showTimestamp: Bool
    let showProfileInfo: Bool
    let isInCluster: Bool
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("You")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(hex: "004aad"))
                        )
                    
                    if showTimestamp {
                        Text(message.formattedTime)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    if showProfileInfo {
                        Text(message.senderName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemGray5))
                        )
                    
                    if showTimestamp {
                        Text(message.formattedTime)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 4)
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Typing...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.secondary.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .offset(y: animationOffset)
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animationOffset
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemGray5))
                )
            }
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 4)
        .onAppear {
            animationOffset = -4
        }
    }
}

<<<<<<< Updated upstream
=======
// MARK: - Premium Supporting Views

struct PremiumChatBubble: View {
    let message: NetworkChatMessage
    let showTimestamp: Bool
    let showProfileInfo: Bool
    let isInCluster: Bool
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
                
                // Current user message (right side)
                VStack(alignment: .trailing, spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "004aad"),
                                        Color(hex: "0066dd")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text(message.content)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                    .frame(maxWidth: 280, alignment: .trailing)
                    
                    if showTimestamp {
                        Text(message.formattedTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                    }
                }
            } else {
                // Other user message (left side)
                VStack(alignment: .leading, spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                            )
                        
                        Text(message.content)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .frame(maxWidth: 280, alignment: .leading)
                    
                    if showTimestamp {
                        HStack(spacing: 6) {
                            if showProfileInfo {
                                Text(message.senderName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "004aad"))
                                
                                Text("•")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(message.formattedTime)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 4)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }
}

struct PremiumTypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                        )
                    
                    HStack(spacing: 6) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color(hex: "004aad").opacity(0.6))
                                .frame(width: 8, height: 8)
                                .scaleEffect(animationPhase == index ? 1.3 : 1.0)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: animationPhase
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                .frame(maxWidth: 280, alignment: .leading)
                
                Text("Typing...")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .onAppear {
            animationPhase = 0
        }
    }
}

>>>>>>> Stashed changes
// MARK: - Data Models

struct NetworkChatMessage: Identifiable, Codable {
    let id: String
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    let isRead: Bool
    
    var senderName: String {
        isFromCurrentUser ? "You" : "Sarah Johnson" // Default sender name
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        let now = Date()
        let timeInterval = now.timeIntervalSince(timestamp)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(timeInterval / 86400)
            if days < 7 {
                return "\(days)d"
            } else {
                formatter.dateFormat = "MMM d"
                return formatter.string(from: timestamp)
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(user: NetworkUser(
            name: "Sarah Johnson",
            username: "sarah.johnson",
            email: "sarah@email.com",
            company: "TechStart Inc",
            bio: "Founder & CEO",
            profile_image: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150",
            tags: ["AI", "Startups"],
            isOnline: true
        ))
    }
}
