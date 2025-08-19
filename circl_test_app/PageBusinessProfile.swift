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
    @State private var isAnimating = false
    @State private var isEditing = false
    @State private var showMoreMenu = false
    
    // User profile data for header
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @AppStorage("user_id") private var userId: Int = 0

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

                // 🔥 Scrollable app content (base layer)
                VStack(spacing: 0) {
                    headerSection
                    scrollableSection
                }

                // MARK: - Twitter/X Style Bottom Navigation
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        // Forum / Home
                        NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                Image(systemName: "house")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("Home")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        // Connect and Network
                        NavigationLink(destination: PageMyNetwork().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("Network")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        // Circles
                        NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                Image(systemName: "circle.grid.2x2")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("Circles")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        // Business Profile (Current page - highlighted)
                        VStack(spacing: 4) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                            Text("Business")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                        }
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            isAnimating = true
                        }
                        
                        // More / Additional Resources
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu.toggle()
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("More")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .padding(.bottom, 8)
                    .background(
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(UIColor.separator))
                            .padding(.horizontal, 16),
                        alignment: .top
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)

                // MARK: - More Menu Popup
                if showMoreMenu {
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("More Options")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                .foregroundColor(.primary)
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                // Professional Services
                                NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "briefcase.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Professional Services")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Find business services and experts")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // News & Knowledge
                                NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "newspaper.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("News & Knowledge")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Stay updated with industry insights")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Circl Exchange
                                NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("The Circl Exchange")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Buy and sell skills and services")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Settings
                                NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "gear.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Settings")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Manage your account and preferences")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                            }
                            
                            // Close button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMoreMenu = false
                                }
                            }) {
                                Text("Close")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .background(Color(UIColor.systemGray6))
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80) // Leave space for bottom navigation
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(2)
                }

                // Tap-out-to-dismiss layer
                if showMoreMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                        }
                        .zIndex(1)
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.all) // This will make the background extend to the notch
            .onAppear {
                fetchUnreadMessageCount()
                loadUserData()
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
    
    private func fetchUnreadMessageCount() {
        guard let url = URL(string: "https://circlapp.online/api/unread_message_count/\(userId)/") else {
            print("Invalid URL for unread message count")
            return
        }

        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([String: Int].self, from: data) {
                    DispatchQueue.main.async {
                        self.unreadMessageCount = decodedResponse["unread_count"] ?? 0
                    }
                } else {
                    print("Failed to decode unread message count")
                }
            } else if let error = error {
                print("Error fetching unread message count: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    var headerSection: some View {
        VStack(spacing: 0) {
            ZStack {
                // Left side - Profile
                HStack {
                    NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                    Group {
                        if let encoded = userProfileImageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: encoded),
                           !userProfileImageURL.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                default:
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                }
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    Spacer()
                }
                
                // Center - Logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Spacer()
                    // Edit / Save toggle
                    Button(action: {
                        if isEditing {
                            saveChanges()
                        }
                        withAnimation { isEditing.toggle() }
                    }) {
                        Text(isEditing ? "Save" : "Edit")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                    }

                    // Right side - Messages
                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            if unreadMessageCount > 0 {
                                Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .padding(.top, 50) // Add safe area padding for status bar and notch
        .background(Color(hex: "004aad"))
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
                                colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
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
                if isEditing {
                    TextField("Your Company", text: $companyName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .textFieldStyle(.roundedBorder)
                } else if let companyWebsiteURL = companyWebsiteURL {
                    Link(companyName.isEmpty ? "Your Company" : companyName, destination: companyWebsiteURL)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "004aad"))
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
                    .foregroundColor(Color(hex: "004aad"))
                
                Text("About")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if isEditing {
                TextEditor(text: $aboutText)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            } else {
                Text(aboutText.isEmpty ? "Tell us about your company..." : aboutText)
                    .font(.system(size: 16))
                    .foregroundColor(aboutText.isEmpty ? .secondary : .primary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // Save changes to backend (PATCH business-profile/<userId>/)
    private func saveChanges() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ User ID not found in UserDefaults")
            return
        }

        guard let url = URL(string: "\(baseURL)users/business-profile/\(userId)/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token"), !token.isEmpty {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        var payload: [String: Any] = [:]
        payload["business_name"] = companyName.trimmingCharacters(in: .whitespacesAndNewlines)
        payload["about"] = aboutText.trimmingCharacters(in: .whitespacesAndNewlines)
        payload["vision"] = values["Vision"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["company_culture"] = values["Company Culture"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["product_service"] = solutionDetails["Product/Service"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["unique_selling_proposition"] = solutionDetails["Unique Selling Proposition"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["traction"] = solutionDetails["Traction/Progress"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["revenue_streams"] = businessModelDetails["Revenue Streams"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["pricing_strategy"] = businessModelDetails["Pricing Strategy"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["advisors_mentors"] = teamDetails["Advisors/Mentors"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["cofounders"] = teamDetails["CoFounders"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["key_hires"] = teamDetails["Key Hires"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["industry"] = companyDetails["Industry"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["location"] = companyDetails["Location"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["revenue"] = companyDetails["Revenue"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["stage"] = companyDetails["Stage"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["type"] = companyDetails["Type"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        payload["looking_for"] = companyDetails["Looking for"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        print("📤 Sending business profile PATCH payload: \(payload)")

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
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("📡 business-profile PATCH status: \(status)")
            if let data = data, let body = String(data: data, encoding: .utf8) {
                print("📦 business-profile PATCH body: \(body)")
            }
            DispatchQueue.main.async {
                isEditing = false
                viewModel.fetchProfile(for: userId)
            }
        }.resume()
    }

    private var companyDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
                
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

                        if isEditing {
                            TextField("Enter \(key)", text: Binding(
                                get: { companyDetails[key, default: ""] },
                                set: { companyDetails[key] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        } else {
                            Text(companyDetails[key, default: ""].isEmpty ? "Not specified" : companyDetails[key, default: ""]) 
                                .font(.system(size: 16))
                                .foregroundColor(companyDetails[key, default: ""].isEmpty ? .secondary : .primary)
                        }
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
                Image(systemName: "heart.rectangle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
                
                Text("Our Values")
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

                        if isEditing {
                            TextEditor(text: Binding(
                                get: { values[key, default: ""] },
                                set: { values[key] = $0 }
                            ))
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(values[key, default: ""].isEmpty ? "Not specified" : values[key, default: ""]) 
                                .font(.system(size: 16))
                                .foregroundColor(values[key, default: ""].isEmpty ? .secondary : .primary)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
                    .foregroundColor(Color(hex: "004aad"))
                
                Text("Our Solution")
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

                        if isEditing {
                            TextEditor(text: Binding(
                                get: { solutionDetails[key, default: ""] },
                                set: { solutionDetails[key] = $0 }
                            ))
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(solutionDetails[key, default: ""].isEmpty ? "Not specified" : solutionDetails[key, default: ""]) 
                                .font(.system(size: 16))
                                .foregroundColor(solutionDetails[key, default: ""].isEmpty ? .secondary : .primary)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
                
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

                        if isEditing {
                            TextEditor(text: Binding(
                                get: { businessModelDetails[key, default: ""] },
                                set: { businessModelDetails[key] = $0 }
                            ))
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(businessModelDetails[key, default: ""].isEmpty ? "Not specified" : businessModelDetails[key, default: ""]) 
                                .font(.system(size: 16))
                                .foregroundColor(businessModelDetails[key, default: ""].isEmpty ? .secondary : .primary)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
                    .foregroundColor(Color(hex: "004aad"))
                
                Text("Our Team")
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

                        if isEditing {
                            TextEditor(text: Binding(
                                get: { teamDetails[key, default: ""] },
                                set: { teamDetails[key] = $0 }
                            ))
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(teamDetails[key, default: ""].isEmpty ? "Not specified" : teamDetails[key, default: ""]) 
                                .font(.system(size: 16))
                                .foregroundColor(teamDetails[key, default: ""].isEmpty ? .secondary : .primary)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
    
    private var financialsFundingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
                
                Text("Financials & Funding")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(financialsDetails.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { financialsDetails[key, default: ""] },
                                set: { financialsDetails[key] = $0 }
                            ))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(financialsDetails[key, default: ""])
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
    
    private var lookingForSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
                
                Text("What We're Looking For")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(lookingForDetails.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { lookingForDetails[key, default: ""] },
                                set: { lookingForDetails[key] = $0 }
                            ))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text(lookingForDetails[key, default: ""])
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
    
    private var contactUsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contact Us")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(contactPerson)
                    .foregroundColor(Color(hex: "004aad"))
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
    
    func loadUserData() {
        userFirstName = UserDefaults.standard.string(forKey: "user_first_name") ?? "User"
        userProfileImageURL = UserDefaults.standard.string(forKey: "user_profile_image_url") ?? ""
    }
}

struct PageBusinessProfile_Previews: PreviewProvider {
    static var previews: some View {
        PageBusinessProfile()
    }
}
