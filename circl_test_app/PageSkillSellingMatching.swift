import SwiftUI

// MARK: - Data Models
struct StudentServicePost: Codable, Identifiable {
    let id = UUID()
    let studentName: String
    let serviceTitle: String
    let description: String
    let skills: [String]
    let pricing: PricingType
    let rating: Double
    let completedProjects: Int
    let profileImage: String
    let datePosted: Date
    
    enum PricingType: String, CaseIterable, Codable {
        case hourly = "Hourly"
        case project = "Per Project"
        case negotiable = "Negotiable"
    }
}

struct CompanyProjectPost: Codable, Identifiable {
    let id = UUID()
    let companyName: String
    let projectTitle: String
    let description: String
    let requiredSkills: [String]
    let budget: BudgetRange
    let duration: String
    let companyLogo: String
    let datePosted: Date
    
    enum BudgetRange: String, CaseIterable, Codable {
        case under500 = "Under $500"
        case range500to1k = "$500 - $1,000"
        case range1kto5k = "$1,000 - $5,000"
        case range5kto10k = "$5,000 - $10,000"
        case over10k = "Over $10,000"
        case negotiable = "Negotiable"
    }
}

// MARK: - Main View
struct PageSkillSellingMatching: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedSkillFilter = "All"
    @State private var showMoreMenu = false
    @State private var unreadMessageCount: Int = 0
    
    // Sample data
    @State private var studentServices: [StudentServicePost] = [
        StudentServicePost(
            studentName: "Alex Chen",
            serviceTitle: "iOS App Development",
            description: "Experienced iOS developer specializing in SwiftUI and UIKit. I can help build your app from concept to App Store.",
            skills: ["Swift", "SwiftUI", "UIKit", "Core Data"],
            pricing: .hourly,
            rating: 4.9,
            completedProjects: 12,
            profileImage: "person.circle.fill",
            datePosted: Date().addingTimeInterval(-86400)
        ),
        StudentServicePost(
            studentName: "Sarah Johnson",
            serviceTitle: "UI/UX Design & Prototyping",
            description: "Creative designer with 3 years of experience in mobile and web design. Expert in Figma and user research.",
            skills: ["Figma", "Adobe XD", "User Research", "Prototyping"],
            pricing: .project,
            rating: 4.8,
            completedProjects: 18,
            profileImage: "person.circle.fill",
            datePosted: Date().addingTimeInterval(-172800)
        ),
        StudentServicePost(
            studentName: "Marcus Rodriguez",
            serviceTitle: "Full-Stack Web Development",
            description: "MERN stack developer offering end-to-end web solutions. From database design to responsive frontends.",
            skills: ["React", "Node.js", "MongoDB", "Express"],
            pricing: .negotiable,
            rating: 4.7,
            completedProjects: 8,
            profileImage: "person.circle.fill",
            datePosted: Date().addingTimeInterval(-259200)
        )
    ]
    
    @State private var companyProjects: [CompanyProjectPost] = [
        CompanyProjectPost(
            companyName: "TechStart Inc.",
            projectTitle: "Mobile Food Delivery App",
            description: "Looking for a talented developer to create a food delivery app with real-time tracking, payment integration, and restaurant management features.",
            requiredSkills: ["Swift", "Firebase", "Maps SDK", "Payment APIs"],
            budget: .range1kto5k,
            duration: "2-3 months",
            companyLogo: "building.2.fill",
            datePosted: Date().addingTimeInterval(-43200)
        ),
        CompanyProjectPost(
            companyName: "GreenTech Solutions",
            projectTitle: "Sustainability Dashboard Design",
            description: "Need a UX/UI designer to create an intuitive dashboard for tracking carbon footprint and sustainability metrics for enterprise clients.",
            requiredSkills: ["Figma", "Data Visualization", "Dashboard Design", "User Research"],
            budget: .range500to1k,
            duration: "4-6 weeks",
            companyLogo: "leaf.fill",
            datePosted: Date().addingTimeInterval(-129600)
        ),
        CompanyProjectPost(
            companyName: "EduTech Innovations",
            projectTitle: "Learning Management System",
            description: "Seeking a full-stack developer to build a comprehensive LMS with video streaming, progress tracking, and interactive assignments.",
            requiredSkills: ["React", "Node.js", "PostgreSQL", "Video Streaming"],
            budget: .range5kto10k,
            duration: "3-4 months",
            companyLogo: "graduationcap.fill",
            datePosted: Date().addingTimeInterval(-216000)
        )
    ]
    
    let skillOptions = ["All", "Swift", "SwiftUI", "React", "Node.js", "Figma", "UI/UX", "Firebase", "MongoDB"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header Section with integrated search
                VStack(spacing: 0) {
                    // Blue header background
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "004aad"),
                                Color(hex: "004aad").opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                        
                        VStack(spacing: 0) {
                            // Top Navigation Bar
                            HStack {
                                // Profile Button
                                Button(action: {
                                    // Profile action
                                }) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.15))
                                                .frame(width: 44, height: 44)
                                        )
                                }
                                
                                Spacer()
                                
                                // Circl Logo
                                Text("Circl.")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                
                                Spacer()
                                
                                // Messages Button
                                Button(action: {
                                    // Messages action
                                }) {
                                    ZStack {
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        // Notification badge (if needed)
                                        if unreadMessageCount > 0 {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 18, height: 18)
                                                .overlay(
                                                    Text("\(min(unreadMessageCount, 99))")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                                .offset(x: 12, y: -12)
                                        }
                                    }
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 55)
                            .padding(.bottom, 24)
                            
                            // Tab Selector
                            HStack(spacing: 0) {
                                // Student Services Tab
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTab = 0
                                    }
                                }) {
                                    VStack(spacing: 10) {
                                        HStack(spacing: 8) {
                                            Image(systemName: selectedTab == 0 ? "person.badge.plus.fill" : "person.badge.plus")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("Student Services")
                                                .font(.system(size: 15, weight: selectedTab == 0 ? .semibold : .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(selectedTab == 0 ? Color.white.opacity(0.2) : Color.clear)
                                        )
                                        
                                        // Active indicator
                                        Capsule()
                                            .fill(selectedTab == 0 ? Color.white : Color.clear)
                                            .frame(width: selectedTab == 0 ? 40 : 0, height: 3)
                                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Company Projects Tab
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedTab = 1
                                    }
                                }) {
                                    VStack(spacing: 10) {
                                        HStack(spacing: 8) {
                                            Image(systemName: selectedTab == 1 ? "building.2.fill" : "building.2")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("Company Projects")
                                                .font(.system(size: 15, weight: selectedTab == 1 ? .semibold : .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(selectedTab == 1 ? Color.white.opacity(0.2) : Color.clear)
                                        )
                                        
                                        // Active indicator
                                        Capsule()
                                            .fill(selectedTab == 1 ? Color.white : Color.clear)
                                            .frame(width: selectedTab == 1 ? 40 : 0, height: 3)
                                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 4)
                        }
                    }
                    
                    // Search section directly connected
                    VStack(spacing: 8) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField(selectedTab == 0 ? "Search services..." : "Search projects...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                        
                        // Skill Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(skillOptions, id: \.self) { skill in
                                    Button(action: { selectedSkillFilter = skill }) {
                                        Text(skill)
                                            .font(.system(size: 14, weight: .medium))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedSkillFilter == skill ? Color(hex: "004aad") : Color(.systemGray5))
                                            .foregroundColor(selectedSkillFilter == skill ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .background(Color(.systemBackground))
                }
                
                // Content Area
                ScrollView {
                    VStack(spacing: 0) {
                        // Tab Content
                        if selectedTab == 0 {
                            studentServicesView
                        } else {
                            companyProjectsView
                        }
                    }
                }
                .background(Color(.systemGray6))
                
                // Bottom Navigation
                bottomNavigationBar
            }
            .navigationBarHidden(true)
            .overlay(
                // More Menu Popup
                showMoreMenu ? moreMenuPopup : nil
            )
        }
    }
    
    // MARK: - Student Services View
    private var studentServicesView: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredStudentServices) { service in
                StudentServiceCard(service: service)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 100) // Space for bottom navigation
    }
    
    // MARK: - Company Projects View
    private var companyProjectsView: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredCompanyProjects) { project in
                CompanyProjectCard(project: project)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 100) // Space for bottom navigation
    }
    
    // MARK: - Filtered Data
    private var filteredStudentServices: [StudentServicePost] {
        studentServices.filter { service in
            let matchesSearch = searchText.isEmpty ||
                service.serviceTitle.localizedCaseInsensitiveContains(searchText) ||
                service.studentName.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesSkill = selectedSkillFilter == "All" ||
                service.skills.contains { skill in
                    skill.localizedCaseInsensitiveContains(selectedSkillFilter)
                }
            
            return matchesSearch && matchesSkill
        }
    }

    private var filteredCompanyProjects: [CompanyProjectPost] {
        companyProjects.filter { project in
            let matchesSearch = searchText.isEmpty ||
                project.projectTitle.localizedCaseInsensitiveContains(searchText) ||
                project.companyName.localizedCaseInsensitiveContains(searchText) ||
                project.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesSkill = selectedSkillFilter == "All" ||
                project.requiredSkills.contains { skill in
                    skill.localizedCaseInsensitiveContains(selectedSkillFilter)
                }
            
            return matchesSearch && matchesSkill
        }
    }
}

// MARK: - Bottom Navigation Bar
extension PageSkillSellingMatching {
    private var bottomNavigationBar: some View {
        VStack {
            HStack(spacing: 0) {
                // Forum / Home
                Button(action: {
                    // Home action
                }) {
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
                
                // Connect and Network
                Button(action: {
                    // Network action
                }) {
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
                
                // Circles
                Button(action: {
                    // Circles action
                }) {
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
                
                // Exchange (Current page - highlighted)
                VStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                    Text("Exchange")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                }
                .frame(maxWidth: .infinity)
                
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
    }
    
    // MARK: - More Menu Popup
    private var moreMenuPopup: some View {
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
                    Button(action: {
                        // Professional Services action
                    }) {
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
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // News & Knowledge
                    Button(action: {
                        // News & Knowledge action
                    }) {
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
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Settings
                    Button(action: {
                        // Settings action
                    }) {
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
                .background(Color(.systemGray6))
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMoreMenu = false
                    }
                }
        )
        .zIndex(2)
    }
}

// MARK: - Student Service Card
struct StudentServiceCard: View {
    let service: StudentServicePost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with profile
            HStack(spacing: 12) {
                Image(systemName: service.profileImage)
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "004aad"))
                    .frame(width: 50, height: 50)
                    .background(Color(hex: "004aad").opacity(0.1))
                    .cornerRadius(25)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.studentName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", service.rating))
                                .font(.system(size: 12, weight: .medium))
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(service.completedProjects) projects")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(service.pricing.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    
                    Text(timeAgoString(from: service.datePosted))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // Service Title
            Text(service.serviceTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            // Description
            Text(service.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Skills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(service.skills, id: \.self) { skill in
                        Text(skill)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "004aad").opacity(0.1))
                            .foregroundColor(Color(hex: "004aad"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 1)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Contact action
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Contact")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "004aad"))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // View profile action
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("View Profile")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "004aad").opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    // Save/bookmark action
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Company Project Card
struct CompanyProjectCard: View {
    let project: CompanyProjectPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with company info
            HStack(spacing: 12) {
                Image(systemName: project.companyLogo)
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "004aad"))
                    .frame(width: 50, height: 50)
                    .background(Color(hex: "004aad").opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.companyName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(project.budget.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(project.duration)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(timeAgoString(from: project.datePosted))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Project Title
            Text(project.projectTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            // Description
            Text(project.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(4)
            
            // Required Skills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(project.requiredSkills, id: \.self) { skill in
                        Text(skill)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 1)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Apply action
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Apply Now")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "004aad"))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // View details action
                }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("View Details")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "004aad").opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    // Save/bookmark action
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Helper Functions
private func timeAgoString(from date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    let days = Int(interval / 86400)
    
    if days == 0 {
        return "Today"
    } else if days == 1 {
        return "1 day ago"
    } else {
        return "\(days) days ago"
    }
}

// MARK: - Preview
struct PageSkillSellingMatching_Previews: PreviewProvider {
    static var previews: some View {
        PageSkillSellingMatching()
    }
}

