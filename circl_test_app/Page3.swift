import SwiftUI

struct Page3: View {
    @State private var selectedUsageInterest: String? = nil
    @State private var selectedIndustryInterest: String? = nil
    
    // State variables for text fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    
    // State for submission handling
    @State private var isSubmitting: Bool = false
    @State private var submissionMessage: String = ""
    @State private var navigateToPage4: Bool = false
    @State private var showAlert = false

    
    let usageInterestOptions = [
        "Sell a Skill",
        "Make Investments",
        "Share Knowledge",
        "Be Part of the Community",
        "Find Investors",
        "Find Mentors",
        "Find Co-Founder/s",
        "Network with Entrepreneurs",
        "Scale Your Business",
        "Start Your Business"
    ]
    
    let industryInterestOptions = [
        "Not Mentioned",
        "Non-Profit Organization",
        "Public Administration",
        "Arts, Design, and Recreation",
        "Hospitality and Food Services",
        "Entertainment and Media",
        "Professional Services",
        "Education",
        "Health Care and Social Assistance",
        "Real Estate",
        "Finance and Insurance",
        "Telecommunications",
        "Information Technology",
        "Transportation and Logistics",
        "Wholesale",
        "Retail",
        "Utilities",
        "Manufacturing",
        "Construction",
        "Mining and Extraction",
        "Agriculture"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)
                
                // Clouds and other UI components...
                
                VStack(spacing: 20) {
                    TitleSection()
                    Spacer()
                    PersonalInformationSection(firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber)
                    Spacer()
                    ExperienceSetupSection(
                        usageInterestOptions: usageInterestOptions,
                        industryInterestOptions: industryInterestOptions,
                        selectedUsageInterest: $selectedUsageInterest,
                        selectedIndustryInterest: $selectedIndustryInterest
                    )
                    Spacer()
                    NextButton(
                        isSubmitting: $isSubmitting,
                        submissionMessage: $submissionMessage,
                        action: {
                            if firstName.isEmpty || lastName.isEmpty || email.isEmpty || phoneNumber.isEmpty || selectedUsageInterest == nil || selectedIndustryInterest == nil {
                                showAlert = true
                            } else {
                                submitUserInfo()
                            }
                        }
                    )

                    Spacer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Missing Fields"),
                        message: Text("Please fill out all fields before continuing."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                .padding(.horizontal, 40)
            }
            .overlay(CloudsOverlay(), alignment: .topLeading)
            .background(
                NavigationLink(
                    destination: Page4(),
                    isActive: $navigateToPage4,
                    label: { EmptyView() }
                )
            )
        }
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
            "phone": phoneNumber,
            "main_usage": selectedUsageInterest ?? "",
            "industry_interest": selectedIndustryInterest ?? ""
        ]

        // ✅ Debugging: Print the JSON payload before sending
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

        isSubmitting = true // Start submission

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false // Stop submission

                if let error = error {
                    submissionMessage = "Error: \(error.localizedDescription)"
                    print("❌ Request Error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 201 {
                        submissionMessage = "Success! User registered."
                        print("✅ User registered successfully.")

                        // ✅ Extract user_id from response and store it
                        if let data = data,
                           let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let userId = responseDict["user_id"] as? Int {
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(userId, forKey: "user_id")
                                UserDefaults.standard.synchronize() // ✅ Ensures immediate storage
                                print("📌 Stored user_id in UserDefaults: \(userId)")
                            }
                        } else {
                            print("❌ Failed to extract user_id from response.")
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToPage4 = true // Navigate to Page4 after success
                        }
                    } else {
                        submissionMessage = "Failed to register user. Status code: \(httpResponse.statusCode)"
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

// MARK: - Subviews

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
    @Binding var phoneNumber: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personal Information")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 15) {
                StyledTextField(placeholder: "First Name", text: $firstName)
                StyledTextField(placeholder: "Last Name", text: $lastName)
                StyledTextField(placeholder: "Email", text: $email)
                StyledTextField(placeholder: "Phone Number", text: $phoneNumber)
            }
        }
    }
}

struct ExperienceSetupSection: View {
    let usageInterestOptions: [String]
    let industryInterestOptions: [String]
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
                DropdownField(
                    placeholder: "Main Industry Interest",
                    options: industryInterestOptions,
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
    @Binding var submissionMessage: String

    var action: () -> Void

    var body: some View {
        VStack {
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
                    .background(isSubmitting ? Color.gray : Color(hexCode: "ffde59"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .disabled(isSubmitting) // Disable button while submitting

            if !submissionMessage.isEmpty {
                Text(submissionMessage)
                    .foregroundColor(submissionMessage.contains("Success") ? .green : .red)
                    .padding()
            }
        }
    }
}

// Other subviews (CloudsOverlay, StyledTextField, DropdownField) remain the same...


struct CloudsOverlay: View {
    var body: some View {
        ZStack {
            createCloud(
                xOffsets: [-150, -120, -110, -90, -50, -40],
                yOffsets: [-100, -80, -60, -40, -30, -20],
                sizes: [120, 100, 90, 80, 70, 60]
            )
        }
    }

    private func createCloud(xOffsets: [CGFloat], yOffsets: [CGFloat], sizes: [CGFloat]) -> some View {
        ForEach(0..<xOffsets.count, id: \.self) { index in
            Circle()
                .fill(Color.white)
                .frame(width: sizes[index], height: sizes[index])
                .offset(x: xOffsets[index], y: yOffsets[index])
        }
    }
}

struct StyledTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
                .frame(height: 50)

            TextField(placeholder, text: $text)
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

struct Page3View_Previews: PreviewProvider {
    static var previews: some View {
        Page3()
    }
}
