import SwiftUI
import Foundation

// MARK: - Main View for Entrepreneur Matching
struct PageEntrepreneurMatching: View {
    @State private var declinedEmails: Set<String> = []
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil
    @State private var selectedFullProfile: FullProfile? = nil
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false
    @State private var userFirstName: String = ""
    
    // User profile data for header
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @AppStorage("user_id") private var userId: Int = 0
    
    @ObservedObject private var networkManager = NetworkDataManager.shared

    enum HammerPage {
        case forum, resources, knowledge, business
    }
    @State private var navigateTo: HammerPage? = nil

    
    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 8) {
                enhancedHeaderSection
                welcomeSection
                selectionButtonsSection
                scrollableContent
            }

            footerSection

            // ✅ These trigger navigation when a menu option is tapped
            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true), tag: .forum, selection: $navigateTo) { EmptyView() }
            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true), tag: .resources, selection: $navigateTo) { EmptyView() }
            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true), tag: .knowledge, selection: $navigateTo) { EmptyView() }
            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true), tag: .business, selection: $navigateTo) { EmptyView() }
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("🎯 PageEntrepreneurMatching appeared - using shared network manager")
            
            // Load user profile data for header
            loadUserData()
            
            // Extract user's first name for personalization
            let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
            userFirstName = fullName.components(separatedBy: " ").first ?? "Friend"
            
            // Start animation
            withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            // Use shared network manager to refresh data
            networkManager.refreshAllData()
        }
    }

    private var enhancedHeaderSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        Text("Circl.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                 Spacer()

                ProfileHeaderView(
                    userFirstName: $userFirstName,
                    userProfileImageURL: $userProfileImageURL,
                    unreadMessageCount: $unreadMessageCount
                )
            }
            .padding(.horizontal)
            .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 15)
            .padding(.bottom, 20)
        }
        .background(
            animatedBackground
                .ignoresSafeArea(.all, edges: .top)
        )
        .clipped()
    }
    
    private var animatedBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "001a3d"),
                    Color(hex: "004aad"),
                    Color(hex: "0066ff"),
                    Color(hex: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hex: "0066ff").opacity(0.3),
                    Color.clear,
                    Color(hex: "004aad").opacity(0.2),
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 0.0 : 1.0,
                    y: isAnimating ? 0.0 : 1.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 1.0 : 0.0,
                    y: isAnimating ? 1.0 : 0.0
                )
            )
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back, \(userFirstName)! 👋")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Ready to grow your network? Connect with amazing entrepreneurs and mentors...")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            
            UnifiedMetricsView()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.top, -5)
    }
    
    private var selectionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Discover Industry Professionals")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 8) {
                NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                    enhancedButtonContent(
                        title: "Entrepreneurs",
                        subtitle: "Growth Partners",
                        icon: "person.2.fill",
                        isSelected: true,
                        color: Color(hex: "004aad")
                    )
                }
                
                NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                    enhancedButtonContent(
                        title: "Mentors",
                        subtitle: "Expert Guidance",
                        icon: "graduationcap.fill",
                        isSelected: false,
                        color: .gray
                    )
                }
                
                NavigationLink(destination: PageMyNetwork().navigationBarBackButtonHidden(true)) {
                    enhancedButtonContent(
                        title: "My Network",
                        subtitle: "Connections",
                        icon: "person.3.fill",
                        isSelected: false,
                        color: .gray
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func enhancedButtonContent(title: String, subtitle: String, icon: String, isSelected: Bool, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : color)
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color : Color(.systemGray6))
                .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var scrollableContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if networkManager.entrepreneurs.isEmpty {
                    emptyStateView
                } else {
                    ForEach(networkManager.entrepreneurs.filter { !declinedEmails.contains($0.email) }, id: \.email) { entrepreneur in
                        enhancedEntrepreneurCard(for: entrepreneur)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .slide.combined(with: .opacity)
                            ))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Space for floating button
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("🤝 Send Connection Request?"),
                message: Text("Ready to start building an amazing partnership? Let's connect you with this entrepreneur!"),
                primaryButton: .default(Text("Yes, Let's Connect! 🚀")) {
                    if let email = selectedEmailToAdd {
                        networkManager.addToNetwork(email: email)
                        // The NetworkDataManager will handle removing from the entrepreneurs list
                    }
                },
                secondaryButton: .cancel(Text("Maybe Later"))
            )
        }
        .onAppear {
            // Data will be loaded from NetworkDataManager.shared
        }
        .sheet(item: $selectedFullProfile) { profile in
            DynamicProfilePreview(profileData: profile, isInNetwork: networkManager.userNetworkEmails.contains(profile.email ?? ""))
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Your Network Awaits! 🌟")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("We're discovering amazing entrepreneurs for you. Check back in a moment to see your perfect matches!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                networkManager.refreshAllData()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "004aad"))
                .cornerRadius(25)
            }
        }
        .padding(.vertical, 40)
    }
    
    private func enhancedEntrepreneurCard(for entrepreneur: SharedEntrepreneurProfileData) -> some View {
        Button(action: {
            print("🎯 Card tapped for user: \(entrepreneur.name)")
            fetchUserProfile(userId: entrepreneur.user_id) { profile in
                if let profile = profile {
                    print("✅ Profile fetched successfully for: \(profile.first_name ?? "Unknown")")
                    selectedFullProfile = profile
                } else {
                    print("❌ Failed to fetch profile for user ID: \(entrepreneur.user_id)")
                }
            }
        }) {
            EnhancedEntrepreneurTemplate(
                entrepreneur: entrepreneur,
                onConnect: {
                    selectedEmailToAdd = entrepreneur.email
                    showConfirmation = true
                },
                onSkip: {
                    withAnimation(.easeInOut) {
                        let _ = declinedEmails.insert(entrepreneur.email)
                        // The entrepreneur will be filtered out in the ForEach
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var footerSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if showMenu {
                // 🧼 Tap-to-dismiss layer
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                    .zIndex(0)
            }

            VStack(alignment: .trailing, spacing: 8) {
                if showMenu {
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
                            MenuItem(icon: "person.3.fill", title: "The Circl Exchange")
                        }

                        Divider()

                        NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true))
 {
                            MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(width: 250)
                    .transition(.scale.combined(with: .opacity))
                }

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showMenu.toggle()
                        rotationAngle += 360 // spin the logo
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "004aad"))
                            .frame(width: 60, height: 60)

                        Image("CirclLogoButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .rotationEffect(.degrees(rotationAngle))
                    }
                }
                .shadow(radius: 4)
                .padding(.bottom, 19)

            }
            .padding(.trailing, 20)
            .zIndex(1)
        }    }




    
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
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
                if let raw = String(data: data, encoding: .utf8) {
                    print("📡 Raw Response: \(raw)")
                }
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
    
    // MARK: - User Profile Functions
    func loadUserData() {
        fetchCurrentUserProfile()
        loadMessages()
    }
    
    func fetchCurrentUserProfile() {
        guard userId > 0 else {
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
                print("❌ Network error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(FullProfile.self, from: data)
                DispatchQueue.main.async {
                    // Update profile image URL
                    if let profileImage = decoded.profile_image, !profileImage.isEmpty {
                        self.userProfileImageURL = profileImage
                        print("✅ Profile image loaded: \(profileImage)")
                    } else {
                        self.userProfileImageURL = ""
                        print("❌ No profile image found for current user")
                    }
                    
                    // Update user name info
                    self.userFirstName = decoded.first_name
                }
            } catch {
                print("❌ Failed to decode current user profile:", error)
            }
        }.resume()
    }
    
    func loadMessages() {
        guard userId > 0 else { return }
        
        guard let url = URL(string: "https://circlapp.online/api/messages/user_messages/\(userId)/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode([String: [MessageModel]].self, from: data)
                DispatchQueue.main.async {
                    let allMessages = response["messages"] ?? []
                    self.messages = allMessages
                    self.calculateUnreadMessageCount()
                }
            } catch {
                print("Error decoding messages:", error)
            }
        }.resume()
    }
    
    func calculateUnreadMessageCount() {
        guard userId > 0 else { return }
        
        let unreadMessages = messages.filter { message in
            message.receiver_id == userId && !message.is_read && message.sender_id != userId
        }
        
        unreadMessageCount = unreadMessages.count
    }
}



// MARK: - Preview
struct PageEntrepreneurMatching_Previews: PreviewProvider {
    static var previews: some View {
        PageEntrepreneurMatching()
    }
}




// MARK: - Enhanced EntrepreneurProfileTemplate
struct EnhancedEntrepreneurTemplate: View {
    let entrepreneur: SharedEntrepreneurProfileData
    let onConnect: () -> Void
    let onSkip: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with profile image and basic info
            HStack(alignment: .top, spacing: 15) {
                // Profile Image with premium styling
                ZStack {
                    if let imageURL = entrepreneur.profileImage,
                       let encodedURLString = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: encodedURLString) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Image("default_image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                    } else {
                        Image("default_image")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                    }
                    
                    // Status indicator
                    Circle()
                        .fill(Color.green)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 25, y: 25)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(entrepreneur.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if entrepreneur.isMentor {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                Text("Mentor")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.orange)
                            )
                        }
                    }
                    
                    Text(entrepreneur.company)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "004aad"))
                    
                    Text(entrepreneur.proficiency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Tags section
            if !entrepreneur.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entrepreneur.tags.prefix(4), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "004aad").opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(hex: "004aad").opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 15)
            }
            
            // Action buttons
            HStack(spacing: 15) {
                Button(action: onSkip) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.headline)
                        Text("Skip")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Button(action: onConnect) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.headline)
                        Text("Connect")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}

// MARK: - EntrepreneurCardTemplate (kept for compatibility)
struct EntrepreneurCardTemplate: View {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String?
    var onAccept: () -> Void
    var onDecline: () -> Void
    var isMentor: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    // Profile Image
                    if let imageURL = profileImage,
                       let encodedURLString = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: encodedURLString) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Image("default_image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    } else {
                        Image("default_image")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(name)
                            .font(.headline)
                        
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        Button(action: onAccept) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.green)
                        }
                        
                        Button(action: onDecline) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Tags
                HStack(spacing: 10) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            
            // MENTOR BANNER
            if isMentor {
                Text("Mentor")
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .cornerRadius(5)
                    .padding(.top, 6)
                    .padding(.leading, 6)
            }
        }
    }
}
