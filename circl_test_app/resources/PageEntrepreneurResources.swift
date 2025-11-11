import SwiftUI
import Foundation

struct PageEntrepreneurResources: View {
    // MARK: - State Management
    @State private var showMoreMenu = false
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @AppStorage("user_id") private var userId: Int = 0

    // Resource categories with improved organization
    private let resourceCategories = [
        ResourceCategory(title: "Accountants/Tax Advisors", icon: "dollarsign.circle.fill", color: Color.green, destination: AnyView(AccountantsQuizView())),
        ResourceCategory(title: "Legal Team", icon: "scale.3d", color: Color.blue, destination: AnyView(LegalQuizView())),
        ResourceCategory(title: "Bank Loans", icon: "banknote.fill", color: Color.orange, destination: AnyView(BankLoanQuizView())),
        ResourceCategory(title: "Business Consultants", icon: "lightbulb.fill", color: Color.yellow, destination: AnyView(ConsultantQuizView())),
        ResourceCategory(title: "Business Insurance", icon: "shield.fill", color: Color.purple, destination: AnyView(InsuranceQuizView())),
        ResourceCategory(title: "Marketing Companies", icon: "megaphone.fill", color: Color.pink, destination: AnyView(MarketingQuizView())),
        ResourceCategory(title: "Real Estate Teams", icon: "house.fill", color: Color.brown, destination: AnyView(RealEstateQuizView())),
        ResourceCategory(title: "HR Teams", icon: "person.3.fill", color: Color.cyan, destination: AnyView(HRQuizView())),
        ResourceCategory(title: "Manufacturing Firms", icon: "gearshape.2.fill", color: Color.gray, destination: AnyView(ManufacturingQuizView())),
        ResourceCategory(title: "Customer Service Teams", icon: "headphones", color: Color.teal, destination: AnyView(CustomerServiceQuizView())),
        ResourceCategory(title: "Sales Teams", icon: "chart.line.uptrend.xyaxis", color: Color.red, destination: AnyView(SalesQuizView())),
        ResourceCategory(title: "CSR Teams", icon: "heart.fill", color: Color.green, destination: AnyView(CSRQuizView())),
        ResourceCategory(title: "Mental Health Teams", icon: "brain.head.profile", color: Color.mint, destination: AnyView(MentalHealthQuizView()))
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background gradient inspired by PageGroupchats
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(hex: "004aad").opacity(0.02),
                        Color(hex: "004aad").opacity(0.01)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    scrollableContent
                }
                
                // Bottom navigation as overlay
                VStack {
                    Spacer()
                    bottomNavigationBar
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
                
                // More Menu Popup (inspired by PageUnifiedNetworking)
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
                                // Professional Services (current page)
                                HStack(spacing: 16) {
                                    Image(systemName: "briefcase.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Professional Services")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text("Current page")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Network
                                NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Network")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Connect with entrepreneurs")
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
                                            Text("Manage your preferences")
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
                        .padding(.bottom, 100) // Leave space for bottom navigation
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
            .ignoresSafeArea(.all, edges: [.top, .bottom])
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchUnreadMessageCount()
                loadUserData()              // fallback values
                fetchCurrentUserProfile()   // ✅ live fetch ensures profile pic loads
            }
            .withTutorialOverlay() // ✅ Enable tutorial overlay on PageEntrepreneurResources

        }
    }
    
    // MARK: - Header Section (inspired by PageUnifiedNetworking)
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Profile with shadow
                NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        if !userProfileImageURL.isEmpty {
                            AsyncImage(url: URL(string: userProfileImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        // Online indicator
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 12, y: -12)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                // Center - Simple Logo
                Text("Circl.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side - Messages
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        if unreadMessageCount > 0 {
                            Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                                )
                                .offset(x: 12, y: -12)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .padding(.top, 12)
        }
        .padding(.top, 50) // Add safe area padding for status bar and notch
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "004aad"),
                    Color(hex: "004aad").opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Scrollable Content
    private var scrollableContent: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Hero section with modern design
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Professional Services")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Connect with trusted professionals to grow your business")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "briefcase.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "004aad"))
                            .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                
                // Resource categories grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(resourceCategories, id: \.title) { category in
                        NavigationLink(destination: category.destination) {
                            ModernResourceCard(category: category)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120) // Add bottom padding to clear navigation
        }
        .refreshable {
            fetchUnreadMessageCount()
        }
    }
    
    // MARK: - Bottom Navigation Bar (inspired by PageUnifiedNetworking)
    private var bottomNavigationBar: some View {
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
            
            // Network
            NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
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
            
            // Growth Hub
            NavigationLink(destination: PageSkillSellingPlaceholder().navigationBarBackButtonHidden(true)) {
                VStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                    Text("Growth Hub")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
            
            // More Menu
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
    private func fetchCurrentUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        guard let url = URL(string: "https://circlapp.online/api/users/profile/\(userId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                DispatchQueue.main.async {
                    self.userFirstName = decoded.first_name
                    self.userProfileImageURL = decoded.profile_image ?? ""
                }
            }
        }.resume()
    }

    // MARK: - Helper Functions
    private func fetchUnreadMessageCount() {
        guard let url = URL(string: "\(baseURL)users/get_messages/\(userId)/") else {
            print("Invalid URL for messages")
            return
        }

        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: [MessageModel]].self, from: data)
                    DispatchQueue.main.async {
                        let allMessages = response["messages"] ?? []
                        self.messages = allMessages
                        self.calculateUnreadMessageCount()
                    }
                } catch {
                    print("Failed to decode messages: \(error)")
                }
            } else if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func calculateUnreadMessageCount() {
        unreadMessageCount = messages.filter { message in
            message.receiver_id == userId && !message.is_read
        }.count
    }
    
    private func loadUserData() {
        let fullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
        userFirstName = fullName.components(separatedBy: " ").first ?? "User"
        userProfileImageURL = UserDefaults.standard.string(forKey: "user_profile_image_url") ?? ""
        fetchUnreadMessageCount()
    }
}

// MARK: - Supporting Views and Models

struct ResourceCategory {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
}

struct ModernResourceCard: View {
    let category: ResourceCategory
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(category.color)
            }
            
            // Title
            Text(category.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(category.color.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

struct PageEntrepreneurResources_Previews: PreviewProvider {
    static var previews: some View {
        PageEntrepreneurResources()
    }
}
