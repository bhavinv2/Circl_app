import SwiftUI

struct Page14: View {
    @State private var agreedToTerms = false
    @State private var agreedToPrivacyPolicy = false
    @State private var showAlert = false // State to control the alert
    @State private var navigateToPage18 = false // State to control navigation

    var body: some View {
        NavigationStack { // Use NavigationStack for programmatic navigation
            ZStack {
                // Background Color
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    Text("Terms and Conditions")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))

                    // Separator
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)

                    // White Display Box for Legal Text
                    VStack(spacing: 20) {
                        ScrollView {
                            Text("""
                            A. Terms & Conditions
                            Effective Date: March 30, 2025
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
                            
                            B. Privacy Policy
                            Effective Date: March 30, 2025
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
                            
                            D. Community Guidelines
                            Effective Date: March 30, 2025
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
                                .font(.body)
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    // Checkbox to agree to terms
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms and Conditions")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)

                    // Checkbox to agree to privacy policy
                    Toggle(isOn: $agreedToPrivacyPolicy) {
                        Text("I agree to the Privacy Policy")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)

                    Spacer()

                    // Next Button
                    Button(action: {
                        if agreedToTerms && agreedToPrivacyPolicy {
                            navigateToPage18 = true // Trigger navigation
                        } else {
                            showAlert = true // Show alert if conditions are not met
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hexCode: "004aad"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hexCode: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 50)
                            .padding(.bottom, 20)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text("Please accept both the Terms and Conditions and the Privacy Policy to proceed."),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToPage18) {
                Page18() // Navigate to Page18 when `navigateToPage18` is true
            }
        }
    }
}

struct Page14View_Previews: PreviewProvider {
    static var previews: some View {
        Page14()
    }
}
