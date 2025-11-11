import SwiftUI
import Foundation
import UIKit

struct PageSkillSellingPlaceholder: View {
    // MARK: - State Management
    @State private var showMoreMenu = false
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @AppStorage("user_id") private var userId: Int = 0

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Main Content
                VStack(spacing: 0) {
                    headerSection
                    placeholderContent
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
                        
                        // Growth Hub (Current page - highlighted)
                        VStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("Growth Hub")
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
        .navigationBarHidden(true)
        .onAppear {
            loadUserData()
        }
    }

    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Profile
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
                
                // Center - Logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
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
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 15)
            .padding(.top, 4)
        }
        .padding(.top, 12) // Reduced from 15 to 12
        .background(Color(hex: "004aad"))
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
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 100) // Space for bottom navigation
            }
        }
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Functions
    func loadUserData() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        let urlString = "\(baseURL)users/profile/\(userId)/"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let profile = try? JSONDecoder().decode(FullProfile.self, from: data) {
                DispatchQueue.main.async {
                    self.userFirstName = profile.first_name ?? ""
                    self.userProfileImageURL = profile.profile_image ?? ""
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