import SwiftUI

struct UserProfile: Codable {
    let id: Int
    let name: String
    let age: Int
    let educationLevel: String
    let institutionAttended: String
    let certifications: String?
    let experienceYears: Int
    let location: String
    let achievements: String?
    let skills: String
    let projects: String?
    let availability: String
    let interests: String?
    let entrepreneurialHistory: String?
    let bio: String?
    let profilePictureURL: String?
}

struct UserProfilePage: View {
    @State private var isLoading = false
    @State private var userProfile: UserProfile?
    let userId: Int  // ID of the user whose profile is being viewed

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading profile...")
            } else if let userProfile = userProfile {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Picture
                        if let profilePictureURL = userProfile.profilePictureURL,
                           let url = URL(string: profilePictureURL) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        }

                        // User Info
                        Text(userProfile.name)
                            .font(.title)
                            .bold()
                        
                        Text("\(userProfile.educationLevel) at \(userProfile.institutionAttended)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(userProfile.bio ?? "No bio available")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()

                        // Additional Info
                        VStack(alignment: .leading, spacing: 10) {
                            infoRow(title: "Age", value: "\(userProfile.age)")
                            infoRow(title: "Certifications", value: userProfile.certifications ?? "None")
                            infoRow(title: "Experience", value: "\(userProfile.experienceYears) years")
                            infoRow(title: "Location", value: userProfile.location)
                            infoRow(title: "Skills", value: userProfile.skills)
                            infoRow(title: "Projects", value: userProfile.projects ?? "Not available")
                            infoRow(title: "Availability", value: userProfile.availability)
                            infoRow(title: "Interests", value: userProfile.interests ?? "Not provided")
                            infoRow(title: "Entrepreneurial History", value: userProfile.entrepreneurialHistory ?? "Not shared")
                            infoRow(title: "Achievements", value: userProfile.achievements ?? "None")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                        Spacer()
                    }
                    .padding()
                }
            } else {
                Text("Profile not found")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            fetchUserProfile(userId: userId)
        }
    }

    // MARK: - Helper Function for Displaying Info
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text("\(title):")
                .font(.headline)
                .foregroundColor(.blue)
            Text(value)
                .font(.body)
                .foregroundColor(.black)
        }
    }

    // MARK: - Fetch User Profile Data from Backend
    private func fetchUserProfile(userId: Int) {
        guard let url = URL(string: "http://34.136.164.254:8000/api/users/profile/\(userId)/") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    DispatchQueue.main.async {
                        self.userProfile = profile
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - Preview
struct UserProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        UserProfilePage(userId: 1)
    }
}
