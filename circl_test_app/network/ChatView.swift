import SwiftUI
import Foundation

struct ChatView: View {
    let user: NetworkUser
    @State private var messageText = ""
    @State private var messages: [NetworkChatMessage] = []
    @State private var isTyping = false
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
        .navigationBarHidden(true)
        .onAppear {
            loadDummyMessages()
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // User info
                VStack(spacing: 2) {
                    Text(user.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(user.isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(user.isOnline ? "Online" : "Offline")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Profile button
                Button(action: {
                    // Handle profile tap
                }) {
                    AsyncImage(url: URL(string: user.profile_image ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        default:
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .padding(.top, 50)
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
    
    // MARK: - Messages Section
    var messagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        NetworkChatBubble(message: message)
                            .id(message.id)
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
                // Attachment button
                Button(action: {
                    // Handle attachment
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "004aad"))
                }
                
                // Text input
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
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
            NetworkChatMessage(
                id: "1",
                content: "Hey! Great to connect with you.",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: true
            ),
            NetworkChatMessage(
                id: "2",
                content: "Thanks! I'm excited to explore potential collaboration opportunities.",
                isFromCurrentUser: true,
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: true
            ),
            NetworkChatMessage(
                id: "3",
                content: "I saw your presentation on AI in product development. Really impressive work!",
                isFromCurrentUser: false,
                timestamp: Calendar.current.date(byAdding: .minute, value: -90, to: Date()) ?? Date(),
                isRead: true
            ),
            NetworkChatMessage(
                id: "4",
                content: "Thank you! I'd love to hear about what you're working on as well.",
                isFromCurrentUser: true,
                timestamp: Calendar.current.date(byAdding: .minute, value: -85, to: Date()) ?? Date(),
                isRead: true
            ),
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
}

// MARK: - Supporting Views

struct NetworkChatBubble: View {
    let message: NetworkChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("You")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
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
                    HStack {
                        Text(message.senderName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
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
