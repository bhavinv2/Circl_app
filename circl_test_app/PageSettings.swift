import SwiftUI

// MARK: - Main View
struct PageSettings: View {
    @State private var showMenu = false // State for hammer menu

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection

                    // Middle Section: Settings Options
                    ScrollView {
                        VStack(spacing: 20) {
                            // Invite a Friend
                            SectionHeader(title: "Invite a Friend")
                            settingsOption(title: "Invite a Friend", iconName: "person.badge.plus.fill", destination: InviteFriendPage())

                            // Account Settings
                            SectionHeader(title: "Account Settings")
                            settingsOption(title: "Change Password", iconName: "lock.fill", destination: ChangePasswordPage())
                            settingsOption(title: "Two-Factor Authentication", iconName: "shield.fill", destination: TwoFactorAuthPage())
                            settingsOption(title: "Delete Account", iconName: "trash.fill", destination: DeleteAccountPage())
                            settingsOption(title: "Your Invite Code", iconName: "link.circle.fill", destination: InviteCodeView())

                            // Feedback & Suggestions
                            SectionHeader(title: "Feedback & Suggestions")
                            settingsOption(title: "Rate the App", iconName: "star.fill", destination: RateAppPage())
                            settingsOption(title: "Suggest a Feature", iconName: "lightbulb.fill", destination: SuggestFeaturePage())
                            settingsOption(title: "Report a Problem", iconName: "exclamationmark.triangle.fill", destination: ReportProblemPage())

                            // Legal & Policies
                            SectionHeader(title: "Legal & Policies")
                            settingsOption(title: "Terms of Service", iconName: "doc.text.fill", destination: TermsOfServicePage())
                            settingsOption(title: "Privacy Policy", iconName: "hand.raised.fill", destination: PrivacyPolicyPage())
                            settingsOption(title: "Community Guidelines", iconName: "person.2.fill", destination: CommunityGuidelinesPage())

                            // Help & Support
                            SectionHeader(title: "Help & Support")
                            settingsOption(title: "Help Center", iconName: "questionmark.circle.fill", destination: HelpCenterPage())
                            settingsOption(title: "Contact Support", iconName: "headphones", destination: ContactSupportPage())
                            settingsOption(title: "FAQs", iconName: "text.bubble.fill", destination: FAQsPage())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .navigationBarHidden(true)

                // Hammer Menu
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
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Circl.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .resizable()
                        .frame(width: 50, height: 40)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }
    }

    // MARK: - Section Header
    private func SectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, 20)
    }

    // MARK: - Settings Option
    private func settingsOption(title: String, iconName: String, destination: some View) -> some View {
        NavigationLink(destination: destination.navigationBarBackButtonHidden(true)) {
            HStack {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.fromHex("004aad"))
                    .cornerRadius(8)

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.leading, 10)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Menu Item Component
struct MenuItem: View {
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
    static func fromHex(_ hex: String) -> Color {
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

// MARK: - Placeholder Pages
struct ChangePasswordPage: View { var body: some View { Text("Change Password Page") } }
struct TwoFactorAuthPage: View { var body: some View { Text("Two-Factor Authentication Page") } }
struct DeleteAccountPage: View { var body: some View { Text("Delete Account Page") } }
struct RateAppPage: View { var body: some View { Text("Rate the App Page") } }
struct SuggestFeaturePage: View { var body: some View { Text("Suggest a Feature Page") } }
struct ReportProblemPage: View { var body: some View { Text("Report a Problem Page") } }
struct TermsOfServicePage: View { var body: some View { Text("Terms of Service Page") } }
struct PrivacyPolicyPage: View { var body: some View { Text("Privacy Policy Page") } }
struct CommunityGuidelinesPage: View { var body: some View { Text("Community Guidelines Page") } }
struct HelpCenterPage: View { var body: some View { Text("Help Center Page") } }
struct ContactSupportPage: View { var body: some View { Text("Contact Support Page") } }
struct FAQsPage: View { var body: some View { Text("FAQs Page") } }
struct InviteFriendPage: View { var body: some View { Text("Invite a Friend Page") } }
struct PageMessages: View { var body: some View { Text("Messages Page") } }
struct PageEntrepreneurMatching: View { var body: some View { Text("Entrepreneur Matching Page") } }
struct PageBusinessProfile: View { var body: some View { Text("Business Profile Page") } }
struct PageForum: View { var body: some View { Text("Forum Feed Page") } }
struct PageEntrepreneurResources: View { var body: some View { Text("Professional Services Page") } }
struct PageEntrepreneurKnowledge: View { var body: some View { Text("News & Knowledge Page") } }
struct PageSkillSellingMatching: View { var body: some View { Text("Skill Selling Page") } }
struct PageCircles: View { var body: some View { Text("Circles Page") } }
struct InviteCodeView: View { var body: some View { Text("Invite Code View") } }

// MARK: - Preview
struct PageSettings_Previews: PreviewProvider {
    static var previews: some View {
        PageSettings()
    }
}

