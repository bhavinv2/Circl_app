import SwiftUI

// MARK: - Main View
struct UserProfilePage: View {
    // Placeholder Data
    @State private var userName: String = "Fragne"
    @State private var userProfileImage: String = "person.circle.fill"
    @State private var aboutText: String = "Write about the user here..."
    @State private var contactDetails: [String: String] = [
        "Email": "user@example.com",
        "Phone": "+1 123 456 7890",
        "Location": "San Francisco, CA"
    ]
    @State private var achievements: [String: String] = [
        "Milestones": "Successfully launched 3 apps",
        "Awards": "Best Startup Award 2024"
    ]
    @State private var skills: [String: String] = [
        "iOS Development": "Swift, UIKit, SwiftUI",
        "UI/UX Design": "Figma, Sketch"
    ]
    @State private var projects: [String: String] = [
        "Current Project": "Building a cross-platform app",
        "Previous Projects": "E-commerce, Fitness Tracking"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                scrollableSection
                footerSection
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side: "Circl." text
                Text("Circl.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()

                // Right side: Messages Icon
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .resizable()
                        .frame(width: 50, height: 40)
                        .foregroundColor(.white)
                }

                // Square and Pencil Icon for edit action
                Button(action: {
                    // Action for edit
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.white)
                        .font(.title)
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color(hex: "004aad")) // Blue background for the header
        }
    }



    // MARK: - Scrollable Section
    private var scrollableSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileSection
                personalSecretSection
                aboutSection
                entrepreneurialHistorySection
                achievementsSection
                skillsSection
                interestsSection
                mentorshipPreferencesSection
                referencesSection
                collaborationsSection
                valuesVisionMissionSection
                portfolioSection
                socialProofSection
                contactSection
            }
            .padding()
            .background(Color(.systemGray4))
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customHex("004aad"))
                    .frame(height: 300)

                VStack(spacing: 15) {
                    // Profile Image
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        )

                    // Stats section
                    HStack(spacing: 40) {
                        VStack {
                            Text("Connections:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.customHex("#ffde59"))
                            Text("123") // Placeholder for backend data
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                        }

                        VStack {
                            Text("Circles:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.customHex("#ffde59"))
                            Text("45") // Placeholder for backend data
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                        }

                        VStack {
                            Text("Circs:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.customHex("#ffde59"))
                            Text("980") // Placeholder for backend data
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                    }

                    // Profile name, role, and personality type
                    VStack(spacing: 5) {
                        Text("Fragne Delgado") // Placeholder for backend data
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text("CEO - ")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        + Text("Circl International") // Redirectable link
                            .font(.system(size: 18, weight: .semibold))
                            .underline()
                            .foregroundColor(.white)

                        Text("ENFJ - A") // Personality type placeholder
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 5) {
                AboutItem(title: "Age", value: "22") // Replace with dynamic data
                AboutItem(title: "Education Level", value: "Bachelor's Degree") // Replace with dynamic data
                AboutItem(title: "Institution Attended", value: "University of XYZ") // Replace with dynamic data
                AboutItem(title: "Certifications/Licenses", value: "Certified Professional Developer") // Replace with dynamic data
                AboutItem(title: "Years of Experience", value: "5") // Replace with dynamic data
                AboutItem(title: "Location", value: "New York, USA") // Replace with dynamic data
                AboutItem(title: "Achievements", value: "Employee of the Year, 2024") // Replace with dynamic data
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    struct AboutItem: View {
        var title: String
        var value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(width: 160, alignment: .leading)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
            }
        }
    }
    
    // MARK: - Entrepreneurial History Section
    private var entrepreneurialHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Entrepreneurial History")
                .font(.headline)
                .foregroundColor(.black)
            
            Text(entrepreneurialHistoryText)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    // Placeholder data for Entrepreneurial History
    private var entrepreneurialHistoryText: String {
        return """
        In 2010, I co-founded my first startup, TechWave Solutions, a software development company focused on creating web apps for small businesses. Within three years, TechWave had grown significantly, securing contracts with Fortune 500 companies and revolutionizing the way these businesses interacted with customers through digital platforms.

        """
    }
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(achievements.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: achievements[key] ?? "")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Skills Section
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Skills")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(skills.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: skills[key] ?? "")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Projects Section
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Projects")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(projects.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: projects[key] ?? "")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contact Details")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(contactDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: contactDetails[key] ?? "")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Interests Section
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interests")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Clubs/Organizations:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("• Tech Innovators Club\n• Global Entrepreneurs Network\n• GreenTech Advocates")
                    .font(.body)
                    .foregroundColor(.black)
                    .lineSpacing(5)
                
                Divider()
                
                Text("Hobbies/Passions:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("• Traveling the world and experiencing different cultures\n• Sustainable living and eco-friendly practices\n• Mentoring aspiring entrepreneurs\n• Playing tennis and hiking in nature")
                    .font(.body)
                    .foregroundColor(.black)
                    .lineSpacing(5)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Mentorship Preferences Section
    private var mentorshipPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mentorship Preferences")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Seeking Mentorship In:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Business Development, Fundraising, Marketing Strategy")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Mentorship Style:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Hands-on guidance, regular check-ins")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Willing to Mentor:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Yes, in the areas of Product Development and Marketing")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    // MARK: - References & Testimonials Section
    private var referencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("References & Testimonials")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Professional References:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("John Doe, CEO of TechCo, Email: john.doe@techco.com")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Customer Testimonials:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("“This entrepreneur has been a game-changer for our business. Their innovation and leadership are unmatched.” - Jane Smith, Client")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    // MARK: - Values, Vision, and Mission Section
    private var valuesVisionMissionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Values, Vision & Mission")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Personal Values:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Innovation, Sustainability, Integrity")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Vision for the Future:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("To revolutionize the healthcare industry with innovative tech solutions.")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Mission Statement:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Empowering businesses to solve global health challenges using cutting-edge technology.")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    // MARK: - Portfolio & Case Studies Section
    private var portfolioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Portfolio & Case Studies")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Previous Ventures:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("TechCo - Developed a successful mobile app that scaled to 1 million users in the first year.")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Notable Projects:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Launched a marketing campaign for Product X that resulted in a 30% increase in sales.")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    // MARK: - Social Proof & Media Mentions Section
    private var socialProofSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Social Proof & Media Mentions")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Press Mentions:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Featured in TechCrunch for innovation in AI healthcare solutions.")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Social Media Links:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("LinkedIn: linkedin.com/in/entrepreneur")
                    .font(.body)
                    .foregroundColor(.black)
                Text("Twitter: @entrepreneur")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Publications & Articles:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Author of 'The Future of HealthTech' article published in Forbes.")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - Personal Secret Section
    private var personalSecretSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.customHex("004aad"))
                .shadow(radius: 2)
                .frame(height: 200) // Adjust height as needed

            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Secret Idea")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text("Creating an app for entrepreneurs") // Placeholder for the idea
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom, 10) // Space between sections

                Divider()
                    .background(Color.white)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Next Steps")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text("Entrepreneur AI coming soon") // Placeholder for next steps
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
        }
    }


    
    // MARK: - Collaborations & Partnerships Section
    private var collaborationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Collaborations & Partnerships")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Previous Collaborations:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Collaborated with XYZ Corp to launch an innovative product.")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Looking for Partnerships:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Looking for partnerships in the tech and healthcare sectors.")
                    .font(.body)
                    .foregroundColor(.black)
                
                Text("Strategic Interests:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Interested in partnerships with companies focused on AI and sustainability.")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }


    // MARK: - Detail Row Helper Function
    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text("\(title): ")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: 15) {
            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
            }
            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
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
    
    // Custom Circle Button
    struct CustomCircleButton: View {
        let iconName: String
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color(hex: "004aad"))
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



// Preview for ProfilePage
struct UserProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        UserProfilePage()
    }
}
