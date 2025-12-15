import SwiftUI

// MARK: - Shared Adaptive Sidebar Component

struct SharedAdaptiveSidebar: View {
    let configuration: AdaptivePageConfiguration
    let unreadMessageCount: Int
    @ObservedObject var layoutManager: AdaptiveLayoutManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: layoutManager.toggleSidebar) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Navigation Items
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(configuration.navigationItems) { item in
                        NavigationLink(destination: item.destination) {
                            SharedSidebarMenuItem(
                                icon: item.icon,
                                title: item.title,
                                isSelected: item.isCurrentPage,
                                badge: item.badge
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 16)
            }
            
            Spacer()
        }
        .frame(width: 280)
        .background(Color(hex: "004aad"))
    }
}

struct SharedSidebarMenuItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let badge: String?
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(3)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 12, y: -8)
                }
            }
            
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            isSelected ? Color.white.opacity(0.2) : Color.clear
        )
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

// MARK: - Shared Adaptive Header Component

struct SharedAdaptiveHeader: View {
    let configuration: AdaptivePageConfiguration
    let userProfileImageURL: String
    let unreadMessageCount: Int
    @ObservedObject var layoutManager: AdaptiveLayoutManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Sidebar toggle (only show if collapsed)
                if layoutManager.isSidebarCollapsed {
                    Button(action: layoutManager.toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    
                    Text("Circl.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Spacer()
                }
                
                Spacer()
                
                // Page title
                Text(configuration.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Header actions and profile
                HStack(spacing: 16) {
                    ForEach(configuration.customHeaderActions) { action in
                        Button(action: action.action) {
                            ZStack {
                                Image(systemName: action.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                
                                if let badge = action.badge, !badge.isEmpty {
                                    Text(badge)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                    
                    // Messages icon with badge
                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            if unreadMessageCount > 0 {
                                Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                    
                    // Profile picture
                    NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                        AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .background(Color(hex: "004aad"))
    }
}

// MARK: - Shared Bottom Navigation Component

struct SharedBottomNavigation: View {
    let configuration: AdaptivePageConfiguration
    let unreadMessageCount: Int
    @State private var showMoreMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Twitter/X Style Bottom Navigation (copied exactly)
            HStack(spacing: 0) {
                // Forum / Home (Current page - highlighted)
                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 4) {
                        Image(systemName: configuration.title == "Home" ? "house.fill" : "house")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(configuration.title == "Home" ? Color(hex: "004aad") : Color(UIColor.label).opacity(0.6))
                            .padding(.top, 4)
                        Text("Home")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(configuration.title == "Home" ? Color(hex: "004aad") : Color(UIColor.label).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .transaction { transaction in transaction.disablesAnimations = true }

                // Connect and Network
                NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                            .padding(.top, 4)
                        Text("Network")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .transaction { transaction in transaction.disablesAnimations = true }

                // Circles
                NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 4) {
                        Image(systemName: "circle.grid.2x2")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                            .padding(.top, 4)
                        Text("Circles")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .transaction { transaction in transaction.disablesAnimations = true }

                // Growth Hub Profile
                NavigationLink(destination: PageSkillSellingPlaceholder().navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                            .padding(.top, 4)
                        Text("Growth Hub")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .transaction { transaction in transaction.disablesAnimations = true }

                // More / Additional Resources
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMoreMenu.toggle()
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                            .padding(.top, 4)
                        Text("More")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, -2)
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
    }
}

// MARK: - Adaptive Content Wrapper

struct AdaptiveContentWrapper<Content: View>: View {
    let configuration: AdaptivePageConfiguration
    let content: Content
    let customHeader: ((AdaptiveLayoutManager) -> AnyView)?
    @StateObject private var layoutManager = AdaptiveLayoutManager()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // User data (these could be passed in or fetched)
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    
    init(configuration: AdaptivePageConfiguration, @ViewBuilder content: () -> Content) {
        self.configuration = configuration
        self.content = content()
        self.customHeader = nil
    }
    
    init<CustomHeader: View>(configuration: AdaptivePageConfiguration, @ViewBuilder customHeader: @escaping (AdaptiveLayoutManager) -> CustomHeader, @ViewBuilder content: () -> Content) {
        self.configuration = configuration
        self.content = content()
        self.customHeader = { manager in AnyView(customHeader(manager)) }
    }
    
    var body: some View {
        Group {
            if layoutManager.shouldUseSidebar {
                // iPad/Mac Layout
                HStack(spacing: 0) {
                    // Sidebar
                    if !layoutManager.isSidebarCollapsed {
                        SharedAdaptiveSidebar(
                            configuration: configuration,
                            unreadMessageCount: unreadMessageCount,
                            layoutManager: layoutManager
                        )
                        .transition(.move(edge: .leading))
                    }
                    
                    // Main Content
                    VStack(spacing: 0) {
                        if let customHeader = customHeader {
                            customHeader(layoutManager)
                        } else {
                            SharedAdaptiveHeader(
                                configuration: configuration,
                                userProfileImageURL: userProfileImageURL,
                                unreadMessageCount: unreadMessageCount,
                                layoutManager: layoutManager
                            )
                        }
                        
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(Color(.systemBackground))
                }
                .animation(.easeInOut(duration: 0.3), value: layoutManager.isSidebarCollapsed)
            } else {
                // iPhone Layout with bottom navigation
                ZStack {
                    if let customHeader = customHeader {
                        // Pages with custom headers: render header + content
                        VStack(spacing: 0) {
                            customHeader(layoutManager)
                            content
                        }
                    } else {
                        // Pages without custom headers: just render content
                        content
                    }
                    
                    // Bottom Navigation Overlay for iPhone
                    VStack {
                        Spacer()
                        SharedBottomNavigation(
                            configuration: configuration,
                            unreadMessageCount: unreadMessageCount
                        )
                    }
                    .zIndex(1)
                }
            }
        }
        .onAppear {
            layoutManager.updateSizeClass(horizontalSizeClass)
            fetchUserData()
        }
        .onChange(of: horizontalSizeClass) { newValue in
            layoutManager.updateSizeClass(newValue)
        }
    }
    
    private func fetchUserData() {
        // Fetch user profile image
        if let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
            fetchCurrentUserProfile(userId: userId)
        }
        
        // Fetch unread message count
        fetchUnreadMessageCount()
    }
    
    private func fetchCurrentUserProfile(userId: Int) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                DispatchQueue.main.async {
                    if let profileImage = decoded.profile_image, !profileImage.isEmpty {
                        self.userProfileImageURL = profileImage
                    }
                }
            }
        }.resume()
    }
    
    private func fetchUnreadMessageCount() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        let urlString = "https://circlapp.online/api/messages/"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let messages = try? JSONDecoder().decode([MessageModel].self, from: data) {
                let unreadMessages = messages.filter { $0.receiver_id == userId && !$0.is_read }
                DispatchQueue.main.async {
                    self.unreadMessageCount = unreadMessages.count
                }
            }
        }.resume()
    }
}
