import SwiftUI
import UIKit
import Foundation

struct ChatView: View {
    let user: NetworkUser
    @State private var messageText = ""
    @State private var messages: [NetworkChatMessage] = []
    @State private var isTyping = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var showingMediaPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    // Real messages from PageMessages
    private let realMessages: [Message]?
    private let currentUserId: String
    
    // MARK: - Initializers
    
    // Original initializer for dummy messages
    init(user: NetworkUser) {
        self.user = user
        self.realMessages = nil
        self.currentUserId = String(UserDefaults.standard.integer(forKey: "user_id"))
    }
    
    // New initializer for real messages
    init(user: NetworkUser, messages: [Message]) {
        self.user = user
        self.realMessages = messages
        self.currentUserId = String(UserDefaults.standard.integer(forKey: "user_id"))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            linkedinHeaderSection
            
            // Messages
            linkedinMessagesSection
            
            // Input bar
            linkedinInputSection
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.all, edges: [.top, .bottom])
        .navigationBarHidden(true)
        .padding(.bottom, keyboardHeight)
        .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        .onAppear {
            if let realMessages = realMessages {
                loadRealMessages(realMessages)
            } else {
                loadDummyMessages()
            }
            addKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    // MARK: - LinkedIn Header Section
    var linkedinHeaderSection: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(Color(hex: "004aad"))
                .frame(height: 57)
            
            // Main header with profile
            HStack(spacing: 12) {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Profile picture
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
                
                // User info
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
                
                Spacer()
                
                // Right side button
                Button(action: {
                    // Handle more options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Separator
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
        .background(Color(hex: "004aad"))
    }
    
    // MARK: - LinkedIn Messages Section
    var linkedinMessagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Date separator
                    HStack {
                        Spacer()
                        Text("JUN 16")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    ForEach(messages) { message in
                        LinkedInMessageBubble(message: message, user: user)
                            .id(message.id)
                    }
                    
                    // Typing indicator
                    if isTyping {
                        LinkedInTypingIndicator()
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .onChange(of: messages.count) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - LinkedIn Input Section
    var linkedinInputSection: some View {
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
            
            Divider()
            
            HStack(spacing: 12) {
                // Blue plus button (now opens media picker)
                Button(action: {
                    showingMediaPicker = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(hex: "004aad"))
                        )
                }
                
                // Text input
                TextField("Write a message...", text: $messageText)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .onSubmit {
                        sendMessage()
                    }
                
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
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil && selectedVideoURL == nil)
                .opacity(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil && selectedVideoURL == nil ? 0.5 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, keyboardHeight > 0 ? 0 : 20) // Adjust bottom padding based on keyboard
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingMediaPicker) {
            MediaPicker(image: $selectedImage, videoURL: $selectedVideoURL)
        }
    }
    
    // MARK: - Helper Functions
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let currentUserId = UserDefaults.standard.integer(forKey: "user_id")
        let receiverId = user.id   // ✅ Make sure NetworkUser has `id: Int`
        
        let payload: [String: Any] = [
            "sender_id": currentUserId,
            "receiver_id": receiverId,
            "content": messageText
        ]
        
        guard let url = URL(string: "\(baseURL)users/send_message/") else {
            print("❌ Invalid send_message URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error sending message:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 send_message response code:", httpResponse.statusCode)
            }
            
            // Optimistically update UI
            DispatchQueue.main.async {
                let newMessage = NetworkChatMessage(
                    id: UUID().uuidString,
                    content: messageText,
                    isFromCurrentUser: true,
                    timestamp: Date(),
                    isRead: false,
                    actualSenderName: nil,
                    mediaURL: nil
                )
                withAnimation(.easeInOut(duration: 0.3)) {
                    messages.append(newMessage)
                }
                messageText = ""
            }
        }.resume()
    }

    private func sendMessageWithMedia() {
        print("🔴 sendMessageWithMedia() called")
        print("🔴 Message: '\(messageText)', HasImage: \(selectedImage != nil), HasVideo: \(selectedVideoURL != nil)")
        
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil || selectedVideoURL != nil else {
            print("🔴 No content to send in media message")
            return
        }
        
        guard let url = URL(string: "\(baseURL)users/send_message_with_media/") else {
            print("🔴 Failed to create media URL")
            return
        }

        print("🔴 About to send media POST to: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let currentUserId = UserDefaults.standard.integer(forKey: "user_id")
        let receiverId = user.id
        
        let fields: [String: String] = [
            "sender_id": "\(currentUserId)",
            "receiver_id": receiverId,
            "content": messageText
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

        // Create a temporary message with local media to show immediately
        let tempMessage = NetworkChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromCurrentUser: true,
            timestamp: Date(),
            isRead: false,
            actualSenderName: nil,
            mediaURL: nil,
            localImage: selectedImage,
            localVideoURL: selectedVideoURL
        )
        
        // Store the local media for temporary display
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.messages.append(tempMessage)
            }
            self.messageText = ""
            // Don't clear selectedImage/selectedVideoURL yet - we need them for display
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("🔴 Media response received - Error: \(error?.localizedDescription ?? "none")")
            if let httpResponse = response as? HTTPURLResponse {
                print("🔴 Media HTTP Status: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("🔴 Media Server Response: \(responseString)")
            }
            
            DispatchQueue.main.async {
                print("🔴 Clearing media after upload")
                self.selectedImage = nil
                self.selectedVideoURL = nil
            }
        }.resume()
        
        print("🔴 Media request sent!")
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
            isRead: true,
            actualSenderName: user.name,
            mediaURL: nil
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(responseMessage)
        }
    }
    
    private func loadDummyMessages() {
        let dummyMessages = [
            NetworkChatMessage(
                id: "1",
                content: "Hey! Great to connect with you.",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: user.name,
                mediaURL: nil
            ),
            NetworkChatMessage(
                id: "2",
                content: "Thanks! I'm excited to explore potential collaboration opportunities.",
                isFromCurrentUser: true,
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: nil,
                mediaURL: nil
            ),
            NetworkChatMessage(
                id: "3",
                content: "I saw your presentation on AI in product development. Really impressive work!",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .minute, value: -90, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: user.name,
                mediaURL: nil
            ),
            NetworkChatMessage(
                id: "4",
                content: "Thank you! I'd love to hear about what you're working on as well.",
                isFromCurrentUser: true,
                timestamp: Calendar.current.date(byAdding: .minute, value: -85, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: nil,
                mediaURL: nil
            ),
            NetworkChatMessage(
                id: "5",
                content: "We're building some exciting fintech solutions. Would you be interested in a quick call this week to discuss potential synergies?",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                isRead: true,
                actualSenderName: user.name,
                mediaURL: nil
            )
        ]
        
        self.messages = dummyMessages
    }
    
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
                let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
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
    

}

// MARK: - LinkedIn Supporting Views

struct LinkedInMessageBubble: View {
    let message: NetworkChatMessage
    let user: NetworkUser
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !message.isFromCurrentUser {
                // Profile picture for other user (left side)
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
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Sender name (only show for other users)
                if !message.isFromCurrentUser {
                    HStack(spacing: 4) {
                        Text(message.senderName)
                            .font(.caption)
                            .foregroundColor(.gray)
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
                
                // Timestamp
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if message.isFromCurrentUser {
                // Profile picture for current user (right side)
                AsyncImage(url: URL(string: UserDefaults.standard.string(forKey: "user_profile_image_url") ?? "")) { phase in
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
        }
        .frame(maxWidth: .infinity, alignment: message.isFromCurrentUser ? .trailing : .leading)
        .padding(.horizontal, 4)
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
}

// MARK: - Supporting Views

struct NetworkChatBubble: View {
    let message: NetworkChatMessage
    
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
                    
                    Text(message.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.senderName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemGray5))
                        )
                    
                    Text(message.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
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

// MARK: - Premium Supporting Views

struct PremiumChatBubble: View {
    let message: NetworkChatMessage
    
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
                    
                    Text(message.formattedTime)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
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
                    
                    HStack(spacing: 6) {
                        Text(message.senderName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "004aad"))
                        
                        Text("•")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Text(message.formattedTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 4)
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

// MARK: - Data Models

struct NetworkChatMessage: Identifiable, Codable {
    let id: String
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    let isRead: Bool
    let actualSenderName: String? // Store the actual sender name
    let mediaURL: String? // Add media URL field
    
    // Non-Codable local media for temporary display
    var localImage: UIImage?
    var localVideoURL: URL?
    
    init(id: String, content: String, isFromCurrentUser: Bool, timestamp: Date, isRead: Bool, actualSenderName: String?, mediaURL: String?, localImage: UIImage? = nil, localVideoURL: URL? = nil) {
        self.id = id
        self.content = content
        self.isFromCurrentUser = isFromCurrentUser
        self.timestamp = timestamp
        self.isRead = isRead
        self.actualSenderName = actualSenderName
        self.mediaURL = mediaURL
        self.localImage = localImage
        self.localVideoURL = localVideoURL
    }
    
    var senderName: String {
        if isFromCurrentUser {
            return "You"
        } else {
            return actualSenderName ?? "Contact" // Use actual name or fallback to "Contact"
        }
    }
    
    // Custom Codable implementation to handle non-Codable properties
    private enum CodingKeys: String, CodingKey {
        case id, content, isFromCurrentUser, timestamp, isRead, actualSenderName, mediaURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isFromCurrentUser = try container.decode(Bool.self, forKey: .isFromCurrentUser)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        actualSenderName = try container.decodeIfPresent(String.self, forKey: .actualSenderName)
        mediaURL = try container.decodeIfPresent(String.self, forKey: .mediaURL)
        localImage = nil
        localVideoURL = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(isFromCurrentUser, forKey: .isFromCurrentUser)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(isRead, forKey: .isRead)
        try container.encodeIfPresent(actualSenderName, forKey: .actualSenderName)
        try container.encodeIfPresent(mediaURL, forKey: .mediaURL)
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
