import SwiftUI
// Copy this from PageCircleMessages.swift
struct Member: Identifiable, Decodable, Hashable {
    let id: Int
    let full_name: String
    let profile_image: String?
    let user_id: Int
    let is_moderator: Bool
}

struct MemberListPage: View {
    let circleName: String
    let circleId: Int
    @AppStorage("user_id") private var userId: Int = 0
    let isModerator: Bool // 👈 passed in from parent view

    @State private var members: [Member] = []
    @State private var selectedMember: Member? = nil

    var body: some View {
        VStack(spacing: 16) {
          

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(members) { member in
                        Button(action: {
                            selectedMember = member
                        }) {
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: member.profile_image ?? "")) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                                HStack(spacing: 4) {
                                    Text(member.full_name)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    if member.is_moderator {
                                        Text("Admin")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }


                                Spacer()

                                // 🔴 Show remove button ONLY if user is moderator and not self
                                if isModerator && member.user_id != userId {
                                    Menu {
                                        Button(role: .destructive) {
                                            removeUserFromCircle(member.user_id)
                                        } label: {
                                            Label("Remove User", systemImage: "trash")
                                        }
                                        Button {
                                            makeUserModerator(member.user_id)
                                        } label: {
                                            Label("Make Moderator", systemImage: "star.fill")
                                        }

                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 18, weight: .semibold))
                                            .padding(6)
                                            .contentShape(Rectangle()) // better tap area
                                    }
                                }

                            }

                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedMember) { member in
            DynamicProfilePreview(
                profileData: convertToFullProfile(from: member),
                isInNetwork: true
            )
        }
        .onAppear {
            fetchMembers()
        }
    }
    func makeUserModerator(_ memberUserId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/make_moderator/") else { return }

        let body: [String: Any] = [
            "user_id": memberUserId,
            "circle_id": circleId,
            "requesting_user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error making moderator:", error.localizedDescription)
                return
            }

            print("✅ Made user \(memberUserId) a moderator")
            // Optional: refresh members or show toast
        }.resume()
    }

    func convertToFullProfile(from member: Member) -> FullProfile {
        return FullProfile(
            user_id: member.user_id,
            profile_image: member.profile_image,
            first_name: member.full_name,
            last_name: "",
            email: "",
            main_usage: "",
            industry_interest: "",
            title: "",
            bio: nil,
            birthday: nil,
            education_level: nil,
            institution_attended: nil,
            certificates: nil,
            years_of_experience: nil,
            personality_type: nil,
            locations: nil,
            achievements: [],
            skillsets: nil,
            availability: "",
            clubs: nil,
            hobbies: nil,
            connections_count: 0,
            circs: 0,
            entrepreneurial_history: nil
        )
    }

    func removeUserFromCircle(_ memberUserId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/remove_user/") else { return }

        let body: [String: Any] = [
            "user_id": memberUserId,
            "circle_id": circleId,
            "requesting_user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("❌ Error removing user:", error!.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                // Immediately remove from UI
                members.removeAll { $0.user_id == memberUserId }
            }
        }.resume()
    }

    func fetchMembers() {
        guard let url = URL(string: "https://circlapp.online/api/circles/members/\(circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch members:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                DispatchQueue.main.async {
                    self.members = decoded.sorted { $0.is_moderator && !$1.is_moderator }

                }
            } catch {
                print("❌ Failed to decode members:", error)
            }
        }.resume()
    }
}
