import SwiftUI
import Foundation
import UIKit

struct PageSkillSellingPlaceholder: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // User data for header
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        AdaptiveContentWrapper(
            configuration: AdaptivePageConfiguration(
                title: "Growth Hub",
                navigationItems: AdaptivePageConfiguration.defaultNavigation(currentPageTitle: "Growth Hub", unreadMessageCount: unreadMessageCount)
            ),
            customHeader: { layoutManager in
                growthHubHeader(layoutManager: layoutManager)
            }
        ) {
            placeholderContent
        }
    }

    // MARK: - Placeholder Content
    var placeholderContent: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Add some spacing from header
                Spacer().frame(height: 20)
                
                // Marketplace Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                }
                
                // Coming Soon Message
                VStack(spacing: 20) {
                    Text("The Growth Hub is Almost Here!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                
                // Features Preview
                VStack(spacing: 20) {
                    Text("What's Coming:")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if isCompact {
                        // iPhone: Single column
                        VStack(spacing: 16) {
                            FeaturePreviewCard(
                                icon: "dollarsign.circle.fill",
                                title: "Earn Extra Income",
                                description: "Turn your skills into cash flow. Set your rates, work on your schedule, and get paid securely through our escrow system."
                            )
                            
                            FeaturePreviewCard(
                                icon: "person.2.crop.square.stack.fill",
                                title: "Build or Hire Your Team",
                                description: "From finding your next co-founder to building your marketing team — everything you need to scale your venture. Connect with the right people and turn your vision into reality."
                            )
                            
                            FeaturePreviewCard(
                                icon: "shield.checkered",
                                title: "Work With Confidence",
                                description: "No more payment worries. Our secure escrow system protects both parties until projects are completed to satisfaction."
                            )
                            
                            FeaturePreviewCard(
                                icon: "network",
                                title: "Access Hidden Opportunities",
                                description: "Discover exclusive projects and collaborations that aren't posted anywhere else - from fellow entrepreneurs who get it."
                            )
                            
                            FeaturePreviewCard(
                                icon: "hammer.fill",
                                title: "Collaborate on Projects",
                                description: "Build your résumé and gain hands-on experience by working closely with real companies. Prove your skills, grow your network, and maybe even land your next job."
                            )
                            
                            FeaturePreviewCard(
                                icon: "building.2.fill",
                                title: "Join Companies & Startups",
                                description: "Step into the action — join emerging startups or established teams looking for talent like you. Turn your ambition into opportunity and build the career you've been working for."
                            )
                        }
                    } else {
                        // iPad: Two columns
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            FeaturePreviewCard(
                                icon: "dollarsign.circle.fill",
                                title: "Earn Extra Income",
                                description: "Turn your skills into cash flow. Set your rates, work on your schedule, and get paid securely through our escrow system."
                            )
                            
                            FeaturePreviewCard(
                                icon: "person.2.crop.square.stack.fill",
                                title: "Build or Hire Your Team",
                                description: "From finding your next co-founder to building your marketing team — everything you need to scale your venture. Connect with the right people and turn your vision into reality."
                            )
                            
                            FeaturePreviewCard(
                                icon: "shield.checkered",
                                title: "Work With Confidence",
                                description: "No more payment worries. Our secure escrow system protects both parties until projects are completed to satisfaction."
                            )
                            
                            FeaturePreviewCard(
                                icon: "network",
                                title: "Access Hidden Opportunities",
                                description: "Discover exclusive projects and collaborations that aren't posted anywhere else - from fellow entrepreneurs who get it."
                            )
                            
                            FeaturePreviewCard(
                                icon: "hammer.fill",
                                title: "Collaborate on Projects",
                                description: "Build your résumé and gain hands-on experience by working closely with real companies. Prove your skills, grow your network, and maybe even land your next job."
                            )
                            
                            FeaturePreviewCard(
                                icon: "building.2.fill",
                                title: "Join Companies & Startups",
                                description: "Step into the action — join emerging startups or established teams looking for talent like you. Turn your ambition into opportunity and build the career you've been working for."
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100) // Space for bottom navigation
            }
        }
        .background(Color(.systemGray6))
    }
    
    // MARK: - Custom Header
    private func growthHubHeader(layoutManager: AdaptiveLayoutManager) -> some View {
        VStack(spacing: 0) {
            HStack {
                // Left side: Profile picture
                NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
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
                
                // Center: Circl. logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side: Messages icon with badge
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Image(systemName: "envelope.fill")
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
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(hex: "004aad"))
        .onAppear {
            fetchUserData()
        }
    }
    
    // MARK: - Data Fetching
    private func fetchUserData() {
        if let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
            fetchCurrentUserProfile(userId: userId)
        }
        fetchUnreadMessageCount()
    }
    
    private func fetchCurrentUserProfile(userId: Int) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                DispatchQueue.main.async {
                    if let profileImage = decoded.profile_image, !profileImage.isEmpty {
                        self.userProfileImageURL = profileImage
                    }
                }
            }
        }.resume()
    }
    
    private func fetchUnreadMessageCount() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        let urlString = "https://circlapp.online/api/messages/"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let messages = try? JSONDecoder().decode([MessageModel].self, from: data) {
                let unreadMessages = messages.filter { $0.receiver_id == userId && !$0.is_read }
                DispatchQueue.main.async {
                    self.unreadMessageCount = unreadMessages.count
                }
            }
        }.resume()
    }
}

// MARK: - Feature Preview Card
struct FeaturePreviewCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "004aad"))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: "004aad").opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview
struct PageSkillSellingPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        PageSkillSellingPlaceholder()
    }
}