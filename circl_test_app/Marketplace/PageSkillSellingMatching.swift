import SwiftUI
import Foundation
import UIKit

struct PageSkillSellingMatching: View {
    // MARK: - State Management
    @State private var isAnimating = false
    @State private var showMoreMenu = false
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var selectedTab: String = "projects" // "projects" or "jobboard"
    @State private var selectedFilter: String = "all"
    @State private var showFilters = false
    @AppStorage("user_id") private var userId: Int = 0

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Main Content
                VStack(spacing: 0) {
                    headerSection
                    scrollableContent
                }
                
                // MARK: - Bottom Navigation (PageForum Style)
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
                        
                        // Marketplace (Current page - highlighted)
                        VStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("Marketplace")
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

                // MARK: - More Menu Overlay
                if showMoreMenu {
                    ZStack {
                        // Tap-to-dismiss background
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showMoreMenu = false
                                }
                            }
                        
                        // Menu content - positioned at bottom right
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("More Options")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.regularMaterial)

                                    Button(action: {}) {
                                        HStack {
                                            Image(systemName: "ellipsis.circle.fill")
                                                .foregroundColor(Color(hex: "004aad"))
                                                .frame(width: 24)
                                            Text("More Options")
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                    }
                                    Button(action: {}) {
                                        HStack {
                                            Image(systemName: "gearshape.fill")
                                                .foregroundColor(Color(hex: "004aad"))
                                                .frame(width: 24)
                                            Text("Settings")
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                    }
                                }
                                .background(.thickMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .frame(width: 200)
                                .padding(.trailing, 16)
                                .padding(.bottom, 100) // Position above bottom nav
                            }
                        }
                    }
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
        }
        // Load data when view appears
        .onAppear {
            loadMarketplaceData()
        }
    }

    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Profile
                Button(action: {
                    // Navigate to Profile when available
                }) {
                    AsyncImage(url: URL(string: userProfileImageURL)) { phase in
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
                }
                
                Spacer()
                
                // Center - Logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side - Messages
                Button(action: {
                    // Navigate to Messages when available
                }) {
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
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
            
            // Tab Buttons Row - Twitter/X style tabs
            HStack(spacing: 0) {
                Spacer()
                
                // Projects Tab
                HStack {
                    VStack(spacing: 8) {
                        Text("Projects")
                            .font(.system(size: 15, weight: selectedTab == "projects" ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(selectedTab == "projects" ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(width: 80)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = "projects"
                }
                
                Spacer()
                
                // Job Board Tab
                HStack {
                    VStack(spacing: 8) {
                        Text("Job Board")
                            .font(.system(size: 15, weight: selectedTab == "jobboard" ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(selectedTab == "jobboard" ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(width: 90)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = "jobboard"
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .background(Color(hex: "004aad"))
    }
    
    // MARK: - Scrollable Content
    var scrollableContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Filters Section
                VStack(spacing: 0) {
                    HStack {
                        Text(selectedTab == "projects" ? "Browse Projects" : "Browse Jobs")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showFilters.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14))
                                Text("Filter")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "004aad").opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    
                    // Quick Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(title: "All", isSelected: selectedFilter == "all") {
                                selectedFilter = "all"
                            }
                            FilterButton(title: "Remote", isSelected: selectedFilter == "remote") {
                                selectedFilter = "remote"
                            }
                            FilterButton(title: "Equity", isSelected: selectedFilter == "equity") {
                                selectedFilter = "equity"
                            }
                            FilterButton(title: "Full-Time", isSelected: selectedFilter == "fulltime") {
                                selectedFilter = "fulltime"
                            }
                            FilterButton(title: "Startup", isSelected: selectedFilter == "startup") {
                                selectedFilter = "startup"
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)
                }
                .background(Color(UIColor.systemBackground))
                
                // Post Your Own Section
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedTab == "projects" ? "Post Your Project" : "Post a Job")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(selectedTab == "projects" ? "Find collaborators or offer your services" : "Find the perfect candidate")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Handle post creation
                        }) {
                            Text("Create Listing")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "004aad"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "004aad").opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                
                // Listings Content
                if selectedTab == "projects" {
                    ProjectListingsView(filter: selectedFilter)
                } else {
                    JobBoardListingsView(filter: selectedFilter)
                }
            }
        }
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "004aad"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "004aad") : Color(hex: "004aad").opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - Project Listings View
struct ProjectListingsView: View {
    let filter: String
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredProjects, id: \.id) { project in
                ProjectCard(project: project)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
    }
    
    var filteredProjects: [ProjectListing] {
        let projects = MockData.projects
        switch filter {
        case "remote":
            return projects.filter { $0.isRemote }
        case "equity":
            return projects.filter { $0.compensationType.contains("Equity") }
        case "fulltime":
            return projects.filter { $0.type == "Full-Time" }
        case "startup":
            return projects.filter { $0.companyType == "Startup" }
        default:
            return projects
        }
    }
}

// MARK: - Job Board Listings View  
struct JobBoardListingsView: View {
    let filter: String
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredJobs, id: \.id) { job in
                JobCard(job: job)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
    }
    
    var filteredJobs: [JobListing] {
        let jobs = MockData.jobs
        switch filter {
        case "remote":
            return jobs.filter { $0.isRemote }
        case "equity":
            return jobs.filter { $0.compensationType.contains("Equity") }
        case "fulltime":
            return jobs.filter { $0.type == "Full-Time" }
        case "startup":
            return jobs.filter { $0.companyType == "Startup" }
        default:
            return jobs
        }
    }
}

// MARK: - Project Card Component
struct ProjectCard: View {
    let project: ProjectListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with badges
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(project.company)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(project.timePosted)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Badges
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Badge(text: project.type, color: .blue)
                    Badge(text: project.compensationType, color: .green)
                    if project.isRemote {
                        Badge(text: "Remote", color: .purple)
                    }
                    Badge(text: project.companyType, color: .orange)
                }
            }
            
            // Description
            Text(project.description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Skills
            if !project.skills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(project.skills, id: \.self) { skill in
                            Text(skill)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "004aad").opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Action buttons
            HStack {
                Button(action: {
                    // Handle apply/request work
                }) {
                    Text("Request Work")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "004aad"))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    // Handle save/bookmark
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "004aad"))
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Job Card Component
struct JobCard: View {
    let job: JobListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(job.company)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    if !job.location.isEmpty {
                        Text(job.location)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(job.timePosted)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Badges
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Badge(text: job.type, color: .blue)
                    Badge(text: job.compensationType, color: .green)
                    if job.isRemote {
                        Badge(text: "Remote", color: .purple)
                    }
                    Badge(text: job.companyType, color: .orange)
                }
            }
            
            // Description
            Text(job.description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Salary if available
            if !job.salaryRange.isEmpty {
                Text(job.salaryRange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
            }
            
            // Action buttons
            HStack {
                Button(action: {
                    // Handle apply
                }) {
                    Text("Apply Now")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "004aad"))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    // Handle save
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "004aad"))
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Badge Component
struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(badgeTextColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeBackgroundColor)
            .cornerRadius(6)
    }
    
    private var badgeTextColor: Color {
        switch color {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        default: return .primary
        }
    }
    
    private var badgeBackgroundColor: Color {
        switch color {
        case .blue: return .blue.opacity(0.1)
        case .green: return .green.opacity(0.1)
        case .purple: return .purple.opacity(0.1)
        case .orange: return .orange.opacity(0.1)
        default: return .gray.opacity(0.1)
        }
    }
}

// MARK: - Data Models
struct ProjectListing {
    let id: String
    let title: String
    let company: String
    let type: String // "Project Collaboration", "Service Offering", "Co-Founder Search", etc.
    let description: String
    let skills: [String]
    let compensationType: String // "Equity", "Paid Contract", "Collaboration", etc.
    let isRemote: Bool
    let companyType: String // "Startup", "Small Business", "Enterprise"
    let timePosted: String
}

struct JobListing {
    let id: String
    let title: String
    let company: String
    let location: String
    let type: String // "Full-Time", "Part-Time", "Internship", etc.
    let description: String
    let salaryRange: String
    let compensationType: String
    let isRemote: Bool
    let companyType: String
    let timePosted: String
}

// MARK: - Mock Data
struct MockData {
    static let projects: [ProjectListing] = [
        ProjectListing(
            id: "p1",
            title: "Looking for iOS Developer Co-Founder",
            company: "HealthTech Startup",
            type: "Co-Founder Search",
            description: "Building the next generation health monitoring app. Looking for a technical co-founder with iOS expertise to join as CTO. Equity-based opportunity with huge market potential.",
            skills: ["SwiftUI", "iOS", "Healthcare", "Startup"],
            compensationType: "Equity Position",
            isRemote: true,
            companyType: "Startup",
            timePosted: "2h ago"
        ),
        ProjectListing(
            id: "p2",
            title: "UI/UX Designer for SaaS Dashboard",
            company: "TechFlow Solutions",
            type: "Contract",
            description: "Need an experienced designer to create a beautiful dashboard for our B2B SaaS platform. 3-month project with potential for ongoing work.",
            skills: ["Figma", "UI/UX", "SaaS", "Dashboard Design"],
            compensationType: "Paid Contract",
            isRemote: true,
            companyType: "Startup",
            timePosted: "4h ago"
        ),
        ProjectListing(
            id: "p3",
            title: "Marketing Strategy Collaboration",
            company: "EcoTech Innovations",
            type: "Project Collaboration",
            description: "Environmental startup looking for marketing expert to help develop go-to-market strategy. Great opportunity to make an impact in sustainability.",
            skills: ["Marketing Strategy", "Sustainability", "Growth"],
            compensationType: "Collaboration",
            isRemote: false,
            companyType: "Startup",
            timePosted: "1d ago"
        ),
        ProjectListing(
            id: "p4",
            title: "Full-Stack Developer for Equity",
            company: "FinanceAI",
            type: "Equity-Based Role",
            description: "Join our AI-powered finance platform as a senior developer. Offering significant equity stake in a fast-growing company.",
            skills: ["React", "Node.js", "AI/ML", "Finance"],
            compensationType: "Equity Position",
            isRemote: true,
            companyType: "Startup",
            timePosted: "2d ago"
        ),
        ProjectListing(
            id: "p5",
            title: "Content Creator Service",
            company: "CreativeWorks",
            type: "Service Offering",
            description: "Professional content creator available for hire. Specializing in tech startup content, social media strategy, and brand storytelling.",
            skills: ["Content Creation", "Social Media", "Branding"],
            compensationType: "Service Offering",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "3d ago"
        )
    ]
    
    static let jobs: [JobListing] = [
        JobListing(
            id: "j1",
            title: "Senior Software Engineer",
            company: "TechCorp",
            location: "San Francisco, CA",
            type: "Full-Time",
            description: "Join our engineering team building scalable web applications. We're looking for someone with 5+ years experience in full-stack development.",
            salaryRange: "$120k - $180k",
            compensationType: "Salary + Equity",
            isRemote: false,
            companyType: "Enterprise",
            timePosted: "1h ago"
        ),
        JobListing(
            id: "j2",
            title: "Product Design Intern",
            company: "StartupXYZ",
            location: "Remote",
            type: "Internship",
            description: "3-month paid internship working on user experience design for our mobile app. Great opportunity to learn from experienced designers.",
            salaryRange: "$2k/month",
            compensationType: "Paid Internship",
            isRemote: true,
            companyType: "Startup",
            timePosted: "3h ago"
        ),
        JobListing(
            id: "j3",
            title: "Marketing Manager",
            company: "GrowthCo",
            location: "New York, NY",
            type: "Full-Time",
            description: "Lead our marketing efforts across digital channels. Experience with B2B SaaS marketing preferred. Hybrid work environment.",
            salaryRange: "$80k - $120k",
            compensationType: "Salary + Bonus",
            isRemote: false,
            companyType: "Small Business",
            timePosted: "6h ago"
        ),
        JobListing(
            id: "j4",
            title: "Part-Time Data Analyst",
            company: "DataInsights",
            location: "Chicago, IL",
            type: "Part-Time",
            description: "20 hours/week analyzing customer data and creating reports. Perfect for students or career changers looking to gain experience.",
            salaryRange: "$25/hour",
            compensationType: "Hourly",
            isRemote: true,
            companyType: "Startup",
            timePosted: "8h ago"
        ),
        JobListing(
            id: "j5",
            title: "Frontend Developer",
            company: "WebTech Solutions",
            location: "Austin, TX",
            type: "Contract",
            description: "6-month contract building React components for enterprise client. Possibility of full-time conversion after contract period.",
            salaryRange: "$60/hour",
            compensationType: "Contract",
            isRemote: true,
            companyType: "Enterprise",
            timePosted: "12h ago"
        )
    ]
}
    
    // MARK: - Helper Functions
    private func loadMarketplaceData() {
        // Load user profile data from API like PageForum does
        fetchCurrentUserProfile()
    }
    
    private func fetchCurrentUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        print("🌐 Fetching current user profile from:", urlString)

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error)
                return
            }

            if let data = data {
                print("📦 Received current user data:", String(data: data, encoding: .utf8) ?? "No string")

                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        print("✅ Decoded current user:", decoded.full_name)
                        
                        // Update profile image URL
                        if let profileImage = decoded.profile_image, !profileImage.isEmpty {
                            self.userProfileImageURL = profileImage
                            print("✅ Profile image loaded: \(profileImage)")
                        } else {
                            self.userProfileImageURL = ""
                            print("❌ No profile image found for current user")
                        }
                        
                        // Update user name info
                        self.userFirstName = decoded.first_name
                    }
                } else {
                    print("❌ Failed to decode current user profile")
                }
            }
        }.resume()
    }
}

// MARK: - Filter Button Component