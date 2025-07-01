import SwiftUI
import Foundation

struct PageMentorMatching: View {
    @State private var mentors: [MentorProfileData] = []
    @State private var declinedEmails: Set<String> = []
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil
    @State private var selectedFullProfile: FullProfile? = nil
    @State private var showProfilePreview = false
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false
    @State private var userFirstName: String = ""
    
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
            print("🎯 PageMentorMatching appeared - starting mentor fetch process")
            
            // Extract user's first name for personalization
            let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
            userFirstName = fullName.components(separatedBy: " ").first ?? "Friend"
            
            // Start animation
            withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            // Use shared network manager to refresh data
            networkManager.refreshAllData()
            fetchMentors()
            
            // Also call fetchMentors directly as a fallback
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if mentors.isEmpty {
                    print("🔄 No mentors loaded, trying direct fetch...")
                    fetchMentors()
                }
            }
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Send Connection Request?"),
                message: Text("Are you sure you want to connect with this mentor?"),
                primaryButton: .default(Text("Yes")) {
                    if let email = selectedEmailToAdd {
                        networkManager.addToNetwork(email: email)
                        mentors.removeAll { $0.email == email }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: Binding(
            get: { showProfilePreview && selectedFullProfile != nil },
            set: { newValue in showProfilePreview = newValue }
        )) {
            if let profile = selectedFullProfile {
                DynamicProfilePreview(profileData: profile, isInNetwork: false)
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
                    SwiftUI.Color(hexCode: "001a3d"),
                    SwiftUI.Color(hexCode: "004aad"),
                    SwiftUI.Color(hexCode: "0066ff"),
                    SwiftUI.Color(hexCode: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    SwiftUI.Color(hexCode: "0066ff").opacity(0.3),
                    Color.clear,
                    SwiftUI.Color(hexCode: "004aad").opacity(0.2),
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
                    Text("Find Expert Mentors, \(userFirstName)! 🎯")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Connect with experienced mentors who can guide your entrepreneurial journey and accelerate your growth...")
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
                        isSelected: false,
                        color: .gray
                    )
                }
                
                NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                    enhancedButtonContent(
                        title: "Mentors",
                        subtitle: "Expert Guidance",
                        icon: "graduationcap.fill",
                        isSelected: true,
                        color: SwiftUI.Color(hexCode: "004aad")
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
                // Mentors Section
                mentorsSection
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var mentorsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Expert Mentors (\(mentors.count))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if mentors.isEmpty {
                emptyMentorsStateView
            } else {
                ForEach(mentors, id: \.email) { mentor in
                    enhancedMentorCard(for: mentor)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .slide.combined(with: .opacity)
                        ))
                }
            }
        }
    }
    
    private var emptyMentorsStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "graduationcap.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Discover Amazing Mentors! 🌟")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Connect with experienced professionals who can guide your entrepreneurial journey and help you achieve your goals!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    networkManager.refreshAllData()
                    fetchMentors()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Mentors")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hexCode: "004aad"))
                    .cornerRadius(20)
                }
                
                NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                        Text("Find Entrepreneurs")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hexCode: "004aad").opacity(0.1))
                    .cornerRadius(20)
                }
                
                NavigationLink(destination: PageMyNetwork().navigationBarBackButtonHidden(true)) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                        Text("My Network")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hexCode: "004aad"))
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
    
    private func enhancedMentorCard(for mentor: MentorProfileData) -> some View {
        Button(action: {
            fetchUserProfile(userId: mentor.user_id) { profile in
                if let profile = profile {
                    selectedFullProfile = profile
                    showProfilePreview = true
                }
            }
        }) {
            MentorProfileTemplate(
                name: mentor.name,
                username: mentor.username,
                title: "Mentor",
                company: mentor.company,
                proficiency: mentor.proficiency,
                tags: mentor.tags,
                email: mentor.email,
                profileImage: mentor.profileImage,
                onAccept: {
                    selectedEmailToAdd = mentor.email
                    showConfirmation = true
                },
                onDecline: {
                    declinedEmails.insert(mentor.email)
                    mentors.removeAll { $0.email == mentor.email }
                },
                isMentor: true
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
    func fetchMentors() {
        let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
        print("🎯 Starting fetchMentors for current user: \(currentUserEmail)")
        
        // Use DispatchGroup to wait for both API calls
        let group = DispatchGroup()
        var allMentors: [MentorProfileData] = []
        
        // Fetch from dedicated mentors API
        group.enter()
        fetchDedicatedMentors { dedicatedMentors in
            print("📥 Received \(dedicatedMentors.count) mentors from dedicated API")
            allMentors.append(contentsOf: dedicatedMentors)
            group.leave()
        }
        
        // Fetch mentors from entrepreneurs API
        group.enter()
        fetchMentorsFromEntrepreneurs { entrepreneurMentors in
            print("📥 Received \(entrepreneurMentors.count) mentors from entrepreneurs API")
            allMentors.append(contentsOf: entrepreneurMentors)
            group.leave()
        }
        
        // When both calls complete, combine and deduplicate
        group.notify(queue: .main) {
            print("🔄 Processing \(allMentors.count) total mentors before filtering")
            print("🔍 Current user network emails: \(self.networkManager.userNetworkEmails)")
            print("🔍 Declined emails: \(self.declinedEmails)")
            
            // Deduplicate by email and filter out current user, network members, and declined users
            var mentorsByEmail: [String: MentorProfileData] = [:]
            for mentor in allMentors {
                print("🔍 Processing mentor: \(mentor.name) (\(mentor.email))")
                if !self.networkManager.userNetworkEmails.contains(mentor.email) && 
                   !self.declinedEmails.contains(mentor.email) && 
                   mentor.email != currentUserEmail {
                    mentorsByEmail[mentor.email] = mentor
                    print("✅ Added mentor: \(mentor.name)")
                } else {
                    print("❌ Filtered out mentor: \(mentor.name) - Network: \(self.networkManager.userNetworkEmails.contains(mentor.email)), Declined: \(self.declinedEmails.contains(mentor.email)), Current user: \(mentor.email == currentUserEmail)")
                }
            }
            
            self.mentors = Array(mentorsByEmail.values)
            print("✅ Final mentors count: \(self.mentors.count)")
            print("📊 Mentors breakdown - Dedicated API + Entrepreneur API (mentors only)")
            
            for mentor in self.mentors {
                print("📋 Final mentor: \(mentor.name) - \(mentor.title) at \(mentor.company)")
            }
        }
    }
    
    private func fetchDedicatedMentors(completion: @escaping ([MentorProfileData]) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/approved_mentors/") else {
            print("❌ Invalid URL for dedicated mentors API")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Dedicated mentors API error: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No data from dedicated mentors API")
                completion([])
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([MentorProfileData].self, from: data)
                print("✅ Loaded \(decodedResponse.count) mentors from dedicated API")
                completion(decodedResponse)
            } catch {
                print("❌ JSON Decoding Error for dedicated mentors: \(error)")
                completion([])
            }
        }.resume()
    }
    
    private func fetchMentorsFromEntrepreneurs(completion: @escaping ([MentorProfileData]) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/get-entrepreneurs/") else {
            print("❌ Invalid URL for entrepreneurs API")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Entrepreneurs API error: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No data from entrepreneurs API")
                completion([])
                return
            }
            
            // Parse the entrepreneurs data and filter for mentors
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("🔍 Entrepreneurs API response for mentors: \(json)")
                    
                    // Check both possible response structures
                    var entrepreneurList: [[String: Any]] = []
                    if let results = json["results"] as? [[String: Any]] {
                        entrepreneurList = results
                        print("🔍 Found entrepreneurs in 'results' key: \(entrepreneurList.count)")
                    } else if let entrepreneurs = json["entrepreneurs"] as? [[String: Any]] {
                        entrepreneurList = entrepreneurs
                        print("🔍 Found entrepreneurs in 'entrepreneurs' key: \(entrepreneurList.count)")
                    } else {
                        print("❌ No entrepreneurs found in either 'results' or 'entrepreneurs' key")
                        print("🔍 Available keys: \(json.keys)")
                        completion([])
                        return
                    }
                    
                    var mentorsFromEntrepreneurs: [MentorProfileData] = []
                    
                    for dict in entrepreneurList {
                        let isMentor = dict["is_mentor"] as? Bool ?? false
                        print("🔍 Checking user with is_mentor: \(isMentor), data: \(dict)")
                        
                        // Only include if they are marked as a mentor
                        if isMentor {
                            let userId = dict["id"] as? Int ?? 0
                            let firstName = dict["first_name"] as? String ?? ""
                            let lastName = dict["last_name"] as? String ?? ""
                            let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            let username = dict["username"] as? String ?? ""
                            let email = dict["email"] as? String ?? ""
                            let industryInterest = dict["industry_interest"] as? String ?? ""
                            let profilePicture = dict["profile_picture"] as? String
                            
                            print("✅ Found mentor: \(name) (\(email))")
                            
                            let mentorProfile = MentorProfileData(
                                user_id: userId,
                                name: name,
                                username: username,
                                title: "Mentor & Entrepreneur", // Combined title
                                company: industryInterest,
                                proficiency: "Business & Mentoring",
                                tags: [industryInterest].filter { !$0.isEmpty },
                                email: email,
                                profileImage: profilePicture
                            )
                            
                            mentorsFromEntrepreneurs.append(mentorProfile)
                        }
                    }
                    
                    print("✅ Loaded \(mentorsFromEntrepreneurs.count) mentors from entrepreneurs API")
                    completion(mentorsFromEntrepreneurs)
                } else {
                    print("❌ Failed to parse entrepreneurs JSON structure")
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("🔍 Raw response: \(rawString)")
                    }
                    completion([])
                }
            } catch {
                print("❌ JSON parsing error for entrepreneurs: \(error)")
                completion([])
            }
        }.resume()
    }
    struct MentorProfileTemplate: View {
        var name: String
        var username: String
        var title: String
        var company: String
        var proficiency: String
        var tags: [String]
        var email: String
        var profileImage: String?
        var onAccept: () -> Void
        var onDecline: () -> Void
        var isMentor: Bool

        var body: some View {
            HStack(spacing: 12) {
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
                    .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                } else {
                    Image("default_image")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Name (bold)
                    Text(name.isEmpty ? (username.isEmpty ? email : username) : name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Username in smaller text (above company)
                    if !username.isEmpty {
                        Text("@\(username)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // Title (Mentor, or Mentor & Entrepreneur)
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    // Company/Industry
                    if !company.isEmpty {
                        Text(company)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.purple)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Accept/Decline buttons
                HStack(spacing: 10) {
                    Button(action: onAccept) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.green)
                    }

                    Button(action: onDecline) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
    
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


    struct PageMentorMatching_Previews: PreviewProvider {
        static var previews: some View {
            PageMentorMatching()
        }
    }
}
