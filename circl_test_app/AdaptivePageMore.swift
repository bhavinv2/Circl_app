import SwiftUI

// MARK: - Adaptive PageMore Implementation

struct AdaptivePageMore: View {
    @Binding var userFirstName: String
    @Binding var userProfileImageURL: String
    @Binding var unreadMessageCount: Int
    
    // Menu items data
    private let menuItems = [
        AdaptiveMenuItem(icon: "person.2.fill", title: "Connect and Network", description: "Build your professional network", destination: "PageMyNetwork"),
        AdaptiveMenuItem(icon: "person.crop.square.fill", title: "Your Business Profile", description: "Manage your business presence", destination: "PageBusinessProfile"),
        AdaptiveMenuItem(icon: "briefcase.fill", title: "Professional Services", description: "Explore business resources", destination: "PageEntrepreneurResources"),
        AdaptiveMenuItem(icon: "person.3.fill", title: "Find Entrepreneurs", description: "Connect with fellow entrepreneurs", destination: "PageEntrepreneurMatching"),
        AdaptiveMenuItem(icon: "graduationcap.fill", title: "Find Mentors", description: "Get guidance from experts", destination: "PageMentorMatching"),
        AdaptiveMenuItem(icon: "newspaper.fill", title: "News & Knowledge", description: "Stay informed and learn", destination: "PageEntrepreneurKnowledge"),
        AdaptiveMenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange", description: "Monetize your skills", destination: "PageSkillSellingMatching"),
        AdaptiveMenuItem(icon: "circle.grid.2x2.fill", title: "Circles", description: "Join interest-based groups", destination: "PageCircles"),
        AdaptiveMenuItem(icon: "bubble.left.and.bubble.right.fill", title: "Group Chats", description: "Participate in discussions", destination: "PageGroupchats")
    ]

    var body: some View {
        AdaptivePage(title: "More", unreadMessageCount: unreadMessageCount) {
            ScrollView {
                VStack(spacing: 0) {
                    // Welcome header
                    VStack(spacing: 16) {
                        Text("Welcome, \(userFirstName)!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Discover resources to grow your business")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    .padding(.horizontal)
                    
                    // Adaptive menu grid
                    AdaptiveGrid {
                        ForEach(menuItems) { item in
                            AdaptiveMenuItemCard(item: item)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Menu Item Data Model

struct AdaptiveMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let destination: String
}

// MARK: - Adaptive Menu Item Card

struct AdaptiveMenuItemCard: View {
    let item: AdaptiveMenuItem
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        Button(action: {
            // Handle navigation based on destination
            navigateToDestination(item.destination)
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "004aad").opacity(0.1))
                        .frame(width: isCompactLayout ? 50 : 60, height: isCompactLayout ? 50 : 60)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: isCompactLayout ? 20 : 24, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: isCompactLayout ? 16 : 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if !isCompactLayout {
                        Text(item.description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.secondary)
            }
            .padding(isCompactLayout ? 16 : 20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func navigateToDestination(_ destination: String) {
        // This would be handled by your navigation system
        print("Navigate to: \(destination)")
        
        // You could implement this with a navigation coordinator or
        // by using NavigationLink destinations
    }
}

// MARK: - Usage Instructions

/*
 To use this adaptive PageMore in your app:
 
 1. Replace your existing PageMore with AdaptivePageMore
 2. Or update your existing PageMore to use the adaptive wrapper:
 
 struct PageMore: View {
     @Binding var userFirstName: String
     @Binding var userProfileImageURL: String
     @Binding var unreadMessageCount: Int

     var body: some View {
         AdaptivePageMore(
             userFirstName: $userFirstName,
             userProfileImageURL: $userProfileImageURL,
             unreadMessageCount: $unreadMessageCount
         )
     }
 }
 */