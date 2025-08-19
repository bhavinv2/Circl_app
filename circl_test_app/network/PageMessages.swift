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
    @State private var groupedMessages: [String: [Message]] = [:]
    @State private var showChatPage = false

    @State private var timer: Timer?
    @State private var selectedProfile: FullProfile? = nil
    @State private var userProfileImageURL: String? = nil
    @State private var showMoreMenu = false
    @State private var rotationAngle: Double = 0
    @State private var unreadMessageCount: Int = 0
    @State private var userFirstName: String = ""

    @State private var myNetwork: [NetworkUser] = [] // ✅ Correct type
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background gradient
                let backgroundColors = [
                    Color(.systemBackground),
                    Color(hex: "004aad").opacity(0.02),
                    Color(hex: "004aad").opacity(0.01)
                ]
                
                LinearGradient(
                    gradient: Gradient(colors: backgroundColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    searchBarSection
                    scrollableSection
                }
                
                // Bottom navigation as overlay
                VStack {
                    Spacer()
                    bottomNavigationBar
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
                
                // More Menu Popup
                if showMoreMenu {
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("More Options")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                .foregroundColor(.primary)
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                // Messages (current page)
                                HStack(spacing: 16) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Messages")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text("Current page")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Network
                                NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Network")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Connect with entrepreneurs")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Professional Services
                                NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "briefcase.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Professional Services")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Find business experts")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Settings
                                NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "gear.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Settings")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Manage preferences")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                            }
                            
                            // Close button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMoreMenu = false
                                }
                            }) {
                                Text("Close")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .background(Color(UIColor.systemGray6))
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Leave space for bottom navigation
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(2)
                }
                
                // Tap-out-to-dismiss layer
                if showMoreMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                        }
                        .zIndex(1)
                }
            }
            .ignoresSafeArea(.all, edges: [.top, .bottom])
            .navigationBarBackButtonHidden(true)
            .onAppear {
                self.checkUserAuthentication()
                fetchNetworkUsers()
                loadUserProfileImage()
                loadUserData()
           
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
    
    // MARK: - Header Section (matching other pages)
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Profile with shadow
                NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        AsyncImage(url: URL(string: userProfileImageURL ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Online indicator
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 12, y: -12)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                // Center - Simple Logo
                Text("Circl.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side - Home
                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
    
    
    
    // MARK: - Enhanced Search Bar Section
    var searchBarSection: some View {
        VStack(spacing: 16) {
            // Search Bar with modern styling
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
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
                    .font(.system(size: 16))
                    .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            suggestedUsers = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(25)
                
                NavigationLink(
                    destination: selectedUser.map { user in
                        ChatView(user: user, messages: groupedMessages[user.id, default: []])
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
                        ZStack {
                            Circle()
                                .fill(Color(hex: "004aad"))
                                .frame(width: 48, height: 48)
                                .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(selectedUser != nil ? 1.0 : 0.7)
                        .opacity(selectedUser != nil ? 1.0 : 0.5)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedUser != nil)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Enhanced Suggested Users Dropdown
            if !suggestedUsers.isEmpty && !searchText.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggestedUsers.prefix(5), id: \.id) { user in
                        Button(action: {
                            selectedUser = user
                            searchText = user.name
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                suggestedUsers.removeAll() // ✅ Clears dropdown immediately
                            }
                        }) {
                            HStack(spacing: 12) {
                                // User avatar
                                AsyncImage(url: URL(string: user.profile_image ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    default:
                                        Circle()
                                            .fill(Color(.systemGray4))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(.secondary)
                                            )
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    Text("@\(user.username)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color(.systemBackground))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if user.id != suggestedUsers.last?.id {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 20)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    var scrollableSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Premium Empty State with Animations
                if groupedMessages.isEmpty {
                    VStack(spacing: 32) {
                        Spacer()
                        
                        // Animated Icon with Breathing Effect
                        ZStack {
                            // Outer glow rings
                            ForEach(0..<3) { index in
                            Circle()
                                    .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                                Color(hex: "004aad").opacity(0.3 - Double(index) * 0.1),
                                                Color(hex: "004aad").opacity(0.1 - Double(index) * 0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                                    .opacity(0.6 - Double(index) * 0.2)
                                    .scaleEffect(1.0 + Double(index) * 0.1)
                                    .animation(
                                        .easeInOut(duration: 2.0 + Double(index) * 0.5)
                                        .repeatForever(autoreverses: true),
                                        value: groupedMessages.isEmpty
                                    )
                            }
                            
                            // Main icon container
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "004aad").opacity(0.15),
                                            Color(hex: "004aad").opacity(0.05),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .overlay(
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .scaleEffect(1.0)
                                            .animation(
                                                .easeInOut(duration: 2.0)
                                                .repeatForever(autoreverses: true),
                                                value: groupedMessages.isEmpty
                                            )
                                    }
                                )
                        }
                        .shadow(color: Color(hex: "004aad").opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        // Premium Text Content
                        VStack(spacing: 12) {
                            Text("Your Conversations")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Connect with your network and start meaningful conversations")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 20)
                        }
                        
                        // Premium Action Buttons
                        VStack(spacing: 16) {
                            if myNetwork.isEmpty {
                                Button(action: {
                                    print("🔄 Manual refresh triggered")
                                    fetchNetworkUsers()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        fetchMessages()
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Refresh Messages")
                                            .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                            .background(
                                        RoundedRectangle(cornerRadius: 14)
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
                                            .shadow(color: Color(hex: "004aad").opacity(0.4), radius: 12, x: 0, y: 6)
                                    )
                                }
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: myNetwork.isEmpty)
                            }
                            
                            // Discover People Button
                            NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Discover People")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                    .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color(hex: "004aad").opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
                
                // Premium Conversation List with Enhanced Spacing
                LazyVStack(spacing: 12) {
                    ForEach(Array(groupedMessages.keys).sorted(by: { userId1, userId2 in
                        let messages1 = groupedMessages[userId1] ?? []
                        let messages2 = groupedMessages[userId2] ?? []
                        
                        let lastMessage1 = messages1.last?.timestamp ?? ""
                        let lastMessage2 = messages2.last?.timestamp ?? ""
                        
                        return lastMessage1 > lastMessage2 // Sort descending (newest first)
                    }), id: \.self) { userId in
                        if let messages = groupedMessages[userId], let user = myNetwork.first(where: { $0.id == userId }) {
                            let myUserId = String(UserDefaults.standard.integer(forKey: "user_id"))
                            let hasUnread = messages.contains { message in
                                message.receiver_id == myUserId &&
                                !message.is_read &&
                                message.sender_id != myUserId
                            }
                        
                        // Premium Conversation Card with Advanced Visual Effects
                        NavigationLink(
                            destination: ChatView(user: user, messages: messages)
                                .onAppear {
                                    markMessagesAsRead(senderId: user.id)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        fetchMessages()
                                    }
                                }
                        ) {
                            HStack(spacing: 16) {
                                // Premium Profile Avatar with Glow Effects
                                Button(action: {
                                    if let userIdInt = Int(user.id) {
                                        fetchUserProfile(userId: userIdInt) { profile in
                                            if let profile = profile,
                                               let window = UIApplication.shared.windows.first {
                                                let profileView = DynamicProfilePreview(profileData: profile, isInNetwork: true)
                                                window.rootViewController?.present(UIHostingController(rootView: profileView), animated: true)
                                            }
                                        }
                                    }
                                }) {
                                    ZStack {
                                        // Compact glow ring for unread messages
                                        if hasUnread {
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(hex: "004aad").opacity(0.6),
                                                            Color(hex: "0066dd").opacity(0.3),
                                                            Color.clear
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                                .frame(width: 50, height: 50)
                                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: hasUnread)
                                        }
                                        
                                        // Compact avatar container
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    RadialGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(hex: "004aad").opacity(0.08),
                                                            Color(hex: "004aad").opacity(0.03),
                                                            Color.clear
                                                        ]),
                                                        center: .center,
                                                        startRadius: 8,
                                                        endRadius: 24
                                                    )
                                                )
                                                .frame(width: 48, height: 48)
                                            
                                            if let imageURL = user.profile_image,
                                               let url = URL(string: imageURL) {
                                                AsyncImage(url: url) { phase in
                                                    if let image = phase.image {
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 44, height: 44)
                                                            .clipShape(Circle())
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(.ultraThinMaterial, lineWidth: 1.5)
                                                            )
                                                    } else {
                                                        Circle()
                                                            .fill(.ultraThinMaterial)
                                                            .frame(width: 44, height: 44)
                                                            .overlay(
                                                                Image(systemName: "person.fill")
                                                                    .font(.system(size: 18, weight: .medium))
                                                                    .foregroundColor(Color(hex: "004aad").opacity(0.7))
                                                            )
                                                    }
                                                }
                                            } else {
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                                    .frame(width: 44, height: 44)
                                                    .overlay(
                                                        Image(systemName: "person.fill")
                                                            .font(.system(size: 18, weight: .medium))
                                                            .foregroundColor(Color(hex: "004aad").opacity(0.7))
                                                    )
                                            }
                                        }
                                        .shadow(color: hasUnread ? Color(hex: "004aad").opacity(0.25) : .black.opacity(0.08), radius: hasUnread ? 6 : 3, x: 0, y: hasUnread ? 3 : 1)
                                        
                                        // Compact online indicator
                                        if user.isOnline {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.green)
                                                    .frame(width: 14, height: 14)
                                                    .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 0)
                                                
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .frame(width: 14, height: 14)
                                            }
                                            .offset(x: 15, y: -15)
                                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: user.isOnline)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Premium Content Layout
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(user.name)
                                            .font(.system(size: 18, weight: hasUnread ? .bold : .semibold))
                                            .foregroundColor(hasUnread ? .primary : .primary)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        if let lastMessage = messages.last {
                                            Text(lastMessage.formattedTime)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(hasUnread ? Color(hex: "004aad") : .secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    hasUnread ?
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color(hex: "004aad").opacity(0.1))
                                                    : nil
                                                )
                                        }
                                    }
                                    
                                    HStack {
                                        let lastMessage = messages.last
                                        Text(lastMessage?.content ?? "Start a conversation...")
                                            .font(.system(size: 16, weight: hasUnread ? .semibold : .medium))
                                            .foregroundColor(hasUnread ? .primary : .secondary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        if hasUnread {
                                            let myUserId = String(UserDefaults.standard.integer(forKey: "user_id"))
                                            let unreadCount = messages.filter {
                                                $0.receiver_id == myUserId && !$0.is_read && $0.sender_id != myUserId
                                            }.count

                                            if unreadCount > 0 {
                                                ZStack {
                                                    Circle()
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
                                                        .frame(width: 24, height: 24)
                                                        .shadow(color: Color(hex: "004aad").opacity(0.4), radius: 8, x: 0, y: 4)
                                                    
                                                    Text("\(min(unreadCount, 99))")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                                .scaleEffect(1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: unreadCount)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                ZStack {
                                    // Base glass morphism background
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    hasUnread ?
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(hex: "004aad").opacity(0.08),
                                                            Color(hex: "004aad").opacity(0.03),
                                                            Color.white.opacity(0.95)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    :
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.white.opacity(0.95),
                                                            Color(.systemBackground).opacity(0.8)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                    
                                    // Subtle border with gradient
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            hasUnread ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "004aad").opacity(0.3),
                                                    Color(hex: "004aad").opacity(0.1),
                                                    Color.clear
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            :
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(.separator).opacity(0.3),
                                                    Color.clear
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            )
                            .shadow(
                                color: hasUnread ? Color(hex: "004aad").opacity(0.15) : .black.opacity(0.05),
                                radius: hasUnread ? 12 : 6,
                                x: 0,
                                y: hasUnread ? 6 : 2
                            )
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasUnread)
                        }
                    }
                }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .padding(.bottom, 120) // Add bottom padding to clear navigation
        }
        .refreshable {
            fetchMessages()
        }
    }
    
    // MARK: - Bottom Navigation Bar
    private var bottomNavigationBar: some View {
        HStack(spacing: 0) {
            // Forum / Home
            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                VStack(spacing: 4) {
                    Image(systemName: "house")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                    Text("Home")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
            
            // Network
            NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                VStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                    Text("Network")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
            
            // Circles
            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                VStack(spacing: 4) {
                    Image(systemName: "circle.grid.2x2")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                    Text("Circles")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
            
            // Business Profile
            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                VStack(spacing: 4) {
                    Image(systemName: "building.2")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                    Text("Business")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
            
            // More Menu
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showMoreMenu.toggle()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                    Text("More")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(UIColor.separator))
                .padding(.horizontal, 16),
            alignment: .top
        )
    }
    
    // MARK: - Helper Functions
    private func loadUserData() {
        let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
        userFirstName = fullName.components(separatedBy: " ").first ?? "User"
        userProfileImageURL = UserDefaults.standard.string(forKey: "user_profile_image_url") ?? ""
    }
    
    private func loadUserProfileImage() {
        // This function loads the user profile image URL from UserDefaults
        // It's already handled in loadUserData(), but keeping this for compatibility
        userProfileImageURL = UserDefaults.standard.string(forKey: "user_profile_image_url") ?? ""
    }
    
    // MARK: - Helper Functions
    
    private func checkUserAuthentication() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let authToken = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ Missing user authentication data")
            return
        }
        
        print("✅ User authenticated - ID: \(userId), Token: \(authToken.prefix(10))...")
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
        let messages = groupedMessages[user.id, default: []]
        let chatView = ChatView(user: user, messages: messages)
        navigateTo(chatView)
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

        guard let url = URL(string: "\(baseURL)users/get_network/\(userId)/") else {
            print("❌ Invalid URL for get_network")
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
                    // Try to decode as API format first (with Int IDs)
                    let apiUsers = try JSONDecoder().decode([APINetworkUser].self, from: data)
                    
                    // Convert to SharedDataModels format
                    let convertedUsers = apiUsers.map { apiUser in
                        NetworkUser(
                            id: String(apiUser.id),
                            name: apiUser.name,
                            username: apiUser.email, // Use email as username if not provided
                            email: apiUser.email,
                            company: "", // Default empty if not provided
                            bio: "", // Default empty if not provided
                            profile_image: apiUser.profileImage,
                            tags: [],
                            isOnline: false
                        )
                    }
                    
                DispatchQueue.main.async {
                        self.myNetwork = convertedUsers
                        print("✅ Network Updated: \(self.myNetwork.map { "\($0.name) (\($0.id))" })")
                }
            } catch {
                    print("❌ JSON Decoding Error:", error)
                    print("❌ Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                }
            }
        }.resume()
    }

    func fetchMessages() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "\(baseURL)users/get_messages/\(userId)/") else {
            print("❌ Invalid messages URL")
            return
        }


        print("📡 Fetching messages from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Messages network error:", error.localizedDescription)
                return
            }

            if let data = data {
                print("📦 Raw messages response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                
                do {
                    // Try different response formats
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Format 1: {"messages": [...]}
                        if let messagesArray = jsonObject["messages"] as? [[String: Any]] {
                            let apiMessages = try JSONSerialization.data(withJSONObject: messagesArray)
                            let decodedMessages = try JSONDecoder().decode([APIMessage].self, from: apiMessages)
                            
                            let convertedMessages = decodedMessages.map { apiMessage in
                                Message(
                                    id: String(apiMessage.id),
                                    sender_id: String(apiMessage.sender_id),
                                    receiver_id: String(apiMessage.receiver_id),
                                    content: apiMessage.content,
                                    timestamp: apiMessage.timestamp,
                                    is_read: apiMessage.is_read
                                )
                            }
                            
                DispatchQueue.main.async {
                                print("=== MESSAGES DEBUG ===")
                                convertedMessages.forEach { message in
                                    print("Message \(message.id): From \(message.sender_id) to \(message.receiver_id), Read: \(message.is_read), Content: \(message.content)")
                                }
                                print("=====================")
                                
                                let userIdString = String(userId)
                                self.groupedMessages = Dictionary(grouping: convertedMessages) { message in
                                    return message.sender_id == userIdString ? message.receiver_id : message.sender_id
                                }
                                print("✅ Grouped \(convertedMessages.count) messages into \(self.groupedMessages.count) conversations")
                            }
                        } else {
                            print("❌ No 'messages' array found in response")
                        }
                    } else {
                        // Format 2: Direct array
                        let decodedMessages = try JSONDecoder().decode([APIMessage].self, from: data)
                        let convertedMessages = decodedMessages.map { apiMessage in
                            Message(
                                id: String(apiMessage.id),
                                sender_id: String(apiMessage.sender_id),
                                receiver_id: String(apiMessage.receiver_id),
                                content: apiMessage.content,
                                timestamp: apiMessage.timestamp,
                                is_read: apiMessage.is_read
                            )
                        }
                        
                    DispatchQueue.main.async {
                            let userIdString = String(userId)
                            self.groupedMessages = Dictionary(grouping: convertedMessages) { message in
                                return message.sender_id == userIdString ? message.receiver_id : message.sender_id
                            }
                            print("✅ Processed \(convertedMessages.count) messages")
                        }
                }
            } catch {
                    print("❌ Error decoding messages:", error)
                    print("❌ Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                }
            }
        }.resume()
    }

    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "\(baseURL)users/profile/\(userId)/"
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


    
    func markMessagesAsRead(senderId: String) {
        guard let myIdInt = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        print("Marking messages as read from \(senderId) to \(myIdInt)")

        guard let url = URL(string: "\(baseURL)users/mark_messages_read/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["sender_id": Int(senderId) ?? 0, "receiver_id": myIdInt]
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
}

// MARK: - API Response Models (for conversion from backend)
struct APINetworkUser: Codable {
    let id: Int
    let name: String
    let email: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case profileImage = "profileImage"
    }
}

struct APIMessage: Codable {
    let id: Int
    let sender_id: Int
    let receiver_id: Int
    let content: String
    let timestamp: String
    let is_read: Bool
}

// MARK: - Supporting Views

struct ModernConversationRow: View {
    let user: NetworkUser
    let messages: [Message]
    let onTap: () -> Void
    let onProfileTap: () -> Void
    let markAsRead: () -> Void
    
    private var hasUnread: Bool {
        let myId = String(UserDefaults.standard.integer(forKey: "user_id"))
        return messages.contains { message in
            message.receiver_id == myId &&
            !message.is_read &&
            message.sender_id != myId
        }
    }
    
    private var unreadCount: Int {
        let myId = String(UserDefaults.standard.integer(forKey: "user_id"))
        return messages.filter { message in
            message.receiver_id == myId &&
            !message.is_read &&
            message.sender_id != myId
        }.count
    }
    
    private var lastMessage: String {
        return messages.last?.content ?? "No messages"
    }
    
    private var timestamp: String {
        guard let lastMsg = messages.last else { return "" }
        return formatTimestamp(lastMsg.timestamp)
    }
    
    var body: some View {
        Button(action: {
            onTap()
            if hasUnread {
                markAsRead()
            }
        }) {
            HStack(spacing: 16) {
                // User avatar with online indicator
                Button(action: onProfileTap) {
                    ZStack {
                        AsyncImage(url: URL(string: user.profile_image ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                            default:
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "004aad").opacity(0.3),
                                            Color(hex: "004aad").opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(hex: "004aad"))
                                    )
                            }
                        }
                        
                        // Online indicator
                        Circle()
                            .fill(Color.green)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Conversation details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(user.name)
                            .font(.system(size: 17, weight: hasUnread ? .semibold : .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(timestamp)
                            .font(.system(size: 14))
                            .foregroundColor(hasUnread ? Color(hex: "004aad") : .secondary)
                            .fontWeight(hasUnread ? .medium : .regular)
                    }
                    
                    HStack {
                        Text(lastMessage)
                            .font(.system(size: 15))
                            .foregroundColor(hasUnread ? .primary : .secondary)
                            .fontWeight(hasUnread ? .medium : .regular)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if hasUnread && unreadCount > 0 {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "004aad"))
                                    .frame(width: 24, height: 24)
                                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                Text("\(unreadCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .opacity(0.6)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(hasUnread ? Color(hex: "004aad").opacity(0.2) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: hasUnread)
    }
    
    private func formatTimestamp(_ timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = formatter.date(from: timestamp) {
            let now = Date()
            let timeInterval = now.timeIntervalSince(date)
            
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
                    return formatter.string(from: date)
                }
            }
        }
        
        return ""
    }
}

struct PageMessages_Previews: PreviewProvider {
    static var previews: some View {
        PageMessages()
    }
}
