import SwiftUI
import UIKit

struct Page3: View {
    @State private var selectedUsageInterest: String? = nil
    @State private var selectedIndustryInterest: String? = nil
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var isEmailValid: Bool = true
    @State private var studentEmail: String = ""
    @State private var isStudentEmailValid: Bool = true
    
    // State for submission handling
    @State private var isSubmitting: Bool = false
    @State private var submissionMessage: String = ""
    @State private var navigateToPage4: Bool = false
    @State private var showAlert = false

    let usageInterestOptions = [
        "Sell a Skill", "Make Investments", "Share Knowledge", "Be Part of the Community",
        "Find Investors", "Find Mentors", "Find Co-Founder/s", "Network with Entrepreneurs",
        "Scale Your Business", "Start Your Business", "Student", "Student Entrepreneur"
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
                Color(hex: "004aad").edgesIgnoringSafeArea(.all)
                
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

                VStack(spacing: 0) {
                    Spacer(minLength: 30)
                    
                    TitleSection()
                    
                    Spacer(minLength: 20)
                    
                    PersonalInformationSection(
                        firstName: $firstName,
                        lastName: $lastName,
                        email: $email,
                        phoneNumber: $phoneNumber,
                        isEmailValid: $isEmailValid
                    )
                    
                    Spacer(minLength: 15)
                    
                    ExperienceSetupSection(
                        usageInterestOptions: usageInterestOptions,
                        industryCategories: industryCategories,
                        selectedUsageInterest: $selectedUsageInterest,
                        selectedIndustryInterest: $selectedIndustryInterest,
                        studentEmail: $studentEmail,
                        isStudentEmailValid: $isStudentEmailValid
                    )
                    
                    Spacer(minLength: 20)
                    
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
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 30)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Registration Error"),
                        message: Text(submissionMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .navigationDestination(isPresented: $navigateToPage4) {
                    Page4()
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        let baseValidation = !firstName.isEmpty &&
                           !lastName.isEmpty &&
                           isEmailValid &&
                           !email.isEmpty &&
                           !phoneNumber.isEmpty &&
                           selectedUsageInterest != nil &&
                           selectedIndustryInterest != nil
        
        // Additional validation for student email if student option is selected
        if selectedUsageInterest == "Student" || selectedUsageInterest == "Student Entrepreneur" {
            return baseValidation && !studentEmail.isEmpty && isStudentEmailValid
        }
        
        return baseValidation
    }
    
    // 🚀 This function ties SwiftUI to PostgreSQL via Django API
    func submitUserInfo() {
        guard let url = URL(string: "https://circlapp.online/api/users/register/") else {
            submissionMessage = "Invalid API URL"
            print("❌ Invalid API URL")
            return
        }

        var userInfo: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone_number": phoneNumber,
            "main_usage": selectedUsageInterest ?? "",
            "industry_interest": selectedIndustryInterest ?? ""
        ]
        
        // Add student email if student option is selected
        if selectedUsageInterest == "Student" || selectedUsageInterest == "Student Entrepreneur" {
            userInfo["student_email"] = studentEmail
        }

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
                            // Store usage interest for personalized onboarding
                            UserDefaults.standard.set(selectedUsageInterest ?? "", forKey: "user_usage_interest")
                            UserDefaults.standard.synchronize()
                            print("📌 Stored user_id in UserDefaults: \(userId)")
                            print("📌 Stored usage interest: \(selectedUsageInterest ?? "")")
                            
                            // Send push token if available
                            if let savedToken = UserDefaults.standard.string(forKey: "pending_push_token") {
                                print("📤 Sending saved push token after registration: \(savedToken)")
                                sendDeviceTokenToBackend(token: savedToken)
                                UserDefaults.standard.removeObject(forKey: "pending_push_token")
                            }
                            
                            // Check if email is .edu and send welcome email
                            if email.lowercased().hasSuffix(".edu") {
                                print("📧 .edu email detected: \(email)")
                                print("📧 Sending welcome email to .edu user")
                                sendWelcomeEmail(userId: userId, email: email)
                            } else {
                                print("ℹ️ Regular email address: \(email)")
                            }
                        } else {
                            print("❌ Failed to extract user_id from response.")
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToPage4 = true
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
        VStack(spacing: 5) {
            Text("Create Your Account")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "ffde59"))

            Rectangle()
                .frame(height: 2)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
        }
    }
}

struct PersonalInformationSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var isEmailValid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personal Information")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 10) {
                TextField("First Name", text: Binding(
                    get: { firstName },
                    set: { firstName = $0.capitalized }
                ))
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .autocapitalization(.words)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                
                TextField("Last Name", text: Binding(
                    get: { lastName },
                    set: { lastName = $0.capitalized }
                ))
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .autocapitalization(.words)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    TextField("Email", text: Binding(
                        get: { email },
                        set: { newValue in
                            email = newValue
                            isEmailValid = isValidEmail(newValue) || newValue.isEmpty
                        }
                    ))
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                    }
                    
                    if !isEmailValid && !email.isEmpty {
                        Text("Please enter a valid email address")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                
                TextField("Phone Number", text: Binding(
                    get: { phoneNumber },
                    set: { newValue in
                        phoneNumber = formatPhoneNumber(newValue)
                    }
                ))
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .keyboardType(.phonePad)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func formatPhoneNumber(_ newValue: String) -> String {
        let filtered = newValue.filter { $0.isNumber }
        let limitedInput = String(filtered.prefix(10))
        
        var formatted = ""
        for (index, char) in limitedInput.enumerated() {
            if index == 0 {
                formatted.append("(")
            }
            if index == 3 {
                formatted.append(") ")
            }
            if index == 6 {
                formatted.append("-")
            }
            formatted.append(char)
        }
        
        return formatted
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
    @Binding var studentEmail: String
    @Binding var isStudentEmailValid: Bool
    
    private var isStudentSelected: Bool {
        selectedUsageInterest == "Student" || selectedUsageInterest == "Student Entrepreneur"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Let Us Set Up Your Experience")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                DropdownField(
                    placeholder: "Main Usage Interest",
                    options: usageInterestOptions,
                    selectedOption: $selectedUsageInterest
                )
                
                // Student Email Field - Only show when Student or Student Entrepreneur is selected
                if isStudentSelected {
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Student Email Address", text: $studentEmail)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isStudentEmailValid ? Color.clear : Color.red, lineWidth: 2)
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .onChange(of: studentEmail) { _ in
                                isStudentEmailValid = validateEmail(studentEmail)
                            }
                        
                        if !isStudentEmailValid && !studentEmail.isEmpty {
                            Text("Please enter a valid email address")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                CategorizedDropdownField(
                    placeholder: "Main Industry Interest",
                    categories: industryCategories,
                    selectedOption: $selectedIndustryInterest
                )
                
                Text("*You Will Get Your Password Upon Approval")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "004aad"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "ffde59"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                )
                .padding(.horizontal, 50)
                .opacity(isFormValid ? 1.0 : 0.6)
        }
        .disabled(!isFormValid || isSubmitting)
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
            HStack {
                Text(selectedOption ?? placeholder)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(
                        selectedOption == nil ?
                            Color(hex: "004aad").opacity(0.6) :
                            Color(hex: "004aad")
                    )
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: "004aad"))
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(12)
            .background(Color(.systemGray5))
            .cornerRadius(8)
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
            HStack {
                Text(selectedOption ?? placeholder)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(
                        selectedOption == nil ?
                        Color(hex: "004aad").opacity(0.6) :
                        Color(hex: "004aad")
                    )
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: "004aad"))
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(12)
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
    }
}

// MARK: - Welcome Email Function
extension Page3 {
    // Function to send welcome email to users with .edu emails
    private func sendWelcomeEmail(userId: Int, email: String) {
        guard let url = URL(string: "https://circlapp.online/api/users/send_welcome_email/") else {
            print("❌ Invalid URL for welcome email")
            return
        }
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "email": email,
            "user_type": "Student"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("❌ Failed to serialize welcome email data")
            return
        }
        
        print("📧 Sending welcome email request for user \(userId)")
        print("📧 Full request URL: \(url)")
        print("📧 Request headers: Content-Type=application/json")
        print("📧 Request payload: \(parameters)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Welcome email error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Welcome email response status: \(httpResponse.statusCode)")
                    
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Welcome email response: \(responseString)")
                    }
                    
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        print("✅ Welcome email sent successfully!")
                    } else {
                        print("❌ Welcome email failed with status: \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("📥 Error response: \(responseString)")
                        }
                    }
                } else {
                    print("❌ No HTTP response received for welcome email")
                }
            }
        }.resume()
    }
}

struct Page3_Previews: PreviewProvider {
    static var previews: some View {
        Page3()
    }
}
