import SwiftUI

// MARK: - Placeholder Dependencies

let sampleCircle = CircleData(
    id: 0,
    name: "Sample Circle",
    industry: "Tech",
    memberCount: 100,
    imageName: "sample.png",
    pricing: "Free",
    description: "This is a placeholder.",
    joinType: .joinNow,
    channels: [],
    creatorId: 0,
    isModerator: false,
    isPrivate: false,
    hasDashboard: false // ✅ Add this
)


struct PageMore: View {
    @Binding var userFirstName: String
    @Binding var userProfileImageURL: String
    @Binding var unreadMessageCount: Int

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 0) {
                        HStack {
                            Text("More")
                                .font(.system(size: 34, weight: .bold, design: .default))
                                .foregroundColor(.white)

                            Spacer()

                            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
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
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .padding(.top, 50)
                    }
                    .background(Color(hex: "004aad"))
                    .ignoresSafeArea(edges: .top)

                    // Menu Content
                    ScrollView {
                        VStack(spacing: 0) {
                            Text("Welcome to your resources")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                                .padding(.bottom, 30)

                            VStack(spacing: 0) {
                                MenuItemRow(icon: "person.2.fill", title: "Connect and Network", color: Color(hex: "004aad"), destination: AnyView(PageMyNetwork().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "person.crop.square.fill", title: "Your Business Profile", color: Color(hex: "004aad"), destination: AnyView(PageBusinessProfile().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "briefcase.fill", title: "Professional Services", color: Color(hex: "004aad"), destination: AnyView(PageEntrepreneurResources().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "person.3.fill", title: "Find Entrepreneurs", color: Color(hex: "004aad"), destination: AnyView(PageEntrepreneurMatching().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "graduationcap.fill", title: "Find Mentors", color: Color(hex: "004aad"), destination: AnyView(PageMentorMatching().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "newspaper.fill", title: "News & Knowledge", color: Color(hex: "004aad"), destination: AnyView(PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "dollarsign.circle.fill", title: "The Circl Exchange", color: Color(hex: "004aad"), destination: AnyView(PageSkillSellingMatching().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "circle.grid.2x2.fill", title: "Circles", color: Color(hex: "004aad"), destination: AnyView(PageCircles().navigationBarBackButtonHidden(true)))
                                MenuItemRow(icon: "bubble.left.and.bubble.right.fill", title: "Group Chats", color: Color(hex: "004aad"), destination: AnyView(PageGroupchats(circle: sampleCircle).navigationBarBackButtonHidden(true)))
                            }
                        }
                        .padding(.bottom, 120)
                    }
                    .background(Color(UIColor.systemGray6))
                }

                // Bottom Navigation
                VStack {
                    Spacer()
                    HStack(spacing: 0) {
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
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                                    if unreadMessageCount > 0 {
                                        Text("\(unreadMessageCount)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(minWidth: 16, minHeight: 16)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 12, y: -12)
                                    }
                                }
                                Text("Messages")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        VStack(spacing: 4) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("More")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                        }
                        .frame(maxWidth: .infinity)
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
        }
        .navigationBarHidden(true)
    }
}

struct MenuItemRow: View {
    let icon: String
    let title: String
    let color: Color
    let destination: AnyView
    var badgeCount: Int = 0

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)

                    if badgeCount > 0 {
                        Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 15, y: -15)
                    }
                }

                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())

        Divider()
            .background(Color.gray.opacity(0.3))
    }
}
