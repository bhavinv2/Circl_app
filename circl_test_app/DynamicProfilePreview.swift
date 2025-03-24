import SwiftUI
import Foundation


struct DynamicProfilePreview: View {
    var profileData: FullProfile
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main Content (same as ProfilePage)
                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 300)
                            
                            VStack(spacing: 15) {
                                // Profile picture
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
                                        Text("0")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                }
                                
                                VStack(spacing: 5) {
                                    Text(profileData.full_name)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("CEO - ")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    + Text("Circl International")
                                        .font(.system(size: 18, weight: .semibold))
                                        .underline()
                                        .foregroundColor(.white)
                                    
                                    Text(profileData.personality_type ?? "")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        // Personal Secret Section
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
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 150)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Bio")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(profileData.bio ?? "N/A")
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
                                Text("About \(profileData.first_name) \(profileData.last_name)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Age: \(calculateAge(from: profileData.birthday ?? ""))")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Education Level: \(profileData.education_level ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Institution: \(profileData.institution_attended ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Certificates: \(profileData.certificates?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Experience: \(profileData.years_of_experience.map { "\($0) years" } ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Location: \(profileData.locations?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Achievements: \(profileData.achievements?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Technical Side Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 400)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Technical Side")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Skills: \(profileData.skillsets?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Projects/Work Completed: xxx")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Availability: \(profileData.availability ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Interests Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 300)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Interests")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Clubs: \(profileData.clubs?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Hobbies: \(profileData.hobbies?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Entrepreneurial History Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 150)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Entrepreneurial History")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("xxx")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
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
}
