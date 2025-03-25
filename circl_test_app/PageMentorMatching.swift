import SwiftUI
import Foundation

struct PageMentorMatching: View {
    @State private var mentors: [MentorProfileData] = []
    @State private var userNetworkEmails: [String] = []
    @State private var declinedEmails: Set<String> = []
    @State private var showConfirmation = false
    @State private var selectedEmailToAdd: String? = nil
    @State private var selectedFullProfile: FullProfile? = nil
    @State private var showProfilePreview = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Circl.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Button(action: {}) {
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
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad"))
                }

                // Tabs
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

                // Feed
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(mentors, id: \.email) { mentor in
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
                                    title: "Mentor",
                                    company: mentor.company,
                                    proficiency: mentor.proficiency,
                                    tags: mentor.tags,
                                    profileImage: mentor.profileImage,
                                    onAccept: {
                                        selectedEmailToAdd = mentor.email
                                        showConfirmation = true
                                    },
                                    onDecline: {
                                        declinedEmails.insert(mentor.email)
                                        mentors.removeAll { $0.email == mentor.email }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
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
                        fetchMentors()
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

                // Footer
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

    func fetchMentors() {
        let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
        guard let url = URL(string: "http://34.44.204.172:8000/api/users/approved_mentors/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let data = data {
                if let mentorList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.mentors = mentorList.compactMap { mentor in
                            let email = mentor["email"] as? String ?? ""
                            guard email != currentUserEmail,
                                  !userNetworkEmails.contains(email),
                                  !declinedEmails.contains(email),
                                  let user_id = mentor["id"] as? Int else {
                                return nil
                            }

                            return MentorProfileData(
                                user_id: user_id,
                                name: "\(mentor["first_name"] ?? "") \(mentor["last_name"] ?? "")",
                                title: "Mentor",
                                company: mentor["industry_interest"] as? String ?? "Unknown Industry",
                                proficiency: mentor["main_usage"] as? String ?? "Unknown",
                                tags: mentor["tags"] as? [String] ?? [],
                                email: email,
                                profileImage: mentor["profileImage"] as? String
                            )
                        }
                    }
                }
            }
        }.resume()
    }

    func fetchUserNetwork(completion: @escaping () -> Void) {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "http://34.44.204.172:8000/api/users/get_network/\(userId)/") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let list = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.userNetworkEmails = list.compactMap { $0["email"] as? String }
                        completion()
                    }
                }
            }
        }.resume()
    }

    func addToNetwork(email: String) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "http://34.44.204.172:8000/api/users/send_friend_request/") else { return }

        let body: [String: Any] = ["user_id": senderId, "receiver_email": email]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                mentors.removeAll { $0.email == email }
                userNetworkEmails.append(email)
            }
        }.resume()
    }

    struct MentorProfileData {
        var user_id: Int
        var name: String
        var title: String
        var company: String
        var proficiency: String
        var tags: [String]
        var email: String
        var profileImage: String?
    }

    struct MentorProfileTemplate: View {
        var name: String
        var title: String
        var company: String
        var proficiency: String
        var tags: [String]
        var profileImage: String?
        var onAccept: () -> Void
        var onDecline: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
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
                        Text(name).font(.headline)
                        HStack(spacing: 5) {
                            Text(title).font(.subheadline)
                            Text("-")
                            Text(company).font(.subheadline).foregroundColor(.blue)
                        }
                        Text("Proficient in: \(proficiency)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
    
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "http://34.44.204.172:8000/api/users/profile/\(userId)/"
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
