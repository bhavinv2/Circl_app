import SwiftUI
import Foundation

struct PageMessages: View {
    
    // MARK: - Constants
    private let baseURL = "https://circl-backend-bhavinv2.vercel.app/"
    
    // MARK: - State Variables
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
    @State private var showMoreMenu = false
    @State private var rotationAngle: Double = 0
    @State private var userProfileImageURL: String? = nil
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
                loadDummyData() // Add dummy data first
                fetchNetworkUsers()
                loadUserData()
                loadUserProfileImage()
           
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
                        ChatView(user: user)
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
                                    
                                    Text(user.company.isEmpty ? "Network Connection" : user.company)
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

    // MARK: - Enhanced Scrollable Section
    var scrollableSection: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if groupedMessages.isEmpty {
                    // Empty state with modern design
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "004aad").opacity(0.1),
                                            Color(hex: "004aad").opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(Color(hex: "004aad").opacity(0.6))
                        }
                        
                        VStack(spacing: 12) {
                            Text("No conversations yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Start a conversation with someone from your network using the search bar above")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        
                        // Call to action button
                        NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("Find People to Connect")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "004aad"),
                                                Color(hex: "004aad").opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 80)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                } else {
                    // Enhanced conversation list
                    ForEach(Array(groupedMessages.keys).sorted(by: { userId1, userId2 in
                        let messages1 = groupedMessages[userId1] ?? []
                        let messages2 = groupedMessages[userId2] ?? []
                        
                        let lastMessage1 = messages1.last?.timestamp ?? ""
                        let lastMessage2 = messages2.last?.timestamp ?? ""
                        
                        return lastMessage1 > lastMessage2 // Sort descending (newest first)
                    }), id: \.self) { userId in
                        if let messages = groupedMessages[userId], let user = myNetwork.first(where: { $0.id == userId }) {
                            ModernConversationRow(
                                user: user,
                                messages: messages,
                                onTap: {
                                    selectedUser = user
                                    showChatPage = true
                                },
                                onProfileTap: {
                                    if let userId = Int(user.id) {
                                        fetchUserProfile(userId: userId) { profile in
                                            if let profile = profile,
                                               let window = UIApplication.shared.windows.first {
                                                let profileView = DynamicProfilePreview(profileData: profile, isInNetwork: true)
                                                window.rootViewController?.present(UIHostingController(rootView: profileView), animated: true)
                                            }
                                        }
                                    }
                                },
                                markAsRead: {
                                    markMessagesAsRead(senderId: user.id)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        fetchMessages()
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
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
    
    private func loadDummyData() {
        // Create dummy network users
        let dummyUsers = [
            NetworkUser(
                id: "1",
                name: "Sarah Johnson",
                username: "sarah.johnson",
                email: "sarah@email.com",
                company: "TechStart Inc",
                bio: "Founder & CEO at TechStart. Building the future of AI.",
                profile_image: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150",
                tags: ["AI", "Startups", "Leadership"],
                isOnline: true
            ),
            NetworkUser(
                id: "2",
                name: "Michael Chen",
                username: "michael.chen",
                email: "michael@email.com",
                company: "InnovateLab",
                bio: "Product Manager passionate about user experience.",
                profile_image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
                tags: ["Product", "UX", "Innovation"],
                isOnline: false
            ),
            NetworkUser(
                id: "3",
                name: "Emily Rodriguez",
                username: "emily.rodriguez",
                email: "emily@email.com",
                company: "GreenTech Solutions",
                bio: "Sustainability advocate and clean energy entrepreneur.",
                profile_image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150",
                tags: ["CleanTech", "Sustainability", "Impact"],
                isOnline: true
            ),
            NetworkUser(
                id: "4",
                name: "David Kim",
                username: "david.kim",
                email: "david@email.com",
                company: "FinTech Ventures",
                bio: "Building the next generation of financial tools.",
                profile_image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150",
                tags: ["FinTech", "Blockchain", "Investment"],
                isOnline: false
            )
        ]
        
        // Create dummy messages
        let dummyMessages = [
            Message(
                id: "msg1",
                sender_id: "1",
                receiver_id: "5", // Assuming current user ID is 5
                content: "Hey! I saw your post about the startup event. Are you planning to attend?",
                timestamp: "2025-01-27T14:30:00.000000Z",
                is_read: false
            ),
            Message(
                id: "msg2",
                sender_id: "5",
                receiver_id: "1",
                content: "Yes, definitely! I'm really excited about the keynote speaker.",
                timestamp: "2025-01-27T14:32:00.000000Z",
                is_read: true
            ),
            Message(
                id: "msg3",
                sender_id: "1",
                receiver_id: "5",
                content: "Same here! Maybe we can grab coffee afterwards and discuss potential collaboration opportunities?",
                timestamp: "2025-01-27T14:35:00.000000Z",
                is_read: false
            ),
            Message(
                id: "msg4",
                sender_id: "2",
                receiver_id: "5",
                content: "Hi! I loved your presentation on AI in product development. Would you be interested in exploring a partnership?",
                timestamp: "2025-01-26T16:45:00.000000Z",
                is_read: false
            ),
            Message(
                id: "msg5",
                sender_id: "3",
                receiver_id: "5",
                content: "Great meeting you at the sustainability summit! Let's schedule a call to discuss the green tech initiative.",
                timestamp: "2025-01-25T11:20:00.000000Z",
                is_read: true
            ),
            Message(
                id: "msg6",
                sender_id: "4",
                receiver_id: "5",
                content: "Thanks for connecting! I'm interested in learning more about your fintech platform.",
                timestamp: "2025-01-24T09:15:00.000000Z",
                is_read: false
            )
        ]
        
        // Set the dummy data
        self.myNetwork = dummyUsers
        self.messages = dummyMessages
        self.groupedMessages = Dictionary(grouping: dummyMessages, by: { $0.sender_id })
        
        print("✅ Loaded dummy data: \(dummyUsers.count) users and \(dummyMessages.count) messages")
    }
    
    private func filterUsers() {
        // Filter network users based on search text
        if searchText.isEmpty {
            suggestedUsers = []
        } else {
            suggestedUsers = myNetwork.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.company.localizedCaseInsensitiveContains(searchText)
            }
        }
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
    
    // MARK: - Helper Functions
    
    private func fetchNetworkUsers() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "\(baseURL)users/get_network/\(userId)/") else {
            print("❌ Invalid URL")
            return
        }

        print("📡 Fetching network from: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let networkUsers = try JSONDecoder().decode([NetworkUser].self, from: data)
                DispatchQueue.main.async {
                    self.myNetwork = networkUsers
                    print("✅ Fetched \(networkUsers.count) network users")
                }
            } catch {
                print("❌ Failed to decode network users: \(error)")
            }
        }.resume()
    }

    private func fetchMessages() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "\(baseURL)messages/get_messages/\(userId)/") else {
            print("❌ Invalid URL for messages")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let fetchedMessages = try JSONDecoder().decode([Message].self, from: data)
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                    self.groupedMessages = Dictionary(grouping: fetchedMessages, by: { $0.sender_id })
                    print("✅ Fetched \(fetchedMessages.count) messages")
                }
            } catch {
                print("❌ Failed to decode messages: \(error)")
            }
        }.resume()
    }

    private func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        guard let url = URL(string: "\(baseURL)users/profile/\(userId)/") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(FullProfile.self, from: data)
                    DispatchQueue.main.async {
                        completion(profile)
                    }
                } catch {
                    print("Failed to decode profile: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    private func markMessagesAsRead(senderId: String) {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "\(baseURL)messages/mark_as_read/") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = [
            "user_id": userId,
            "sender_id": senderId
        ] as [String : Any]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Failed to encode request body: \(error)")
            return
        }

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
