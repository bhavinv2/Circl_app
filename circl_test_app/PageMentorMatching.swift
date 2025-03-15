import SwiftUI

// MARK: - Main View for Mentor Matching
struct PageMentorMatching: View {
    @State private var mentors: [MentorProfileData] = []

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

                                Text("Hello, Fragne")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad"))
                }

                // Fixed Selection Buttons Section
                HStack(spacing: 10) {
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        Text("Entrepreneurs")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                        Text("Mentors")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
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
                        ForEach(mentors, id: \.email) { mentor in
                            MentorProfileLink(
                                name: mentor.name,
                                title: "Mentor",
                                company: mentor.company,
                                proficiency: "Sharing Knowledge",
                                tags: ["Mentorship", "Business", "Networking"],
                                profileImage: "sampleProfileImage"
                            )
                        }
                    }
                    .padding()
                }
                .onAppear {
                    fetchMentors()
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

    // ✅ Fetch Mentors API Call
    func fetchMentors() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get-mentors/") else { return }

        print("🚀 Fetching Mentors from API...") // Debug Log

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization token if available
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("📡 Response from Backend: \(jsonResponse)") // Debug Log

                    if let mentorList = jsonResponse["mentors"] as? [[String: Any]] {
                        DispatchQueue.main.async {
                            // Map all mentors directly without filtering
                            self.mentors = mentorList.map { mentor in
                                MentorProfileData(
                                    name: "\(mentor["first_name"] ?? "") \(mentor["last_name"] ?? "")",
                                    title: "Mentor",
                                    company: mentor["industry_interest"] as? String ?? "Unknown Industry",
                                    proficiency: "Sharing Knowledge",
                                    tags: ["Mentorship", "Business", "Networking"],
                                    profileImage: "sampleProfileImage",
                                    email: mentor["email"] as? String ?? ""
                                )
                            }
                            print("✅ Mentors Loaded: \(self.mentors.count) mentors") // Debug Log
                        }
                    } else {
                        print("❌ API response missing 'mentors' key")
                    }
                } else {
                    print("❌ Failed to parse JSON response")
                }
            }
        }.resume()
    }
}

// MARK: - MentorProfileData Model
struct MentorProfileData {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    var email: String
}

struct MentorProfileLink: View {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(profileImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text("\(title) at \(company)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(proficiency)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()

            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(5)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            .padding(.leading)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct PageMentorMatching_Previews: PreviewProvider {
    static var previews: some View {
        PageMentorMatching()
    }
}
