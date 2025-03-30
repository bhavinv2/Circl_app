import SwiftUI
import Foundation

struct DynamicProfilePreview: View {
    var profileData: FullProfile
    let isInNetwork: Bool
    
    @State private var showRemoveFriendConfirmation = false
    @Environment(\.dismiss) var dismiss

    let loggedInUserId = UserDefaults.standard.integer(forKey: "user_id")
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            VStack(spacing: 0) {
                ScrollView {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 24, height: 14)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }

                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .padding(.top, -30)

                            
                            if loggedInUserId != profileData.user_id && isInNetwork {

                                VStack {
                                    HStack {
                                        Spacer()
                                        Menu {
                                            Button(role: .destructive) {
                                                showRemoveFriendConfirmation = true
                                            } label: {
                                                Label("Remove user", systemImage: "person.fill.xmark")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top, 8)
                                        .padding(.trailing, 8)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)


                                .confirmationDialog("Remove this user from your network?", isPresented: $showRemoveFriendConfirmation) {
                                    Button("Remove user", role: .destructive) {
                                        removeFriend()
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                            }


                            
                            VStack(spacing: 15) {
                                AsyncImage(url: URL(string: profileData.profile_image ?? "")) { image in
                                    image.resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .foregroundColor(.gray.opacity(0.3))
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                
                                HStack(spacing: 40) {
                                    VStack {
                                        Text("Connections:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("\(profileData.connections_count ?? 0)")
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
                                        Text("\(profileData.circs ?? 0)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }

                                }
                                
                                VStack(spacing: 5) {
                                    Text(profileData.full_name)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("@\(profileData.last_name)\(profileData.user_id)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)

//                                    Text("CEO - ")
//                                        .font(.system(size: 18, weight: .semibold))
//                                        .foregroundColor(.white)
//                                    + Text("Circl International")
//                                        .font(.system(size: 18, weight: .semibold))
//                                        .underline()
//                                        .foregroundColor(.white)
                                }

                            }
                        }
                     
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
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
                        
                        // Bio Section
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Bio")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Text(profileData.bio?.isEmpty == true ? "Bio not set." : (profileData.bio ?? "Bio not set."))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                if let type = profileData.personality_type, !type.isEmpty {
                                    Text("Personality Type: \(type)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding()
                        }

                        // About Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("About \(profileData.first_name) \(profileData.last_name)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                if let birthday = profileData.birthday {
                                    Text("Age: \(calculateAge(from: birthday))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                if let level = profileData.education_level {
                                    Text("Education Level: \(level)")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                if let institution = profileData.institution_attended {
                                    Text("Institution: \(institution)")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                if let locations = profileData.locations {
                                    Text("Location(s): \(locations.joined(separator: ", "))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                

                                if let type = profileData.personality_type {
                                    Text("Personality Type: \(type)")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .padding()
                        }

                        // Technical Side Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Technical Side")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                if let skills = profileData.skillsets {
                                    Text("Skills: \(skills.joined(separator: ", "))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                if let certs = profileData.certificates {
                                    Text("Certificates: \(certs.joined(separator: ", "))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                if let years = profileData.years_of_experience {
                                    Text("Experience: \(years) years")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                
                            }
                            .padding()
                        }

                        // Interests Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Interests")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                if let clubs = profileData.clubs {
                                    Text("Clubs: \(clubs.joined(separator: ", "))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }

                                if let hobbies = profileData.hobbies {
                                    Text("Hobbies: \(hobbies.joined(separator: ", "))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .padding()
                        }

                        // Entrepreneurial History Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Entrepreneurial History")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Text(profileData.entrepreneurial_history?.isEmpty == true ? "Enter work experience..." : (profileData.entrepreneurial_history ?? ""))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                        }

                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray4))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func calculateAge(from birthday: String) -> String {
        guard !birthday.isEmpty else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: birthday) else { return "N/A" }

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return "\(ageComponents.year ?? 0)"
    }
    
    func removeFriend() {
        print("🚨 removeFriend() called")
        print("🔥 Remove friend called with user_id=\(loggedInUserId), friend_id=\(profileData.user_id)")

        guard let url = URL(string: "https://circlapp.online/api/users/remove_friend/") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token set: Token \(token)")
        } else {
            print("⚠️ No auth token found")
        }

        let payload: [String: Any] = [
            "user_id": loggedInUserId,
            "friend_id": profileData.user_id
        ]

        print("📤 Payload: \(payload)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Error creating JSON payload: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            print("📡 Request completed — checking HTTP response")

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response object")
                return
            }

            print("✅ Status code: \(httpResponse.statusCode)")

            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode"
                print("📦 Response data: \(responseString)")
                
                // Handle the response based on status code
                DispatchQueue.main.async {
                    switch httpResponse.statusCode {
                    case 200:
                        print("✅ Friend removed successfully, closing sheet")
                        self.dismiss()
                    case 404:
                        print("❌ Friendship not found — no action taken")
                    default:
                        print("❌ Unexpected status code: \(httpResponse.statusCode)")
                    }
                }
            } else {
                print("⚠️ No data returned")
            }
        }.resume()
    }
}

