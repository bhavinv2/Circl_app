import SwiftUI

// MARK: - Channels Section Component
struct ChannelsSection: View {
    let channels: [Channel]
    let circle: CircleData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Channels Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Channels")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Join conversations by topic")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(channels.count) channels")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "004aad").opacity(0.1))
                    )
            }
            .padding(.horizontal, 20)
            
            if !channels.isEmpty {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(channels, id: \.id) { channel in
                        NavigationLink(destination: PageCircleMessages(channel: channel, circleName: circle.name).navigationBarBackButtonHidden(true)) {
                            ChannelListItem(channel: channel)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                    }
                }
            } else {
                EmptyChannelsView()
            }
        }
        .padding(.bottom, 100) // Space for bottom navigation
    }
}

// MARK: - Channel List Item Component
struct ChannelListItem: View {
    let channel: Channel
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced Channel Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "004aad"),
                                Color(hex: "0066ff"),
                                Color(hex: "3399ff")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "number")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Channel Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(channel.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Activity indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        
                        Text("Active")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                
                Text("Join the conversation in \(channel.name)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Enhanced Stats
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "004aad"))
                        Text("24 members")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "004aad"))
                        Text("18 messages")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Arrow indicator with enhanced styling
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "004aad"))
                .padding(8)
                .background(
                    Circle()
                        .fill(Color(hex: "004aad").opacity(0.1))
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Empty Channels View Component
struct EmptyChannelsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "004aad").opacity(0.4))
            
            Text("No channels available")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Channels will appear here once they're created by moderators")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "004aad").opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
struct ChannelsSection_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsSection(
            channels: [],
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
                isModerator: true
            )
        )
    }
}
