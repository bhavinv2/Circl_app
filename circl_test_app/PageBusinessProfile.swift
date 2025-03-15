import SwiftUI

// MARK: - Main View
struct PageBusinessProfile: View {
    // MARK: - Placeholder Data
    @State private var companyName: String = "Company Name"
    @State private var companyLogo: String = "companyLogo"
    @State private var companyWebsiteURL: URL? = nil
    @State private var aboutText: String = "Write about the company here..."
    @State private var companyDetails: [String: String] = [
        "Industry": "Technology",
        "Type": "Startup",
        "Problem To Solve": "Improving connectivity for entrepreneurs",
        "Cofounders": "2",
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
        "Pricing Strategy": "Outline the pricing approach.",
        "Sales/Revenue": "Summarize current sales/revenue."
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

    var body: some View {
        NavigationView { // Wrap the main view in a NavigationView
            VStack(spacing: 0) {
                headerSection
                scrollableSection
                footerSection
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    var headerSection: some View {
        // Header Section
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // Action for Filter
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                            Text("Filter")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    // Add the Bubble and Person icons above "Hello, Fragne"
                    VStack {
                        HStack(spacing: 10) {
                            // Navigation Link for Bubble Symbol
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .frame(width: 50, height: 40)  // Adjust size
                                    .foregroundColor(.white)
                            }
                            
                            // Person Icon
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // "Hello, Fragne" text below the icons
                        Text("Hello, Fragne")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad")) // Updated blue color
        }
    }
    
    // MARK: - Scrollable Section
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
                financialsFundingSection
                lookingForSection
                contactUsSection
            }
            .padding()
            .background(Color(.systemGray4))
        }
    }
    
    // MARK: - Company Overview Section
    private var companyOverviewSection: some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                // Company logo area
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        Image(companyLogo) // Dynamically bind the company logo
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .foregroundColor(.gray) // Fallback gray color
                    )
                    .cornerRadius(10)
                
                // Company name with dynamic underline for link
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
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.headline)
                .foregroundColor(.black)
            
            Text(aboutText) // Dynamically bind the About text
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .padding()
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
    
    // MARK: - Company Details Section
    private var companyDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Company Overview")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(companyDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: companyDetails[key] ?? "")
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
    
    // MARK: - Values Section
    private var valuesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Values")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(values.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: values[key] ?? "")
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
    
    // MARK: - Solution Section
    private var solutionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Solution")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(solutionDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: solutionDetails[key] ?? "")
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
    
    // MARK: - Business Model Section
    private var businessModelSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Business Model")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(businessModelDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: businessModelDetails[key] ?? "")
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
    
    // MARK: - Team Section
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The Team")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(teamDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: teamDetails[key] ?? "")
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
    
    // MARK: - Financials/Funding Section
    private var financialsFundingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Financials/Funding")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(financialsDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: financialsDetails[key] ?? "")
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
    
    // MARK: - Looking For Section
    private var lookingForSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Looking For")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(lookingForDetails.keys.sorted(), id: \.self) { key in
                    detailRow(title: key, value: lookingForDetails[key] ?? "")
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
    
    // MARK: - Contact Us Section
    private var contactUsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contact Us")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(contactPerson)
                    .foregroundColor(Color.fromHex("004aad"))
                    .underline()
                    .onTapGesture {
                        // Navigate to John Doe's profile
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

    // MARK: - Footer Section
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
    
    // MARK: - Custom Circle Button
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
    
    // MARK: - Detail Row Helper Function
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
}

// MARK: - Color Extension
extension Color {
    static func fromHex5(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Preview
struct PageBusinessProfile_Previews: PreviewProvider {
    static var previews: some View {
        PageBusinessProfile()
    }
}
