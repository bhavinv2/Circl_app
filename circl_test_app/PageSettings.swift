import SwiftUI

// MARK: - Main View
struct PageSettings: View {
    @Environment(\.presentationMode) var presentationMode  // For dismissing the settings page
    @State private var showLogoutAlert = false
    @State private var isLogoutConfirmed = false



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
                        settingsOption(title: "Become a Mentor", iconName: "graduationcap.fill", destination: BecomeMentorPage())

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
                        Button(action: {
                            showLogoutAlert = true  // Trigger alert when button is pressed
                        }) {
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
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Log out of your account?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        logoutUser() // Call the logout function when "Log Out" is pressed
                    },
                    secondaryButton: .cancel()
                )
            }

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
                window.rootViewController = UIHostingController(rootView: Page1()) // Redirect to login page
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
struct BecomeMentorPage: View {
    @State private var name = ""
    @State private var industry = ""
    @State private var reason = ""
    @State private var isSubmitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mentor Application")
                .font(.title)
                .bold()

            TextField("Your Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Industry", text: $industry)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Why do you want to become a mentor?")
                .font(.headline)

            TextEditor(text: $reason)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

            Button(action: {
                submitMentorApplication()
            }) {
                Text("Submit Application")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            if isSubmitted {
                Text("Application submitted! We'll review it shortly.")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
    }

    func submitMentorApplication() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "name": name,
            "industry": industry,
            "reason": reason
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/apply_mentor/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitted = true
                name = ""
                industry = ""
                reason = ""
            }
        }.resume()
    }
}


struct ChangePasswordPage: View {
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var isSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.title)
                .bold()

            SecureField("Current Password", text: $oldPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Confirm New Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: changePassword) {
                Text("Update Password")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(isSuccess ? .green : .red)
            }

            Spacer()
        }
        .padding()
    }

    func changePassword() {
        guard !oldPassword.isEmpty, !newPassword.isEmpty, newPassword == confirmPassword else {
            message = "Please fill all fields and make sure new passwords match."
            isSuccess = false
            return
        }

        guard let url = URL(string: "https://circlapp.online/api/users/change_password/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let payload = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = response["status"] as? String {
                        message = status
                        isSuccess = true
                        oldPassword = ""
                        newPassword = ""
                        confirmPassword = ""
                    } else if let errorMsg = response["error"] as? String {
                        message = errorMsg
                        isSuccess = false
                    }
                } else {
                    message = "Unexpected error occurred."
                    isSuccess = false
                }
            }
        }.resume()
    }
}

struct TwoFactorAuthPage: View { var body: some View { Text("Two-Factor Authentication Page") } }
struct DeleteAccountPage: View {
    @State private var reason = ""
    @State private var message = ""
    @State private var isSubmitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Why do you want to delete your account?")
                .font(.headline)

            TextEditor(text: $reason)
                .frame(height: 150)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

            Button(action: submitDeleteRequest) {
                Text("Request to Delete Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }

            if isSubmitted {
                Text(message)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
    }

    func submitDeleteRequest() {
        guard let url = URL(string: "https://circlapp.online/api/users/request_delete_account/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let payload = ["reason": reason]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitted = true
                message = "Your request has been submitted."
                reason = ""
            }
        }.resume()
    }
}

struct RateAppPage: View { var body: some View { Text("Rate the App Page") } }
struct SuggestFeaturePage: View { var body: some View { Text("Suggest a Feature Page") } }
struct ReportProblemPage: View { var body: some View { Text("Report a Problem Page") } }
struct TermsOfServicePage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("A. Terms & Conditions")
                    .font(.title)
                    .foregroundColor(Color(hexCode: "004aad"))

                Text("Effective Date: March 30, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("""
Welcome to Circl International Inc. (“Circl,” “we,” “us,” or “our”). By accessing or using our platform, you agree to abide by these Terms & Conditions. If you do not agree, please do not use our platform.

1. Use of the Platform
You must be at least 18 years old to use Circl.
You are responsible for all activity under your account.
Misuse of the platform, including spamming, harassment, or unauthorized access, will result in suspension or termination.

2. Intellectual Property
Circl owns all platform content, trademarks, and proprietary materials.
Users retain ownership of their content but grant Circl a license to use it for platform functionality.

3. Modification of Terms
Circl reserves the right to update these Terms & Conditions at any time. Users will be notified of significant changes.

4. Limitation of Liability
Circl is not responsible for business outcomes, financial losses, or damages resulting from platform use.
We provide the platform “as is” without warranties of any kind.

5. Governing Law
These Terms & Conditions are governed by the laws of the State of Texas, USA.

6. Termination
We reserve the right to terminate accounts violating these terms.
""")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Terms & Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("B. Privacy Policy")
                    .font(.title)
                    .foregroundColor(Color(hexCode: "004aad"))

                Text("Effective Date: March 30, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("""
Circl International Inc. values your privacy. This Privacy Policy explains how we collect, use, and protect your data.

1. Information We Collect
Personal data (e.g., name, email, business details).
Usage data (e.g., interactions with the platform).

2. How We Use Your Data
To provide and improve our platform.
To personalize user experience and offer relevant business connections.

3. Data Sharing & Security
We do not sell user data.
Third-party service providers may access data for platform functionality.
We implement security measures but cannot guarantee absolute protection.

4. Data Retention Policy
User data is retained for as long as necessary to provide services and comply with legal obligations.

5. User Rights
You may request data access, modification, or deletion.

C. Competition Clause
Effective Date: March 30, 2025
Circl International Inc. fosters a collaborative entrepreneurial environment. We support businesses on our platform, including those that may compete with each other.

1. Fair Use Policy
Users may engage in competition but must not engage in unethical practices such as data scraping, user poaching, or misleading promotions.

2. Platform Protection
Users may not use Circl to undermine the platform’s integrity or to create a directly competing service using Circl’s proprietary features.

3. Reporting & Enforcement
Violations may result in suspension or legal action.
""")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommunityGuidelinesPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("D. Community Guidelines")
                    .font(.title)
                    .foregroundColor(Color(hexCode: "004aad"))

                Text("Effective Date: March 30, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("""
To maintain a productive environment, Circl International Inc. enforces the following guidelines:

1. Respectful Communication
No harassment, discrimination, or hate speech.
Constructive discussions are encouraged.

2. Business Ethics
No fraudulent activities, scams, or misinformation.
Respect confidentiality and intellectual property.

3. User-Generated Content Policy
Users are responsible for the content they post.
Circl reserves the right to remove content that violates policies.
Users grant Circl a non-exclusive license to use content posted on the platform for operational purposes.

4. Enforcement
Violations may result in content removal, account suspension, or permanent bans.

5. Dispute Resolution & Liability Disclaimer
Effective Date: March 30, 2025

E. Dispute Resolution
Disputes will be resolved through arbitration in the State of Texas, USA.
Users waive the right to class-action lawsuits.

2. Limitation of Liability
Circl is not responsible for user interactions, business decisions, or losses.
Users agree to indemnify Circl against legal claims arising from platform use.

3. Refund & Subscription Policy
If paid services are introduced, refund policies will be clearly stated at the time of purchase.

By using Circl, you agree to these terms. For inquiries, contact join@circlinternational.com.
""")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Community Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpCenterPage: View { var body: some View { Text("Help Center Page") } }
struct ContactSupportPage: View { var body: some View { Text("Contact Support Page") } }
struct FAQsPage: View { var body: some View { Text("FAQs Page") } }
struct InviteFriendPage: View { var body: some View { Text("Invite a Friend Page") } }

struct PageSettings_Previews: PreviewProvider {
    static var previews: some View {
        PageSettings()
    }
}
