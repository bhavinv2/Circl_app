import SwiftUI

struct DynamicProfilePreview: View {
    var profileData: FullProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top section with blue background
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.customHex("004aad"))
                        .frame(height: 300)

                    VStack(spacing: 15) {
                        AsyncImage(url: URL(string: profileData.profile_image ?? "")) { image in
                            image.resizable()
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
                                Text("\(profileData.connections_count)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.white)
                            }
                            
                            VStack {
                                Text("Circles:")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.customHex("#ffde59"))
                                Text("0") // Placeholder
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.white)
                            }

                            VStack {
                                Text("Circs:")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.customHex("#ffde59"))
                                Text("0") // Placeholder
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.white)
                            }
                        }

                        VStack(spacing: 5) {
                            Text(profileData.full_name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            Text(profileData.title ?? "")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Text(profileData.personality_type ?? "")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Bio Section
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.customHex("004aad"))
                        .frame(height: 150)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Bio")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(profileData.bio ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                    }
                    .padding()
                }

                // About Section
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.customHex("004aad"))
                        .frame(height: 400)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("About \(profileData.full_name)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        if let age = calculateAge(from: profileData.birthday ?? "") {
                            Text("Age: \(age)")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }

                        Text("Education Level: \(profileData.education_level ?? "")")
                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Institution: \(profileData.institution_attended ?? "")")
                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Certificates: \(profileData.certificates?.joined(separator: ", ") ?? "N/A")")

                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Experience: \(profileData.years_of_experience.map { "\($0) years" } ?? "N/A")")
                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Location: \(profileData.location ?? "")")
                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Achievements: \(profileData.achievements?.joined(separator: ", ") ?? "N/A")")

                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding()
                }

                // Technical Side Section
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.customHex("004aad"))
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Technical Side")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("Skills: \(profileData.skillsets?.joined(separator: ", ") ?? "N/A")")

                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Availability: \(profileData.availability ?? "N/A")")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding()
                }

                // Interests Section
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.customHex("004aad"))
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Interests")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("Clubs: \(profileData.clubs?.joined(separator: ", ") ?? "N/A")")

                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text("Hobbies: \(profileData.hobbies?.joined(separator: ", ") ?? "N/A")")

                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGray5))
    }

    func calculateAge(from birthday: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: birthday) else { return nil }
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
}

