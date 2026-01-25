import SwiftUI

struct UnifiedMetricsView: View {
    @ObservedObject private var networkManager = NetworkDataManager.shared

    private var totalPotentialMatches: Int {
        networkManager.entrepreneurs.count + networkManager.mentors.count
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                metricCard(
                    icon: "person.3.fill",
                    title: "Your\nNetwork",
                    value: "\(networkManager.userNetworkEmails.count)",
                    color: .blue
                )
                metricCard(
                    icon: "envelope.fill",
                    title: "Pending\nInvites",
                    value: "\(networkManager.friendRequests.count)",
                    color: .orange
                )
                metricCard(
                    icon: "star.fill",
                    title: "Potential\nMatches",
                    value: "\(totalPotentialMatches)",
                    color: .purple
                )
            }
            
            // Temporary debug info and refresh button
            HStack {
                Text("Debug: Network emails count: \(networkManager.userNetworkEmails.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button("Refresh") {
                    networkManager.forceRefreshNetwork()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(4)
            }
        }
        .onAppear {
            print("🔄 UnifiedMetricsView - View appeared, current network count: \(networkManager.userNetworkEmails.count)")
            // Force refresh when view appears
            networkManager.forceRefreshNetwork()
        }
    }

    private func metricCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
