import SwiftUI
import Foundation

struct Member: Identifiable, Decodable, Hashable {
    let id: Int
    let full_name: String
    let profile_image: String?
    let user_id: Int
    let is_moderator: Bool
    let email: String          // ✅ new
    let has_paid: Bool         // ✅ new
}


struct MemberListPage: View {
    @EnvironmentObject var profilePreview: ProfilePreviewCoordinator

    let circleName: String
    let circleId: Int

    @State private var members: [Member] = []
//    @State private var selectedMember: Member? = nil
    @AppStorage("user_id") private var currentUserId: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Members in \(circleName)")
                .font(.title2)
                .bold()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(members) { member in
                        Button(action: {
//                            selectedMember = member
                            profilePreview.present(userId: member.user_id)
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

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.full_name)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    Text(member.has_paid ? "Paid ✅" : "Not Paid ❌")
                                        .font(.caption)
                                        .foregroundColor(member.has_paid ? .green : .red)

                                    Text(member.email)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }


                                Spacer()

                                if member.user_id != currentUserId && !member.is_moderator {
                                    Menu {
                                        Button("Make Moderator") {
                                            promoteToModerator(memberId: member.user_id)
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .rotationEffect(.degrees(90))
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.gray)
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
//        .sheet(item: $selectedMember) { member in
//            DynamicProfilePreview(
//                profileData: convertToFullProfile(from: member),
//                isInNetwork: true
//            )
//        }
        .onAppear {
            fetchMembers()
        }
    }
//    func convertToFullProfile(from member: Member) -> FullProfile {
//        return FullProfile(
//            user_id: member.user_id,
//            profile_image: member.profile_image,
//            first_name: member.full_name,
//            last_name: "",
//            email: member.email,
//
//            main_usage: "",
//            industry_interest: "",
//            title: "",
//            bio: nil,
//            birthday: nil,
//            education_level: nil,
//            institution_attended: nil,
//            certificates: nil,
//            years_of_experience: nil,
//            personality_type: nil,
//            locations: nil,
//            achievements: [],
//            skillsets: nil,
//            availability: "",
//            clubs: nil,
//            hobbies: nil,
//            connections_count: 0,
//            circs: 0,
//            entrepreneurial_history: nil
//        )
//    }
    func promoteToModerator(memberId: Int) {
        guard let url = URL(string: "\(baseURL)circles/make_moderator/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = [
            "user_id": memberId,
            "circle_id": circleId,
            "requesting_user_id": currentUserId
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error promoting moderator:", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                fetchMembers()
            }
        }.resume()
    }


    func fetchMembers() {
        guard let url = URL(string: "\(baseURL)circles/members/\(circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch members:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                DispatchQueue.main.async {
                    self.members = decoded
                }
            } catch {
                print("❌ Failed to decode members:", error)
            }
        }.resume()
    }
}
