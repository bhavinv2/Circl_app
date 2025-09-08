import SwiftUI
import Foundation

// MARK: - User Points Models
struct UserPoints: Identifiable, Codable {
    let id: Int
    let user: Int
    let circle: Int
    let total_points: Int
    let last_updated: String
    let user_name: String
    let circle_name: String
}

struct CircleLeaderboardResponse: Codable {
    let circle_id: Int
    let circle_name: String
    let leaderboard: [UserPoints]
}

struct UserCheckInHistory: Identifiable, Codable {
    let id: Int
    let event_id: Int
    let event_title: String
    let circle_id: Int
    let circle_name: String
    let points_earned: Int
    let checked_in_at: String
}

struct CheckInHistoryResponse: Codable {
    let user_id: Int
    let checkins: [UserCheckInHistory]
    let total_checkins: Int
}

// MARK: - Points Summary View
struct PointsSummaryView: View {
    let circle: CircleData
    @AppStorage("user_id") private var userId: Int = 0
    @State private var userPoints: UserPoints?
    @State private var checkInHistory: [UserCheckInHistory] = []
    @State private var leaderboard: [UserPoints] = []
    @State private var isLoading = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Points & Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Track your engagement and see how you rank")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Tab Picker
            Picker("View", selection: $selectedTab) {
                Text("My Points").tag(0)
                Text("Activity").tag(1)
                Text("Leaderboard").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Content based on selected tab
            if isLoading {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TabView(selection: $selectedTab) {
                    MyPointsView(userPoints: userPoints)
                        .tag(0)
                    
                    ActivityView(checkInHistory: checkInHistory)
                        .tag(1)
                    
                    LeaderboardView(leaderboard: leaderboard)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            fetchData()
        }
        .onChange(of: selectedTab) { _ in
            fetchData()
        }
    }
    
    // MARK: - API Functions
    func fetchData() {
        isLoading = true
        
        switch selectedTab {
        case 0:
            fetchUserPoints()
        case 1:
            fetchCheckInHistory()
        case 2:
            fetchLeaderboard()
        default:
            isLoading = false
        }
    }
    
    func fetchUserPoints() {
        guard let url = URL(string: "\(baseURL)circles/users/\(userId)/points/\(circle.id)/") else {
            print("❌ Invalid URL for user points")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let points = try JSONDecoder().decode(UserPoints.self, from: data)
                    self.userPoints = points
                } catch {
                    print("❌ Failed to decode user points: \(error)")
                }
            }
        }.resume()
    }
    
    func fetchCheckInHistory() {
        guard let url = URL(string: "\(baseURL)circles/users/\(userId)/checkin_history/?circle_id=\(circle.id)") else {
            print("❌ Invalid URL for check-in history")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(CheckInHistoryResponse.self, from: data)
                    self.checkInHistory = response.checkins
                } catch {
                    print("❌ Failed to decode check-in history: \(error)")
                }
            }
        }.resume()
    }
    
    func fetchLeaderboard() {
        guard let url = URL(string: "\(baseURL)circles/circles/\(circle.id)/leaderboard/") else {
            print("❌ Invalid URL for leaderboard")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(CircleLeaderboardResponse.self, from: data)
                    self.leaderboard = response.leaderboard
                } catch {
                    print("❌ Failed to decode leaderboard: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - My Points View
struct MyPointsView: View {
    let userPoints: UserPoints?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let userPoints = userPoints {
                    // Points Card
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(userPoints.total_points)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Total Points")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Circle: \(userPoints.circle_name)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("Last updated: \(formatLastUpdated(userPoints.last_updated))")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // How to Earn Points
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Earn Points")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            PointsEarnRow(
                                icon: "calendar.badge.checkmark",
                                title: "Check into Events",
                                description: "Attend circle events and check in to earn points",
                                color: Color(hex: "004aad")
                            )
                            
                            PointsEarnRow(
                                icon: "person.2.fill",
                                title: "Engage with Community",
                                description: "Participate actively in circle activities",
                                color: .green
                            )
                            
                            PointsEarnRow(
                                icon: "star.circle.fill",
                                title: "Consistent Participation",
                                description: "Regular attendance earns bonus points",
                                color: .orange
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Points Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Start attending events to earn your first points!")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private func formatLastUpdated(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - Points Earn Row
struct PointsEarnRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Activity View
struct ActivityView: View {
    let checkInHistory: [UserCheckInHistory]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if checkInHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Activity Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Your check-in history will appear here.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(checkInHistory) { checkIn in
                            CheckInHistoryCard(checkIn: checkIn)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Check-in History Card
struct CheckInHistoryCard: View {
    let checkIn: UserCheckInHistory
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(checkIn.event_title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(formatCheckinTime(checkIn.checked_in_at))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                
                Text("+\(checkIn.points_earned)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatCheckinTime(_ timeString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: timeString) else {
            return timeString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    let leaderboard: [UserPoints]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if leaderboard.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Leaderboard Data")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Check back after members start earning points.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, userPoints in
                            LeaderboardCard(rank: index + 1, userPoints: userPoints)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Leaderboard Card
struct LeaderboardCard: View {
    let rank: Int
    let userPoints: UserPoints
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 36, height: 36)
                
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userPoints.user_name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Updated \(formatLastUpdated(userPoints.last_updated))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                
                Text("\(userPoints.total_points)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rank <= 3 ? rankColor.opacity(0.3) : Color.clear, lineWidth: 2)
        )
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
    
    private func formatLastUpdated(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - Preview
struct PointsSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        PointsSummaryView(circle: CircleData(
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
            hasDashboard: true
        ))
    }
}
