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
    @State private var showMoreMenu = false
    @State private var showBottomMoreMenu = false // Separate state for bottom navigation menu
    @State private var rotationAngle: Double = 0
    @State private var isLoading = false
    @AppStorage("user_id") private var userId: Int = 0
    
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
                
                loadAllNetworkingData()
                
                // Force load test data immediately to check if cards work
                print("🧪 Force loading test data on appear")
                let testData = [
                    InviteProfileData(
                        user_id: 1001,
                        name: "Test User 1",
                        username: "testuser1",
                        email: "test1@example.com",
                        title: "CEO",
                        company: "Test Corp",
                        proficiency: "Business Strategy",
                        tags: ["Leadership", "Strategy"],
                        profileImage: "https://picsum.photos/100/100?random=1"
                    ),
                    InviteProfileData(
                        user_id: 1002,
                        name: "Test User 2",
                        username: "testuser2",
                        email: "test2@example.com",
                        title: "CTO",
                        company: "Tech Corp",
                        proficiency: "Technology",
                        tags: ["Tech", "Innovation"],
                        profileImage: "https://picsum.photos/100/100?random=2"
                    )
                ]
                self.myNetwork = testData
                print("🧪 Test data loaded: \(self.myNetwork.count) items")
                
                // Force fetch network connections after a short delay
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
                    if !connections.isEmpty || self.myNetwork.isEmpty {
                        self.myNetwork = connections
                        print("🎯 myNetwork updated to \(self.myNetwork.count) connections")
                        print("🎯 myNetwork contents: \(self.myNetwork.map { "\($0.name) - \($0.email)" })")
                    } else {
                        print("🎯 Keeping existing myNetwork data (\(self.myNetwork.count) items) since connections is empty")
                    }
                }
            }
            .onReceive(networkManager.$friendRequests) { requests in
                print("📩 Received \(requests.count) friend requests")
                // Only use friend requests as fallback if we have no network connections AND no existing data
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.myNetwork.isEmpty && !requests.isEmpty {
                        print("🔄 Using friend requests as network connections fallback")
                        self.myNetwork = requests
                    } else if !requests.isEmpty {
                        print("🔄 Keeping existing myNetwork data, but friend requests available: \(requests.count)")
                    }
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
            .sheet(isPresented: $showProfilePreview) {
                if let profile = selectedFullProfile {
                    DynamicProfilePreview(profileData: profile, isInNetwork: false)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Profile
                NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                    if !userProfileImageURL.isEmpty {
                        AsyncImage(url: URL(string: userProfileImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Center - Logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side - Messages
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Image(systemName: "envelope")
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
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
            
            // Tab Buttons Row - Twitter/X style tabs
            HStack(spacing: 0) {
                Spacer()
                
                // Entrepreneurs Tab
                HStack {
                    VStack(spacing: 8) {
                        Text("Entrepreneurs")
                            .font(.system(size: 15, weight: selectedTab == .entrepreneurs ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(selectedTab == .entrepreneurs ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(width: 100)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .entrepreneurs
                    }
                }
                
                Spacer()
                
                // Mentors Tab
                HStack {
                    VStack(spacing: 8) {
                        Text("Mentors")
                            .font(.system(size: 15, weight: selectedTab == .mentors ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(selectedTab == .mentors ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(width: 70)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .mentors
                    }
                }
                
                Spacer()
                
                // My Network Tab
                HStack {
                    VStack(spacing: 8) {
                        Text("My Network")
                            .font(.system(size: 15, weight: selectedTab == .myNetwork ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(selectedTab == .myNetwork ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(width: 90)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .myNetwork
                        // Force refresh network data when My Network tab is selected
                        print("🔄 Switching to My Network tab - forcing refresh")
                        networkManager.fetchNetworkConnections()
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .padding(.top, 50) // Add safe area padding for status bar and notch
        .background(Color(hex: "004aad"))
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
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 120) // Add significant bottom padding to clear the bottom navigation
        }
        .refreshable {
            networkManager.refreshAllData()
        }
    }
    
    // MARK: - Tab Content Views
    private var entrepreneursContent: some View {
        LazyVStack(spacing: 16) {
            if isLoading {
                ProgressView("Loading entrepreneurs...")
                    .padding(.vertical, 40)
            } else {
                ForEach(entrepreneurs.filter { !declinedEmails.contains($0.email) }, id: \.user_id) { entrepreneur in
                    enhancedEntrepreneurCard(for: entrepreneur)
                }
                
                if entrepreneurs.isEmpty {
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
    }
    
    private var mentorsContent: some View {
        LazyVStack(spacing: 16) {
            if isLoading {
                ProgressView("Loading mentors...")
                    .padding(.vertical, 40)
            } else {
                ForEach(mentors.filter { !declinedEmails.contains($0.email) }, id: \.user_id) { mentor in
                    enhancedMentorCard(for: mentor)
                }
                
                if mentors.isEmpty {
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
    }
    
    private var myNetworkContent: some View {
        LazyVStack(spacing: 16) {
            if isLoading {
                ProgressView("Loading your network...")
                    .padding(.vertical, 40)
            } else {
                // Debug information (can be removed later)
                VStack(spacing: 4) {
                    Text("Network: \(myNetwork.count) connections")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !myNetwork.isEmpty {
                        Text("Connected: \(myNetwork.map { $0.name }.joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .lineLimit(2)
                    }
                }
                .padding(.bottom, 8)
                
                ForEach(myNetwork) { connection in
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
                        
                        // Debug button to test network loading
                        Button("Refresh Network") {
                            print("🔄 Manual refresh network connections")
                            networkManager.fetchNetworkConnections()
                        }
                        .padding(.top, 16)
                        .foregroundColor(.blue)
                        
                        // Force load test data button
                        Button("Load Test Data") {
                            print("🧪 Loading test network data")
                            let testData = [
                                InviteProfileData(
                                    user_id: 1001,
                                    name: "John Doe",
                                    username: "johndoe",
                                    email: "john@example.com",
                                    title: "CEO",
                                    company: "Example Corp",
                                    proficiency: "Business Strategy",
                                    tags: ["Leadership", "Strategy"],
                                    profileImage: "https://picsum.photos/100/100?random=3"
                                ),
                                InviteProfileData(
                                    user_id: 1003,
                                    name: "Jane Smith",
                                    username: "janesmith",
                                    email: "jane@example.com",
                                    title: "Designer",
                                    company: "Design Co",
                                    proficiency: "UI/UX Design",
                                    tags: ["Design", "Creative"],
                                    profileImage: "https://picsum.photos/100/100?random=4"
                                )
                            ]
                            self.myNetwork = testData
                        }
                        .padding(.top, 8)
                        .foregroundColor(.green)
                    }
                    .padding(.vertical, 40)
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // Profile Image with AsyncImage
                    if let profileImageURL = entrepreneur.profileImage, !profileImageURL.isEmpty {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.8)
                                )
                        }
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24))
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
                        
                        if !entrepreneur.businessName.isEmpty {
                            Text(entrepreneur.businessName)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            _ = declinedEmails.insert(entrepreneur.email)
                        }
                    }) {
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
                    
                    Button(action: {
                        selectedEmailToAdd = entrepreneur.email
                        showConfirmation = true
                    }) {
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
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // Profile Image with AsyncImage
                    if let profileImageURL = mentor.profileImage, !profileImageURL.isEmpty {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.8)
                                )
                        }
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "graduationcap.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondary)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mentor.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(mentor.proficiency)
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
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            _ = declinedEmails.insert(mentor.email)
                        }
                    }) {
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
                    
                    Button(action: {
                        selectedEmailToAdd = mentor.email
                        showConfirmation = true
                    }) {
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
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func enhancedNetworkConnectionCard(for connection: InviteProfileData) -> some View {
        print("🃏 Creating card for: \(connection.name) - \(connection.email)")
        return Button(action: {
            fetchUserProfile(userId: connection.user_id) { profile in
                if let profile = profile {
                    selectedFullProfile = profile
                    showProfilePreview = true
                } else {
                    print("🎯 No profile data available for connection: \(connection.name)")
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 10) { // Reduced from 12 to 10
                HStack(spacing: 10) { // Reduced from 12 to 10
                    // Profile Image with AsyncImage
                    if let profileImageURL = connection.profileImage, !profileImageURL.isEmpty {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 45, height: 45)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.6)
                                )
                        }
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 45, height: 45)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 3) { // Reduced spacing from 4 to 3
                        Text(connection.name)
                            .font(.system(size: 15, weight: .semibold)) // Reduced from 16
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("@\(connection.username)")
                            .font(.system(size: 13)) // Reduced from 14
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        if !connection.company.isEmpty {
                            Text(connection.company)
                                .font(.system(size: 12)) // Reduced from 13
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Navigate to messages with this user
                        print("📱 Opening message conversation with \(connection.name)")
                        // You could add navigation to messages page here
                    }) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14)) // Reduced from 16
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(6) // Reduced from 8
                            .background(
                                Circle()
                                    .fill(Color(hex: "004aad").opacity(0.1))
                            )
                    }
                }
            }
            .padding(10) // Reduced from 12
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12) // Reduced from 16
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1) // Reduced shadow
        )
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
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
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
        DispatchQueue.main.async {
            unreadMessageCount = 0
        }
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
            if let error = error {
                print("❌ Request failed:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                let fullProfile = FullProfile(
                    user_id: userId,
                    profile_image: userProfile.profile_image,
                    first_name: userProfile.name.components(separatedBy: " ").first ?? "",
                    last_name: userProfile.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                    email: userProfile.email,
                    main_usage: nil,
                    industry_interest: nil,
                    title: nil,
                    bio: userProfile.bio,
                    birthday: nil,
                    education_level: nil,
                    institution_attended: nil,
                    certificates: nil,
                    years_of_experience: nil,
                    personality_type: nil,
                    locations: nil,
                    achievements: nil,
                    skillsets: userProfile.tags,
                    availability: nil,
                    clubs: nil,
                    hobbies: nil,
                    connections_count: nil,
                    circs: nil,
                    entrepreneurial_history: nil
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
