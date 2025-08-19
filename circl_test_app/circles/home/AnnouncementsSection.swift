import SwiftUI
import Foundation

struct AnnouncementModel: Codable, Identifiable {
    let id: Int
    let user: String
    let title: String
    let content: String
    let announced_at: String
}

// MARK: - Announcements Section Component
struct AnnouncementsSection: View {
    let announcements: [AnnouncementModel]
    @Binding var showCreateAnnouncementPopup: Bool
    let userId: Int
    let circle: CircleData
    @State private var showAllAnnouncements = false

    var body: some View {
        if !announcements.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                // Enhanced Section Header with modern design
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "004aad").opacity(0.8),
                                            Color(hex: "0066ff").opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "megaphone.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Announcements")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Enhanced create announcement button for moderators
                    if userId == circle.creatorId {
                        Button(action: {
                            showCreateAnnouncementPopup = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                
                                Text("Create")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "004aad"),
                                        Color(hex: "0066ff")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Enhanced Announcements List - Show top 3
                VStack(spacing: 12) {
                    ForEach(announcements.prefix(3)) { announcement in
                        AnnouncementCard(announcement: announcement)
                    }

                    // Show All button if more than 3
                    if announcements.count > 3 {
                        Button(action: {
                            showAllAnnouncements = true
                        }) {
                            Text("Show All Announcements")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.top, 6)
                        }
                        .sheet(isPresented: $showAllAnnouncements) {
                            AllAnnouncementsView(announcements: announcements)
                        }
                    }
                }
                .padding(.horizontal, 20)

            }
        } else {
            // Enhanced Empty State
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "004aad").opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "megaphone")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "004aad").opacity(0.6))
                }
                
                VStack(spacing: 8) {
                    Text("No Announcements Yet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Stay tuned for important updates from circle moderators")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Create announcement button for moderators in empty state
                if userId == circle.creatorId {
                    Button(action: {
                        showCreateAnnouncementPopup = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Create First Announcement")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "004aad"),
                                    Color(hex: "0066ff")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Enhanced Announcement Card Component
struct AnnouncementCard: View {
    let announcement: AnnouncementModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Enhanced compact header - always visible
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Microphone symbol instead of moderator badge
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 32, height: 32)

                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(announcement.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 6) {
                            Text("By \(announcement.user)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 3, height: 3)
                            
                            Text(formatDate(announcement.announced_at))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Enhanced expand/collapse indicator
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable content with enhanced styling
            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    // Elegant divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 18)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(announcement.content)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.95))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Posted \(formatDate(announcement.announced_at))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            // Engagement icons
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "message")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .bottom))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "004aad"), location: 0.0),
                            .init(color: Color(hex: "0056cc"), location: 0.5),
                            .init(color: Color(hex: "0066ff"), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "004aad").opacity(0.25), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Date Formatting Helper
private func formatDate(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    
    if let date = formatter.date(from: dateString) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
    
    return "Recently"
}

// MARK: - Preview
struct AnnouncementsSection_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementsSection(
            announcements: [
                AnnouncementModel(
                    id: 1,
                    user: "CirclModerator",
                    title: "Welcome to our Circle! 🎉",
                    content: "Hello everyone! We're excited to have you join our community. Please take a moment to introduce yourself in the introductions channel and read our community guidelines. Looking forward to great discussions!",
                    announced_at: "2024-12-20T10:30:00Z"
                ),
                AnnouncementModel(
                    id: 2,
                    user: "TechLead",
                    title: "Weekly Networking Event 🚀",
                    content: "Join us this Friday at 6 PM PST for our weekly virtual networking session.",
                    announced_at: "2024-12-19T15:45:00Z"
                )
            ],
            showCreateAnnouncementPopup: .constant(false),
            userId: 1,
            circle: CircleData(
                id: 1,
                name: "Test Circle",
                industry: "Tech",
                memberCount: 100,
                imageName: "test",
                pricing: "Free",
                description: "Test Description",
                joinType: .joinNow,
                channels: ["general"],
                creatorId: 1,
                isModerator: true,
                isPrivate: false,
                hasDashboard: true
            )
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
struct AllAnnouncementsView: View {
    let announcements: [AnnouncementModel]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(announcements) { announcement in
                        AnnouncementCard(announcement: announcement)
                    }
                }
                .padding()
            }
            .navigationTitle("All Announcements")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
