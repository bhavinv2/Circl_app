import SwiftUI
// Copy this from PageCircleMessages.swift
struct Member: Identifiable, Decodable, Hashable {
    let id: Int
    let full_name: String
    let profile_image: String?
    let user_id: Int
}

struct MemberListPage: View {
    let circleName: String
    let circleId: Int

    @State private var members: [Member] = []
    @State private var selectedMember: Member? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("Members in \(circleName)")
                .font(.title2)
                .bold()

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

                                Text(member.full_name)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()
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
                    self.members = decoded
                }
            } catch {
                print("❌ Failed to decode members:", error)
            }
        }.resume()
    }
}
