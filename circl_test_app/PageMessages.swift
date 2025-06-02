import SwiftUI

// MARK: - Main View
struct PageMessages: View {
    @State private var messages: [Message] // Messages array
    @State private var isWriteMessagePopupPresented = false
    @State private var showMenu = false // State for hammer menu

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    headerSection
                    tabNavigation
                    scrollableSection
                }
                .navigationBarHidden(true)
                
                // Hammer Menu (replaces footer)
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            // Menu Header
                            Text("Welcome to your resources")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                            
                            // Menu Items with Navigation
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
                            
                            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 250)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Main floating button
                    Button(action: {
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "hammer.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.fromHex("004aad"))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $isWriteMessagePopupPresented) {
                WriteMessagePopupView(messages: $messages)
            }
        }
    }

    var headerSection: some View {
        // Header Section
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // Action for Filter
                    }) {
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
                    // Add the Bubble and Person icons above "Hello, Fragne"
                    VStack {
                        HStack(spacing: 10) {
                            // Navigation Link for Bubble Symbol
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .frame(width: 50, height: 40)  // Adjust size
                                    .foregroundColor(.white)
                            
                            // Person Icon
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // "Hello, Fragne" text below the icons
                        Text("Hello, Fragne")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad")) // Updated blue color
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

    private var scrollableSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(messages.sorted { $0.timeAgoValue < $1.timeAgoValue }) { message in
                    MessageRow(message: message)
                }
            }
        }
    }

    struct MessageRow: View {
        let message: Message

        var body: some View {
            NavigationLink(destination: ChatView(message: message)) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(message.senderName)
                                .font(.headline)
                            Text("\(message.senderRole) - \(message.senderCompany)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(message.timeAgo)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Text(message.previewText)
                        .font(.body)
                        .foregroundColor(.black)
                    Divider()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
        }
    }

    struct Message: Identifiable {
        let id = UUID()
        let senderName: String
        let senderRole: String
        let senderCompany: String
        let previewText: String
        let timeAgo: String

        var timeAgoValue: TimeInterval {
            switch timeAgo {
            case "Just Now": return 0
            case "1 hour": return 3600
            case "1 day": return 86400
            case "2 days": return 172800
            case "1 week": return 604800
            default: return Double.greatestFiniteMagnitude
            }
        }
    }

    static let mockMessages = [
        Message(senderName: "Howard Brown", senderRole: "District Manager", senderCompany: "Ross", previewText: "Morning Fragne, wanted to reach out...", timeAgo: "Just Now"),
        Message(senderName: "Ayaan Patel", senderRole: "VP of Human Resources", senderCompany: "Target", previewText: "Hey Fragne, how's the business doin...", timeAgo: "1 hour"),
        Message(senderName: "John Clark III", senderRole: "CTO", senderCompany: "The Clark Group", previewText: "Have you looked into the sales of th...", timeAgo: "1 day"),
        Message(senderName: "Sophia Johnson", senderRole: "Marketing Manager", senderCompany: "TechCorp", previewText: "We need to talk about the campaign...", timeAgo: "2 days"),
        Message(senderName: "Ella Smith", senderRole: "Founder", senderCompany: "Green Ventures", previewText: "I sent the latest pitch deck...", timeAgo: "1 week")
    ]
    
    // Custom init method
    init() {
        // Initialize messages with static mockMessages
        _messages = State(initialValue: PageMessages.mockMessages)
    }
}

// MARK: - Menu Item Component
struct MenuItem12: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.fromHex("004aad"))
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

// MARK: - Color Extension
extension Color {
    static func fromHex7(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Write Message Popup View
struct WriteMessagePopupView: View {
    @Binding var messages: [PageMessages.Message] // Binding to messages
    @State private var searchText: String = ""
    @State private var messageText: String = ""
    @State private var suggestedUsers: [String] = []
    @State private var selectedUser: String? = nil
    let allUsers: [String] = ["Alice Johnson", "Bob Smith", "Charlie Davis", "David Lee", "Emma White"]
    let myNetwork: [String] = ["Alice Johnson", "David Lee"]

    var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            TextField("Search users...", text: $searchText, onEditingChanged: { _ in
                filterUsers()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            // Suggested Users List
            if !suggestedUsers.isEmpty {
                List(suggestedUsers, id: \.self) { user in
                    Text(user)
                        .font(myNetwork.contains(user) ? .headline : .body)
                        .onTapGesture {
                            selectedUser = user
                            searchText = user
                            suggestedUsers = []
                        }
                }
                .frame(height: 150)
            }
            
            // Message Input
            TextField("Write your message here...", text: $messageText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame()
                .padding()
            
            // Send Button
            Button(action: {
                sendMessage()
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
            .disabled(selectedUser == nil || messageText.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }

    private func filterUsers() {
        suggestedUsers = allUsers.filter { user in
            user.lowercased().contains(searchText.lowercased())
        }.sorted { (myNetwork.contains($0) ? 0 : 1) < (myNetwork.contains($1) ? 0 : 1) }
    }

    private func sendMessage() {
        guard let recipient = selectedUser else { return }
        
        // Create a new message
        let newMessage = PageMessages.Message(
            senderName: recipient,
            senderRole: "User Role",
            senderCompany: "User Company",
            previewText: messageText,
            timeAgo: "Just Now"
        )
        
        // Add the new message to the messages array
        messages.append(newMessage)
        
        print("Message sent to \(recipient): \(messageText)")
        
        // Clear the input fields
        messageText = ""
        selectedUser = nil
        searchText = ""
    }
}

// MARK: - Chat View
struct ChatView: View {
    let message: PageMessages.Message
    @State private var messageText: String = ""
    @State private var messages: [(String, Bool)] = [] // Store messages along with a flag for sent-by-user

    var body: some View {
        VStack {
            // Profile Header
            HStack {
                // Profile Picture
                Image(systemName: "person.circle.fill") // Placeholder, replace with an actual profile image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue) // Or set a specific color

                VStack(alignment: .leading) {
                    Text(message.senderName)
                        .font(.headline)
                    
                    Text(message.senderRole) // Sender's position
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(message.senderCompany) // Sender's company
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()

            // Message List
            ScrollView {
                VStack(alignment: .leading) {
                    // Display the current conversation
                    ForEach(messages, id: \.0) { message in
                        Text(message.0) // The message text
                            .padding()
                            .background(message.1 ? Color(hex: "004aad") : Color.gray.opacity(0.2)) // Custom blue if sent by the user
                            .foregroundColor(message.1 ? .white : .black) // White text for sent messages
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: message.1 ? .trailing : .leading) // Align to the right for user messages
                    }
                }
                .padding()
            }

            // Message Input
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button("Send") {
                    if !messageText.isEmpty {
                        // Add the new message to the conversation (true means it is sent by the user)
                        messages.append((messageText, true))
                        messageText = ""
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Initialize the conversation with the first message (or a mockup for now)
            messages.append((message.previewText, false)) // Initially, we assume it's not sent by the user
        }
    }
}

// MARK: - Preview
#Preview {
    PageMessages()
}
