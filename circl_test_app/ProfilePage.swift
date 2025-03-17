import SwiftUI

struct ProfilePage: View {
    
    @State private var showError: Bool = false
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var isMentor: Bool = UserDefaults.standard.bool(forKey: "isMentor")
    @State private var userName: String = "Loading..."
    @State private var userTitle: String = UserDefaults.standard.string(forKey: "userTitle") ?? "No Title Set"
    @State private var isEditingTitle: Bool = false
    @State private var newTitle: String = ""
    @State private var isEditingPersonality: Bool = false
    @State private var newPersonality: String = ""
    @State private var personalityType: String = "Loading..."
    @State private var connectionsCount: Int = 0
    @State private var isEditingMode: Bool = false
    @State private var userBio: String = "Loading..."
    @State private var newBio: String = ""
    @StateObject private var viewModel = UserProfileViewModel()
    
    @State private var connections: [NetworkUser] = []
    
    struct UserProfile: Codable {
        let name: String
        let age: Int?
        let education_level: String? // JSON field is "education_level"
        let institution_attended: String?
        let certifications: [String]?
        let years_of_experience: String?
        let location: String?
        let achievements: String?
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Section 1: Fixed Top Section
                TopSectionView(isEditingMode: $isEditingMode, saveAction: {
                    saveTitleToBackend()
                    savePersonalityToBackend()
                    saveBioToBackend()
                })
                .frame(height: 105)
                .background(Color.white)
                
                // Section 2: Scrollable Middle Section
                ScrollView {
                    VStack(spacing: 20) {
                        ProfileHeaderView(
                            userName: $userName,
                            userTitle: $userTitle,
                            isEditingMode: $isEditingMode,
                            newTitle: $newTitle,
                            personalityType: $personalityType,
                            newPersonality: $newPersonality,
                            isMentor: $isMentor,
                            connectionsCount: $connectionsCount,
                            updateMentorStatus: updateMentorStatus
                        )
                        
                        PersonalSecretSectionView()
                        
                        BioSectionView(userBio: $userBio, isEditingMode: $isEditingMode, newBio: $newBio)
                        
                        AboutSectionView(viewModel: viewModel)
                        
                        TechnicalSideSectionView()
                        
                        InterestsSectionView()
                        
                        EntrepreneurialHistorySectionView()
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray4))
                
                // Section 3: Fixed Bottom Section with Navigation Links
                BottomNavigationView()
                    .padding(.vertical, 10)
                    .background(Color.white)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let storedLoginState = UserDefaults.standard.bool(forKey: "isLoggedIn")
                if !storedLoginState {
                    isLoggedIn = false
                }
                fetchUserName()
                userTitle = UserDefaults.standard.string(forKey: "userTitle") ?? "No Title Set"
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isMentor = UserDefaults.standard.bool(forKey: "isMentor")
                isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                if userTitle == "Loading..." { fetchTitleFromBackend() }
                if personalityType == "Loading..." { fetchPersonalityFromBackend() }
                if userBio == "Loading..." { fetchBioFromBackend() }
                fetchUserName()
                fetchConnectionsCount()
                viewModel.fetchUserProfile()
            }
        }
    }
    
    // MARK: - Subviews
    
    struct TopSectionView: View {
        @Binding var isEditingMode: Bool
        var saveAction: () -> Void
        
        var body: some View {
            HStack {
                Text("Circl")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.customHex("004aad"))
                    .padding(.top, 25)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        if isEditingMode {
                            saveAction()
                        }
                        isEditingMode.toggle()
                    }) {
                        Image(systemName: isEditingMode ? "checkmark" : "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: ProfilePageSettings().navigationBarBackButtonHidden(true)) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 25)
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
    }
    
    struct ProfileHeaderView: View {
        @Binding var userName: String
        @Binding var userTitle: String
        @Binding var isEditingMode: Bool
        @Binding var newTitle: String
        @Binding var personalityType: String
        @Binding var newPersonality: String
        @Binding var isMentor: Bool
        @Binding var connectionsCount: Int
        var updateMentorStatus: (Bool) -> Void
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .frame(height: 300)
                
                VStack(spacing: 15) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        )
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("Connections:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.customHex("#ffde59"))
                            Text("\(connectionsCount)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                        
                        VStack {
                            Text("Circles:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.customHex("#ffde59"))
                            Text("0")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                        
                        VStack {
                            Text("Circs:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.customHex("#ffde59"))
                            Text("0")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                    }
                    
                    VStack(spacing: 5) {
                        Text(userName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        if isEditingMode {
                            TextField("", text: $newTitle)
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .background(Color.clear)
                                .frame(width: 200)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        newTitle = userTitle
                                    }
                                }
                        } else {
                            Text(userTitle)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        if isEditingMode {
                            TextField("", text: $newPersonality)
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .background(Color.clear)
                                .frame(width: 200)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        newPersonality = personalityType
                                    }
                                }
                        } else {
                            Text(personalityType)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Toggle("Mentor?", isOn: $isMentor)
                            .toggleStyle(SwitchToggleStyle(tint: Color.customHex("ffde59")))
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .onChange(of: isMentor) { newValue in
                                updateMentorStatus(newValue)
                            }
                    }
                }
            }
        }
    }
    
    struct PersonalSecretSectionView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .shadow(radius: 2)
                    .frame(height: 200)
                
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Secret Idea")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Creating an app for entrepreneurs")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.bottom, 10)
                    
                    Divider()
                        .background(Color.white)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Next Steps")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Entrepreneur AI coming soon")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
            }
        }
    }
    
    struct BioSectionView: View {
        @Binding var userBio: String
        @Binding var isEditingMode: Bool
        @Binding var newBio: String
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .shadow(radius: 2)
                    .frame(height: 150)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Bio")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if isEditingMode {
                        TextField("", text: $newBio)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.leading)
                            .background(Color.clear)
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                DispatchQueue.main.async {
                                    newBio = userBio
                                }
                            }
                    } else {
                        Text(userBio)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
            }
        }
    }
    
    struct AboutSectionView: View {
        @ObservedObject var viewModel: UserProfileViewModel
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .shadow(radius: 2)
                    .frame(height: 400)
                
                VStack(alignment: .leading, spacing: 15) {
                    if let profile = viewModel.userProfile {
                        Text("About \(profile.name)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Age: \(String(profile.age))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Education Level: \(profile.education_level ?? "N/A")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Institution Attended: \(profile.institution_attended ?? "N/A")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Certifications: \(profile.certifications?.joined(separator: ", ") ?? "N/A")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Years of Experience: \(profile.years_of_experience ?? "N/A")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Location: \(profile.location ?? "N/A")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Achievements: \(profile.achievements ?? "N/A")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        ProgressView()
                            .onAppear {
                                viewModel.fetchUserProfile()
                            }
                    }
                }
                .padding()
            }
        }
    }
    
    struct TechnicalSideSectionView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .shadow(radius: 2)
                    .frame(height: 400)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Technical Side")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Skills: Swift, UI/UX Design, Project Management")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Projects/Work Completed: xxx")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Availability: Open to collaboration, Monday - Friday, 9 AM - 5 PM EST")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
    }
    
    struct InterestsSectionView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .shadow(radius: 2)
                    .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Interests")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Clubs/Organizations: Member of Tau Kappa Epsilon, Volunteer at Habitat for Humanity")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Hobbies/Passions: Reading, Cycling, Digital Art, Traveling")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
    }
    
    struct EntrepreneurialHistorySectionView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .shadow(radius: 2)
                    .frame(height: 150)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Entrepreneurial History")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("xxx")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                .padding()
            }
        }
    }
    
    struct BottomNavigationView: View {
        var body: some View {
            HStack(spacing: 15) {
                NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                    CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
                }
                
                NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                    CustomCircleButton(iconName: "briefcase.fill")
                }
                
                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                    CustomCircleButton(iconName: "captions.bubble.fill")
                }
                
                NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                    CustomCircleButton(iconName: "building.columns.fill")
                }
                
                NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                    CustomCircleButton(iconName: "newspaper")
                }
            }
        }
    }
    
    // MARK: - Functions
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        isLoggedIn = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: Page1())
                window.makeKeyAndVisible()
            }
        }
    }
    
    func fetchUserName() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get_user/\(userId)/") else {
            print("❌ Invalid URL")
            return
        }

        print("📡 Fetching user profile from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code:", httpResponse.statusCode)
            }

            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8) ?? "No response"
                print("📡 Raw API Response:", rawResponse)

                do {
                    let response = try JSONDecoder().decode([String: String].self, from: data)
                    DispatchQueue.main.async {
                        self.userName = "\(response["first_name"] ?? "Unknown") \(response["last_name"] ?? "User")"
                        print("✅ User found: \(self.userName)")
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }
    
    func fetchConnectionsCount() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get-user-connections/\(userId)/") else {
            print("❌ Invalid URL")
            return
        }

        print("📡 Fetching connections count from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code:", httpResponse.statusCode)
            }

            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8) ?? "No response"
                print("📡 Raw API Response:", rawResponse)

                do {
                    let response = try JSONDecoder().decode([String: Int].self, from: data)
                    DispatchQueue.main.async {
                        self.connectionsCount = response["connections_count"] ?? 0
                        print("✅ Connections count updated:", self.connectionsCount)
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }

    func updateMentorStatus(isMentor: Bool) {
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        print("user_id: \(userId), auth_token: \(UserDefaults.standard.string(forKey: "auth_token") ?? "No token")")

        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            return
        }

        let url = URL(string: "http://34.44.204.172:8000/api/users/update-mentor-status/")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "user_id": userId,
            "is_mentor": isMentor
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let data = data {
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            }
        }
        task.resume()
    }
    
    func saveTitleToBackend() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let url = URL(string: "http://34.44.204.172:8000/api/users/update-title/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": userId, "title": newTitle]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        DispatchQueue.main.async {
            userTitle = newTitle
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error updating title:", error.localizedDescription)
                return
            }
            if let data = data {
                print("✅ Title updated:", String(data: data, encoding: .utf8) ?? "No data")
            }
        }.resume()
    }

    func fetchTitleFromBackend() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let url = URL(string: "http://34.44.204.172:8000/api/users/get-user-profile/\(userId)/")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching title:", error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: String].self, from: data)
                    DispatchQueue.main.async {
                        userTitle = response["title"] ?? "No Title Set"
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }
    
    func fetchPersonalityFromBackend() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let url = URL(string: "http://34.44.204.172:8000/api/users/get-user-personality/\(userId)/")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching personality:", error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: String?].self, from: data)
                    DispatchQueue.main.async {
                        personalityType = (response["personality_type"] as? String) ?? "Unknown"
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                    DispatchQueue.main.async {
                        personalityType = "Unknown"
                    }
                }
            }
        }.resume()
    }

    func savePersonalityToBackend() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let url = URL(string: "http://34.44.204.172:8000/api/users/update-personal-details/")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": userId, "personality_type": newPersonality]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        DispatchQueue.main.async {
            personalityType = newPersonality
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error updating personality:", error.localizedDescription)
                return
            }
            if let data = data {
                print("✅ Personality Type updated:", String(data: data, encoding: .utf8) ?? "No data")
            }
        }.resume()
    }

    func fetchBioFromBackend() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let url = URL(string: "http://34.44.204.172:8000/api/users/get-user-bio/\(userId)/")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching bio:", error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: String].self, from: data)
                    DispatchQueue.main.async {
                        userBio = response["bio"] ?? "No Bio Set"
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }
    
    func saveBioToBackend() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let token = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ No user ID or auth token found.")
            return
        }

        let url = URL(string: "http://34.44.204.172:8000/api/users/update-user-bio/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["user_id": userId, "bio": newBio]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            print("❌ Failed to serialize JSON body")
            return
        }
        request.httpBody = httpBody

        print("📡 Sending request to update bio for user \(userId)...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error updating bio:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code:", httpResponse.statusCode)
                if httpResponse.statusCode != 200 {
                    print("❌ Server Error: \(httpResponse.statusCode)")
                    return
                }
            }

            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8) ?? "No response"
                print("📡 Raw API Response:", rawResponse)

                do {
                    let response = try JSONDecoder().decode([String: String].self, from: data)
                    DispatchQueue.main.async {
                        userBio = response["bio"] ?? "No Bio Set"
                        print("✅ Bio successfully updated in UI:", userBio)
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }
}

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?

    func fetchUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let url = URL(string: "http://34.44.204.172:8000/api/users/get-user-profile/\(userId)/")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching user profile:", error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(UserProfile.self, from: data)
                    DispatchQueue.main.async {
                        self.userProfile = decodedResponse
                        print("✅ User Profile Fetched:", decodedResponse)
                    }
                } catch {
                    print("❌ JSON Decoding Error:", error)
                }
            }
        }.resume()
    }
}

extension Color {
    static func customHex(_ hex: String) -> Color {
        let hexValue = Int(hex.dropFirst(), radix: 16) ?? 0
        let red = Double((hexValue >> 16) & 0xFF) / 255.0
        let green = Double((hexValue >> 8) & 0xFF) / 255.0
        let blue = Double(hexValue & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
}
