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
    @State private var showCreateProjectSheet = false
    @State private var showCreateJobSheet = false
    @AppStorage("user_id") private var userId: Int = 0
    @AppStorage("marketplace_banner_dismissed") private var bannerDismissed: Bool = false

    var body: some View {
        AdaptivePage(title: "Growth Hub") {
            VStack(spacing: 0) {
                headerSection
                scrollableContent
            }
        }
        .sheet(isPresented: $showCreateProjectSheet) {
            CreateProjectSheet(isPresented: $showCreateProjectSheet)
        }
        .sheet(isPresented: $showCreateJobSheet) {
            CreateJobSheet(isPresented: $showCreateJobSheet)
        }
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
                        
                        // Show create button when banner is dismissed
                        if bannerDismissed {
                            Button(action: {
                                if selectedTab == "projects" {
                                    showCreateProjectSheet = true
                                } else {
                                    showCreateJobSheet = true
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Create")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                            .padding(.trailing, 8)
                        }
                        
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
                            
                            // Project-specific filters by major/field
                            if selectedTab == "projects" {
                                FilterButton(title: "Offering", isSelected: selectedFilter == "offering") {
                                    selectedFilter = "offering"
                                }
                                FilterButton(title: "Requesting", isSelected: selectedFilter == "requesting") {
                                    selectedFilter = "requesting"
                                }
                                FilterButton(title: "Computer Science", isSelected: selectedFilter == "cs") {
                                    selectedFilter = "cs"
                                }
                                FilterButton(title: "Finance", isSelected: selectedFilter == "finance") {
                                    selectedFilter = "finance"
                                }
                                FilterButton(title: "Marketing", isSelected: selectedFilter == "marketing") {
                                    selectedFilter = "marketing"
                                }
                                FilterButton(title: "Engineering", isSelected: selectedFilter == "engineering") {
                                    selectedFilter = "engineering"
                                }
                                FilterButton(title: "Design", isSelected: selectedFilter == "design") {
                                    selectedFilter = "design"
                                }
                                FilterButton(title: "Sales", isSelected: selectedFilter == "sales") {
                                    selectedFilter = "sales"
                                }
                                FilterButton(title: "Accounting", isSelected: selectedFilter == "accounting") {
                                    selectedFilter = "accounting"
                                }
                                FilterButton(title: "Legal", isSelected: selectedFilter == "legal") {
                                    selectedFilter = "legal"
                                }
                                FilterButton(title: "Human Resources", isSelected: selectedFilter == "hr") {
                                    selectedFilter = "hr"
                                }
                                FilterButton(title: "Sciences", isSelected: selectedFilter == "sciences") {
                                    selectedFilter = "sciences"
                                }
                            } else {
                                // Job Board specific filters (employment type)
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
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)
                }
                .background(Color(UIColor.systemBackground))
                
                // Post Your Own Section - Only show if not dismissed
                if !bannerDismissed {
                    VStack(spacing: 0) {
                        ZStack {
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
                                    // Handle post creation and dismiss banner
                                    if selectedTab == "projects" {
                                        showCreateProjectSheet = true
                                    } else {
                                        showCreateJobSheet = true
                                    }
                                    bannerDismissed = true
                                }) {
                                    Text("Create Listing")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Dismiss button positioned in top-right corner
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            bannerDismissed = true
                                        }
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 20, height: 20)
                                    }
                                    .offset(x: 8, y: -5) // Move down by 2 more pixels (was -7, now -5)
                                }
                                .padding(.top, -8) // Adjust top padding
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(Color(hex: "004aad").opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
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
        case "offering":
            return projects.filter { $0.isOffering }
        case "requesting":
            return projects.filter { !$0.isOffering }
        case "cs":
            return projects.filter { project in
                project.skills.contains { skill in
                    let csSkills = ["SwiftUI", "iOS", "React", "Node.js", "AI/ML", "Python", "JavaScript", "Programming", "Development", "Swift", "Web Development", "Mobile", "Backend", "Frontend", "Software", "Coding", "Tech", "App Development", "Full Stack", "Machine Learning", "AI", "Data Science"]
                    return csSkills.contains { csSkill in
                        skill.lowercased().contains(csSkill.lowercased())
                    }
                }
            }
        case "finance":
            return projects.filter { project in
                project.skills.contains { skill in
                    let financeSkills = ["Finance", "FinTech", "Accounting", "Investment", "Banking", "Economics", "Financial", "Trading", "Valuation", "Financial Modeling", "Excel", "CFA", "FP&A", "Financial Analysis", "Budgeting", "Forecasting"]
                    return financeSkills.contains { financeSkill in
                        skill.lowercased().contains(financeSkill.lowercased())
                    }
                }
            }
        case "marketing":
            return projects.filter { project in
                project.skills.contains { skill in
                    let marketingSkills = ["Marketing Strategy", "Growth", "Content Creation", "Social Media", "SEO", "Digital Marketing", "Branding", "Marketing", "Content", "SEM", "Brand", "Advertising", "Campaign", "Analytics", "Lead Generation", "B2B Marketing", "Performance Marketing"]
                    return marketingSkills.contains { marketingSkill in
                        skill.lowercased().contains(marketingSkill.lowercased())
                    }
                }
            }
        case "engineering":
            return projects.filter { project in
                project.skills.contains { skill in
                    let engineeringSkills = ["Engineering", "Mechanical", "Electrical", "Civil", "Software Engineering", "Systems", "Chemical", "CAD", "Design", "Product Design", "Hardware", "Manufacturing", "Prototyping", "3D Modeling"]
                    return engineeringSkills.contains { engineeringSkill in
                        skill.lowercased().contains(engineeringSkill.lowercased())
                    }
                }
            }
        case "design":
            return projects.filter { project in
                project.skills.contains { skill in
                    let designSkills = ["UI/UX", "Design", "Figma", "Graphic Design", "Product Design", "Web Design", "UI", "UX", "Graphic", "Visual", "Creative", "Adobe", "Sketch", "Branding", "Logo", "User Experience", "Illustration"]
                    return designSkills.contains { designSkill in
                        skill.lowercased().contains(designSkill.lowercased())
                    }
                }
            }
        case "sales":
            return projects.filter { project in
                project.skills.contains { skill in
                    let salesSkills = ["Sales", "Business Development", "Lead Generation", "CRM", "Client Relations", "Account Management", "B2B", "B2C", "Customer Success", "Relationship Management", "Negotiation", "Sales Strategy", "Pipeline Management"]
                    return salesSkills.contains { salesSkill in
                        skill.lowercased().contains(salesSkill.lowercased())
                    }
                }
            }
        case "accounting":
            return projects.filter { project in
                project.skills.contains { skill in
                    let accountingSkills = ["Accounting", "Bookkeeping", "Tax", "Financial Analysis", "Auditing", "QuickBooks", "Financial Reporting", "CPA", "Payroll", "Compliance", "GAAP", "Cost Accounting", "Management Accounting"]
                    return accountingSkills.contains { accountingSkill in
                        skill.lowercased().contains(accountingSkill.lowercased())
                    }
                }
            }
        case "legal":
            return projects.filter { project in
                project.skills.contains { skill in
                    let legalSkills = ["Legal", "Law", "Contract", "Compliance", "Litigation", "Corporate Law", "Legal Research", "Paralegal", "Attorney", "Legal Writing", "Intellectual Property", "IP", "Patent", "Trademark", "Legal Analysis", "Regulatory", "Privacy Law", "GDPR"]
                    return legalSkills.contains { legalSkill in
                        skill.lowercased().contains(legalSkill.lowercased())
                    }
                }
            }
        case "hr":
            return projects.filter { project in
                project.skills.contains { skill in
                    let hrSkills = ["Human Resources", "HR", "Recruitment", "Talent Acquisition", "Employee Relations", "Compensation", "Benefits", "Performance Management", "Training", "Development", "Onboarding", "Payroll", "HR Analytics", "Diversity", "Inclusion", "Organizational Development", "HRIS"]
                    return hrSkills.contains { hrSkill in
                        skill.lowercased().contains(hrSkill.lowercased())
                    }
                }
            }
        case "sciences":
            return projects.filter { project in
                project.skills.contains { skill in
                    let scienceSkills = ["Biology", "Chemistry", "Physics", "Research", "Laboratory", "Data Analysis", "Scientific Writing", "Statistics", "Biotech", "Pharmaceutical", "Clinical Research", "Environmental Science", "Life Sciences", "Molecular Biology", "Genetics", "Biochemistry", "Microbiology", "Neuroscience", "Psychology", "Scientific Research"]
                    return scienceSkills.contains { scienceSkill in
                        skill.lowercased().contains(scienceSkill.lowercased())
                    }
                }
            }
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
            // Header with title and REQUESTING/OFFERING badge in top-right
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(project.company)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(project.industry)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: "004aad").opacity(0.1))
                        .cornerRadius(4)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    // Offering or Requesting badge
                    Text(project.isOffering ? "OFFERING" : "REQUESTING")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(project.isOffering ? Color.green : Color(hex: "004aad"))
                        .cornerRadius(12)
                    Text(project.timePosted)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // Description
            Text(project.description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // All tags in one row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Project type and compensation
                    Badge(text: project.type, color: .blue)
                    Badge(text: project.compensationType, color: .green)
                    if project.isRemote {
                        Badge(text: "Remote", color: .purple)
                    }
                    Badge(text: project.companyType, color: .orange)
                    
                    // Skills
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
            
            // Action buttons
            HStack {
                Button(action: {
                    // Handle apply/request work or hire
                }) {
                    Text(project.isOffering ? "Hire" : "Request Work")
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
    let industry: String // "HealthTech", "FinTech", "EdTech", "E-commerce", etc.
    let type: String // "Project Collaboration", "Service Offering", "Co-Founder Search", etc.
    let description: String
    let skills: [String]
    let compensationType: String // "Equity", "Paid Contract", "Collaboration", etc.
    let isRemote: Bool
    let companyType: String // "Startup", "Small Business", "Enterprise"
    let timePosted: String
    let isOffering: Bool // true = offering services, false = requesting services
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
            industry: "HealthTech",
            type: "Co-Founder Search",
            description: "Building the next generation health monitoring app. Looking for a technical co-founder with iOS expertise to join as CTO. Equity-based opportunity with huge market potential.",
            skills: ["SwiftUI", "iOS", "Healthcare", "Startup"],
            compensationType: "Equity Position",
            isRemote: true,
            companyType: "Startup",
            timePosted: "2h ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p2",
            title: "UI/UX Designer for SaaS Dashboard",
            company: "TechFlow Solutions",
            industry: "SaaS",
            type: "Contract",
            description: "Need an experienced designer to create a beautiful dashboard for our B2B SaaS platform. 3-month project with potential for ongoing work.",
            skills: ["Figma", "UI/UX", "SaaS", "Dashboard Design"],
            compensationType: "Paid Contract",
            isRemote: true,
            companyType: "Startup",
            timePosted: "4h ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p3",
            title: "Marketing Strategy Consultant",
            company: "GrowthHackers Pro",
            industry: "Marketing",
            type: "Service Offering",
            description: "Experienced growth marketer offering consulting services. Helped 20+ startups achieve 300%+ growth in user acquisition.",
            skills: ["Marketing Strategy", "Growth", "Analytics"],
            compensationType: "Hourly Consulting",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "1d ago",
            isOffering: true
        ),
        ProjectListing(
            id: "p4",
            title: "Senior Full-Stack Developer Needed",
            company: "FinanceAI",
            industry: "FinTech",
            type: "Equity-Based Role",
            description: "Join our AI-powered finance platform as a senior developer. Offering significant equity stake in a fast-growing company.",
            skills: ["React", "Node.js", "AI/ML", "Finance"],
            compensationType: "Equity Position",
            isRemote: true,
            companyType: "Startup",
            timePosted: "2d ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p5",
            title: "Content Creator Service",
            company: "CreativeWorks",
            industry: "Marketing",
            type: "Service Offering",
            description: "Professional content creator available for hire. Specializing in tech startup content, social media strategy, and brand storytelling.",
            skills: ["Content Creation", "Social Media", "Branding"],
            compensationType: "Service Offering",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "3d ago",
            isOffering: true
        ),
        ProjectListing(
            id: "p6",
            title: "iOS Developer Available",
            company: "TechFreelancer",
            industry: "Technology",
            type: "Service Offering",
            description: "Senior iOS developer with 8+ years experience available for contract work. Specializing in SwiftUI, health apps, and fintech applications.",
            skills: ["SwiftUI", "iOS", "HealthKit", "Core Data"],
            compensationType: "Hourly Rate",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "5h ago",
            isOffering: true
        ),
        ProjectListing(
            id: "p7",
            title: "Seeking Marketing Co-Founder",
            company: "AI Startup",
            industry: "AI/Tech",
            type: "Co-Founder Search",
            description: "AI startup looking for marketing co-founder to lead growth strategy. Great opportunity to join early-stage company with strong technical foundation.",
            skills: ["Growth Marketing", "B2B SaaS", "Startup Experience"],
            compensationType: "Equity + Salary",
            isRemote: true,
            companyType: "Startup",
            timePosted: "6h ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p8",
            title: "Financial Analyst Available",
            company: "FinanceExpert",
            industry: "Finance",
            type: "Service Offering",
            description: "CFA-certified financial analyst available for consulting. Expertise in investment analysis, financial modeling, and startup valuation.",
            skills: ["Finance", "Investment", "Financial Analysis", "Excel"],
            compensationType: "Hourly Rate",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "1d ago",
            isOffering: true
        ),
        ProjectListing(
            id: "p9",
            title: "Need Sales Strategy Help",
            company: "B2B SaaS Startup",
            industry: "SaaS",
            type: "Project Collaboration",
            description: "Early-stage SaaS company looking for sales expert to help build our go-to-market strategy and train our founding team.",
            skills: ["Sales", "Business Development", "B2B SaaS"],
            compensationType: "Paid Contract",
            isRemote: false,
            companyType: "Startup",
            timePosted: "8h ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p10",
            title: "Mechanical Engineer for Product Design",
            company: "HardwareTech",
            industry: "Hardware",
            type: "Contract",
            description: "Hardware startup seeking mechanical engineer for 6-month contract to design consumer product. Experience with CAD and prototyping required.",
            skills: ["Engineering", "Mechanical", "CAD", "Product Design"],
            compensationType: "Paid Contract",
            isRemote: false,
            companyType: "Startup",
            timePosted: "12h ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p11",
            title: "Legal Consultant Available",
            company: "LegalExpert Pro",
            industry: "Legal Services",
            type: "Service Offering",
            description: "Experienced corporate attorney offering legal consulting services. Specializing in startup law, contracts, and intellectual property protection.",
            skills: ["Legal", "Corporate Law", "Contract", "Intellectual Property"],
            compensationType: "Hourly Rate",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "4h ago",
            isOffering: true
        ),
        ProjectListing(
            id: "p12",
            title: "Need HR System Implementation",
            company: "GrowingStartup",
            industry: "Technology",
            type: "Project Collaboration",
            description: "Fast-growing startup needs HR professional to implement employee onboarding, performance management, and benefits administration systems.",
            skills: ["Human Resources", "HRIS", "Performance Management", "Onboarding"],
            compensationType: "Paid Contract",
            isRemote: false,
            companyType: "Startup",
            timePosted: "7h ago",
            isOffering: false
        ),
        ProjectListing(
            id: "p13",
            title: "Research Data Analysis Expert",
            company: "BioTech Research",
            industry: "BioTech",
            type: "Service Offering",
            description: "PhD in Biology with expertise in statistical analysis and scientific research. Available for data analysis projects in life sciences and biotech.",
            skills: ["Research", "Data Analysis", "Biology", "Statistics", "Scientific Writing"],
            compensationType: "Project-based",
            isRemote: true,
            companyType: "Freelance",
            timePosted: "2d ago",
            isOffering: true
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

// MARK: - Create Project Sheet
struct CreateProjectSheet: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var company: String = ""
    @State private var industry: String = ""
    @State private var description: String = ""
    @State private var selectedType: String = "Project Collaboration"
    @State private var selectedCompensation: String = "Paid Contract"
    @State private var selectedCompanyType: String = "Startup"
    @State private var isRemote: Bool = true
    @State private var isOffering: Bool = false
    @State private var skillInput: String = ""
    @State private var skills: [String] = []
    
    let projectTypes = ["Project Collaboration", "Service Offering", "Co-Founder Search", "Contract", "Internship"]
    let compensationTypes = ["Paid Contract", "Equity Position", "Hourly Rate", "Equity + Salary", "Collaboration", "Project-based"]
    let companyTypes = ["Startup", "Small Business", "Enterprise", "Freelance", "Non-Profit"]
    let industries = ["HealthTech", "FinTech", "SaaS", "E-commerce", "AI/Tech", "Marketing", "Legal Services", "BioTech", "Hardware", "EdTech"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Project Listing")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Find collaborators or offer your services")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Offering/Requesting Toggle
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack(spacing: 12) {
                            Button(action: { isOffering = false }) {
                                HStack {
                                    Image(systemName: isOffering ? "circle" : "checkmark.circle.fill")
                                        .foregroundColor(isOffering ? .gray : Color(hex: "004aad"))
                                    Text("Requesting Services")
                                        .foregroundColor(isOffering ? .gray : Color(hex: "004aad"))
                                }
                                .font(.system(size: 14, weight: .medium))
                            }
                            
                            Button(action: { isOffering = true }) {
                                HStack {
                                    Image(systemName: isOffering ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isOffering ? Color.green : .gray)
                                    Text("Offering Services")
                                        .foregroundColor(isOffering ? Color.green : .gray)
                                }
                                .font(.system(size: 14, weight: .medium))
                            }
                        }
                    }
                    
                    // Basic Information
                    VStack(spacing: 16) {
                        FormField(title: "Project Title", text: $title, placeholder: "e.g. iOS Developer for Health App")
                        FormField(title: "Company/Organization", text: $company, placeholder: "Your company name")
                        
                        // Industry Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Industry")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Menu {
                                ForEach(industries, id: \.self) { industryOption in
                                    Button(industryOption) {
                                        industry = industryOption
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(industry.isEmpty ? "Select Industry" : industry)
                                        .foregroundColor(industry.isEmpty ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Project Details
                    VStack(spacing: 16) {
                        // Project Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project Type")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Menu {
                                ForEach(projectTypes, id: \.self) { type in
                                    Button(type) {
                                        selectedType = type
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedType)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Compensation Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Compensation")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Menu {
                                ForEach(compensationTypes, id: \.self) { compensation in
                                    Button(compensation) {
                                        selectedCompensation = compensation
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCompensation)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Company Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Company Type")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Menu {
                                ForEach(companyTypes, id: \.self) { companyType in
                                    Button(companyType) {
                                        selectedCompanyType = companyType
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCompanyType)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Remote Work Toggle
                    HStack {
                        Text("Remote Work")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Toggle("", isOn: $isRemote)
                            .tint(Color(hex: "004aad"))
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Description")
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Skills Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Required Skills")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            TextField("Add a skill", text: $skillInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !skillInput.isEmpty && !skills.contains(skillInput) {
                                    skills.append(skillInput)
                                    skillInput = ""
                                }
                            }
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: "004aad").opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        // Display added skills
                        if !skills.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(skills.indices, id: \.self) { index in
                                        HStack(spacing: 4) {
                                            Text(skills[index])
                                                .font(.system(size: 12))
                                            Button(action: {
                                                skills.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .foregroundColor(Color(hex: "004aad"))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: "004aad").opacity(0.1))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Handle project creation
                        createProject()
                    }
                    .foregroundColor(isFormValid ? Color(hex: "004aad") : .gray)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !company.isEmpty && !industry.isEmpty && !description.isEmpty && !skills.isEmpty
    }
    
    private func createProject() {
        // Handle project creation logic
        print("Creating project: \(title)")
        isPresented = false
    }
}

// MARK: - Create Job Sheet
struct CreateJobSheet: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var company: String = ""
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var salaryRange: String = ""
    @State private var selectedType: String = "Full-Time"
    @State private var selectedExperience: String = "Mid-Level"
    @State private var isRemote: Bool = false
    @State private var skillInput: String = ""
    @State private var skills: [String] = []
    @State private var benefits: [String] = []
    @State private var benefitInput: String = ""
    
    let jobTypes = ["Full-Time", "Part-Time", "Contract", "Internship", "Freelance"]
    let experienceLevels = ["Entry-Level", "Mid-Level", "Senior-Level", "Executive", "Student"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Post Job Opening")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Find the perfect candidate for your team")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Basic Information
                    VStack(spacing: 16) {
                        FormField(title: "Job Title", text: $title, placeholder: "e.g. Senior iOS Developer")
                        FormField(title: "Company", text: $company, placeholder: "Company name")
                        FormField(title: "Location", text: $location, placeholder: "e.g. San Francisco, CA")
                        FormField(title: "Salary Range", text: $salaryRange, placeholder: "e.g. $80k - $120k")
                    }
                    
                    // Job Details
                    VStack(spacing: 16) {
                        // Job Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Job Type")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Menu {
                                ForEach(jobTypes, id: \.self) { type in
                                    Button(type) {
                                        selectedType = type
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedType)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Experience Level
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Experience Level")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Menu {
                                ForEach(experienceLevels, id: \.self) { level in
                                    Button(level) {
                                        selectedExperience = level
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedExperience)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Remote Work Toggle
                    HStack {
                        Text("Remote Position")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Toggle("", isOn: $isRemote)
                            .tint(Color(hex: "004aad"))
                    }
                    
                    // Job Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Job Description")
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Skills Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Required Skills")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            TextField("Add a skill", text: $skillInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !skillInput.isEmpty && !skills.contains(skillInput) {
                                    skills.append(skillInput)
                                    skillInput = ""
                                }
                            }
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: "004aad").opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        // Display added skills
                        if !skills.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(skills.indices, id: \.self) { index in
                                        HStack(spacing: 4) {
                                            Text(skills[index])
                                                .font(.system(size: 12))
                                            Button(action: {
                                                skills.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .foregroundColor(Color(hex: "004aad"))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: "004aad").opacity(0.1))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Benefits Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Benefits & Perks")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            TextField("Add a benefit", text: $benefitInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !benefitInput.isEmpty && !benefits.contains(benefitInput) {
                                    benefits.append(benefitInput)
                                    benefitInput = ""
                                }
                            }
                            .foregroundColor(Color(hex: "004aad"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: "004aad").opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        // Display added benefits
                        if !benefits.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(benefits.indices, id: \.self) { index in
                                        HStack(spacing: 4) {
                                            Text(benefits[index])
                                                .font(.system(size: 12))
                                            Button(action: {
                                                benefits.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .foregroundColor(Color.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Handle job creation
                        createJob()
                    }
                    .foregroundColor(isFormValid ? Color(hex: "004aad") : .gray)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !company.isEmpty && !location.isEmpty && !description.isEmpty && !skills.isEmpty
    }
    
    private func createJob() {
        // Handle job creation logic
        print("Creating job: \(title)")
        isPresented = false
    }
}

// MARK: - Form Field Component
struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
        }
    }
}

// MARK: - Filter Button Component
