import SwiftUI

struct Page5: View {
    @State private var birthday: String = ""
    @State private var isUnderage: Bool = false
    @State private var educationLevel: String? = nil
    @State private var institutionAttended: String = ""
    @State private var certifications: [String] = [] // Updated to hold multiple selections
    @State private var yearsOfExperience: String = ""
    @State private var personalityType: String = ""
    @State private var showInvalidPersonalityAlert: Bool = false
    @State private var navigateToPage6: Bool = false // Add this line
    @State private var showMissingFieldsAlert = false

    
    let educationOptions = [
        "No Formal Education",
        "Some High School",
        "High School Graduate or Equivalent",
        "Some College / Associate Degree",
        "Bachelor’s Degree",
        "Master’s Degree",
        "Doctorate / PhD"
    ]
    
    let certificationOptions = [
        "Business and Management": [
            "Project Management Professional (PMP)",
            "Certified ScrumMaster (CSM)",
            "Six Sigma (Green Belt, Black Belt, etc.)",
            "Certified Business Analysis Professional (CBAP)",
            "Certified Management Consultant (CMC)",
            "Chartered Financial Analyst (CFA)"
        ],
        "Technology and IT": [
            "Certified Information Systems Security Professional (CISSP)",
            "Certified Ethical Hacker (CEH)",
            "CompTIA A+",
            "Cisco Certified Network Associate (CCNA)",
            "AWS Certified Solutions Architect",
            "Microsoft Certified Azure Fundamentals",
            "Certified Information Systems Auditor (CISA)"
        ],
        "Healthcare": [
            "Registered Nurse (RN)",
            "Certified Medical Assistant (CMA)",
            "Certified Nursing Assistant (CNA)",
            "Board Certified Physician (MD, DO)",
            "Certified Radiologic Technologist (CRT)",
            "Certified Surgical Technologist (CST)",
            "Licensed Clinical Social Worker (LCSW)"
        ],
        "Legal and Compliance": [
            "Certified Legal Manager (CLM)",
            "Certified Paralegal (CP)",
            "Certified Fraud Examiner (CFE)",
            "Certified Compliance & Ethics Professional (CCEP)",
            "Licensed Attorney (JD, LLB)",
            "Certified Information Privacy Professional (CIPP)"
        ],
        "Finance and Accounting": [
            "Certified Public Accountant (CPA)",
            "Certified Management Accountant (CMA)",
            "Chartered Accountant (CA)",
            "Certified Internal Auditor (CIA)",
            "Financial Risk Manager (FRM)",
            "Certified Fraud Examiner (CFE)",
            "Certified Financial Planner (CFP)"
        ],
        "Education and Teaching": [
            "TESOL/TEFL",
            "Certified Teacher (varies by state/country)",
            "National Board Certification (NBC)",
            "Special Education Certification"
        ],
        "Human Resources": [
            "Professional in Human Resources (PHR)",
            "Senior Professional in Human Resources (SPHR)",
            "SHRM Certified Professional (SHRM-CP)",
            "Certified Employee Benefits Specialist (CEBS)",
            "Talent Acquisition Specialist (TAS)"
        ],
        "Engineering and Architecture": [
            "Professional Engineer (PE)",
            "Project Management Professional (PMP)",
            "Certified Energy Manager (CEM)",
            "Certified Manufacturing Engineer (CMfgE)",
            "Architectural Licensing"
        ],
        "Construction and Trades": [
            "Certified Construction Manager (CCM)",
            "Licensed Electrician",
            "Certified Welding Inspector (CWI)",
            "OSHA Safety Certifications"
        ],
        "Sales and Marketing": [
            "Certified Sales Professional (CSP)",
            "Google Ads Certification",
            "HubSpot Inbound Marketing Certification",
            "Certified Digital Marketing Professional (CDMP)",
            "Salesforce Certified Administrator"
        ],
        "Hospitality and Tourism": [
            "Certified Meeting Professional (CMP)",
            "Certified Hospitality Administrator (CHA)",
            "Certified Travel Associate (CTA)"
        ],
        "Real Estate": [
            "Licensed Real Estate Agent/Broker",
            "Certified Commercial Investment Member (CCIM)",
            "Accredited Buyer’s Representative (ABR)",
            "Certified Residential Specialist (CRS)"
        ],
        "Environmental and Sustainability": [
            "Leadership in Energy and Environmental Design (LEED)",
            "Certified Environmental Professional (CEP)",
            "Certified Hazardous Materials Manager (CHMM)"
        ],
        "Creative Arts and Design": [
            "Adobe Certified Expert (ACE)",
            "Certified Graphic Designer (CGD)",
            "Certified Web Designer",
            "Certified Fashion Designer"
        ],
        "Supply Chain and Logistics": [
            "Certified Supply Chain Professional (CSCP)",
            "Certified in Production and Inventory Management (CPIM)",
            "Certified Logistics Associate (CLA)"
        ],
        "Transportation and Aviation": [
            "Commercial Pilot License (CPL)",
            "Certified Flight Instructor (CFI)",
            "Air Traffic Controller Certification",
            "Certified Transportation Professional (CTP)"
        ]
    ]
    
    func formatDateString(_ input: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMddyy" // Expected input format (e.g., "070496")

        if let date = inputFormatter.date(from: input) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd" // Convert to "YYYY-MM-DD"
            return outputFormatter.string(from: date)
        }

        return "" // Return empty if the format is invalid
    }

    func submitPersonalDetails(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://34.136.164.254:8000/api/users/update-personal-details/") else {
            print("❌ Invalid API URL")
            completion(false)
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        
        // ✅ Debugging: Check if user_id is correct
        print("📌 Stored user_id in UserDefaults: \(userId)")

        // ✅ If user_id is missing, show an error and stop
        if userId == 0 {
            print("❌ User ID not found. Make sure you completed registration on Page 3.")
            completion(false)
            return
        }

        let personalDetails: [String: Any] = [
            "user_id": userId,
            "birthday": formatDateString(birthday),
            "education_level": educationLevel ?? "",
            "institution_attended": institutionAttended,
            "certificates": certifications,
            "years_of_experience": Int(yearsOfExperience) ?? 0,
            "personality_type": personalityType
        ]

        // ✅ Debugging: Print the JSON payload before sending
        if let jsonData = try? JSONSerialization.data(withJSONObject: personalDetails),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🚀 Sending Personal Details JSON: \(jsonString)")
        } else {
            print("❌ Failed to encode JSON")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: personalDetails) else {
            print("❌ Failed to encode data")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Request Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        print("✅ Personal Details updated successfully.")
                        completion(true)
                    } else {
                        print("❌ Failed to update personal details. Status code: \(httpResponse.statusCode)")
                        completion(false)
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Response Body: \(responseString)")
                }
            }
        }
        task.resume()
    }

    var body: some View {
        NavigationView { // Wrap the entire view in a NavigationView
            ZStack {
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Create Your Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    
                    HStack {
                        Text("Personal Information")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    VStack(spacing: 15) {
                        TextField("Birthday (MM/DD/YY)", text: $birthday)
                            .onChange(of: birthday) { _ in
                                formatBirthday()
                                validateBirthday()
                            }
                            .textFieldStyle(RoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                            .alert("You must be 18 years or older to sign up.", isPresented: $isUnderage) {
                                Button("OK", role: .cancel) { }
                            }
                        
                        DropdownField(
                            placeholder: "Education Level",
                            options: educationOptions,
                            selectedOption: $educationLevel
                        )
                        .frame(maxWidth: 300, maxHeight: 50)
                        
                        TextField("Institution Attended", text: $institutionAttended)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                        
                        MultiSelectDropdownField(
                            placeholder: "Select Certifications",
                            options: certificationOptions,
                            selectedOptions: $certifications
                        )

                        TextField("Years of Experience", text: $yearsOfExperience)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                        
                        TextField("Personality Type (XXXX-Y)", text: $personalityType)
                            .autocapitalization(.allCharacters)
                            .onChange(of: personalityType) { _ in validatePersonalityType() }
                            .textFieldStyle(RoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                            .alert("Invalid Personality Type format. Use XXXX-Y.", isPresented: $showInvalidPersonalityAlert) {
                                Button("OK", role: .cancel) { }
                            }
                        
                        Link("Take the 16 personalities test", destination: URL(string: "https://www.16personalities.com")!)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hexCode: "ffde59"))
                            .underline(true, color: Color(hexCode: "ffde59"))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // ✅ Updated Next Button with Proper Navigation
                    Button(action: {
                        if birthday.isEmpty ||
                           educationLevel == nil ||
                           institutionAttended.isEmpty ||
                           certifications.isEmpty ||
                           yearsOfExperience.isEmpty ||
                           personalityType.isEmpty {
                            showMissingFieldsAlert = true
                        } else {
                            submitPersonalDetails { success in
                                if success {
                                    navigateToPage6 = true
                                }
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hexCode: "004aad"))
                            .frame(maxWidth: 300)
                            .padding(.vertical, 15)
                            .background(Color(hexCode: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 50)
                    }


                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar
            .alert("Missing Fields", isPresented: $showMissingFieldsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill out all fields before continuing.")
            }

            .background(
                NavigationLink(
                    destination: Page6(),
                    isActive: $navigateToPage6,
                    label: { EmptyView() }
                )
            )
        }
    }


    
    private func formatBirthday() {
        // Remove any non-numeric characters and ensure a 6-character MMDDYY string
        let filtered = birthday.filter { $0.isNumber }
        let formatted = filtered.prefix(6).enumerated().map { (index, char) -> String in
            if index == 2 || index == 4 {
                return "/\(char)"
            } else {
                return String(char)
            }
        }.joined()
        birthday = formatted
    }
    
    private func validateBirthday() {
        let filtered = birthday.filter { $0.isNumber }
        let limitedInput = String(filtered.prefix(6))
        
        if limitedInput.count < 6 {
            birthday = limitedInput
            return
        }
        
        let monthString = String(limitedInput.prefix(2))
        let dayString = String(limitedInput.dropFirst(2).prefix(2))
        
        if let month = Int(monthString), month > 12 {
            birthday = String(monthString)
        } else if let day = Int(dayString), day > 31 {
            birthday = String(limitedInput.prefix(4))
        } else {
            birthday = limitedInput
        }
    }
    
    private func validatePersonalityType() {
        let sanitizedInput = personalityType.filter { $0.isUppercase }
        
        // Limit input to exactly 5 characters including the dash
        if sanitizedInput.count == 5 {
            if let dashIndex = personalityType.firstIndex(of: "-"),
               dashIndex == personalityType.index(personalityType.startIndex, offsetBy: 4) {
                let g = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 0)]
                let h = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 1)]
                let v = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 2)]
                let b = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 3)]
                let y = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 4)]
                
                let validG = ["E", "I"].contains(g)
                let validH = ["S", "N"].contains(h)
                let validV = ["T", "F"].contains(v)
                let validB = ["J", "P"].contains(b)
                let validY = ["A", "T"].contains(y)
                
                if !(validG && validH && validV && validB && validY) {
                    showInvalidPersonalityAlert = true
                }
            } else {
                showInvalidPersonalityAlert = true
            }
        } else {
            showInvalidPersonalityAlert = false
        }
    }
}

// Custom Regex Extension (for matching format)
extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

// DropdownField Component
struct DropdownField2: View {
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

// Multi-Select Dropdown Component
struct MultiSelectDropdownField: View {
    var placeholder: String
    var options: [String: [String]] // Key as category, value as options
    @Binding var selectedOptions: [String]

    var body: some View {
        Menu {
            ForEach(options.keys.sorted(), id: \.self) { category in
                // Category Header
                Text(category)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 5)

                // Options under each category
                ForEach(options[category] ?? [], id: \.self) { option in
                    Button {
                        if selectedOptions.contains(option) {
                            // Remove if already selected
                            selectedOptions.removeAll { $0 == option }
                        } else {
                            // Add if not selected
                            selectedOptions.append(option)
                        }
                    } label: {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectedOptions.contains(option) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
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
                    Text(selectedOptions.isEmpty ? placeholder : selectedOptions.joined(separator: ", "))
                        .foregroundColor(
                            selectedOptions.isEmpty ?
                                Color(hexCode: "004aad").opacity(0.6) :
                                Color(hexCode: "004aad")
                        )
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hexCode: "004aad"))
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(maxWidth: 300, maxHeight: 50)
    }
}

// Custom TextField Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color(hexCode: "d9d9d9"))
            .cornerRadius(10)
            .font(.system(size: 20))
            .foregroundColor(Color(hexCode: "004aad"))
    }
}

// Preview
struct Page5_Previews: PreviewProvider {
    static var previews: some View {
        Page5()
    }
}
