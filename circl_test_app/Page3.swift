import SwiftUI

struct Page3: View {
    @State private var selectedUsageInterest: String? = nil
    @State private var selectedIndustryInterest: String? = nil
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isEmailValid: Bool = true
    
    // State for submission handling
    @State private var isSubmitting: Bool = false
    @State private var submissionMessage: String = ""
    @State private var navigateToPage5: Bool = false
    @State private var showAlert = false

    // Animation states for moving gradient and clouds
    @State private var gradientOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0
    @State private var textOpacity: Double = 0.0

    let usageInterestOptions = [
        "Sell a Skill", "Make Investments", "Share Knowledge", "Be Part of the Community",
        "Find Investors", "Find Mentors", "Find Co-Founder/s", "Network with Entrepreneurs",
        "Scale Your Business", "Start Your Business"
    ]

    let industryCategories: [(String, [String])] = [
        ("Technology & Digital", [
            "Artificial Intelligence", "Blockchain & Web3", "Cloud Computing", "Cybersecurity",
            "Data Science & Analytics", "Internet of Things (IoT)", "Metaverse Technologies",
            "Robotics & Automation", "Software Development", "Virtual/Augmented Reality"
        ]),
        ("Business & Finance", [
            "Accounting & Financial Services", "Consulting & Professional Services",
            "E-Commerce & Marketplaces", "FinTech (Financial Technology)", "Franchising",
            "Investment & Venture Capital", "Real Estate & Property Tech", "Startups & Entrepreneurship"
        ]),
        ("Consumer Goods & Services", [
            "Beauty & Personal Care", "Consumer Electronics", "Fashion & Apparel", "Food & Beverage",
            "Home Goods & Furniture", "Luxury Goods", "Retail & Merchandising"
        ]),
        ("Creative & Media", [
            "Advertising & Marketing", "Architecture & Design", "Arts & Culture", "Entertainment & Media",
            "Gaming & Esports", "Music & Audio Production", "Publishing & Journalism"
        ]),
        ("Education & Knowledge", [
            "Corporate Training", "EdTech (Education Technology)", "Higher Education", "K-12 Education",
            "Online Learning Platforms", "Professional Development"
        ]),
        ("Energy & Environment", [
            "Clean Energy", "Environmental Services", "Green Technology", "Recycling & Waste Management",
            "Sustainability Solutions"
        ]),
        ("Food & Agriculture", [
            "AgTech (Agriculture Technology)", "Beverage Production", "Food Production",
            "Food Service & Hospitality", "Organic Farming", "Restaurant & Dining"
        ]),
        ("Health & Wellness", [
            "Biotechnology", "Fitness & Sports", "HealthTech", "Medical Devices", "Mental Health Services",
            "Pharmaceuticals", "Wellness & Self-Care"
        ]),
        ("Industrial & Manufacturing", [
            "3D Printing", "Advanced Manufacturing", "Aerospace & Defense", "Automotive",
            "Chemical Production", "Construction", "Industrial Equipment"
        ]),
        ("Services", [
            "Childcare & Education", "Cleaning Services", "Event Planning", "Home Services",
            "Legal Services", "Logistics & Delivery", "Staffing & Recruiting"
        ]),
        ("Social Impact", [
            "Community Development", "Nonprofit Organizations", "Social Enterprises",
            "Urban Development", "Women-Led Businesses"
        ])
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced Animated Background
                animatedBackground
                
                // Enhanced Top Left Cloud with animations
                topLeftCloudGroup
                
                // Enhanced Bottom Right Cloud with animations
                bottomRightCloudGroup
                
                // Main content
                mainContent
            }
            .onAppear {
                startAnimations()
            }
        }
    }
    
    // MARK: - Background Component
    private var animatedBackground: some View {
        ZStack {
            // Base gradient layer with multiple blues
            LinearGradient(
                colors: [
                    Color(hexCode: "001a3d"),
                    Color(hexCode: "004aad"),
                    Color(hexCode: "0066ff"),
                    Color(hexCode: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Moving radial gradients for depth
            RadialGradient(
                colors: [
                    Color(hexCode: "0066ff").opacity(0.4),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 350
            )
            .offset(x: gradientOffset * 0.8, y: -gradientOffset * 0.3)
            .rotationEffect(.degrees(rotationAngle * 0.5))
            
            RadialGradient(
                colors: [
                    Color(hexCode: "002d5a").opacity(0.6),
                    Color.clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: 250
            )
            .offset(x: -gradientOffset * 0.5, y: gradientOffset * 0.6)
            .rotationEffect(.degrees(-rotationAngle * 0.3))
            
            // Flowing wave-like gradient
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hexCode: "004aad").opacity(0.2),
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.3),
                    Color.clear
                ],
                startPoint: UnitPoint(x: 0.2 + gradientOffset * 0.001, y: 0),
                endPoint: UnitPoint(x: 0.8 - gradientOffset * 0.001, y: 1)
            )
            
            // Subtle overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    Color.clear,
                    Color.black.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Cloud Components
    private var topLeftCloudGroup: some View {
        Group {
            createCloudCircle(size: 120, opacity: 0.9, 
                            x: -UIScreen.main.bounds.width / 2 + 60 + cloudOffset1 * 0.3,
                            y: -UIScreen.main.bounds.height / 2 + 60 + sin(cloudOffset1 * 0.02) * 10)
            
            createCloudCircle(size: 100, opacity: 0.85,
                            x: -UIScreen.main.bounds.width / 2 + 30 + cloudOffset1 * 0.2,
                            y: -UIScreen.main.bounds.height / 2 + 40 + cos(cloudOffset1 * 0.015) * 8)
            
            createCloudCircle(size: 100, opacity: 0.8,
                            x: -UIScreen.main.bounds.width / 2 + 110 + cloudOffset1 * 0.25,
                            y: -UIScreen.main.bounds.height / 2 + 30 + sin(cloudOffset1 * 0.018) * 6)
            
            createCloudCircle(size: 100, opacity: 0.75,
                            x: -UIScreen.main.bounds.width / 2 + 170 + cloudOffset1 * 0.15,
                            y: -UIScreen.main.bounds.height / 2 + 30 + cos(cloudOffset1 * 0.022) * 7)
            
            createCloudCircle(size: 100, opacity: 0.8,
                            x: -UIScreen.main.bounds.width / 2 + 210 + cloudOffset1 * 0.35,
                            y: -UIScreen.main.bounds.height / 2 + 60 + sin(cloudOffset1 * 0.016) * 9)
            
            createCloudCircle(size: 80, opacity: 0.7,
                            x: -UIScreen.main.bounds.width / 2 + 90 + cloudOffset1 * 0.28,
                            y: -UIScreen.main.bounds.height / 2 + 50 + cos(cloudOffset1 * 0.019) * 5)
            
            createCloudCircle(size: 90, opacity: 0.75,
                            x: -UIScreen.main.bounds.width / 2 + 50 + cloudOffset1 * 0.18,
                            y: -UIScreen.main.bounds.height / 2 + 30 + sin(cloudOffset1 * 0.021) * 6)
            
            createCloudCircle(size: 110, opacity: 0.8,
                            x: -UIScreen.main.bounds.width / 2 + 150 + cloudOffset1 * 0.22,
                            y: -UIScreen.main.bounds.height / 2 + 80 + cos(cloudOffset1 * 0.017) * 8)
        }
    }
    
    private var bottomRightCloudGroup: some View {
        Group {
            createCloudCircle(size: 120, opacity: 0.9,
                            x: UIScreen.main.bounds.width / 2 - 60 + cloudOffset2 * 0.2,
                            y: UIScreen.main.bounds.height / 2 - 60 + sin(cloudOffset2 * 0.025) * 8)
            
            createCloudCircle(size: 100, opacity: 0.85,
                            x: UIScreen.main.bounds.width / 2 - 30 + cloudOffset2 * 0.15,
                            y: UIScreen.main.bounds.height / 2 - 40 + cos(cloudOffset2 * 0.02) * 7)
            
            createCloudCircle(size: 80, opacity: 0.7,
                            x: UIScreen.main.bounds.width / 2 - 90 + cloudOffset2 * 0.3,
                            y: UIScreen.main.bounds.height / 2 - 50 + sin(cloudOffset2 * 0.018) * 6)
            
            createCloudCircle(size: 90, opacity: 0.75,
                            x: UIScreen.main.bounds.width / 2 - 50 + cloudOffset2 * 0.25,
                            y: UIScreen.main.bounds.height / 2 - 30 + cos(cloudOffset2 * 0.023) * 9)
            
            createCloudCircle(size: 90, opacity: 0.75,
                            x: UIScreen.main.bounds.width / 2 - 30 + cloudOffset2 * 0.18,
                            y: UIScreen.main.bounds.height / 2 - 110 + sin(cloudOffset2 * 0.016) * 5)
            
            createCloudCircle(size: 110, opacity: 0.8,
                            x: UIScreen.main.bounds.width / 2 - 155 + cloudOffset2 * 0.28,
                            y: UIScreen.main.bounds.height / 2 - 30 + cos(cloudOffset2 * 0.021) * 7)
            
            createCloudCircle(size: 110, opacity: 0.8,
                            x: UIScreen.main.bounds.width / 2 - 150 + cloudOffset2 * 0.22,
                            y: UIScreen.main.bounds.height / 2 - 80 + sin(cloudOffset2 * 0.019) * 8)
        }
    }
    
    // Helper function to create cloud circles
    private func createCloudCircle(size: CGFloat, opacity: Double, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(opacity), Color.white.opacity(opacity - 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: size > 100 ? 1 : 0.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: size > 100 ? 8 : 4, x: 0, y: size > 100 ? 4 : 2)
            .offset(x: x, y: y)
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                titleSection
                Spacer()
                PersonalInformationSection(
                    firstName: $firstName,
                    lastName: $lastName,
                    email: $email,
                    isEmailValid: $isEmailValid
                )
                Spacer()
                ExperienceSetupSection(
                    usageInterestOptions: usageInterestOptions,
                    industryCategories: industryCategories,
                    selectedUsageInterest: $selectedUsageInterest,
                    selectedIndustryInterest: $selectedIndustryInterest
                )
                Spacer()
                NextButton(
                    isSubmitting: $isSubmitting,
                    action: {
                        if !isFormValid() {
                            submissionMessage = "Please fill out all fields correctly before continuing."
                            showAlert = true
                        } else {
                            submitUserInfo()
                        }
                    },
                    isFormValid: isFormValid()
                )
                Spacer()
            }
            .padding(.horizontal, 40)
            .opacity(textOpacity)
        }
        .dismissKeyboardOnScroll()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Registration Error"),
                message: Text(submissionMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(
            NavigationLink(
                destination: Page5(),
                isActive: $navigateToPage5,
                label: { EmptyView() }
            )
        )
    }
    
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Create Your Account")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.top, 40)

            Rectangle()
                .frame(height: 3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.white,
                            Color.white.opacity(0.8),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Animation Functions
    private func startAnimations() {
        // Start all animations when view appears
        withAnimation(
            Animation.linear(duration: 10.0)
                .repeatForever(autoreverses: true)
        ) {
            gradientOffset = 100
        }
        
        withAnimation(
            Animation.linear(duration: 15.0)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        withAnimation(
            Animation.linear(duration: 20.0)
                .repeatForever(autoreverses: true)
        ) {
            cloudOffset1 = 30
        }
        
        withAnimation(
            Animation.linear(duration: 25.0)
                .repeatForever(autoreverses: true)
        ) {
            cloudOffset2 = -25
        }
        
        // Fade in text content
        withAnimation(
            Animation.easeInOut(duration: 1.5)
        ) {
            textOpacity = 1.0
        }
    }
    
    private func isFormValid() -> Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               isEmailValid &&
               !email.isEmpty &&
             
               selectedUsageInterest != nil &&
               selectedIndustryInterest != nil
    }
    
    // 🚀 This function ties SwiftUI to PostgreSQL via Django API
    func submitUserInfo() {
        guard let url = URL(string: "https://circlapp.online/api/users/register/") else {
            submissionMessage = "Invalid API URL"
            print("❌ Invalid API URL")
            return
        }

        let userInfo: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
           
            "main_usage": selectedUsageInterest ?? "",
            "industry_interest": selectedIndustryInterest ?? ""
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🚀 Sending JSON: \(jsonString)")
        } else {
            print("❌ Failed to encode JSON")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: userInfo) else {
            submissionMessage = "Failed to encode data"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        isSubmitting = true

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

                if let error = error {
                    submissionMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    print("❌ Request Error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")

                    if httpResponse.statusCode == 201 {
                        submissionMessage = "Success! User registered."
                        print("✅ User registered successfully.")

                        if let data = data,
                           let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let userId = responseDict["user_id"] as? Int {
                            UserDefaults.standard.set(userId, forKey: "user_id")
                            UserDefaults.standard.synchronize()
                            print("📌 Stored user_id in UserDefaults: \(userId)")
                        } else {
                            print("❌ Failed to extract user_id from response.")
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToPage5 = true
                        }

                    } else if httpResponse.statusCode == 400 {
                        if let data = data,
                           let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: [String]],
                           let emailErrors = errorDict["email"] {
                            submissionMessage = emailErrors.first ?? "This email is already taken. Please choose a new one."
                        } else {
                            submissionMessage = "This email is already taken. Please choose a new one."
                        }
                        showAlert = true
                        print("❌ Email already in use.")

                    } else {
                        submissionMessage = "Failed to register user. Status code: \(httpResponse.statusCode)"
                        showAlert = true
                        print("❌ Failed to register user. Status code: \(httpResponse.statusCode)")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Response Body: \(responseString)")
                }
            }
        }
        task.resume()
    }
}

// MARK: - Components

struct PersonalInformationSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var isEmailValid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personal Information")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 0.5)

            VStack(spacing: 15) {
                StyledTextField(
                    placeholder: "First Name",
                    text: $firstName,
                    formatter: { $0.capitalized },
                    autocapitalization: .words
                )
                StyledTextField(
                    placeholder: "Last Name",
                    text: $lastName,
                    formatter: { $0.capitalized },
                    autocapitalization: .words
                )

                VStack(alignment: .leading) {
                    StyledTextField(
                        placeholder: "Email",
                        text: Binding(
                            get: { email },
                            set: { newValue in
                                email = newValue
                                isEmailValid = isValidEmail(newValue) || newValue.isEmpty
                            }
                        ),
                        keyboardType: .emailAddress,
                        autocapitalization: .none
                    )
                    if !isEmailValid && !email.isEmpty {
                        Text("Please enter a valid email address")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

               
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}


struct ExperienceSetupSection: View {
    let usageInterestOptions: [String]
    let industryCategories: [(String, [String])]
    @Binding var selectedUsageInterest: String?
    @Binding var selectedIndustryInterest: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Let Us Set Up Your Experience")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 0.5)
            
            VStack(spacing: 15) {
                DropdownField(
                    placeholder: "Main Usage Interest",
                    options: usageInterestOptions,
                    selectedOption: $selectedUsageInterest
                )
                
                CategorizedDropdownField(
                    placeholder: "Main Industry Interest",
                    categories: industryCategories,
                    selectedOption: $selectedIndustryInterest
                )
                
                Spacer()
                Text("*You Will Get Your Password Upon Approval")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 0.5)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct NextButton: View {
    @Binding var isSubmitting: Bool
    var action: () -> Void
    var isFormValid: Bool
    
    var body: some View {
        Button(action: {
            if !isSubmitting {
                action()
            }
        }) {
            Text(isSubmitting ? "Submitting..." : "Next")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hexCode: "004aad"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 50)
                .scaleEffect(isFormValid ? 1.0 : 0.95)
                .opacity(isFormValid ? 1.0 : 0.6)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
        }
        .disabled(!isFormValid || isSubmitting)
    }
}

struct StyledTextField: View {
    var placeholder: String
    @Binding var text: String
    var formatter: ((String) -> String)?
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .none

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.9), Color.white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

            TextField(placeholder, text: Binding(
                get: { text },
                set: { newValue in
                    if let format = formatter {
                        text = format(newValue)
                    } else {
                        text = newValue
                    }
                }
            ))
            .keyboardType(keyboardType)
            .autocapitalization(autocapitalization)
            .disableAutocorrection(true)
            .foregroundColor(Color(hexCode: "004aad"))
            .font(.system(size: 16, weight: .medium))
            .padding(.horizontal, 15)
        }
    }
}

struct DropdownField: View {
    var placeholder: String
    var options: [String]
    @Binding var selectedOption: String?

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selectedOption = option
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                HStack {
                    Text(selectedOption ?? placeholder)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            selectedOption == nil ?
                                Color(hexCode: "004aad").opacity(0.6) :
                                Color(hexCode: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hexCode: "004aad"))
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct CategorizedDropdownField: View {
    var placeholder: String
    var categories: [(String, [String])]
    @Binding var selectedOption: String?
    
    var body: some View {
        Menu {
            ForEach(categories, id: \.0) { category in
                Section(header: Text(category.0).font(.headline)) {
                    ForEach(category.1, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                        }) {
                            Text(option)
                        }
                    }
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                HStack {
                    Text(selectedOption ?? placeholder)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            selectedOption == nil ?
                            Color(hexCode: "004aad").opacity(0.6) :
                            Color(hexCode: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hexCode: "004aad"))
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct Page3_Previews: PreviewProvider {
    static var previews: some View {
        Page3()
    }
}
