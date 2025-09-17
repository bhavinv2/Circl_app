import SwiftUI

struct Page9: View {
    @State private var businessName: String = ""
    @State private var selectedScaleType: String? = nil
    @State private var selectedBusinessStage: String? = nil
    @State private var selectedRevenue: String? = nil
    @State private var selectedIndustry: String? = nil
    @State private var businessLocation: String = ""
    @State private var isIncorporated: Bool = false
    @State private var navigateToPage10 = false
    @State private var showMissingFieldsAlert = false


    // The available scale types
    let scaleTypes = [
        "Micro Business", "Small Business", "Medium Sized Business",
        "Large Business", "Enterprise", "Venture Scale",
        "Startup", "Freelancer/Solopreneur", "Non-Profit Organization", "Franchise"
    ]
    
    // The available business stages
    let businessStages = [
        "Idea/Concept", "Pre-Seed", "Seed", "Early Stage/Growth",
        "Expansion", "Maturity", "Pre-Exit", "Exit/Acquisition"
    ]
    
    // The available revenue ranges (reversed order)
    let revenueRanges = [
        "$1,000,000,000+", "$100,000,001-1,000,000,000", "$10,000,001-100,000,000",
        "$1,000,001-10,000,000", "$100,001-1,000,000", "$0-100,000"
    ]
    
    // The industry categories and their respective options (flipped order)
    let industries = [
        ("Not Mentioned", []),
        ("Agriculture", [
            "Crop Production", "Livestock Farming", "Aquaculture", "Dairy Farming", "Forestry", "Agricultural Support Services"
        ]),
        ("Mining and Extraction", [
            "Coal Mining", "Oil and Gas Extraction", "Metal Ore Mining", "Nonmetallic Mineral Mining", "Quarrying", "Renewable Resource Extraction"
        ]),
        ("Construction", [
            "Residential Building Construction", "Commercial Building Construction", "Civil Engineering", "Specialized Construction", "Heavy and Civil Engineering Construction", "Construction Support Services"
        ]),
        ("Manufacturing", [
            "Food and Beverage Manufacturing", "Textile Manufacturing", "Electronics Manufacturing", "Automobile Manufacturing", "Chemical Manufacturing", "Machinery Manufacturing", "Furniture Manufacturing"
        ]),
        ("Utilities", [
            "Electric Power Generation", "Natural Gas Distribution", "Water Treatment and Distribution", "Sewage Treatment", "Waste Management", "Energy Transmission"
        ]),
        ("Retail", [
            "Grocery Stores", "Clothing and Apparel Stores", "Electronics Retailers", "Home Goods and Furniture Stores", "Sporting Goods Retailers", "E-commerce Platforms", "Pharmacies and Drug Stores"
        ]),
        ("Wholesale", [
            "Durable Goods Wholesale", "Non-Durable Goods Wholesale", "Wholesale Distributors", "Importers and Exporters"
        ]),
        ("Real Estate", [
            "Residential Real Estate", "Commercial Real Estate", "Real Estate Development", "Property Management", "Real Estate Investment Trusts (REITs)"
        ]),
        ("Health Care and Social Assistance", [
            "Hospitals and Clinics", "Outpatient Care Centers", "Nursing and Residential Care Facilities", "Home Health Care", "Mental Health and Substance Abuse Services", "Social Assistance", "Medical Equipment and Supplies"
        ]),
        ("Education", [
            "Primary and Secondary Schools", "Higher Education", "Vocational and Technical Education", "Educational Support Services", "Online Education and E-Learning", "Educational Publishing"
        ]),
        ("Arts, Design, and Recreation", [
            "Graphic Design and Branding", "Performing Arts", "Fine Arts", "Sports and Recreation", "Museums and Cultural Institutions", "Amusement Parks and Zoos"
        ]),
        ("Entertainment and Media", [
            "Film Production and Distribution", "Music Production and Distribution", "Television and Radio Broadcasting", "Video Game Development and Publishing", "Publishing", "Digital Media and Content Creation", "Event Management and Production"
        ]),
        ("Finance and Insurance", [
            "Banking Services", "Insurance", "Investment Services", "Fintech", "Credit Agencies and Rating Services"
        ]),
        ("Information Technology", [
            "Software Development", "IT Services", "Hardware Manufacturing", "Cybersecurity Services", "Data Centers and Hosting Services", "Artificial Intelligence and Machine Learning", "Blockchain and Cryptocurrencies"
        ]),
        ("Telecommunications", [
            "Wireless Telecommunications", "Cable and Satellite TV Providers", "Internet Service Providers", "Satellite Communications", "Telecom Equipment Manufacturing", "Mobile Virtual Network Operators (MVNOs)"
        ]),
        ("Transportation and Logistics", [
            "Air Transportation", "Rail Transportation", "Maritime Shipping", "Truck Transportation", "Warehousing and Storage", "Logistics Support Services", "Courier and Delivery Services"
        ]),
        ("Non-Profit Organization", [
            "Charities and Foundations", "Social Advocacy and Political Organizations", "Religious Organizations", "Environmental Organizations", "Cultural and Arts Organizations", "International Development and Humanitarian Aid"
        ]),
        ("Public Administration", [
            "Government Services", "Public Policy and Regulation", "Public Safety", "Defense and National Security", "Urban Planning and Development"
        ])
    ]
    
    func submitBusinessInfo() {
        guard let url = URL(string: "https://circlapp.online/api/users/update-business-info/") else {
            print("❌ Invalid API URL")
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        print("📌 Debug: Sending business info for user_id = \(userId)")
        if userId == 0 {
            print("❌ User ID not found. Ensure registration is complete on Page 3.")
            return
        }

        let businessData: [String: Any] = [
            "user_id": userId,
            "business_name": businessName,
            "scale_type": selectedScaleType ?? "",
            "business_stage": selectedBusinessStage ?? "",
            "business_revenue": selectedRevenue ?? "",
            "industry": selectedIndustry ?? "",
            "business_location": businessLocation,
            "is_legally_incorporated": isIncorporated
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: businessData) else {
            print("❌ Failed to encode data")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Request Error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        print("✅ Business info updated successfully.")
                        navigateToPage10 = true // ✅ Navigate to Page 10
                    } else {
                        print("❌ Failed to update business info. Status code: \(httpResponse.statusCode)")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Response Body: \(responseString)")
                }
            }
        }.resume()
    }

    var body: some View {
            ZStack {
                // Background Color
                Color(hex: "004aad")
                    .edgesIgnoringSafeArea(.all)
                
                
                // Top Left Cloud (Flipped from Top Right Cloud)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 80), y: -UIScreen.main.bounds.height / 2 + 0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 130), y: -UIScreen.main.bounds.height / 2 + 0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: -UIScreen.main.bounds.height / 2 + 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 110), y: -UIScreen.main.bounds.height / 2 + 50)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -(UIScreen.main.bounds.width / 2 + 170), y: -UIScreen.main.bounds.height / 2 + 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -(UIScreen.main.bounds.width / 2 + 210), y: -UIScreen.main.bounds.height / 2 + 60)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: -(UIScreen.main.bounds.width / 2 + 90), y: -UIScreen.main.bounds.height / 2 + 50)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: -(UIScreen.main.bounds.width / 2 + 50), y: -UIScreen.main.bounds.height / 2 + 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 110, height: 110)
                        .offset(x: -(UIScreen.main.bounds.width / 2 + 150), y: -UIScreen.main.bounds.height / 2 + 80)
                }

                // Bottom Left Cloud (Flipped from Bottom Right Cloud)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 60), y: UIScreen.main.bounds.height / 2 - 60)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 90), y: UIScreen.main.bounds.height / 2 - 50)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 50), y: UIScreen.main.bounds.height / 2 - 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 110)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: -(UIScreen.main.bounds.width / 2 - 135), y: UIScreen.main.bounds.height / 2 - 30)
                }

                // Middle Right Cloud (Flipped from Middle Left Cloud)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: UIScreen.main.bounds.width / 2 - 60, y: 2 + 50)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: UIScreen.main.bounds.width / 2 - 40, y: -20)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: UIScreen.main.bounds.width / 2 - 10, y: 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: UIScreen.main.bounds.width / 2 - 90, y: -30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: UIScreen.main.bounds.width / 2 - 125, y: 20)
                }
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Title
                        Text("Your Business Profile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "ffde59"))
                        
                        // Separator
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                        
                        // Subtitle
                        Text("Basic Business Information")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 7)
                        
                        VStack(spacing: 15) {
                            // Business Name Field
                            TextField("Business Name", text: $businessName)
                                .padding(15)
                                .background(Color(hex: "d9d9d9"))
                                .cornerRadius(10)
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "004aad"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "004aad"), lineWidth: 2)
                                )
                                .frame(maxWidth: .infinity)
                            
                            // Potential Scale Type Dropdown
                            DropdownField(
                                placeholder: "Potential Scale Type",
                                options: scaleTypes,
                                selectedOption: $selectedScaleType
                            )
                            .frame(maxWidth: 300, maxHeight: 50)
                            
                            // Business Stage Dropdown
                            DropdownField(
                                placeholder: "Business Stage",
                                options: businessStages,
                                selectedOption: $selectedBusinessStage
                            )
                            .frame(maxWidth: 300, maxHeight: 50)
                            
                            // Current Revenue Annually Dropdown
                            DropdownField(
                                placeholder: "Current Revenue Annually",
                                options: revenueRanges,
                                selectedOption: $selectedRevenue
                            )
                            .frame(maxWidth: 300, maxHeight: 50)
                            
                            // Industry Dropdown
                            DropdownField3(
                                placeholder: "Industry",
                                options: industries.flatMap { section in
                                    [section.0] + section.1 + ["Other"]
                                }, // Reverted to original order (no reverse)
                                selectedOption: $selectedIndustry,
                                industries: industries
                            )
                            .frame(maxWidth: 300, maxHeight: 50)
                            
                            // Other Input Fields
                            TextField("Location (City, State Abbreviation)", text: $businessLocation)
                                .padding(15)
                                .background(Color(hex: "d9d9d9"))
                                .cornerRadius(10)
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "004aad"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "004aad"), lineWidth: 2)
                                )
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, 7)
                        
                        // Checkbox (Toggle) for "Is this business legally incorporated?"
                        HStack {
                            Button(action: {
                                if businessName.isEmpty ||
                                   selectedScaleType == nil ||
                                   selectedBusinessStage == nil ||
                                   selectedRevenue == nil ||
                                   selectedIndustry == nil ||
                                   businessLocation.isEmpty {
                                    showMissingFieldsAlert = true
                                } else {
                                    submitBusinessInfo()
                                }
                            }) {

                                Image(systemName: isIncorporated ? "checkmark.square" : "square")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Is this business legally incorporated?")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 50)
                        
                        Spacer()
                        
                        // Next Button
                        Button(action: {
                            submitBusinessInfo() // ✅ Sends Business Info & Marks User as Business Owner
                        }) {
                            Text("Next")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "004aad"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color(hex: "ffde59"))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .padding(.horizontal, 50)
                                .padding(.bottom, 20)
                        }
                        
                        // ✅ Navigation to Page 10 will be handled by navigationDestination
                        
                        Spacer()
                    }
                }
                .dismissKeyboardOnScroll()
                
            }
            .navigationBarHidden(true) // ✅ Hides default navigation bar
            .alert("Missing Fields", isPresented: $showMissingFieldsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill out all fields before continuing.")
            }
            .navigationDestination(isPresented: $navigateToPage10) {
                Page10()
            }
    }
}

// Custom Dropdown Component (with industries passed in)
struct DropdownField3: View {
    var placeholder: String
    var options: [String]
    @Binding var selectedOption: String?
    var industries: [(String, [String])]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                // Check if the option is a header
                if industries.flatMap({ $0.1 }).contains(option) || option == "Other" {
                    Button(option) {
                        selectedOption = option
                    }
                } else {
                    // Display headers as styled section
                    Text(option)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                        .background(Color(hex: "004aad"))
                        .padding(.horizontal, 10)
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
                                Color(hex: "004aad").opacity(0.6) :
                                Color(hex: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hex: "004aad"))
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(maxWidth: .infinity) // Make the dropdown width match the input field
    }
}

// Custom Input Field Component
struct InputField: View {
    var placeholder: String

    var body: some View {
        TextField(placeholder, text: .constant(""))
            .padding(15)
            .background(Color(hex: "d9d9d9"))
            .cornerRadius(10)
            .font(.system(size: 20))
            .foregroundColor(Color(hex: "004aad"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "004aad"), lineWidth: 2)
            )
            .frame(maxWidth: .infinity)
    }
}

// Preview
struct Page9View_Previews: PreviewProvider {
    static var previews: some View {
        Page9()
    }
}
