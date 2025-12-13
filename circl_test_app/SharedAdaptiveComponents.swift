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
            // Separator line
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            HStack(spacing: 0) {
                // Main navigation items (first 4)
                ForEach(Array(configuration.navigationItems.prefix(4).enumerated()), id: \.element.id) { index, item in
                    NavigationLink(destination: item.destination) {
                        VStack(spacing: 4) {
                            ZStack {
                                Image(systemName: item.icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(item.isCurrentPage ? Color(hex: "004aad") : .gray)
                                
                                if let badge = item.badge, !badge.isEmpty {
                                    Text(badge)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 12, y: -12)
                                }
                            }
                            
                            Text(item.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(item.isCurrentPage ? Color(hex: "004aad") : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // More menu for remaining items
                if configuration.navigationItems.count > 4 {
                    Button(action: { showMoreMenu = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                            
                            Text("More")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.white)
            .padding(.bottom, 34) // Safe area padding for home indicator
        }
        .actionSheet(isPresented: $showMoreMenu) {
            ActionSheet(
                title: Text("More Options"),
                buttons: configuration.navigationItems.dropFirst(4).map { item in
                    .default(Text(item.title)) {
                        // Navigate to the item destination
                        // Note: This is simplified - you might want to use a proper navigation mechanism
                    }
                } + [.cancel()]
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
                // iPhone Layout
                ZStack {
                    VStack(spacing: 0) {
                        // Content with top padding for header
                        content
                            .padding(.top, customHeader != nil ? 160 : 100) // More space for custom headers
                            .padding(.bottom, 90) // Space for bottom navigation
                    }
                    
                    // Fixed header overlay
                    VStack {
                        if let customHeader = customHeader {
                            customHeader(layoutManager)
                        } else {
                            SharedAdaptiveHeader(
                                configuration: configuration,
                                userProfileImageURL: userProfileImageURL,
                                unreadMessageCount: unreadMessageCount,
                                layoutManager: layoutManager
                            )
                            .padding(.top, 50) // Safe area
                        }
                        
                        Spacer()
                    }
                    
                    // Fixed bottom navigation
                    VStack {
                        Spacer()
                        
                        SharedBottomNavigation(
                            configuration: configuration,
                            unreadMessageCount: unreadMessageCount
                        )
                    }
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
