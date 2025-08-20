import SwiftUI
import Foundation

struct PageUnifiedNetworking: View {
    // MARK: - State Management
    @State private var selectedTab: NetworkingTab = .entrepreneurs
    @State private var myNetwork: [InviteProfileData] = []
    @State private var declinedEmails: Set<String> = []
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil
    @State private var showProfilePreview: Bool = false
    @State private var selectedFullProfile: FullProfile?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @State private var showMoreMenu = false
    @State private var showBottomMoreMenu = false // Separate state for bottom navigation menu
    @State private var rotationAngle: Double = 0
    @State private var isLoading = false
    @AppStorage("user_id") private var userId: Int = 0
    @State private var pendingRequests: [InviteProfileData] = []
    @State private var selectedProfile: FullProfile?
    @State private var showProfileSheet = false
    // Local data arrays (instead of using NetworkDataManager)
    @State private var entrepreneurs: [SharedEntrepreneurProfileData] = []
    @State private var mentors: [MentorProfileData] = []
    @State private var userNetworkEmails: [String] = []
    
    // Alert state
    @State private var alertTitle = ""
    @State private var alertIcon = "checkmark.circle"
    
    // NetworkDataManager integration
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
        
        var compactTitle: String {
            switch self {
            case .entrepreneurs: return "Connect"
            case .mentors: return "Mentors"
            case .myNetwork: return "My Network"
            }
        }
        
        var color: Color {
            return Color(hex: "004aad")
        }
        
        var buttonColor: Color {
            switch self {
            case .entrepreneurs: return .yellow
            case .mentors: return .yellow
            case .myNetwork: return .gray
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background gradient inspired by PageGroupchats
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(hex: "004aad").opacity(0.02),
                        Color(hex: "004aad").opacity(0.01)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    scrollableContent
                    // Remove Spacer() to prevent layout issues
                }
                
                // Bottom navigation as overlay
                VStack {
                    Spacer()
                    bottomNavigationBar
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
                
                // MARK: - More Menu Popup (EXACT copy from Forum page)
                if showBottomMoreMenu {
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
                                            Text("Find business services and experts")
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
                                
                                // News & Knowledge
                                NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "newspaper.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("News & Knowledge")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Stay updated with industry insights")
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
                                
                                // Circl Exchange
                                NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("The Circl Exchange")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Buy and sell skills and services")
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
                                
                                // Settings/Profile
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
                                            Text("Manage your account and preferences")
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
                                    showBottomMoreMenu = false
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

                // Tap-out-to-dismiss layer (EXACT copy from Forum page)
                if showBottomMoreMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showBottomMoreMenu = false
                            }
                        }
                        .zIndex(1)
                }
            }
            .ignoresSafeArea(.all, edges: [.top, .bottom])
            .navigationBarBackButtonHidden(true)
            .onAppear {
                let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
                userFirstName = fullName.components(separatedBy: " ").first ?? "Friend"

                fetchCurrentUserProfile()   // ✅ now pulls live profile image
                loadAllNetworkingData()
                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("🔄 Force refreshing network connections after onAppear")
                    networkManager.fetchNetworkConnections()
                }
            }

            .onReceive(networkManager.$entrepreneurs) { entrepreneurs in
                self.entrepreneurs = entrepreneurs
            }
            .onReceive(networkManager.$mentors) { mentors in
                self.mentors = mentors
            }
            .onReceive(networkManager.$userNetworkEmails) { emails in
                self.userNetworkEmails = emails
            }
            .onReceive(networkManager.$networkConnections) { connections in
                print("🔄 Received network connections: \(connections.count)")
                print("🔍 Connection details: \(connections.map { "\($0.name) (\($0.email))" })")
                DispatchQueue.main.async {
                    // Only update if we have real data OR if current myNetwork is empty
                    self.myNetwork = connections
                    print("🎯 myNetwork replaced with \(self.myNetwork.count) connections")
                    print("🎯 myNetwork contents: \(self.myNetwork.map { "\($0.name) - \($0.email)" })")

                }
            }
            .onReceive(networkManager.$friendRequests) { requests in
                print("📩 Received \(requests.count) pending friend requests")
                DispatchQueue.main.async {
                    self.pendingRequests = requests
                }
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
                            addToNetwork(email: email)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showProfileSheet) {
                if let profile = selectedProfile {
                    DynamicProfilePreview(
                        profileData: profile,
                        isInNetwork: true // ✅ because these are your connections
                    )
                }
            }

        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Enhanced Profile with shadow
                NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        if !userProfileImageURL.isEmpty {
                            AsyncImage(url: URL(string: userProfileImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
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
                
                // Center - Enhanced Logo with subtle glow
                VStack(spacing: 2) {
                    Text("Circl.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)
                }
                
                Spacer()
                
                // Right side - Enhanced Messages with notification
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        if unreadMessageCount > 0 {
                            Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                                )
                                .offset(x: 12, y: -12)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            .padding(.top, 10)
            
            // Clean tab design matching the example
            HStack(spacing: 0) {
                ForEach(NetworkingTab.allCases, id: \.self) { tab in
                    VStack(spacing: 8) {
                        Text(tab.compactTitle)
                            .font(.system(size: 16, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundColor(.white)
                            .opacity(selectedTab == tab ? 1.0 : 0.7)
                        
                        // Clean underline indicator
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: selectedTab == tab ? 3 : 0)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)
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
    
    // MARK: - Selection Buttons Section (DEPRECATED - now integrated into header)
    /*
    private var selectionButtonsSection: some View {
        HStack(spacing: 10) {
            ForEach(NetworkingTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                        // Force refresh network data when My Network tab is selected
                        if tab == .myNetwork {
                            print("🔄 Switching to My Network tab - forcing refresh")
                            networkManager.fetchNetworkConnections()
                        }
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 12))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == tab ? tab.buttonColor : Color.gray)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    */
    
    // MARK: - Scrollable Content
    private var scrollableContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
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
            .padding(.top, 16)
            .padding(.bottom, 120) // Add significant bottom padding to clear the bottom navigation
        }
        .sheet(isPresented: $showProfilePreview) {
            if let profile = selectedFullProfile {
                DynamicProfilePreview(
                    profileData: profile,
                    isInNetwork: false
                )
            } else {
                Text("Loading profile...")
                    .padding()
            }
        }
        .refreshable {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                networkManager.refreshAllData()
            }
        }
    }
    
    // MARK: - Tab Content Views
    private var entrepreneursContent: some View {
        LazyVStack(spacing: 20) {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(hex: "004aad"))
                    
                    Text("Discovering entrepreneurs...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
            } else {
                ForEach(entrepreneurs.filter { !declinedEmails.contains($0.email) }, id: \.user_id) { entrepreneur in
                    enhancedEntrepreneurCard(for: entrepreneur)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
                
                if entrepreneurs.isEmpty {
                    VStack(spacing: 20) {
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
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(Color(hex: "004aad").opacity(0.6))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No entrepreneurs found")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Check back later for new connections and growth partners")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                }
            }
        }
    }
    
    private var mentorsContent: some View {
        LazyVStack(spacing: 20) {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.orange)
                    
                    Text("Finding expert mentors...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
            } else {
                ForEach(mentors.filter { !declinedEmails.contains($0.email) }, id: \.user_id) { mentor in
                    enhancedMentorCard(for: mentor)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
                
                if mentors.isEmpty {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange.opacity(0.1),
                                            Color.orange.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.orange.opacity(0.6))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No mentors available")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Expert mentors will appear here when available to guide your journey")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                }
            }
        }
    }
    
    private var myNetworkContent: some View {
        LazyVStack(spacing: 20) {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.green)
                    
                    Text("Loading your network...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
            } else {
                // Network stats card
                HStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("\(myNetwork.count)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "004aad"))
                        
                        Text("Connections")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "004aad").opacity(0.1))
                    )
                    
                    VStack(spacing: 6) {
                        Text("\(userNetworkEmails.count)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("Active")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                .padding(.bottom, 8)
                
                // 🔹 Pending requests
                if !networkManager.friendRequests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pending Requests")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)

                        ForEach(networkManager.friendRequests, id: \.user_id) { request in
                            HStack {
                                Text(request.name)
                                    .font(.body)
                                Spacer()
                                Button("Accept") {
                                    networkManager.acceptFriendRequest(senderEmail: request.email,
                                                                       receiverId: UserDefaults.standard.integer(forKey: "user_id"))
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Decline") {
                                    networkManager.declineFriendRequest(senderEmail: request.email,
                                                                        receiverId: UserDefaults.standard.integer(forKey: "user_id"))
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }


                // 🔹 Accepted friends (my network)
                if !networkManager.networkConnections.isEmpty {
                    ForEach(networkManager.networkConnections) { connection in
                        enhancedNetworkConnectionCard(for: connection)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                } else {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green.opacity(0.1),
                                            Color.green.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.3.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.green.opacity(0.6))
                        }

                        VStack(spacing: 8) {
                            Text("No connections yet")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Start connecting with entrepreneurs and mentors to build your network")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = .entrepreneurs
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 14, weight: .medium))

                                Text("Find Connections")
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
                        .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                }
            }
        }
    }
    
    // MARK: - Footer Section with Floating Menu
    private var footerSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if showMoreMenu {
                // Tap-to-dismiss layer
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showMoreMenu = false
                        }
                    }
                    .zIndex(0)
            }

            VStack(alignment: .trailing, spacing: 8) {
                if showMoreMenu {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Welcome to your resources")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray5))

                        NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
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

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showMoreMenu.toggle()
                        rotationAngle += 360
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
                .padding(.bottom, 35)
            }
            .padding(.trailing, 20)
            .zIndex(1)
        }
    }
    
    // MARK: - Bottom Navigation Bar (EXACT copy from Forum page)
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
            
            // More / Additional Resources
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBottomMoreMenu.toggle()
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
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Enhanced Profile Image with gradient border
                    ZStack {
                        // Gradient border ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "004aad").opacity(0.8),
                                        Color(hex: "004aad").opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 68, height: 68)
                        
                        // Profile Image with AsyncImage
                        if let profileImageURL = entrepreneur.profileImage, !profileImageURL.isEmpty {
                            AsyncImage(url: URL(string: profileImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(.systemGray6),
                                                Color(.systemGray5)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    )
                            }
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(.systemGray6),
                                            Color(.systemGray5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.secondary)
                                )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entrepreneur.name)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "briefcase")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            
                            Text(entrepreneur.businessStage.isEmpty ? "Entrepreneur" : entrepreneur.businessStage)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                                .lineLimit(1)
                        }
                        
                        if !entrepreneur.businessName.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Text(entrepreneur.businessName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                
                // Quick profile insights section
                VStack(alignment: .leading, spacing: 10) {
                    // Industry section
                                       VStack(alignment: .leading, spacing: 4) {
                                           Text("Industry")
                                               .font(.system(size: 11, weight: .medium))
                                               .foregroundColor(.secondary)
                                               .textCase(.uppercase)
                                               .tracking(0.5)
                        
                                           Text(entrepreneur.businessIndustry.isEmpty ? "Startup" : entrepreneur.businessIndustry)
                                                                      .font(.system(size: 14, weight: .semibold))
                                                                      .foregroundColor(.primary)
                                                                      .lineLimit(1)
                    }
                    
                    // Skills/Interests tags
                    if !entrepreneur.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entrepreneur.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: "004aad").opacity(0.1))
                                        )
                                }
                                
                                if entrepreneur.tags.count > 3 {
                                    Text("+\(entrepreneur.tags.count - 3)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(.systemGray6))
                                        )
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    
                    // Bio/Value proposition
                    HStack(spacing: 8) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("Looking to scale innovative solutions and build meaningful partnerships")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6).opacity(0.5))
                    )
                }
                
                // Enhanced action buttons with modern styling
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            _ = declinedEmails.insert(entrepreneur.email)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Pass")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                    }
                    let alreadyRequested = networkManager.sentRequests.contains(entrepreneur.email)
                    let hasIncomingRequest = networkManager.friendRequests.contains { $0.email == entrepreneur.email }
                    let alreadyConnected = networkManager.networkConnections.contains { $0.email == entrepreneur.email }

                    if alreadyRequested {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Request Sent")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.15))
                        )
                    } else if alreadyConnected && !hasIncomingRequest {
                        // ✅ Only show "Connected" if they are truly connected
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Connected")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.15))
                        )
                    } else {
                        // ✅ Fallback → Show Connect (including if hasIncomingRequest)
                        Button(action: {
                            selectedEmailToAdd = entrepreneur.email
                            showConfirmation = true
                            networkManager.addToNetwork(email: entrepreneur.email)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "link")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Connect")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
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
                    }


                }
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func enhancedMentorCard(for mentor: MentorProfileData) -> some View {
        Button(action: {
            fetchUserProfile(userId: mentor.user_id) { profile in
                if let profile = profile {
                    selectedFullProfile = profile
                    showProfilePreview = true
                } else {
                    print("🎯 No profile data available for mentor: \(mentor.name)")
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Enhanced Profile Image with mentor-specific gradient
                    ZStack {
                        // Mentor-specific gradient border ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.orange.opacity(0.8),
                                        Color(hex: "004aad").opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 68, height: 68)
                        
                        // Profile Image with AsyncImage
                        if let profileImageURL = mentor.profileImage, !profileImageURL.isEmpty {
                            AsyncImage(url: URL(string: profileImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(.systemGray6),
                                                Color(.systemGray5)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    )
                            }
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(.systemGray6),
                                            Color(.systemGray5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "graduationcap.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.secondary)
                                )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(mentor.name)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        // Expertise badge
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                            
                            Text(mentor.proficiency)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.orange)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        if !mentor.company.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Text(mentor.company)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Mentor status indicator with experience
                    VStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        
                        Text("Expert")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
                
                // Quick mentor insights section
                VStack(alignment: .leading, spacing: 10) {
                    // Experience & Specialization
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Experience")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text("15+ Years")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Mentees")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text("50+ Guided")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                        }
                    }
                    
                    // Specialization areas
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Areas of Expertise")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                let expertiseAreas = ["Strategy", "Scaling", "Fundraising", "Leadership"]
                                ForEach(expertiseAreas.prefix(3), id: \.self) { area in
                                    Text(area)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.orange.opacity(0.1))
                                        )
                                }
                                
                                if expertiseAreas.count > 3 {
                                    Text("+\(expertiseAreas.count - 3)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(.systemGray6))
                                        )
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    
                    // Mentor approach/philosophy
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text("Passionate about helping entrepreneurs scale their ventures and develop strategic thinking")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.05))
                    )
                    
                    // Availability indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        
                        Text("Available for new mentees")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("1-2 sessions/month")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Enhanced action buttons with mentor-specific styling
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            _ = declinedEmails.insert(mentor.email)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Pass")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: {
                        selectedEmailToAdd = mentor.email
                        showConfirmation = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "graduationcap")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Request Mentorship")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange,
                                            Color.orange.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                }
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private func enhancedNetworkConnectionCard(for connection: InviteProfileData) -> some View {
        print("🃏 Creating card for: \(connection.name) - \(connection.email)")
        return Button(action: {
            fetchUserProfile(userId: connection.user_id) { profile in
                if let profile = profile {
                    selectedProfile = profile
                    showProfileSheet = true
                }
            }
        }) {

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    // Enhanced Profile Image with connection-specific styling
                    ZStack {
                        // Connection status ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.green.opacity(0.8),
                                        Color(hex: "004aad").opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 54, height: 54)
                        
                        // Profile Image with AsyncImage
                        if let profileImageURL = connection.profileImage,
                           !profileImageURL.isEmpty,
                           profileImageURL != "default_profile" {   // ✅ skip invalid
                            AsyncImage(url: URL(string: profileImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(.systemGray6),
                                                Color(.systemGray5)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        ProgressView().scaleEffect(0.6)
                                    )
                            }
                        } else {
                            // Default fallback
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(.systemGray6),
                                            Color(.systemGray5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.secondary)
                                )
                        }


                        
                        // Connected indicator
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 18, y: -18)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(connection.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "briefcase")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            
                            Text(connection.title.isEmpty ? "Professional" : connection.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                                .lineLimit(1)
                        }
                        
                        if !connection.company.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                
                                Text(connection.company)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Enhanced message button with unread indicator
                    VStack(spacing: 4) {
                        Button(action: {
                            // Navigate to messages with this user
                            print("📱 Opening message conversation with \(connection.name)")
                            // You could add navigation to messages page here
                        }) {
                            ZStack {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
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
                                            .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 6, x: 0, y: 3)
                                    )
                                
                                // Simulated unread indicator (random for demo)
                                if Bool.random() {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 12, y: -12)
                                }
                            }
                        }
                        
                        Text("Chat")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Connection insights section
                VStack(alignment: .leading, spacing: 10) {
                   
                    
                    // Shared interests/tags
                    if !connection.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Shared Interests")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(connection.tags.prefix(3), id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(
                                                Capsule()
                                                    .fill(Color.green.opacity(0.1))
                                            )
                                    }
                                    
                                    if connection.tags.count > 3 {
                                        Text("+\(connection.tags.count - 3)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(
                                                Capsule()
                                                    .fill(Color(.systemGray6))
                                            )
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                    }
                    
                  
                    
                    Spacer()
                    
                    Button(action: {
                        print("👥 View mutual connections with \(connection.name)")
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 11, weight: .medium))
                            Text("Mutual")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func hasPendingRequest(for email: String) -> Bool {
        return networkManager.friendRequests.contains { $0.email.lowercased() == email.lowercased() }
    }

    // MARK: - API Functions
    func loadAllNetworkingData() {
        isLoading = true
        loadUserData()
        // Use NetworkDataManager for all data loading
        networkManager.refreshAllData()
        
        // Set loading to false after a brief delay to allow data to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
        }
    }
    
    func loadUserData() {
        fetchCurrentUserProfile()
        fetchUnreadMessageCount()
    }
    
    func fetchCurrentUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        guard let url = URL(string: "https://circlapp.online/api/users/profile/\(userId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                DispatchQueue.main.async {
                    self.userFirstName = decoded.first_name
                    self.userProfileImageURL = decoded.profile_image ?? ""
                }
            }
        }.resume()
    }

    
    func fetchUnreadMessageCount() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id in UserDefaults for message count")
            return
        }

        guard let url = URL(string: "\(baseURL)users/get_messages/\(userId)/") else {
            print("❌ Invalid URL for messages")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Request failed for messages:", error)
                return
            }

            guard let data = data else {
                print("❌ No data received for messages")
                return
            }

            do {
                let response = try JSONDecoder().decode([String: [MessageModel]].self, from: data)
                DispatchQueue.main.async {
                    let allMessages = response["messages"] ?? []
                    self.messages = allMessages
                    self.calculateUnreadMessageCount()
                    print("✅ Messages loaded successfully, count: \(allMessages.count)")
                }
            } catch {
                print("❌ Error decoding messages:", error)
                DispatchQueue.main.async {
                    self.unreadMessageCount = 0
                }
            }
        }.resume()
    }
    
    func calculateUnreadMessageCount() {
        guard let myId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        let unreadMessages = messages.filter { message in
            message.receiver_id == myId && !message.is_read && message.sender_id != myId
        }
        unreadMessageCount = unreadMessages.count
                print("📊 Calculated unread message count: \(unreadMessageCount)")
    }
    
    func fetchMyNetwork() {
        // Use NetworkDataManager for network connections (which fetches the actual connected profiles)
        networkManager.fetchNetworkConnections()
    }
    
    func fetchEntrepreneurs() {
        // Use NetworkDataManager for entrepreneurs data
        networkManager.fetchEntrepreneursData()
    }
    
    func fetchMentors() {
        // Use NetworkDataManager for mentors data
        networkManager.fetchMentorsData()
    }
    
    func fetchUserNetwork(completion: @escaping () -> Void) {
        // Use NetworkDataManager for user network emails
        networkManager.fetchUserNetwork()
        completion()
    }
    
    func addToNetwork(email: String) {
        // Use NetworkDataManager for adding connections
        networkManager.addToNetwork(email: email)
        
        // Show feedback to user
        DispatchQueue.main.async {
            self.alertMessage = "Connection request sent to \(email)!"
            self.showAlert = true
        }
    }
    
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "\(baseURL)users/profile/\(userId)/"
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
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(FullProfile.self, from: data)
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } catch {
                print("❌ Failed to decode user profile:", error)
                completion(nil)
            }
        }.resume()
    }

}

// MARK: - UserProfile Model for API responses
struct UserProfile: Codable {
    let name: String
    let username: String
    let email: String
    let company: String
    let bio: String
    let profile_image: String?
    let tags: [String]
}
