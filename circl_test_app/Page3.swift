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
                Color(hexCode: "004aad").edgesIgnoringSafeArea(.all)
                
                // Top Left Cloud
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 60, y: -UIScreen.main.bounds.height / 2 + 60)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 30, y: -UIScreen.main.bounds.height / 2 + 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 110, y: -UIScreen.main.bounds.height / 2 + 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 170, y: -UIScreen.main.bounds.height / 2 + 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 210, y: -UIScreen.main.bounds.height / 2 + 60)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 90, y: -UIScreen.main.bounds.height / 2 + 50)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 50, y: -UIScreen.main.bounds.height / 2 + 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 110, height: 110)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 150, y: -UIScreen.main.bounds.height / 2 + 80)
                }

                // Bottom Left Cloud
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 30, y: UIScreen.main.bounds.height / 2 - 80)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 30, y: UIScreen.main.bounds.height / 2 - 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 170, y: UIScreen.main.bounds.height / 2 - 20)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 80, y: UIScreen.main.bounds.height / 2 - 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 110, height: 110)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 150, y: UIScreen.main.bounds.height / 2 - 80)
                }

                // Middle Right Cloud
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: UIScreen.main.bounds.width / 2 - 60, y: 0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 100)
                        .offset(x: UIScreen.main.bounds.width / 2 - 30, y: -20)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: UIScreen.main.bounds.width / 2 - 0, y: 20)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: UIScreen.main.bounds.width / 2 - 100, y: -40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: UIScreen.main.bounds.width / 2 - 115, y: 10)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        TitleSection()
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

struct TitleSection: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Create Your Account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hexCode: "ffde59"))
                .padding(.top, 40)

            Rectangle()
                .frame(height: 2)
                .foregroundColor(.white)
        }
    }
}

struct PersonalInformationSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var isEmailValid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personal Information")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

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
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
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
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
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
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hexCode: "004aad"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(isSubmitting ? Color.gray : (isFormValid ? Color(hexCode: "ffde59") : Color.gray))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                )
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
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
                .frame(height: 50)

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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: 50)

                HStack {
                    Text(selectedOption ?? placeholder)
                        .foregroundColor(
                            selectedOption == nil ?
                                Color(hexCode: "004aad").opacity(0.6) :
                                Color(hexCode: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hexCode: "004aad"))
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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: 50)
                
                HStack {
                    Text(selectedOption ?? placeholder)
                        .foregroundColor(
                            selectedOption == nil ?
                            Color(hexCode: "004aad").opacity(0.6) :
                            Color(hexCode: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hexCode: "004aad"))
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
