import SwiftUI

// MARK: - InviteProfileTemplate
struct InviteProfileTemplate: View {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    var showAcceptDeclineButtons: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
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
                        Text(title)
                            .font(.subheadline)
                        Text("-")
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }

                    Text("Proficient in: \(proficiency)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                if showAcceptDeclineButtons {
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

// MARK: - InviteProfileDetailPage
struct InviteProfileDetailPage: View {
    var name: String
    var title: String
    var company: String
    var proficiency: String
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

            Text(title)
                .font(.title2)
                .foregroundColor(.gray)

            Text(company)
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.bottom)

            Text("Proficient in: \(proficiency)")
                .font(.body)
                .foregroundColor(.gray)

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
        .navigationBarTitle("Profile", displayMode: .inline)
        .padding()
    }
}

// MARK: - InviteProfileLink
struct InviteProfileLink: View {
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    var showAcceptDeclineButtons: Bool = true

    var body: some View {
        NavigationLink(destination: InviteProfileDetailPage(
            name: name,
            title: title,
            company: company,
            proficiency: proficiency,
            tags: tags,
            profileImage: profileImage
        )) {
            InviteProfileTemplate(
                name: name,
                title: title,
                company: company,
                proficiency: proficiency,
                tags: tags,
                profileImage: profileImage,
                showAcceptDeclineButtons: showAcceptDeclineButtons
            )
        }
    }
}

// MARK: - PageInvites
struct PageInvites: View {
    @State private var showMenu = false // State for hammer menu
    
    var friendRequests: [InviteProfileData] = [
        InviteProfileData(name: "John Doe", title: "Software Engineer", company: "TechCorp", proficiency: "iOS Development", tags: ["iOS", "Swift", "App Development"], profileImage: "sampleProfileImage"),
        InviteProfileData(name: "Jane Smith", title: "Product Manager", company: "InnoTech", proficiency: "Product Strategy", tags: ["Product", "Strategy", "Management"], profileImage: "sampleProfileImage")
    ]
    
    var myNetwork: [InviteProfileData] = [
        InviteProfileData(name: "Sam Johnston", title: "VP of Sales", company: "Dell", proficiency: "Sales", tags: ["Technology", "Real Estate", "Online Sales"], profileImage: "sampleProfileImage"),
        InviteProfileData(name: "Emily Adams", title: "CTO", company: "TechNova", proficiency: "Software Engineering", tags: ["AI", "Software", "Innovation"], profileImage: "sampleProfileImage"),
        InviteProfileData(name: "Michael Lee", title: "Founder", company: "GreenTech", proficiency: "Sustainability", tags: ["Green Energy", "Innovation", "Tech Startups"], profileImage: "sampleProfileImage"),
        InviteProfileData(name: "Sarah Kline", title: "Product Manager", company: "HealthPlus", proficiency: "Product Development", tags: ["Healthcare", "Product Design", "Tech"], profileImage: "sampleProfileImage"),
        InviteProfileData(name: "David Wilson", title: "Marketing Director", company: "EcoSolutions", proficiency: "Digital Marketing", tags: ["Marketing", "E-commerce", "Branding"], profileImage: "sampleProfileImage")
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
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
                    
                    HStack(spacing: 10) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            Text("Messages")
                                .font(.system(size: 12))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }

                        NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                            Text("Circles")
                                .font(.system(size: 12))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }

                        NavigationLink(destination: PageInvites().navigationBarBackButtonHidden(true)) {
                            Text("Friends")
                                .font(.system(size: 12))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.fromHex("ffde59"))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Networking Request")
                                .font(.headline)
                                .padding(.top)
                            
                            ForEach(friendRequests) { profile in
                                InviteProfileLink(
                                    name: profile.name,
                                    title: profile.title,
                                    company: profile.company,
                                    proficiency: profile.proficiency,
                                    tags: profile.tags,
                                    profileImage: profile.profileImage,
                                    showAcceptDeclineButtons: true
                                )
                            }
                            
                            Divider().padding(.vertical)
                            
                            Text("My Network")
                                .font(.headline)
                                .padding(.top)
                            
                            ForEach(myNetwork) { profile in
                                InviteProfileLink(
                                    name: profile.name,
                                    title: profile.title,
                                    company: profile.company,
                                    proficiency: profile.proficiency,
                                    tags: profile.tags,
                                    profileImage: profile.profileImage,
                                    showAcceptDeclineButtons: false
                                )
                            }
                        }
                        .padding()
                    }
                }
                .navigationBarHidden(true)
                
                // Hammer Menu (replaces footer)
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            // Menu Header
                            Text("Welcome to your resources")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                            
                            // Menu Items with Navigation
                            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "person.2.fill", title: "Connect and Network")
                            }
                            
                            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
                            }
                            
                            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
                            }
                            
                            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "briefcase.fill", title: "Professional Services")
                            }
                            
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "envelope.fill", title: "Messages")
                            }
                            
                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                            }
                            
                            Divider()
                            
                            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 250)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Main floating button
                    Button(action: {
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "hammer.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.fromHex("004aad"))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Menu Item Component
struct MenuItem9: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.fromHex("004aad"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Color Extension
extension Color {
    static func fromHex15(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

// Sample Profile Data Model
struct InviteProfileData: Identifiable {
    var id = UUID()
    var name: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
}

// MARK: - Preview
struct PageInvites_Previews: PreviewProvider {
    static var previews: some View {
        PageInvites()
    }
}
