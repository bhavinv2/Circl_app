import SwiftUI

// MARK: - Main View
struct PageSettings: View {
    @Environment(\.presentationMode) var presentationMode  // For dismissing the settings page

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ✅ Back Arrow - aligned to system height
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 12, height: 20)
                            .foregroundColor(.blue)
                            .padding(.leading, 5)
                    }
                    Spacer()
                }
                .padding(.top, 15) // ✅ Standard iOS nav top spacing
                .padding(.leading, 15)
                .padding(.bottom, 5)

                // ✅ Settings Content (moved up slightly)
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

                        // Logout Button
                        Button(action: logoutUser) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5) // ✅ Moved up content spacing
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
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
        NavigationLink(destination:
            destination
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
        ) {
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

    // MARK: - Logout Functionality
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: Page1())
                window.makeKeyAndVisible()
            }
        }
    }

    // MARK: - Circle Button (Optional, unused)
    struct CustomCircleButton: View {
        let iconName: String
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.fromHex("004aad"))
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

// MARK: - Placeholder Pages for Navigation
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

struct PageSettings_Previews: PreviewProvider {
    static var previews: some View {
        PageSettings()
    }
}
