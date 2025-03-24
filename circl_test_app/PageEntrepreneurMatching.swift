import SwiftUI

// MARK: - Main View for Entrepreneur Matching
struct PageEntrepreneurMatching: View {
    @State private var entrepreneurs: [EntrepreneurProfileData] = []

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

//                                Text("Hello, Fragne")
//                                    .foregroundColor(.white)
//                                    .font(.headline)
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
                                proficiency: "Networking",
                                tags: ["Business Growth", "Startups", "Investing"],
                                profileImage: "sampleProfileImage"
                            )
                        }
                    }
                    .padding()
                }
                .onAppear {
                    fetchEntrepreneurs()
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

    // ✅ Fetch Entrepreneurs API Call
    func fetchEntrepreneurs() {
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
                            self.entrepreneurs = entrepreneurList.compactMap { entrepreneur in
                                EntrepreneurProfileData(
                                    name: "\(entrepreneur["first_name"] ?? "") \(entrepreneur["last_name"] ?? "")",
                                    title: "Entrepreneur",
                                    company: entrepreneur["industry_interest"] as? String ?? "Unknown Industry",
                                    proficiency: entrepreneur["main_usage"] as? String ?? "Unknown",
                                    tags: entrepreneur["tags"] as? [String] ?? [],
                                    email: entrepreneur["email"] as? String ?? "",
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
                    Button(action: {
                        // Accept action
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.green)
                    }

                    Button(action: {
                        // Decline action
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
