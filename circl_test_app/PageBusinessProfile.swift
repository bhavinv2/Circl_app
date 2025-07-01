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
    // MARK: - State Variables

    @State private var showBusinessOwnerMessage = false
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false

    // MARK: - Animated Background
    private var animatedBackground: some View {
        ZStack {
            // Base gradient
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
            
            // First flowing layer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.2),
                    Color.clear,
                    Color(hexCode: "004aad").opacity(0.15),
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? -0.3 : 1.3,
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 1.0 : 0.0,
                    y: 1.0
                )
            )
            
            // Second flowing layer (opposite direction)
            LinearGradient(
                colors: [
                    Color(hexCode: "002d5a").opacity(0.1),
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.18),
                    Color.clear,
                    Color(hexCode: "001a3d").opacity(0.12)
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 1.2 : -0.2,
                    y: 0.3
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 0.1 : 0.9,
                    y: 0.7
                )
            )
            
            // Third subtle wave layer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.1),
                    Color.clear,
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 0.2 : 0.8,
                    y: isAnimating ? 0.0 : 1.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 0.9 : 0.1,
                    y: isAnimating ? 1.0 : 0.0
                )
            )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }


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
            ZStack(alignment: .bottomTrailing) {

                // 🔥 Scrollable app content (base layer)
                VStack(spacing: 0) {
                    headerSection
                    scrollableSection
                }

                // 🔨 Floating hammer button + menu
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Welcome to your resources")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))

                            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "person.2.fill", title: "Connect and Network")
                            }
                            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
                            }
                            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
                            }
                            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "briefcase.fill", title: "Professional Services")
                            }
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "envelope.fill", title: "Messages")
                            }
                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                            }
                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
                            }

                            Divider()

                            NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true))
 {
                                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 250)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showMenu.toggle()
                            rotationAngle += 360 // spin the logo
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hexCode: "004aad"))
                                .frame(width: 60, height: 60)

                            Image("CirclLogoButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .rotationEffect(.degrees(rotationAngle))
                        }
                    }
                    .shadow(radius: 4)
                    .padding(.bottom, 19)




                }
                .padding()
                .zIndex(3) // Top layer for hammer button/menu

                // 🧼 Tap-out-to-dismiss layer
                if showMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }
                        .zIndex(2) // Above main content, below hammer button
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.all) // This will make the background extend to the notch
            .onAppear {
                if let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
                    viewModel.fetchProfile(for: userId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let profile = viewModel.profile {
                            companyDetails = [
                                "Industry": profile.industry ?? "",
                                "Type": profile.type ?? "",
                                "Stage": profile.stage ?? "",
                                "Revenue": profile.revenue ?? "",
                                "Location": profile.location ?? "",
                                "Looking for": profile.looking_for ?? ""
                            ]
                        }
                    }
                } else {
                    print("⚠️ User ID not found in UserDefaults")
                }
            }
            .onReceive(viewModel.$profile) { profile in
                guard let profile = profile else { return }
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


        }
    }
    
    
    
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        Text("Circl.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            ZStack {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .frame(width: 50, height: 40)
                                    .foregroundColor(.white)
                            }
                        }

                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
        }
        .padding(.top, 60) // Fixed padding instead of dynamic safe area
        .background(animatedBackground.ignoresSafeArea(.all))
        .clipped()
    }

    
    private var scrollableSection: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(UIColor.systemGray6))
        .dismissKeyboardOnScroll()
    }
    
    private var companyOverviewSection: some View {
        VStack(spacing: 16) {
            // Company Logo & Name Card
            VStack(spacing: 16) {
                // Logo placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hexCode: "004aad"), Color(hexCode: "0066ff")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("Company Logo")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Company Name
                if let companyWebsiteURL = companyWebsiteURL {
                    Link(companyName.isEmpty ? "Your Company" : companyName, destination: companyWebsiteURL)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hexCode: "004aad"))
                        .underline()
                } else {
                    Text(companyName.isEmpty ? "Your Company" : companyName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
    }

    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                
                Text("About")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(aboutText.isEmpty ? "Tell us about your company..." : aboutText)
                .font(.system(size: 16))
                .foregroundColor(aboutText.isEmpty ? .secondary : .primary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var companyDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                
                Text("Company Overview")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }

            VStack(alignment: .leading, spacing: 16) {
                ForEach(companyDetails.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(key)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(companyDetails[key, default: ""].isEmpty ? "Not specified" : companyDetails[key, default: ""])
                            .font(.system(size: 16))
                            .foregroundColor(companyDetails[key, default: ""].isEmpty ? .secondary : .primary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    
    private var valuesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                
                Text("Values")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(["Vision", "Company Culture"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(key)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text(values[key, default: ""].isEmpty ? "Not specified" : values[key, default: ""])
                            .font(.system(size: 16))
                            .foregroundColor(values[key, default: ""].isEmpty ? .secondary : .primary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var solutionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                
                Text("Solution")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(["Product/Service", "Unique Selling Proposition", "Traction/Progress"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(key)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(solutionDetails[key, default: ""].isEmpty ? "Not specified" : solutionDetails[key, default: ""])
                            .font(.system(size: 16))
                            .foregroundColor(solutionDetails[key, default: ""].isEmpty ? .secondary : .primary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var businessModelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                
                Text("Business Model")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(["Revenue Streams", "Pricing Strategy"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(key)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(businessModelDetails[key, default: ""].isEmpty ? "Not specified" : businessModelDetails[key, default: ""])
                            .font(.system(size: 16))
                            .foregroundColor(businessModelDetails[key, default: ""].isEmpty ? .secondary : .primary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hexCode: "004aad"))
                
                Text("The Team")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(["CoFounders", "Key Hires", "Advisors/Mentors"], id: \.self) { key in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(key)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(teamDetails[key, default: ""].isEmpty ? "Not specified" : teamDetails[key, default: ""])
                            .font(.system(size: 16))
                            .foregroundColor(teamDetails[key, default: ""].isEmpty ? .secondary : .primary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
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
    
    
    
    struct CustomCircleButton: View {
        let iconName: String
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color(hexCode: "004aad"))
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

        let url = URL(string: "https://circlapp.online/api/users/business-profile/\(userId)/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "about": aboutText.trimmingCharacters(in: .whitespacesAndNewlines),
            "vision": values["Vision"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "mission": values["Mission"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "company_culture": values["Company Culture"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "product_service": solutionDetails["Product/Service"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "unique_selling_proposition": solutionDetails["Unique Selling Proposition"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "traction": solutionDetails["Traction/Progress"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "revenue_streams": businessModelDetails["Revenue Streams"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "pricing_strategy": businessModelDetails["Pricing Strategy"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "advisors_mentors": teamDetails["Advisors/Mentors"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "cofounders": teamDetails["CoFounders"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "key_hires": teamDetails["Key Hires"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "industry": companyDetails["Industry"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "location": companyDetails["Location"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "business_name": companyName.trimmingCharacters(in: .whitespacesAndNewlines),
            "revenue": companyDetails["Revenue"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "stage": companyDetails["Stage"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "type": companyDetails["Type"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "looking_for": companyDetails["Looking for"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ]

        // 🔍 Log the payload for debugging
        print("📤 Sending payload: \(payload)")


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
                            viewModel.fetchProfile(for: userId)
                            
                            // Small delay to ensure fetch finishes
                            viewModel.fetchProfile(for: userId)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                if let profile = viewModel.profile {
                                    self.applyProfileToUI(profile)
                                } else {
                                    print("⚠️ No profile returned yet — might need longer delay")
                                }
                            }

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
    
    func applyProfileToUI(_ profile: BusinessProfile) {
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
            "Mission": profile.mission ?? "",
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


}


// MARK: - Preview
struct PageBusinessProfile_Previews: PreviewProvider {
    static var previews: some View {
        PageBusinessProfile()
    }
}
