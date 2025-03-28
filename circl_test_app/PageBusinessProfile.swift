import SwiftUI

struct BusinessProfile: Codable {
    let id: Int?
    let business_name: String?
    let about: String?
    let vision: String?
    let mission: String?
    let company_culture: String?
    let product_service: String?
    let traction: String?
    let unique_selling_proposition: String?
    let revenue_streams: String?
    let advisors_mentors: String?
    let cofounders: String?
    let key_hires: String?
    let amount_raised: String?
    let financial_projections: String?
    let funding_stage: String?
    let use_of_funds: String?
    let investment: String?
    let mentorship: String?
    let other: String?
    let roles_needed: String?
    let user: Int?
    let pricing_strategy: String?
    let industry: String?
    let type: String?
    let stage: String?
    let revenue: String?
    let location: String?
    let looking_for: String?
}

// MARK: - Main View
struct PageBusinessProfile: View {
    // MARK: - Placeholder Data
    @State private var isEditing: Bool = false
    @State private var showBusinessOwnerMessage = false
    
    @State private var companyName: String = "Company Name"
    @State private var companyLogo: String = "companyLogo"
    @State private var companyWebsiteURL: URL? = nil
    @State private var aboutText: String = "Write about the company here..."
    @State private var companyDetails: [String: String] = [
        "Industry": "Technology",
        "Type": "Startup",
        "Stage": "Seed",
        "Revenue": "Pre-revenue",
        "Location": "San Francisco, CA",
        "Looking for": "Investors, Mentors, Partners"
    ]
    @State private var values: [String: String] = [
        "Vision": "To revolutionize connectivity among entrepreneurs.",
        "Mission": "To empower entrepreneurs by fostering meaningful connections.",
        "Company Culture": "Innovative, inclusive, and results-driven."
    ]
    @State private var solutionDetails: [String: String] = [
        "Product/Service": "Describe the product or service here.",
        "Unique Selling Proposition": "Highlight what makes this unique.",
        "Traction/Progress": "Summarize the milestones achieved."
    ]
    @State private var businessModelDetails: [String: String] = [
        "Revenue Streams": "List the revenue streams.",
        "Pricing Strategy": "Outline the pricing approach."
    ]
    @State private var teamDetails: [String: String] = [
        "CoFounders": "List of cofounders.",
        "Key Hires": "List of key hires.",
        "Advisors/Mentors": "List of advisors or mentors."
    ]
    @State private var financialsDetails: [String: String] = [
        "Funding Stage": "Specify the funding stage.",
        "Amount Raised": "Total amount raised.",
        "Use of Funds": "Describe how funds are utilized.",
        "Financial Projections": "Summarize projections."
    ]
    @State private var lookingForDetails: [String: String] = [
        "Roles Needed": "List roles needed.",
        "Mentorship": "Specify areas where mentorship is needed.",
        "Investment": "Describe investment needs.",
        "Other": "Other needs or requirements."
    ]
    @State private var contactPerson: String = "John Doe"
    @StateObject private var viewModel = BusinessProfileViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    headerSection
                    scrollableSection
                    footerSection
                }
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    if let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
                        viewModel.fetchProfile(for: userId)
                    } else {
                        print("⚠️ User ID not found in UserDefaults")
                    }
                }
                .onReceive(viewModel.$profile) { profile in
                    guard let profile = profile, !isEditing else { return }
                    
                    showBusinessOwnerMessage = !hasBusinessInfo(profile: profile)
                    
                    companyName = profile.business_name ?? ""
                    aboutText = profile.about ?? ""
                    
                    companyDetails = [
                        "Industry": profile.industry ?? "",
                        "Type": profile.type ?? "",
                        "Stage": profile.stage ?? "",
                        "Revenue": profile.revenue ?? "",
                        "Location": profile.location ?? "",
                        "Looking for": profile.looking_for ?? ""
                    ]
                    
                    values = [
                        "Vision": profile.vision ?? "",
                        //"Mission": profile.mission ?? "",
                        "Company Culture": profile.company_culture ?? ""
                    ]
                    
                    solutionDetails = [
                        "Product/Service": profile.product_service ?? "",
                        "Unique Selling Proposition": profile.unique_selling_proposition ?? "",
                        "Traction/Progress": profile.traction ?? ""
                    ]
                    
                    businessModelDetails = [
                        "Revenue Streams": profile.revenue_streams ?? "",
                        "Pricing Strategy": profile.pricing_strategy ?? ""
                    ]
                    
                    teamDetails = [
                        "CoFounders": profile.cofounders ?? "",
                        "Key Hires": profile.key_hires ?? "",
                        "Advisors/Mentors": profile.advisors_mentors ?? ""
                    ]
                    
                    financialsDetails = [
                        "Funding Stage": profile.funding_stage ?? "",
                        "Amount Raised": profile.amount_raised ?? "",
                        "Use of Funds": profile.use_of_funds ?? "",
                        "Financial Projections": profile.financial_projections ?? ""
                    ]
                    
                    lookingForDetails = [
                        "Roles Needed": profile.roles_needed ?? "",
                        "Mentorship": profile.mentorship ?? "",
                        "Investment": profile.investment ?? "",
                        "Other": profile.other ?? ""
                    ]
                }
                
                // Overlay for non-business owners
                if showBusinessOwnerMessage {
                    VStack {
                        // Dark overlay background
                        Color.gray.opacity(0.7)
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Covers the content
                            .onTapGesture {}

                        // Add some padding and set a max width/height for the overlay message
                        VStack {
                            Spacer() // Push message towards top
                            Text("Business owners only")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .frame(maxWidth: 300) // Adjust the max width
                                .padding(.bottom, 700) // Add padding to push message away from footer
                        }
                        .frame(maxHeight: 40) // Adjust the height to prevent overlaying footer
                    }
                }

            }
        }
    }
    
    private func hasBusinessInfo(profile: BusinessProfile) -> Bool {
        return profile.industry != nil ||
               profile.location != nil ||
               profile.business_name != nil ||
               profile.about != nil
    }
    
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer() // Moves the "Edit" button towards the center

                // Edit button centered
                Button(action: {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }

                Spacer() // Balances the layout and keeps "Edit" centered

                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 50, height: 40)
                                .foregroundColor(.white)
                        }

                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad")) // Updated blue color
        }
    }

    
    private var scrollableSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                companyOverviewSection
                aboutSection
                companyDetailsSection
                valuesSection
                solutionSection
                businessModelSection
                teamSection
//                financialsFundingSection
//                lookingForSection
//                contactUsSection
            }
            .padding()
            .background(Color(.systemGray4))
        }
    }
    
    private var companyOverviewSection: some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        Image(companyLogo)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(10)
                
                if let companyWebsiteURL = companyWebsiteURL {
                    Link(companyName, destination: companyWebsiteURL)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .underline()
                } else {
                    Text(companyName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.fromHex("004aad"))
            .cornerRadius(10)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.headline)
                .foregroundColor(.black)
            
            if isEditing {
                TextEditor(text: $aboutText)
                    .frame(height: 120)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
            } else {
                Text(aboutText)
                    .frame(height: 120)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private var companyDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Company Overview")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(companyDetails.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text(companyDetails[key] ?? "")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var valuesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Values")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(["Vision", "Company Culture"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { values[key, default: ""] },
                                set: { values[key] = $0 }
                            ))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(values[key, default: ""])
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var solutionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Solution")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(["Product/Service", "Unique Selling Proposition", "Traction/Progress"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { solutionDetails[key, default: ""] },
                                set: { solutionDetails[key] = $0 }
                            ))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(solutionDetails[key, default: ""])
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var businessModelSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Business Model")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(["Revenue Streams", "Pricing Strategy"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { businessModelDetails[key, default: ""] },
                                set: { businessModelDetails[key] = $0 }
                            ))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(businessModelDetails[key, default: ""])
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The Team")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(["CoFounders", "Key Hires", "Advisors/Mentors"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { teamDetails[key, default: ""] },
                                set: { teamDetails[key] = $0 }
                            ))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(teamDetails[key, default: ""])
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
//    private var financialsFundingSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Financials/Funding")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.black)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(financialsDetails.keys.sorted(), id: \.self) { key in
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(key)
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.gray)
//                        
//                        if isEditing {
//                            TextEditor(text: Binding(
//                                get: { financialsDetails[key, default: ""] },
//                                set: { financialsDetails[key] = $0 }
//                            ))
//                            .frame(height: 80)
//                            .padding(8)
//                            .background(Color(.systemGray6))
//                            .cornerRadius(8)
//                        } else {
//                            Text(financialsDetails[key, default: ""])
//                                .foregroundColor(.primary)
//                        }
//                    }
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.gray, lineWidth: 1)
//            )
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//    }
//    
//    private var lookingForSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Looking For")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.black)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(lookingForDetails.keys.sorted(), id: \.self) { key in
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(key)
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.gray)
//                        
//                        if isEditing {
//                            TextEditor(text: Binding(
//                                get: { lookingForDetails[key, default: ""] },
//                                set: { lookingForDetails[key] = $0 }
//                            ))
//                            .frame(height: 80)
//                            .padding(8)
//                            .background(Color(.systemGray6))
//                            .cornerRadius(8)
//                        } else {
//                            Text(lookingForDetails[key, default: ""])
//                                .foregroundColor(.primary)
//                        }
//                    }
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.gray, lineWidth: 1)
//            )
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//    }
//    
//    private var contactUsSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Contact Us")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.black)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text(contactPerson)
//                    .foregroundColor(Color.fromHex("004aad"))
//                    .underline()
//                    .onTapGesture {
//                        // Navigate to John Doe's profile
//                    }
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.gray, lineWidth: 1)
//            )
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//    }
    
    private var footerSection: some View {
        HStack(spacing: 15) {
            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
            }
            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "briefcase.fill")
            }
            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "captions.bubble.fill")
            }
            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "building.columns.fill")
            }
            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "newspaper")
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
    }
    
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
    
    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text("\(title): ")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
    
    func saveChanges() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ User ID not found in UserDefaults")
            return
        }

        let url = URL(string: "http://34.136.164.254:8000/api/users/business-profile/\(userId)/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "about": aboutText,
            "vision": values["Vision", default: ""],
            "mission": values["Mission", default: ""],
            "company_culture": values["Company Culture", default: ""],
            "product_service": solutionDetails["Product/Service", default: ""],
            "unique_selling_proposition": solutionDetails["Unique Selling Proposition", default: ""],
            "traction": solutionDetails["Traction/Progress", default: ""],
            "revenue_streams": businessModelDetails["Revenue Streams", default: ""],
            "pricing_strategy": businessModelDetails["Pricing Strategy", default: ""],
            "advisors_mentors": teamDetails["Advisors/Mentors", default: ""],
            "cofounders": teamDetails["CoFounders", default: ""],
            "key_hires": teamDetails["Key Hires", default: ""],
            "industry": companyDetails["Industry", default: ""],  // Add industry field
            "location": companyDetails["Location", default: ""],  // Add location field
            "revenue": companyDetails["Revenue", default: ""],  // Add revenue field
            "stage": companyDetails["Stage", default: ""],  // Add stage field
            "type": companyDetails["Type", default: ""],  // Add type field
            "looking_for": companyDetails["Looking for", default: ""],  // Add looking_for field
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("⚠️ JSON encode error: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Save failed: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
                if let data = data {
                    do {
                        DispatchQueue.main.async {
                            isEditing = false
                            // Refresh profile after successful update
                            viewModel.fetchProfile(for: userId)
                        }
                    } catch {
                        print("❌ JSON decode failed: \(error)")
                    }

                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("📦 Response body: \(responseBody)")
                    }
                }
            } else {
                print("⚠️ No HTTP response")
            }
        }.resume()
    }

}


// MARK: - Preview
struct PageBusinessProfile_Previews: PreviewProvider {
    static var previews: some View {
        PageBusinessProfile()
    }
}
