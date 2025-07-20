import SwiftUI
import Foundation

struct PageUnifiedNetworking: View {
    // MARK: - State Management
    @State private var selectedTab: NetworkingTab = .entrepreneurs
    @State private var searchText: String = ""
    @State private var searchedUser: InviteProfileData?
    @State private var myNetwork: [InviteProfileData] = []
    @State private var declinedEmails: Set<String> = []
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil
    @State private var selectedUserForPreview: InviteProfileData?
    @State private var showProfilePreview: Bool = false
    @State private var selectedFullProfile: FullProfile?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var showMoreMenu = false
    @AppStorage("user_id") private var userId: Int = 0
    
    @ObservedObject private var networkManager = NetworkDataManager.shared

    // MARK: - Initializer
    init(initialTab: NetworkingTab = .entrepreneurs) {
        self._selectedTab = State(initialValue: initialTab)
    }

    enum NetworkingTab: String, CaseIterable {
        case entrepreneurs = "Entrepreneurs"
        case mentors = "Mentors"
        case myNetwork = "My Network"
        
        var icon: String {
            switch self {
            case .entrepreneurs: return "person.2.fill"
            case .mentors: return "graduationcap.fill"
            case .myNetwork: return "person.3.fill"
            }
        }
        
        var subtitle: String {
            switch self {
            case .entrepreneurs: return "Growth Partners"
            case .mentors: return "Expert Guidance"
            case .myNetwork: return "Connections"
            }
        }
        
        var color: Color {
            return Color(hex: "004aad")
        }
    }

    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ZStack {
            VStack(spacing: 0) {
                enhancedHeaderSection
                welcomeSection
                scrollableContent
            }

            // MARK: - Twitter/X Style Bottom Navigation
            VStack {
                Spacer()
                
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
                    
                    // Connect and Network (Current page - highlighted)
                    VStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                        Text("Network")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                    }
                    .frame(maxWidth: .infinity)
                    
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
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(
                    Color(.systemBackground)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                )
            }
            
            // MARK: - More Menu Popup
            if showMoreMenu {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Professional Services
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                            // Navigate to Professional Services
                        }) {
                            HStack {
                                Image(systemName: "briefcase.fill")
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Professional Services")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Legal, Accounting, Consulting & More")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // News & Knowledge
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                            // Navigate to News & Knowledge
                        }) {
                            HStack {
                                Image(systemName: "newspaper.fill")
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("News & Knowledge")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Industry Insights & Learning Resources")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // Circl Exchange
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                            // Navigate to Circl Exchange
                        }) {
                            HStack {
                                Image(systemName: "arrow.2.squarepath")
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Circl Exchange")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Trade Services & Resources")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // Settings
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                            // Navigate to Settings
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Settings")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("App Preferences & Account")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 40)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.4)
                    .zIndex(1)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showMoreMenu)
            }
        }
        .ignoresSafeArea(.all, edges: [.top, .bottom])
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("🎯 PageUnifiedNetworking appeared - using shared network manager")
            
            // Extract user's first name for personalization
            let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
            userFirstName = fullName.components(separatedBy: " ").first ?? "Friend"
            
            // Load user data and refresh network data
            loadUserData()
            networkManager.refreshAllData()
            fetchMyNetwork()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Network Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Send Connection Request?"),
                message: Text("Are you sure you want to connect with this professional?"),
                primaryButton: .default(Text("Yes")) {
                    if let email = selectedEmailToAdd {
                        networkManager.addToNetwork(email: email)
                        // Remove from appropriate list based on current tab
                        if selectedTab == .mentors {
                            networkManager.mentors.removeAll { $0.email == email }
                        } else if selectedTab == .entrepreneurs {
                            networkManager.entrepreneurs.removeAll { $0.email == email }
                        }
                        alertMessage = "Connection request sent!"
                        showAlert = true
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showProfilePreview) {
            if let profile = selectedFullProfile {
                DynamicProfilePreview(profile: profile)
            }
        }
        .onTapGesture {
            // Dismiss more menu when tapping outside
            if showMoreMenu {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showMoreMenu = false
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var enhancedHeaderSection: some View {
        VStack(spacing: 0) {
            HStack {
                // App Logo
                Text("CIRCL")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "004aad"))
                
                Spacer()
                
                // Message notification bell
                Button(action: {
                    print("🔔 Message bell tapped")
                }) {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(UIColor.label))
                        
                        if unreadMessageCount > 0 {
                            VStack {
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 16, height: 16)
                                        .overlay(
                                            Text("\(min(unreadMessageCount, 9))")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Connect & Network")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Expand your professional circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Tab Selection
            HStack(spacing: 0) {
                ForEach(NetworkingTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                            
                            VStack(spacing: 2) {
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                                
                                Text(tab.subtitle)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? tab.color.opacity(0.1) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Scrollable Content
    private var scrollableContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                switch selectedTab {
                case .entrepreneurs:
                    entrepreneursContent
                case .mentors:
                    mentorsContent
                case .myNetwork:
                    myNetworkContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Tab Content Views
    private var entrepreneursContent: some View {
        LazyVStack(spacing: 16) {
            ForEach(networkManager.entrepreneurs.filter { !declinedEmails.contains($0.email) }, id: \.user_id) { entrepreneur in
                enhancedEntrepreneurCard(for: entrepreneur)
            }
            
            if networkManager.entrepreneurs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No entrepreneurs found")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Check back later for new connections")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
            }
        }
    }
    
    private var mentorsContent: some View {
        LazyVStack(spacing: 16) {
            ForEach(networkManager.mentors, id: \.user_id) { mentor in
                enhancedMentorCard(for: mentor)
            }
            
            if networkManager.mentors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No mentors available")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Mentors will appear here when available")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
            }
        }
    }
    
    private var myNetworkContent: some View {
        LazyVStack(spacing: 16) {
            ForEach(myNetwork, id: \.email) { connection in
                enhancedNetworkConnectionCard(for: connection)
            }
            
            if myNetwork.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Your network is empty")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Connect with entrepreneurs and mentors to build your network")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
            }
        }
    }
    
    // MARK: - Card Views
    private func enhancedEntrepreneurCard(for entrepreneur: SharedEntrepreneurProfileData) -> some View {
        Button(action: {
            fetchUserProfile(userId: entrepreneur.user_id) { profile in
                if let profile = profile {
                    selectedFullProfile = profile
                    showProfilePreview = true
                }
            }
        }) {
            EntrepreneurCard(
                entrepreneur: entrepreneur,
                onConnect: {
                    selectedEmailToAdd = entrepreneur.email
                    showConfirmation = true
                },
                onDecline: {
                    withAnimation {
                        _ = declinedEmails.insert(entrepreneur.email)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func enhancedMentorCard(for mentor: MentorProfileData) -> some View {
        Button(action: {
            // Handle mentor card tap
            print("🎯 Mentor card tapped for: \(mentor.name)")
        }) {
            MentorCard(
                mentor: mentor,
                onConnect: {
                    selectedEmailToAdd = mentor.email
                    showConfirmation = true
                },
                onDecline: {
                    // Handle decline for mentors if needed
                    print("Mentor declined: \(mentor.email)")
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func enhancedNetworkConnectionCard(for connection: InviteProfileData) -> some View {
        Button(action: {
            // Handle network connection tap
            print("🎯 Network connection tapped for: \(connection.name)")
        }) {
            NetworkConnectionCard(
                name: connection.name,
                username: connection.username,
                email: connection.email,
                company: connection.company,
                tags: connection.tags,
                profileImage: connection.profileImage
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - API Functions
    func loadUserData() {
        fetchCurrentUserProfile()
        fetchUnreadMessageCount()
    }
    
    func fetchCurrentUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        print("🌐 Fetching current user profile from:", urlString)

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
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
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    userProfileImageURL = profile.profile_image ?? ""
                    print("✅ User profile loaded successfully")
                }
            } catch {
                print("❌ Failed to decode user profile:", error)
            }
        }.resume()
    }
    
    func fetchUnreadMessageCount() {
        // Implementation for fetching unread message count
        // This would connect to your messaging API
        DispatchQueue.main.async {
            unreadMessageCount = 0 // Placeholder
        }
    }
    
    func fetchMyNetwork() {
        // Implementation for fetching user's network
        // This would connect to your network API
        DispatchQueue.main.async {
            myNetwork = [] // Placeholder
        }
    }
    
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        print("🌐 Fetching user profile from:", urlString)

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

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                let fullProfile = FullProfile(
                    name: userProfile.name,
                    username: userProfile.username,
                    email: userProfile.email,
                    company: userProfile.company,
                    bio: userProfile.bio,
                    profileImage: userProfile.profile_image,
                    tags: userProfile.tags
                )
                
                DispatchQueue.main.async {
                    completion(fullProfile)
                }
            } catch {
                print("❌ Failed to decode user profile:", error)
                completion(nil)
            }
        }.resume()
    }
}

// MARK: - Supporting Card Views
struct EntrepreneurCard: View {
    let entrepreneur: SharedEntrepreneurProfileData
    let onConnect: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Profile Image
                if let imageURL = entrepreneur.profileImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entrepreneur.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("@\(entrepreneur.username)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if !entrepreneur.company.isEmpty {
                        Text(entrepreneur.company)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Bio
            if !entrepreneur.bio.isEmpty {
                Text(entrepreneur.bio)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Tags
            if !entrepreneur.tags.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(entrepreneur.tags.prefix(6), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "004aad").opacity(0.1))
                            )
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onDecline) {
                    Text("Pass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Button(action: onConnect) {
                    Text("Connect")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "004aad"))
                        )
                }
            }
        }
        .padding(16)
    }
}

struct MentorCard: View {
    let mentor: MentorProfileData
    let onConnect: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Profile Image
                if let imageURL = mentor.profileImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "graduationcap.fill")
                                    .foregroundColor(.secondary)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mentor.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(mentor.expertise)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                    
                    if !mentor.company.isEmpty {
                        Text(mentor.company)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Bio
            if !mentor.bio.isEmpty {
                Text(mentor.bio)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onDecline) {
                    Text("Pass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Button(action: onConnect) {
                    Text("Connect")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "004aad"))
                        )
                }
            }
        }
        .padding(16)
    }
}

struct NetworkConnectionCard: View {
    let name: String
    let username: String
    let email: String
    let company: String
    let tags: [String]
    let profileImage: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Profile Image
                if let imageURL = profileImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                            )
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("@\(username)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if !company.isEmpty {
                        Text(company)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Handle message action
                    print("Message \(name)")
                }) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "004aad"))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color(hex: "004aad").opacity(0.1))
                        )
                }
            }
            
            // Tags
            if !tags.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 6) {
                    ForEach(tags.prefix(4), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "004aad").opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(12)
    }
}
