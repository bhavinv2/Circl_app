import SwiftUI
import Foundation

// MARK: - Dashboard Models
struct DashboardSummary: Codable {
    let total_events: Int
    let total_points: Int
    let total_members: Int
    let total_revenue: Int
    let total_projects: Int?

    let event_type_distribution: [String: Int]
}

struct LeaderboardEntry: Identifiable, Codable {
    let user_id: Int
    let name: String
    let email: String
    let points: Int
    
    var id: Int { user_id }
}

// MARK: - Dashboard View
struct DashboardView: View {
    let circle: CircleData
    @State private var summary: DashboardSummary?
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var isLoading = false
    @State private var selectedTimeframe: String = "all"
    
    let timeframes = ["all", "weekly", "monthly"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(circle.name) Dashboard")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Overview of circle activity and analytics")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Circle Info Card
                CircleInfoCard(circle: circle)
                    .padding(.horizontal, 20)
                
                // Summary Cards
                if let summary = summary {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        NavigationLink(
                            destination: CalendarView(circle: circle, defaultShowAllEvents: true)
                        ) {
                            SummaryCard(
                                title: "Total Events",
                                value: "\(summary.total_events)",
                                icon: "calendar.badge.plus",
                                color: Color(hex: "004aad")
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        
                        NavigationLink(
                            destination: MemberListPage(circleName: circle.name, circleId: circle.id)
                        ) {
                            SummaryCard(
                                title: "Total Members",
                                value: "\(summary.total_members)",
                                icon: "person.2.fill",
                                color: .green
                            )
                        }
                        .buttonStyle(PlainButtonStyle()) // Prevents blue highlight on tap

                        
//                        SummaryCard(
//                            title: "Total Points",
//                            value: "\(summary.total_points)",
//                            icon: "star.fill",
//                            color: .orange
//                        )
//                        
//                        SummaryCard(
//                            title: "Revenue",
//                            value: "$\(summary.total_revenue)",
//                            icon: "dollarsign.circle.fill",
//                            color: .purple
//                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Event Type Distribution
                if let summary = summary, !summary.event_type_distribution.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Event Types")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(summary.event_type_distribution.keys.sorted()), id: \.self) { eventType in
                                if let count = summary.event_type_distribution[eventType] {
                                    EventTypeRow(
                                        eventType: eventType,
                                        count: count,
                                        total: summary.event_type_distribution.values.reduce(0, +)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Leaderboard Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Circle Leaderboard")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Timeframe picker
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            Text("All Time").tag("all")
                            Text("Weekly").tag("weekly")
                            Text("Monthly").tag("monthly")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200)
                    }
                    .padding(.horizontal, 20)
                    .onChange(of: selectedTimeframe) { _ in
                        fetchLeaderboard()
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    } else if leaderboard.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "trophy")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("No leaderboard data")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(
                                    rank: index + 1,
                                    entry: entry
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 100) // Space for bottom navigation
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            fetchDashboardData()
            fetchLeaderboard()
        }
    }
    
    // MARK: - API Functions
    func fetchDashboardData() {
        guard let url = URL(string: "\(baseURL)circles/dashboard/\(circle.id)/") else {
                print("❌ Invalid URL for dashboard summary")
                loadSampleSummary()
                return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    loadSampleSummary()
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    loadSampleSummary()
                    return
                }
                
                do {
                    let decodedSummary = try JSONDecoder().decode(DashboardSummary.self, from: data)
                    print("✅ Successfully decoded summary: \(decodedSummary)")
                    self.summary = decodedSummary
                } catch {
                    print("❌ Failed to decode summary: \(error)")
                }

            }
        }.resume()
    }
    
    func fetchLeaderboard() {
        var urlString = "\(baseURL)circles/leaderboard/\(circle.id)/"

        if selectedTimeframe != "all" {
            urlString += "?timeframe=\(selectedTimeframe)"
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for leaderboard")
            loadSampleLeaderboard()
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    loadSampleLeaderboard()
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    loadSampleLeaderboard()
                    return
                }
                
                do {
                    let decodedLeaderboard = try JSONDecoder().decode([LeaderboardEntry].self, from: data)
                    self.leaderboard = Array(decodedLeaderboard.prefix(10)) // Top 10
                } catch {
                    print("❌ Failed to decode leaderboard: \(error)")
                    loadSampleLeaderboard()
                }
            }
        }.resume()
    }
    
    // Sample data for testing
    func loadSampleSummary() {
        summary = DashboardSummary(
            total_events: 25,
            total_points: 350,
            total_members: circle.memberCount,
            total_revenue: 1200,
            total_projects: 8,
            event_type_distribution: [
                "Workshop": 12,
                "Speaker": 8,
                "Social": 5
            ]
        )
    }
    
    func loadSampleLeaderboard() {
        leaderboard = [
            LeaderboardEntry(user_id: 1, name: "Alice Johnson", email: "alice@example.com", points: 95),
            LeaderboardEntry(user_id: 2, name: "Bob Smith", email: "bob@example.com", points: 87),
            LeaderboardEntry(user_id: 3, name: "Charlie Brown", email: "charlie@example.com", points: 72),
            LeaderboardEntry(user_id: 4, name: "Diana Prince", email: "diana@example.com", points: 68),
            LeaderboardEntry(user_id: 5, name: "Ethan Hunt", email: "ethan@example.com", points: 55)
        ]
    }
}

// MARK: - Circle Info Card Component
struct CircleInfoCard: View {
    let circle: CircleData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(circle.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(circle.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                InfoPill(
                    icon: "person.2.fill",
                    text: "\(circle.memberCount) members",
                    color: Color(hex: "004aad")
                )
                
                InfoPill(
                    icon: "building.2.fill",
                    text: circle.industry,
                    color: .green
                )
                
                InfoPill(
                    icon: "dollarsign.circle.fill",
                    text: circle.pricing,
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Info Pill Component
struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Summary Card Component
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Event Type Row Component
struct EventTypeRow: View {
    let eventType: String
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(eventType)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(count) events")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: "004aad"))
                        .frame(width: geometry.size.width * percentage)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width * (1 - percentage))
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Leaderboard Row Component
struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(entry.email)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                
                Text("\(entry.points)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1:
            return Color(hex: "FFD700") // Gold
        case 2:
            return Color(hex: "C0C0C0") // Silver
        case 3:
            return Color(hex: "CD7F32") // Bronze
        default:
            return Color(hex: "004aad")
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(circle: CircleData(
            id: 1,
            name: "Test Circle",
            industry: "Tech",
            memberCount: 100,
            imageName: "test",
            pricing: "Free",
            description: "A community of tech entrepreneurs",
            joinType: .joinNow,
            channels: ["general"],
            creatorId: 1,
            isModerator: true,
            isPrivate: false,
            hasDashboard: true // ✅ Add this
            
        ))
    }
}
