import SwiftUI
import Foundation

struct PageMyNetworkNew: View {
    @State private var searchText: String = ""
    @State private var searchedUser: InviteProfileData?
    @State private var friendRequests: [InviteProfileData] = []
    @State private var myNetwork: [InviteProfileData] = []
    @State private var selectedUserForPreview: InviteProfileData?
    @State private var showProfilePreview: Bool = false
    @State private var selectedFullProfile: FullProfile?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false
    @State private var userFirstName: String = ""

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
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Extract user's first name for personalization
            let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
            userFirstName = fullName.components(separatedBy: " ").first ?? "Friend"
            
            // Start animation
            withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            fetchFriendRequests()
            fetchMyNetwork()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Network Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .overlay(
            Group {
                if showProfilePreview && selectedFullProfile != nil {
                    ProfilePreviewWrapper(
                        profileData: selectedFullProfile!,
                        isInNetwork: true,
                        onDismiss: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showProfilePreview = false
                                selectedFullProfile = nil
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(999)
                }
            }
        )
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
                
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 15) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 50, height: 40)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
                        }
                        
                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
                        }
                    }
                }
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
                    Color(hexCode: "001a3d"),
                    Color(hexCode: "004aad"),
                    Color(hexCode: "0066ff"),
                    Color(hexCode: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.3),
                    Color.clear,
                    Color(hexCode: "004aad").opacity(0.2),
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
                    
                    Text("Manage your connections, respond to requests, and grow your professional network...")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            
            // Connection stats card
            HStack(spacing: 15) {
                connectionStatCard(icon: "person.2.fill", title: "Active\nConnections", value: "\(myNetwork.count)", color: .blue)
                connectionStatCard(icon: "bell.fill", title: "Friend\nRequests", value: "\(friendRequests.count)", color: .orange)
                connectionStatCard(icon: "chart.line.uptrend.xyaxis", title: "Network\nGrowth", value: "100%", color: .green)
            }
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
    
    private func connectionStatCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
    
    private var selectionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Network Management")
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
                        isSelected: false,
                        color: .gray
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
                        isSelected: true,
                        color: Color(hexCode: "004aad")
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
                // Search Bar Section
                searchSection
                
                // Display Searched User
                if let user = searchedUser {
                    VStack {
                        enhancedSearchResultCard(for: user)
                    }
                    .padding(.horizontal)
                }

                // Friend Requests Section
                if !friendRequests.isEmpty {
                    friendRequestsSection
                }

                // My Network Section
                myNetworkSection
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Find New Connections")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                TextField("Enter unique username...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: searchUserByUsername) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color(hexCode: "004aad"))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private func enhancedSearchResultCard(for user: InviteProfileData) -> some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hexCode: "004aad"))
                    
                    Text("Search Result")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            
            ModernSearchResultCard(
                userData: user,
                onConnect: {
                    // Handle connect action
                    let urlString = "https://circlapp.online/api/users/send_friend_request/"
                    guard let url = URL(string: urlString) else { return }
                    
                    let requestBody = [
                        "sender_id": UserDefaults.standard.value(forKey: "user_id") ?? 0,
                        "receiver_id": user.user_id
                    ]
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let data = data {
                            if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                DispatchQueue.main.async {
                                    if let success = responseData["success"] as? Bool, success {
                                        alertMessage = "Connection request sent to \(user.name)"
                                    } else {
                                        alertMessage = "Failed to send connection request"
                                    }
                                    showAlert = true
                                }
                            }
                        }
                    }.resume()
                },
                onViewProfile: {
                    // Handle view profile action
                    fetchUserProfile(userId: user.user_id) { profile in
                        if let profile = profile {
                            selectedFullProfile = profile
                            showProfilePreview = true
                        }
                    }
                }
            )
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(hexCode: "004aad").opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hexCode: "004aad").opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 100
                        )
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var friendRequestsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Friend Requests (\(friendRequests.count))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            ForEach(friendRequests, id: \.email) { request in
                enhancedFriendRequestCard(for: request)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .slide.combined(with: .opacity)
                    ))
            }
        }
    }
    
    private func enhancedFriendRequestCard(for request: InviteProfileData) -> some View {
        ModernFriendRequestCard(
            friendRequests: $friendRequests,
            showAlert: $showAlert,
            alertMessage: $alertMessage,
            name: request.name,
            username: request.username,
            email: request.email,
            title: request.title,
            company: request.company,
            proficiency: request.proficiency,
            tags: request.tags,
            profileImage: request.profileImage
        )
    }
    
    private var myNetworkSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("My Network (\(myNetwork.count))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if myNetwork.isEmpty {
                emptyNetworkStateView
            } else {
                ForEach(myNetwork, id: \.email) { connection in
                    enhancedNetworkConnectionCard(for: connection)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .slide.combined(with: .opacity)
                        ))
                }
            }
        }
    }
    
    private var emptyNetworkStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Start Building Your Network! 🌟")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Connect with amazing professionals and grow your business network. Use the search above to find new connections!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                        Text("Find Entrepreneurs")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hexCode: "004aad"))
                    .cornerRadius(20)
                }
                
                NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                    HStack(spacing: 8) {
                        Image(systemName: "graduationcap.fill")
                        Text("Find Mentors")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hexCode: "004aad").opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
    
    private func enhancedNetworkConnectionCard(for connection: InviteProfileData) -> some View {
        Button(action: {
            fetchUserProfile(userId: connection.user_id) { profile in
                if let profile = profile {
                    selectedFullProfile = profile
                    showProfilePreview = true
                }
            }
        }) {
            ModernNetworkCard(
                name: connection.name,
                username: connection.username,
                email: connection.email,
                company: connection.company,
                tags: connection.tags,
                profileImage: connection.profileImage
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var footerSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if showMenu {
                // Tap-to-dismiss layer
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

                        NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true)) {
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
                            .fill(Color(hexCode: "004aad"))
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
        }
    }

    // MARK: - API Functions
    func searchUserByUsername() {
        guard !searchText.isEmpty else { return }
        
        let urlString = "https://circlapp.online/api/users/search_by_username/"
        guard let url = URL(string: urlString) else { return }
        
        let requestBody = ["username": searchText]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let userId = userData["id"] as? Int {
                            self.searchedUser = InviteProfileData(
                                user_id: userId,
                                name: "\(userData["first_name"] as? String ?? "") \(userData["last_name"] as? String ?? "")",
                                username: userData["username"] as? String ?? "",
                                email: userData["email"] as? String ?? "",
                                title: userData["title"] as? String ?? "Professional",
                                company: userData["company"] as? String ?? "Unknown Company",
                                proficiency: userData["proficiency"] as? String ?? "Unknown",
                                tags: userData["tags"] as? [String] ?? [],
                                profileImage: userData["profileImage"] as? String
                            )
                        }
                    }
                }
            }
        }.resume()
    }

    func fetchFriendRequests() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        let urlString = "https://circlapp.online/api/users/get_friend_requests/\(userId)/"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let requestList = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.friendRequests = requestList.compactMap { request in
                            guard let userId = request["id"] as? Int else { return nil }
                            return InviteProfileData(
                                user_id: userId,
                                name: "\(request["first_name"] as? String ?? "") \(request["last_name"] as? String ?? "")",
                                username: request["username"] as? String ?? "",
                                email: request["email"] as? String ?? "",
                                title: request["title"] as? String ?? "Professional",
                                company: request["company"] as? String ?? "Unknown Company",
                                proficiency: request["proficiency"] as? String ?? "Unknown",
                                tags: request["tags"] as? [String] ?? [],
                                profileImage: request["profileImage"] as? String
                            )
                        }
                    }
                }
            }
        }.resume()
    }

    func fetchMyNetwork() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        let urlString = "https://circlapp.online/api/users/get_network/\(userId)/"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let networkList = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.myNetwork = networkList.compactMap { user in
                            guard let userId = user["id"] as? Int else { return nil }
                            return InviteProfileData(
                                user_id: userId,
                                name: "\(user["first_name"] as? String ?? "") \(user["last_name"] as? String ?? "")",
                                username: user["username"] as? String ?? "",
                                email: user["email"] as? String ?? "",
                                title: user["title"] as? String ?? "Professional",
                                company: user["company"] as? String ?? "Unknown Company",
                                proficiency: user["proficiency"] as? String ?? "Unknown",
                                tags: user["tags"] as? [String] ?? [],
                                profileImage: user["profileImage"] as? String
                            )
                        }
                    }
                }
            }
        }.resume()
    }

    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        guard let url = URL(string: urlString) else {
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
            if let data = data {
                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                    return
                }
            }
            completion(nil)
        }.resume()
    }
}

// MARK: - Modern Network Card Component
struct ModernNetworkCard: View {
    let name: String
    let username: String
    let email: String
    let company: String
    let tags: [String]
    let profileImage: String?
    
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            // Profile Image with elegant border
            profileImageSection
            
            // Content section
            VStack(alignment: .leading, spacing: 6) {
                // Name (bold and prominent)
                Text(name.isEmpty ? (username.isEmpty ? email : username) : name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Username with elegant styling
                if !username.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "at")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hexCode: "004aad"))
                        
                        Text(username)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hexCode: "004aad"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(hexCode: "004aad").opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color(hexCode: "004aad").opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Company/Email with icon
                HStack(spacing: 6) {
                    Image(systemName: company.isEmpty ? "envelope.fill" : "building.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(company.isEmpty ? email : company)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Tags if available
                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(tags.prefix(2)), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray5))
                                    )
                            }
                            
                            if tags.count > 2 {
                                Text("+\(tags.count - 2)")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemGray4))
                                    )
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Connection status indicator
            connectionStatusIndicator
        }
        .padding(18)
        .background(modernCardBackground)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(Double.random(in: 0...0.3))) {
                isAnimating = true
            }
        }
    }
    
    private var profileImageSection: some View {
        Group {
            if let imageURL = profileImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.secondary.opacity(0.5))
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color(hexCode: "004aad").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color(hexCode: "004aad").opacity(0.2), radius: 6, x: 0, y: 3)
    }
    
    private var connectionStatusIndicator: some View {
        VStack(spacing: 8) {
            // Connection status dot with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green,
                            Color.green.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 2)
            
            // View profile hint
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
    }
    
    private var modernCardBackground: some View {
        ZStack {
            // Main gradient background similar to ProfilePage
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Subtle overlay for depth
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
        }
    }
}

// MARK: - Modern Friend Request Card Component
struct ModernFriendRequestCard: View {
    @Binding var friendRequests: [InviteProfileData]
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    let name: String
    let username: String
    let email: String
    let title: String
    let company: String
    let proficiency: String
    let tags: [String]
    let profileImage: String?
    
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            profileImageSection
            
            // Content section
            VStack(alignment: .leading, spacing: 6) {
                // Name (bold)
                Text(name.isEmpty ? (username.isEmpty ? email : username) : name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Username with elegant styling
                if !username.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "at")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text(username)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.orange.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(.orange.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Company
                HStack(spacing: 6) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(company)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { acceptFriendRequest() }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green,
                                            Color.green.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 4)
                }

                Button(action: { declineFriendRequest() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.red,
                                            Color.red.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .red.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(18)
        .background(modernRequestCardBackground)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(Double.random(in: 0...0.3))) {
                isAnimating = true
            }
        }
    }
    
    private var profileImageSection: some View {
        Group {
            if let imageURL = profileImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.secondary.opacity(0.5))
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.orange.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.orange.opacity(0.25), radius: 6, x: 0, y: 3)
    }
    
    private var modernRequestCardBackground: some View {
        ZStack {
            // Main gradient background with orange accent
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color.orange.opacity(0.05),
                            Color(.systemGray6).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Subtle orange accent overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.1),
                            Color.clear
                        ],
                        center: .topTrailing,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
        }
    }

    func acceptFriendRequest() {
        guard let receiverId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let requestBody: [String: Any] = [
            "sender_email": email,
            "receiver_id": receiverId
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/accept_friend_request/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                friendRequests.removeAll { $0.email == email }
                alertMessage = "Friend request accepted"
                showAlert = true
            }
        }.resume()
    }

    func declineFriendRequest() {
        guard let receiverId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let requestBody: [String: Any] = [
            "sender_email": email,
            "receiver_id": receiverId
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/decline_friend_request/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                friendRequests.removeAll { $0.email == email }
                alertMessage = "Friend request declined"
                showAlert = true
            }
        }.resume()
    }
}

// MARK: - ProfilePreviewWrapper
struct ProfilePreviewWrapper: View {
    let profileData: FullProfile
    let isInNetwork: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            DynamicProfilePreview(
                profileData: profileData,
                isInNetwork: isInNetwork
            )
            
            // Custom dismiss button overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white.opacity(0.8))
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

// MARK: - ModernSearchResultCard
struct ModernSearchResultCard: View {
    let userData: InviteProfileData
    let onConnect: () -> Void
    let onViewProfile: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.customHex("001a3d"),
                            Color.customHex("004aad"),
                            Color.customHex("0066ff")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Subtle overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        center: .topTrailing,
                        startRadius: 30,
                        endRadius: 120
                    )
                )
            
            VStack(spacing: 16) {
                HStack(spacing: 15) {
                    AsyncImage(url: URL(string: userData.profileImage ?? "")) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray.opacity(0.4))
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(userData.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("@\(userData.username)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                        
                        if !userData.title.isEmpty {
                            Text(userData.title)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Button(action: onConnect) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Connect")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: onViewProfile) {
                        HStack(spacing: 6) {
                            Image(systemName: "eye")
                                .font(.system(size: 14, weight: .semibold))
                            Text("View")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}