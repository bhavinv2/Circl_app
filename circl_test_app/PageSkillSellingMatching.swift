import SwiftUI

struct PageSkillSellingMatching: View {
    @State private var showMenu = false // State for showing/hiding the hammer menu
    @State private var rotationAngle: Double = 0

    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                    Text("Circl.")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }

                                
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
                                    
                                   
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                        .background(Color(hexCode: "004aad"))
                    }
                    
                    // Scrollable Section
                    ScrollView {
                        VStack(spacing: 20) {
                            // Hammer Symbol above the text
                            Image(systemName: "hammer.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(hexCode: "004aad"))
                            
                            // Text below the hammer symbol
                            Text("We are currently working on creating our \"Marketplace\" feature - an opportunity for you to choose to monetize your skills. Sell anything from your sales expertise to web development to getting a project from a local business to add to your resume. We are very excited to release this feature for you to find a new way to generate revenue from our platform!")
                                .font(.body)
                                .foregroundColor(Color(hexCode: "004aad"))
                                .padding()
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(10)
                                .padding(.top)
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .navigationBarHidden(true)
                
                // Hammer Menu (replaces footer)
                ZStack(alignment: .bottomTrailing) {
                    if showMenu {
                        // Tap-to-dismiss background
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showMenu = false
                                }
                            }
                            .zIndex(0)
                    }

                    VStack(alignment: .trailing, spacing: 8) {
                        if showMenu {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Welcome to your resources")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray5))

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
                                NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                    MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
                                }

                                Divider()

                                NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true))
 {
                                    MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .frame(width: 250)
                            .transition(.scale.combined(with: .opacity))
                        }

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showMenu.toggle()
                                rotationAngle += 360 // spin the logo
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hexCode: "004aad"))
                                    .frame(width: 60, height: 60)

                                Image("CirclLogoButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .rotationEffect(.degrees(rotationAngle))
                            }
                        }
                        .shadow(radius: 4)
                        .padding(.bottom, 5)

                    }
                    .padding(.trailing, 20)
                    .zIndex(1)
                }

            }
        }
    }
}

// MARK: - Menu Item Component
struct MenuItem14: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hexCode: "004aad"))
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

// MARK: - Color Extension removed (using ColorExtensions.swift instead)

// MARK: - Preview
#Preview {
    PageSkillSellingMatching()
}


//import SwiftUI
//
//// MARK: - SkillSellingProfileData Model
//struct SkillSellingProfileData {
//    var name: String
//    var skill: String
//    var price: String
//    var availability: String
//    var tags: [String]
//    var profileImage: String
//}
//
//// MARK: - SkillSellingProfileTemplate
//struct SkillSellingProfileTemplate: View {
//    var name: String
//    var skill: String
//    var price: String
//    var availability: String
//    var tags: [String]
//    var profileImage: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack(alignment: .top) {
//                // Profile Image
//                Image(profileImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 60)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(name)
//                        .font(.headline)
//
//                    HStack(spacing: 5) {
//                        Text("Selling: \(skill)")  // Updated to "Selling: [skill]"
//                            .font(.subheadline)
//                    }
//
//                    Text("Available: \(availability)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//
//                    // Price line moved below Availability
//                    Text("Price: \(price)")
//                        .font(.subheadline)
//                        .foregroundColor(.green)
//                        .padding(.top, 2) // Add a small padding for separation
//                }
//
//                Spacer()
//
//                HStack(spacing: 10) {
//                    Button(action: {
//                        // Accept action
//                    }) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .frame(width: 45, height: 45)
//                            .foregroundColor(.green)
//                    }
//
//                    Button(action: {
//                        // Decline action
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .resizable()
//                            .frame(width: 45, height: 45)
//                            .foregroundColor(.red)
//                    }
//                }
//            }
//
//            // Tags Section
//            HStack(spacing: 10) {
//                ForEach(tags, id: \.self) { tag in
//                    Text(tag)
//                        .font(.caption)
//                        .padding(8)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(10)
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 2)
//    }
//}
//
//// MARK: - SkillSellingProfileDetailPage (Skill Seller's Unique Profile Page)
//struct SkillSellingProfileDetailPage: View {
//    var name: String
//    var skill: String
//    var price: String
//    var availability: String
//    var tags: [String]
//    var profileImage: String
//
//    var body: some View {
//        VStack {
//            Image(profileImage)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 120, height: 120)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
//                .padding()
//
//            Text(name)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//
//            Text(skill)
//                .font(.title2)
//                .foregroundColor(.gray)
//
//            Text("Price: \(price)")
//                .font(.title2)
//                .foregroundColor(.green)
//                .padding(.bottom)
//
//            Text("Available: \(availability)")
//                .font(.body)
//                .foregroundColor(.gray)
//
//            // Tags Section
//            HStack(spacing: 10) {
//                ForEach(tags, id: \.self) { tag in
//                    Text(tag)
//                        .font(.caption)
//                        .padding(8)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(10)
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding(.top, 20)
//
//            Spacer()
//        }
//        .navigationBarTitle("Skill Selling Profile", displayMode: .inline)
//        .padding()
//    }
//}
//
//// MARK: - SkillSellingProfileLink (Tappable Profile)
//struct SkillSellingProfileLink: View {
//    var name: String
//    var skill: String
//    var price: String
//    var availability: String
//    var tags: [String]
//    var profileImage: String
//
//    var body: some View {
//        NavigationLink(destination: SkillSellingProfileDetailPage(
//            name: name,
//            skill: skill,
//            price: price,
//            availability: availability,
//            tags: tags,
//            profileImage: profileImage
//        )) {
//            SkillSellingProfileTemplate(
//                name: name,
//                skill: skill,
//                price: price,
//                availability: availability,
//                tags: tags,
//                profileImage: profileImage
//            )
//        }
//    }
//}
//
//// MARK: - Main View for Skill Selling Matching
//struct PageSkillSellingMatching: View {
//    @State private var showMenu = false // State for hammer menu
//
//    var profiles: [SkillSellingProfileData] = [
//        SkillSellingProfileData(name: "Jane Smith", skill: "Graphic Design", price: "$50/hr", availability: "Mon-Fri", tags: ["Design", "Illustration", "Creative"], profileImage: "sampleProfileImage1"),
//        SkillSellingProfileData(name: "Mark Taylor", skill: "Web Development", price: "$75/hr", availability: "Weekends", tags: ["Frontend", "Backend", "HTML", "CSS"], profileImage: "sampleProfileImage2"),
//        SkillSellingProfileData(name: "Emily Johnson", skill: "Content Writing", price: "$40/hr", availability: "Flexible", tags: ["Writing", "SEO", "Blogging"], profileImage: "sampleProfileImage3"),
//        SkillSellingProfileData(name: "David Lee", skill: "SEO Expert", price: "$60/hr", availability: "Mon-Fri", tags: ["SEO", "Digital Marketing", "Google Analytics"], profileImage: "sampleProfileImage4"),
//        SkillSellingProfileData(name: "Sophia Carter", skill: "Photography", price: "$80/hr", availability: "Evenings", tags: ["Photography", "Portraits", "Editing"], profileImage: "sampleProfileImage5")
//    ]
//
//    var body: some View {
//        NavigationView {
//            ZStack(alignment: .bottomTrailing) {
//                VStack(spacing: 0) {
//                    // Header Section
//                    VStack(spacing: 0) {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 5) {
//                                Text("Circl.")
//                                    .font(.largeTitle)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.white)
//
//                                Button(action: {
//                                    // Action for Filter
//                                }) {
//                                    HStack {
//                                        Image(systemName: "slider.horizontal.3")
//                                            .foregroundColor(.white)
//                                        Text("Filter")
//                                            .font(.headline)
//                                            .foregroundColor(.white)
//                                    }
//                                }
//                            }
//
//                            Spacer()
//
//                            VStack(alignment: .trailing, spacing: 5) {
//                                VStack {
//                                    HStack(spacing: 10) {
//                                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
//                                            Image(systemName: "bubble.left.and.bubble.right.fill")
//                                                .resizable()
//                                                .frame(width: 50, height: 40)
//                                                .foregroundColor(.white)
//                                        }
//
//                                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
//                                            Image(systemName: "person.circle.fill")
//                                                .resizable()
//                                                .frame(width: 50, height: 50)
//                                                .foregroundColor(.white)
//                                        }
//                                    }
//
//                                    Text("Hello, Fragne")
//                                        .foregroundColor(.white)
//                                        .font(.headline)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 15)
//                        .padding(.bottom, 10)
//                        .background(Color.fromHex("004aad"))
//                    }
//
//                    // Improved Horizontal Scrollable Selection Buttons
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 15) {
//                            // Entrepreneurs Button (Active)
//                            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
//                                Text("Entrepreneurs")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .padding(.horizontal, 20)
//                                    .padding(.vertical, 10)
//                                    .background(Color(.systemGray5))
//                                    .foregroundColor(.black)
//                                    .cornerRadius(20)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//
//                            // Mentors Button
//                            NavigationLink(destination: PageMentorMatching().navigationBarBackButtonHidden(true)) {
//                                Text("Mentors")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .padding(.horizontal, 20)
//                                    .padding(.vertical, 10)
//                                    .background(Color(.systemGray5))
//                                    .foregroundColor(.primary)
//                                    .cornerRadius(20)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//
//                            // Investors Button
//                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
//                                Text("Investors")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .padding(.horizontal, 20)
//                                    .padding(.vertical, 10)
//                                    .background(Color.fromHex("ffde59"))
//                                    .foregroundColor(.primary)
//                                    .cornerRadius(20)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                        .padding(.horizontal)
//                    }
//                    .padding(.vertical, 10)
//
//                    // Scrollable Section
//                    ScrollView {
//                        VStack(spacing: 20) {
//                            ForEach(profiles, id: \.name) { profile in
//                                SkillSellingProfileLink(
//                                    name: profile.name,
//                                    skill: profile.skill,
//                                    price: profile.price,
//                                    availability: profile.availability,
//                                    tags: profile.tags,
//                                    profileImage: profile.profileImage
//                                )
//                            }
//                        }
//                        .padding()
//                    }
//                }
//                .navigationBarHidden(true)
//
//                // Hammer Menu (replaces footer)
//                VStack(alignment: .trailing, spacing: 8) {
//                    if showMenu {
//                        VStack(alignment: .leading, spacing: 0) {
//                            // Menu Header
//                            Text("Welcome to your resources")
//                                .font(.headline)
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color(.systemGray5))
//
//                            // Menu Items with Navigation
//                            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "person.2.fill", title: "Connect and Network")
//                            }
//
//                            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
//                            }
//
//                            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
//                            }
//
//                            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "briefcase.fill", title: "Professional Services")
//                            }
//
//                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "envelope.fill", title: "Messages")
//                            }
//
//                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
//                            }
//
//                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
//                            }
//
//                            Divider()
//
//                            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
//                            }
//                        }
//                        .background(Color(.systemGray6))
//                        .cornerRadius(12)
//                        .shadow(radius: 5)
//                        .frame(width: 250)
//                        .transition(.scale.combined(with: .opacity))
//                    }
//
//                    // Main floating button
//                    Button(action: {
//                        withAnimation(.spring()) {
//                            showMenu.toggle()
//                        }
//                    }) {
//                        Image(systemName: "hammer.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(.white)
//                            .padding(16)
//                            .background(Color.fromHex("004aad"))
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                }
//                .padding()
//            }
//            .edgesIgnoringSafeArea(.bottom)
//            .navigationBarBackButtonHidden(true)
//        }
//    }
//}
//
//// MARK: - Menu Item Component
//struct MenuItem14: View {
//    let icon: String
//    let title: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(Color.fromHex("004aad"))
//                .frame(width: 24)
//            Text(title)
//                .foregroundColor(.primary)
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 12)
//        .contentShape(Rectangle())
//    }
//}
//
//// MARK: - Color Extension
//extension Color {
//    static func fromHex4(_ hex: String) -> Color {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
//
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//
//        let red = Double((rgb >> 16) & 0xFF) / 255.0
//        let green = Double((rgb >> 8) & 0xFF) / 255.0
//        let blue = Double(rgb & 0xFF) / 255.0
//
//        return Color(red: red, green: green, blue: blue)
//    }
//}
//
//// MARK: - Preview
//struct PageSkillSellingMatching_Previews: PreviewProvider {
//    static var previews: some View {
//        PageSkillSellingMatching()
//    }
//}
