import SwiftUI
import Foundation

struct PageMyNetwork: View {
    @State private var searchText: String = ""
    @State private var searchedUser: InviteProfileData?
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
    @State private var potentialMatchesCount: Int = 0
    
    @ObservedObject private var networkManager = NetworkDataManager.shared

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
            print("🎯 PageMyNetwork appeared - using shared network manager")
            
            // Extract user's first name for personalization
            let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
            userFirstName = fullName.components(separatedBy: " ").first ?? "Friend"
            
            // Start animation
            withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            // Use shared network manager to refresh data
            networkManager.refreshAllData()
            fetchMyNetwork()
            fetchPotentialMatchesCount()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Network Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: Binding(
            get: { showProfilePreview && selectedFullProfile != nil },
            set: { newValue in showProfilePreview = newValue }
        )) {
            if let profile = selectedFullProfile {
                DynamicProfilePreview(profileData: profile, isInNetwork: true)
            }
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
                    Text("Wagwan Crodie, \(userFirstName)! 👋")
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
                UnifiedMetricsView()
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
                if !networkManager.friendRequests.isEmpty {
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
                Text("Search Result")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            InviteProfileLink(
                friendRequests: $networkManager.friendRequests,
                showAlert: $showAlert,
                alertMessage: $alertMessage,
                name: user.name,
                username: user.username,
                email: user.email,
                title: user.title,
                company: user.company,
                proficiency: user.proficiency,
                tags: user.tags,
                profileImage: user.profileImage
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var friendRequestsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Friend Requests (\(networkManager.friendRequests.count))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            ForEach(networkManager.friendRequests, id: \.email) { request in
                enhancedFriendRequestCard(for: request)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .slide.combined(with: .opacity)
                    ))
            }
        }
    }
    
    private func enhancedFriendRequestCard(for request: InviteProfileData) -> some View {
        InviteProfileTemplate(
            friendRequests: $networkManager.friendRequests,
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
    func fetchPotentialMatchesCount() {
        // This is a placeholder. In a real app, you would fetch this from your backend.
        // For example, the total number of users minus the current user and their network.
        self.potentialMatchesCount = 50 // Example value
    }

    func searchUserByUsername() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let url = URL(string: "https://circlapp.online/api/search-user/?username=\(searchText)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let userId = userData["id"] as? Int {
                            // Debug: Print all available fields
                            print("Search API Response: \(userData)")
                            
                            // Try multiple possible name field combinations
                            let firstName = userData["first_name"] as? String ?? ""
                            let lastName = userData["last_name"] as? String ?? ""
                            let name = userData["name"] as? String ?? ""
                            let fullName = userData["full_name"] as? String ?? ""
                            let displayName = userData["display_name"] as? String ?? ""
                            let username = userData["username"] as? String ?? ""
                            let handle = userData["handle"] as? String ?? ""
                            let userHandle = userData["user_handle"] as? String ?? ""
                            let email = userData["email"] as? String ?? ""
                            
                            // Debug: Print specific username-related fields
                            print("Search Username fields - username: '\(username)', handle: '\(handle)', user_handle: '\(userHandle)', email: '\(email)'")
                            
                            // Determine actual username with priority order (using ProfilePage format)
                            let actualUsername: String
                            if !lastName.isEmpty {
                                actualUsername = "\(lastName)\(userId)"
                            } else if !username.isEmpty {
                                actualUsername = username
                            } else if !handle.isEmpty {
                                actualUsername = handle
                            } else if !userHandle.isEmpty {
                                actualUsername = userHandle
                            } else {
                                // Fallback to part before @ in email
                                actualUsername = email.components(separatedBy: "@").first ?? ""
                            }
                            
                            // Construct full name from first and last name
                            let constructedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            
                            // Priority order for name selection
                            let finalName: String
                            if !fullName.isEmpty {
                                finalName = fullName
                            } else if !displayName.isEmpty {
                                finalName = displayName
                            } else if !name.isEmpty {
                                finalName = name
                            } else if !constructedName.isEmpty {
                                finalName = constructedName
                            } else if !username.isEmpty {
                                finalName = username.capitalized
                            } else {
                                finalName = email.components(separatedBy: "@").first?.capitalized ?? email
                            }
                            
                            self.searchedUser = InviteProfileData(
                                user_id: userId,
                                name: finalName,
                                username: actualUsername,
                                email: email,
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
                            
                            // Debug: Print all available fields
                            print("API Response for user \(userId): \(user)")
                            
                            // Try multiple possible name field combinations
                            let firstName = user["first_name"] as? String ?? ""
                            let lastName = user["last_name"] as? String ?? ""
                            let name = user["name"] as? String ?? ""
                            let fullName = user["full_name"] as? String ?? ""
                            let displayName = user["display_name"] as? String ?? ""
                            let username = user["username"] as? String ?? ""
                            let handle = user["handle"] as? String ?? ""
                            let userHandle = user["user_handle"] as? String ?? ""
                            let email = user["email"] as? String ?? ""
                            
                            // Debug: Print specific username-related fields
                            print("Username fields - username: '\(username)', handle: '\(handle)', user_handle: '\(userHandle)', email: '\(email)'")
                            
                            // Determine actual username with priority order (using ProfilePage format)
                            let actualUsername: String
                            if !lastName.isEmpty {
                                actualUsername = "\(lastName)\(userId)"
                            } else if !username.isEmpty {
                                actualUsername = username
                            } else if !handle.isEmpty {
                                actualUsername = handle
                            } else if !userHandle.isEmpty {
                                actualUsername = userHandle
                            } else {
                                // Fallback to part before @ in email
                                actualUsername = email.components(separatedBy: "@").first ?? ""
                            }
                            
                            // Construct full name from first and last name
                            let constructedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            
                            // Priority order for name selection
                            let finalName: String
                            if !fullName.isEmpty {
                                finalName = fullName
                            } else if !displayName.isEmpty {
                                finalName = displayName
                            } else if !name.isEmpty {
                                finalName = name
                            } else if !constructedName.isEmpty {
                                finalName = constructedName
                            } else if !username.isEmpty {
                                finalName = username.capitalized
                            } else {
                                finalName = email.components(separatedBy: "@").first?.capitalized ?? email
                            }
                            
                            return InviteProfileData(
                                user_id: userId,
                                name: finalName,
                                username: actualUsername,
                                email: email,
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

// MARK: - Supporting Views
struct NetworkConnectionCard: View {
    let name: String
    let username: String
    let email: String
    let company: String
    let tags: [String]
    let profileImage: String?

    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let imageURL = profileImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("default_image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            } else {
                Image("default_image")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            }

            VStack(alignment: .leading, spacing: 3) {
                // Display actual name or fallback - BOLD
                Text(name.isEmpty ? (username.isEmpty ? email : username) : name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Username in smaller text (above email)
                if !username.isEmpty {
                    Text("@\(username)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Email in smallest text (at bottom)
                Text(email)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct InviteProfileTemplate: View {
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

    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let imageURL = profileImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("default_image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(company)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Text("@\(username)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Accept/Decline buttons
            HStack(spacing: 10) {
                Button(action: { acceptFriendRequest() }) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                }

                Button(action: { declineFriendRequest() }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
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

struct InviteProfileLink: View {
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

    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let imageURL = profileImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("default_image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(company)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Text("@\(username)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Send connection request button
            Button(action: { sendConnectionRequest() }) {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                    Text("Connect")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hexCode: "004aad"))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    func sendConnectionRequest() {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let requestBody: [String: Any] = [
            "sender_id": senderId,
            "receiver_email": email
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/send_friend_request/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                alertMessage = "Connection request sent!"
                showAlert = true
            }
        }.resume()
    }
}
