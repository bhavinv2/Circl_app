import SwiftUI

// MARK: - SkillSellingProfileData Model
struct SkillSellingProfileData {
    var name: String
    var skill: String
    var price: String
    var availability: String
    var tags: [String]
    var profileImage: String
}

// MARK: - SkillSellingProfileTemplate
struct SkillSellingProfileTemplate: View {
    var name: String
    var skill: String
    var price: String
    var availability: String
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
                        Text("Selling: \(skill)")  // Updated to "Selling: [skill]"
                            .font(.subheadline)
                    }

                    Text("Available: \(availability)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Price line moved below Availability
                    Text("Price: \(price)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.top, 2) // Add a small padding for separation
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

// MARK: - SkillSellingProfileDetailPage (Skill Seller's Unique Profile Page)
struct SkillSellingProfileDetailPage: View {
    var name: String
    var skill: String
    var price: String
    var availability: String
    var tags: [String]
    var profileImage: String

    var body: some View {
        VStack {
            Image(profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .padding()

            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(skill)
                .font(.title2)
                .foregroundColor(.gray)

            Text("Price: \(price)")
                .font(.title2)
                .foregroundColor(.green)
                .padding(.bottom)

            Text("Available: \(availability)")
                .font(.body)
                .foregroundColor(.gray)

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
            .padding(.top, 20)

            Spacer()
        }
        .navigationBarTitle("Skill Selling Profile", displayMode: .inline)
        .padding()
    }
}

// MARK: - SkillSellingProfileLink (Tappable Profile)
struct SkillSellingProfileLink: View {
    var name: String
    var skill: String
    var price: String
    var availability: String
    var tags: [String]
    var profileImage: String

    var body: some View {
        NavigationLink(destination: SkillSellingProfileDetailPage(
            name: name,
            skill: skill,
            price: price,
            availability: availability,
            tags: tags,
            profileImage: profileImage
        )) {
            SkillSellingProfileTemplate(
                name: name,
                skill: skill,
                price: price,
                availability: availability,
                tags: tags,
                profileImage: profileImage
            )
        }
    }
}

// MARK: - Main View for Skill Selling Matching
struct PageSkillSellingMatching: View {
    var profiles: [SkillSellingProfileData] = [
        SkillSellingProfileData(name: "Jane Smith", skill: "Graphic Design", price: "$50/hr", availability: "Mon-Fri", tags: ["Design", "Illustration", "Creative"], profileImage: "sampleProfileImage1"),
        SkillSellingProfileData(name: "Mark Taylor", skill: "Web Development", price: "$75/hr", availability: "Weekends", tags: ["Frontend", "Backend", "HTML", "CSS"], profileImage: "sampleProfileImage2"),
        SkillSellingProfileData(name: "Emily Johnson", skill: "Content Writing", price: "$40/hr", availability: "Flexible", tags: ["Writing", "SEO", "Blogging"], profileImage: "sampleProfileImage3"),
        SkillSellingProfileData(name: "David Lee", skill: "SEO Expert", price: "$60/hr", availability: "Mon-Fri", tags: ["SEO", "Digital Marketing", "Google Analytics"], profileImage: "sampleProfileImage4"),
        SkillSellingProfileData(name: "Sophia Carter", skill: "Photography", price: "$80/hr", availability: "Evenings", tags: ["Photography", "Portraits", "Editing"], profileImage: "sampleProfileImage5")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
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
                            // Add the Bubble and Person icons above "Hello, Fragne"
                            VStack {
                                HStack(spacing: 10) {
                                    // Navigation Link for Bubble Symbol
                                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)  // Adjust size
                                            .foregroundColor(.white)
                                    }

                                    // Person Icon
                                    NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.white)
                                    }
                                }

                                // "Hello, Fragne" text below the icons
                                Text("Hello, Fragne")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad")) // Updated blue color
                }

                // Fixed Selection Buttons Section
                HStack(spacing: 10) {
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        Text("Entrepreneurs")
                            .font(.system(size: 12)) // Reduced font size
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray) // Changed to gray
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
                        Text("Mentors")
                            .font(.system(size: 12)) // Reduced font size
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray) // Changed to gray
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Skill Selling action (currently on the same page)
                    }) {
                        Text("Skill Selling")
                            .font(.system(size: 12)) // Reduced font size
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow) // Changed to yellow
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                // Scrollable Section
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(profiles, id: \.name) { profile in
                            SkillSellingProfileLink(
                                name: profile.name,
                                skill: profile.skill,
                                price: profile.price,
                                availability: profile.availability,
                                tags: profile.tags,
                                profileImage: profile.profileImage
                            )
                        }
                    }
                    .padding()
                }

                // Footer Section with Navigation
                HStack(spacing: 15) {
                    // NavigationLink for "Hand Raised" icon
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
                    }

                    // NavigationLink for "Briefcase" icon
                    NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "briefcase.fill")
                    }

                    // NavigationLink for "Person 3" icon
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "captions.bubble.fill")
                    }

                    // NavigationLink for "Person 2" icon
                    NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {  // Adjust the destination as needed
                        CustomCircleButton(iconName: "building.columns.fill")
                    }

                    // NavigationLink for "Book" icon
                    NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {  // Adjust the destination as needed
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
}

// MARK: - CustomCircleButton
struct CustomCircleButton4: View {
    let iconName: String

    var body: some View {
        Button(action: {
            // Action for button
        }) {
            ZStack {
                Circle()
                    .fill(Color.fromHex4("004aad"))
                    .frame(width: 60, height: 60)
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    static func fromHex4(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Preview
struct PageSkillSellingMatching_Previews: PreviewProvider {
    static var previews: some View {
        PageSkillSellingMatching()
    }
}
