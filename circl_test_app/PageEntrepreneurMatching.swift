import SwiftUI

// MARK: - Main View for Entrepreneur Matching
struct PageEntrepreneurMatching: View {
    @State private var entrepreneurs: [EntrepreneurProfileData] = []
    @State private var userNetworkEmails: [String] = [] // ✅ STEP 1: Added state for network emails
    @State private var declinedEmails: Set<String> = [] // ✅ STEP 1: Added state for declined emails
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Circl.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Button(action: {
                                // Action for Filter
                            }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.white)
                                    Text("Filter")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 5) {
                            VStack {
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
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad"))
                }

                // Selection Buttons Section
                HStack(spacing: 10) {
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        Text("Entrepreneurs")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                        Text("Mentors")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                        Text("Skill Selling")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                // Scrollable Section
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(entrepreneurs, id: \.email) { entrepreneur in
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

                                onDecline: { // ✅ STEP 4: Added onDecline callback
                                    declinedEmails.insert(entrepreneur.email)
                                    entrepreneurs.removeAll { $0.email == entrepreneur.email }
                                }
                            )
                        }
                    }
                    .padding()
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

                }
                .onAppear {
                    fetchUserNetwork {
                        fetchEntrepreneurs()
                    }
                }


                // Footer Section with Navigation
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
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }



    // ✅ Fetch Entrepreneurs API Call with Filtering (STEP 3)
    func fetchEntrepreneurs() {
        let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
        print("🔍 Stored user_email in UserDefaults:", currentUserEmail)

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get-entrepreneurs/") else { return }
        
        print("🚀 Fetching Entrepreneurs from API...") // Debug Log

        URLSession.shared.dataTask(with: url) { data, response, error in
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


                                return EntrepreneurProfileData(
                                    name: "\(entrepreneur["first_name"] ?? "") \(entrepreneur["last_name"] ?? "")",
                                    title: "Entrepreneur",
                                    company: entrepreneur["industry_interest"] as? String ?? "Unknown Industry",
                                    proficiency: entrepreneur["main_usage"] as? String ?? "Unknown",
                                    tags: entrepreneur["tags"] as? [String] ?? [],
                                    email: email,
                                    profileImage: "sampleProfileImage"
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
              let url = URL(string: "http://34.44.204.172:8000/api/users/get_network/\(userId)/") else {
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






    // ✅ STEP 6: Add to Network Function
    func addToNetwork(email: String) {
        guard let url = URL(string: "http://34.44.204.172:8000/api/users/add-to-network/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error adding to network: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                entrepreneurs.removeAll { $0.email == email }
                userNetworkEmails.append(email)
            }
        }.resume()
    }
}

// MARK: - EntrepreneurProfileData Model
struct EntrepreneurProfileData {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var email: String
    var profileImage: String
}

// MARK: - EntrepreneurProfileTemplate
struct EntrepreneurProfileTemplate: View {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    var onAccept: () -> Void // ✅ STEP 5: Added onAccept
    var onDecline: () -> Void // ✅ STEP 5: Added onDecline

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                // Profile Image
                Image(profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))

                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.headline)

                    HStack(spacing: 5) {
                        Text(title)
                            .font(.subheadline)
                        Text("-")
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }

                    Text("Proficient in: \(proficiency)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 10) {
                    Button(action: { // ✅ STEP 5: Updated to use onAccept
                        onAccept()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.green)
                    }

                    Button(action: { // ✅ STEP 5: Updated to use onDecline
                        onDecline()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.red)
                    }
                }
            }

            // Tags Section
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
    }
}


// MARK: - Preview
struct PageEntrepreneurMatching_Previews: PreviewProvider {
    static var previews: some View {
        PageEntrepreneurMatching()
    }
}
