import SwiftUI
import Foundation

// MARK: - Main View for Entrepreneur Matching
struct PageEntrepreneurMatching: View {
    @State private var entrepreneurs: [EntrepreneurProfileData] = []
    @State private var userNetworkEmails: [String] = []
    @State private var declinedEmails: Set<String> = []
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil
    @State private var selectedFullProfile: FullProfile? = nil
    @State private var showProfilePreview = false
    @State private var showMenu = false

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
            VStack(spacing: 0) {
                headerSection
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
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }

    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        Text("Circl.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    
//                    Button(action: {}) {
//                        HStack {
//                            Image(systemName: "slider.horizontal.3")
//                                .foregroundColor(.white)
//                            Text("Filter")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                        }
//                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 50, height: 40)
                                .foregroundColor(.white)
                        }
                        
                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }
    }
    
    private var selectionButtonsSection: some View {
        HStack(spacing: 10) {
            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                buttonContent(title: "Entrepreneurs", color: .yellow)
            }
            
            NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                buttonContent(title: "Mentors", color: .gray)
            }
            
            NavigationLink(destination: PageInvites().navigationBarBackButtonHidden(true)) {
                buttonContent(title: "My Network", color: .gray)
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    private func buttonContent(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 12))
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.black)
            .cornerRadius(10)
    }
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(entrepreneurs, id: \.email) { entrepreneur in
                    entrepreneurButton(for: entrepreneur)
                }
            }
            .padding()
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Send Friend Request?"),
                message: Text("Are you sure you want to send a friend request to this user?"),
                primaryButton: .default(Text("Yes")) {
                    if let email = selectedEmailToAdd {
                        addToNetwork(email: email)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            fetchUserNetwork {
                fetchEntrepreneurs()
            }
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
    
    private func entrepreneurButton(for entrepreneur: EntrepreneurProfileData) -> some View {
        Button(action: {
            fetchUserProfile(userId: entrepreneur.user_id) { profile in
                if let profile = profile {
                    selectedFullProfile = profile
                    showProfilePreview = true
                }
            }
        }) {
            EntrepreneurProfileTemplate(
                name: entrepreneur.name,
                title: "Entrepreneur",
                company: entrepreneur.company,
                proficiency: entrepreneur.proficiency,
                tags: entrepreneur.tags,
                profileImage: entrepreneur.profileImage,

                onAccept: {
                    selectedEmailToAdd = entrepreneur.email
                    showConfirmation = true
                },
                onDecline: {
                    declinedEmails.insert(entrepreneur.email)
                    entrepreneurs.removeAll { $0.email == entrepreneur.email }
                },
                isMentor: entrepreneur.isMentor
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
                    withAnimation(.spring()) {
                        showMenu.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.fromHex("004aad"))
                            .frame(width: 60, height: 60)

                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .shadow(radius: 4)
                .padding(.bottom, 34)
            }
            .padding(.trailing, 20)
            .zIndex(1)
        }
    }




    
    // All the existing methods remain exactly the same...
    func fetchEntrepreneurs() {
        let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
        print("🔍 Stored user_email in UserDefaults:", currentUserEmail)
        
        guard let url = URL(string: "https://circlapp.online/api/users/get-entrepreneurs/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Request Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                if let decodedResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("📡 Response from Backend: \(decodedResponse)") // Debug Log
                    
                    if let entrepreneurList = decodedResponse["entrepreneurs"] as? [[String: Any]] {
                        DispatchQueue.main.async {
                            self.entrepreneurs = entrepreneurList.compactMap { entrepreneur -> EntrepreneurProfileData? in
                                
                                let email = entrepreneur["email"] as? String ?? ""
                                
                                // Get current user's email
                                let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
                                
                                guard email != currentUserEmail, // ← exclude myself
                                      !self.userNetworkEmails.contains(email),
                                      !self.declinedEmails.contains(email) else {
                                    return nil
                                }
                                
                                
                                guard let user_id = entrepreneur["id"] as? Int else {
                                    return nil
                                }
                                
                                return EntrepreneurProfileData(
                                    user_id: user_id,
                                    name: "\(entrepreneur["first_name"] ?? "") \(entrepreneur["last_name"] ?? "")",
                                    title: "Entrepreneur",
                                    company: entrepreneur["industry_interest"] as? String ?? "Unknown Industry",
                                    proficiency: entrepreneur["main_usage"] as? String ?? "Unknown",
                                    tags: entrepreneur["tags"] as? [String] ?? [],
                                    email: email,
                                    profileImage: entrepreneur["profileImage"] as? String,
                                    isMentor: entrepreneur["is_mentor"] as? Bool ?? false
                                )
                            }
                        }
                    } else {
                        print("❌ API response missing 'entrepreneurs' key")
                    }
                } else {
                    print("❌ Failed to parse JSON response")
                }
            }
        }.resume()
    }
    
    func fetchUserNetwork(completion: @escaping () -> Void) {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "https://circlapp.online/api/users/get_network/\(userId)/") else {
            print("❌ No user_id in UserDefaults")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network fetch error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("🔎 Raw Network Response: \(json)")
                
                if let networkArray = json as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.userNetworkEmails = networkArray.compactMap { $0["email"] as? String }
                        completion()
                    }
                } else if let dict = json as? [String: Any],
                          let network = dict["network"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.userNetworkEmails = network.compactMap { $0["email"] as? String }
                        completion()
                    }
                } else {
                    print("❌ Unknown format in network response")
                }
                
            } catch {
                if let rawString = String(data: data, encoding: .utf8) {
                    print("❌ JSON Parsing Error – Raw text: \(rawString)")
                } else {
                    print("❌ JSON Parsing Error: Could not decode response")
                }
            }
        }.resume()
    }
    
    func addToNetwork(email: String) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "https://circlapp.online/api/users/send_friend_request/") else {
            print("❌ Missing sender ID or bad URL")
            return
        }
        
        let body: [String: Any] = [
            "user_id": senderId,
            "receiver_email": email
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error sending friend request:", error.localizedDescription)
                return
            }
            
            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8)
                print("📡 Friend Request Response:", rawResponse ?? "No response body")
            }
            
            DispatchQueue.main.async {
                entrepreneurs.removeAll { $0.email == email }
                userNetworkEmails.append(email)
            }
        }.resume()
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
    
    // MARK: - EntrepreneurProfileData Model
    struct EntrepreneurProfileData {
        var user_id: Int
        var name: String
        var title: String
        var company: String
        var proficiency: String
        var tags: [String]
        var email: String
        var profileImage: String?
        var isMentor: Bool
    }
    
    // MARK: - Preview
    struct PageEntrepreneurMatching_Previews: PreviewProvider {
        static var previews: some View {
            PageEntrepreneurMatching()
        }
    }
}




// MARK: - EntrepreneurProfileTemplate (kept exactly the same)
struct EntrepreneurProfileTemplate: View {
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
