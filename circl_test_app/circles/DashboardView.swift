import SwiftUI
import Foundation

// MARK: - Dashboard Models
struct DashboardSummary: Codable {
    let total_events: Int
    let total_points: Int
    let total_members: Int
    let total_revenue: Int
    let total_projects: Int
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
    @State private var showKanbanPopup = false
    @State private var showCRMPopup = false
    
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
                        SummaryCard(
                            title: "Total Events",
                            value: "\(summary.total_events)",
                            icon: "calendar.badge.plus",
                            color: Color(hex: "004aad")
                        )
                        
                        SummaryCard(
                            title: "Total Members",
                            value: "\(summary.total_members)",
                            icon: "person.2.fill",
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Total Points",
                            value: "\(summary.total_points)",
                            icon: "star.fill",
                            color: .orange
                        )
                        
                        SummaryCard(
                            title: "Revenue",
                            value: "$\(summary.total_revenue)",
                            icon: "dollarsign.circle.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // KPI Tiles Section
                KPITilesSection()
                    .padding(.horizontal, 20)
                
                // Kanban Board Section
                Button(action: {
                    withAnimation(.spring()) {
                        showKanbanPopup = true
                    }
                }) {
                    KanbanBoardSection()
                        .padding(.horizontal, 20)
                }
                .buttonStyle(PlainButtonStyle())
                
                // CRM Pipeline Section
                Button(action: {
                    withAnimation(.spring()) {
                        showCRMPopup = true
                    }
                }) {
                    CRMPipelineSection()
                        .padding(.horizontal, 20)
                }
                .buttonStyle(PlainButtonStyle())
                
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
        .overlay(
            // Kanban Popup
            Group {
                if showKanbanPopup {
                    KanbanPopupView(isPresented: $showKanbanPopup)
                }
            }
        )
        .overlay(
            // CRM Popup
            Group {
                if showCRMPopup {
                    CRMPopupView(isPresented: $showCRMPopup)
                }
            }
        )
    }
    
    // MARK: - API Functions
    func fetchDashboardData() {
        guard let url = URL(string: "http://localhost:8000/api/circles/dashboard/\(circle.id)/") else {
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
                    self.summary = decodedSummary
                } catch {
                    print("❌ Failed to decode summary: \(error)")
                    loadSampleSummary()
                }
            }
        }.resume()
    }
    
    func fetchLeaderboard() {
        var urlString = "http://localhost:8000/api/circles/leaderboard/\(circle.id)/"
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
            return Color.gray
        }
    }
}

// MARK: - New Dashboard Models
struct KPITile: Identifiable {
    let id = UUID()
    let title: String
    let current: Int
    let target: Int
    let unit: String
    let color: Color
    
    var progress: Double {
        return target > 0 ? Double(current) / Double(target) : 0
    }
    
    var progressText: String {
        return "\(current)/\(target) (\(Int(progress * 100))%)"
    }
}

struct KanbanTask: Identifiable, Codable {
    let id = UUID()
    let title: String
    let assignedUser: String
    let dueDate: Date
    let tag: String?
    var column: KanbanColumn
    
    enum KanbanColumn: String, CaseIterable, Codable {
        case backlog = "Backlog"
        case thisWeek = "This Week"
        case inProgress = "In Progress"
        case blocked = "Blocked"
        case done = "Done"
    }
}

struct CRMContact: Identifiable, Codable {
    let id = UUID()
    let name: String
    let company: String
    let assignedOwner: String
    let notes: String
    var stage: CRMStage
    
    enum CRMStage: String, CaseIterable, Codable {
        case new = "New"
        case qualified = "Qualified"
        case meeting = "Meeting"
        case proposal = "Proposal"
        case won = "Won"
        case lost = "Lost"
    }
}

// MARK: - KPI Tiles Section
struct KPITilesSection: View {
    @State private var kpiTiles: [KPITile] = [
        KPITile(title: "Meetings Booked", current: 4, target: 10, unit: "meetings", color: Color(hex: "004aad")),
        KPITile(title: "Events Hosted", current: 7, target: 12, unit: "events", color: .green),
        KPITile(title: "New Members", current: 23, target: 50, unit: "members", color: .orange),
        KPITile(title: "Revenue Goal", current: 1200, target: 3000, unit: "$", color: .purple)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Performance Indicators")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(kpiTiles) { kpi in
                    KPITileView(kpi: kpi)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - KPI Tile View
struct KPITileView: View {
    let kpi: KPITile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(kpi.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(kpi.color.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: kpi.progress)
                    .stroke(kpi.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: kpi.progress)
                
                Text("\(Int(kpi.progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(kpi.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(kpi.progressText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(kpi.unit)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(kpi.color.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Kanban Board Section
struct KanbanBoardSection: View {
    @State private var tasks: [KanbanTask] = [
        KanbanTask(title: "Design new logo", assignedUser: "Alice", dueDate: Date().addingTimeInterval(86400 * 3), tag: "Design", column: .thisWeek),
        KanbanTask(title: "Update website", assignedUser: "Bob", dueDate: Date().addingTimeInterval(86400 * 7), tag: "Development", column: .inProgress),
        KanbanTask(title: "Plan networking event", assignedUser: "Carol", dueDate: Date().addingTimeInterval(86400 * 14), tag: "Event", column: .backlog),
        KanbanTask(title: "Client presentation", assignedUser: "Dave", dueDate: Date().addingTimeInterval(86400 * 2), tag: "Business", column: .blocked),
        KanbanTask(title: "Setup analytics", assignedUser: "Eve", dueDate: Date().addingTimeInterval(-86400 * 2), tag: "Development", column: .done)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Project Board")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(KanbanTask.KanbanColumn.allCases, id: \.self) { column in
                        KanbanColumnView(
                            column: column,
                            tasks: tasks.filter { $0.column == column }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Kanban Column View
struct KanbanColumnView: View {
    let column: KanbanTask.KanbanColumn
    let tasks: [KanbanTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                Text(column.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "004aad"))
                    .cornerRadius(8)
            }
            
            // Tasks
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    KanbanTaskCard(task: task)
                }
                
                if tasks.isEmpty {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(height: 60)
                        .overlay(
                            Text("Drop tasks here")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        )
                }
            }
        }
        .padding(12)
        .frame(width: 250)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Kanban Task Card
struct KanbanTaskCard: View {
    let task: KanbanTask
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack {
                // User Avatar
                Circle()
                    .fill(Color(hex: "004aad"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(String(task.assignedUser.prefix(1)))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Spacer()
                
                // Due Date
                Text(dateFormatter.string(from: task.dueDate))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Tag
            if let tag = task.tag {
                Text(tag)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: "004aad").opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - CRM Pipeline Section
struct CRMPipelineSection: View {
    @State private var contacts: [CRMContact] = [
        CRMContact(name: "John Smith", company: "Tech Corp", assignedOwner: "Alice", notes: "Interested in premium plan", stage: .new),
        CRMContact(name: "Sarah Johnson", company: "Design Studio", assignedOwner: "Bob", notes: "Needs custom solution", stage: .qualified),
        CRMContact(name: "Mike Brown", company: "Startup Inc", assignedOwner: "Carol", notes: "Meeting scheduled for next week", stage: .meeting),
        CRMContact(name: "Lisa Davis", company: "Enterprise Ltd", assignedOwner: "Dave", notes: "Reviewing proposal", stage: .proposal),
        CRMContact(name: "Tom Wilson", company: "Local Business", assignedOwner: "Eve", notes: "Signed contract!", stage: .won)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sales Pipeline")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("$\(calculatePipelineValue())")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(CRMContact.CRMStage.allCases.filter { $0 != .lost }, id: \.self) { stage in
                        CRMStageColumn(
                            stage: stage,
                            contacts: contacts.filter { $0.stage == stage }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func calculatePipelineValue() -> Int {
        // Mock calculation - in real app, would use actual deal values
        return contacts.filter { $0.stage != .lost }.count * 500
    }
}

// MARK: - CRM Stage Column
struct CRMStageColumn: View {
    let stage: CRMContact.CRMStage
    let contacts: [CRMContact]
    
    var stageColor: Color {
        switch stage {
        case .new: return .blue
        case .qualified: return .orange
        case .meeting: return .purple
        case .proposal: return .green
        case .won: return Color(hex: "004aad")
        case .lost: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stage Header
            HStack {
                Text(stage.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(contacts.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(stageColor)
                    .cornerRadius(8)
            }
            
            // Contacts
            VStack(spacing: 8) {
                ForEach(contacts) { contact in
                    CRMContactCard(contact: contact, stageColor: stageColor)
                }
                
                if contacts.isEmpty {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(height: 60)
                        .overlay(
                            Text("No contacts")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        )
                }
            }
        }
        .padding(12)
        .frame(width: 220)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - CRM Contact Card
struct CRMContactCard: View {
    let contact: CRMContact
    let stageColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(contact.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(contact.company)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack {
                // Owner Avatar
                Circle()
                    .fill(stageColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text(String(contact.assignedOwner.prefix(1)))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text(contact.assignedOwner)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if !contact.notes.isEmpty {
                Text(contact.notes)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(stageColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Kanban Popup View
struct KanbanPopupView: View {
    @Binding var isPresented: Bool
    @State private var tasks: [KanbanTask] = [
        KanbanTask(title: "Design new logo", assignedUser: "Alice", dueDate: Date().addingTimeInterval(86400 * 3), tag: "Design", column: .thisWeek),
        KanbanTask(title: "Update website", assignedUser: "Bob", dueDate: Date().addingTimeInterval(86400 * 7), tag: "Development", column: .inProgress),
        KanbanTask(title: "Plan networking event", assignedUser: "Carol", dueDate: Date().addingTimeInterval(86400 * 14), tag: "Event", column: .backlog),
        KanbanTask(title: "Client presentation", assignedUser: "Dave", dueDate: Date().addingTimeInterval(86400 * 2), tag: "Business", column: .blocked),
        KanbanTask(title: "Setup analytics", assignedUser: "Eve", dueDate: Date().addingTimeInterval(-86400 * 2), tag: "Development", column: .done),
        KanbanTask(title: "Marketing campaign", assignedUser: "Frank", dueDate: Date().addingTimeInterval(86400 * 5), tag: "Marketing", column: .thisWeek),
        KanbanTask(title: "User testing", assignedUser: "Grace", dueDate: Date().addingTimeInterval(86400 * 10), tag: "Research", column: .inProgress)
    ]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            
            // Popup content
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Project Board - Detailed View")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(KanbanTask.KanbanColumn.allCases, id: \.self) { column in
                            KanbanPopupColumn(
                                column: column,
                                tasks: tasks.filter { $0.column == column }
                            )
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Kanban Popup Column
struct KanbanPopupColumn: View {
    let column: KanbanTask.KanbanColumn
    let tasks: [KanbanTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(column.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(tasks.count) tasks")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "004aad"))
                    .cornerRadius(12)
            }
            
            if tasks.isEmpty {
                Text("No tasks in this column")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(tasks) { task in
                            KanbanPopupTaskCard(task: task)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Kanban Popup Task Card
struct KanbanPopupTaskCard: View {
    let task: KanbanTask
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "004aad"))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(task.assignedUser.prefix(1)))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    Text(task.assignedUser)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Due")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    
                    Text(dateFormatter.string(from: task.dueDate))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            
            if let tag = task.tag {
                HStack {
                    Text(tag)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "004aad").opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .frame(width: 200) // Reduced width for more compact cards
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CRM Popup View
struct CRMPopupView: View {
    @Binding var isPresented: Bool
    @State private var contacts: [CRMContact] = [
        CRMContact(name: "John Smith", company: "Tech Corp", assignedOwner: "Alice", notes: "Interested in premium plan", stage: .new),
        CRMContact(name: "Sarah Johnson", company: "Design Studio", assignedOwner: "Bob", notes: "Needs custom solution", stage: .qualified),
        CRMContact(name: "Mike Brown", company: "Startup Inc", assignedOwner: "Carol", notes: "Meeting scheduled for next week", stage: .meeting),
        CRMContact(name: "Lisa Davis", company: "Enterprise Ltd", assignedOwner: "Dave", notes: "Reviewing proposal", stage: .proposal),
        CRMContact(name: "Tom Wilson", company: "Local Business", assignedOwner: "Eve", notes: "Signed contract!", stage: .won),
        CRMContact(name: "Rachel Green", company: "Fashion Inc", assignedOwner: "Alice", notes: "Exploring options", stage: .new),
        CRMContact(name: "Mark Johnson", company: "Food Chain", assignedOwner: "Bob", notes: "Budget approved", stage: .qualified)
    ]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            
            // Popup content
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sales Pipeline - Detailed View")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Total Pipeline Value: $\(calculatePipelineValue())")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "004aad"))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(CRMContact.CRMStage.allCases.filter { $0 != .lost }, id: \.self) { stage in
                            CRMPopupStage(
                                stage: stage,
                                contacts: contacts.filter { $0.stage == stage }
                            )
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private func calculatePipelineValue() -> Int {
        return contacts.filter { $0.stage != .lost }.count * 500
    }
}

// MARK: - CRM Popup Stage
struct CRMPopupStage: View {
    let stage: CRMContact.CRMStage
    let contacts: [CRMContact]
    
    var stageColor: Color {
        switch stage {
        case .new: return .blue
        case .qualified: return .orange
        case .meeting: return .purple
        case .proposal: return .green
        case .won: return Color(hex: "004aad")
        case .lost: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(stage.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(contacts.count) contacts")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(stageColor)
                    .cornerRadius(12)
            }
            
            if contacts.isEmpty {
                Text("No contacts in this stage")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(contacts) { contact in
                            CRMPopupContactCard(contact: contact, stageColor: stageColor)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - CRM Popup Contact Card
struct CRMPopupContactCard: View {
    let contact: CRMContact
    let stageColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(contact.company)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(stageColor)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(contact.assignedOwner.prefix(1)))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    Text(contact.assignedOwner)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
            
            if !contact.notes.isEmpty {
                Text(contact.notes)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .frame(width: 180) // Reduced width for more compact cards
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(stageColor.opacity(0.3), lineWidth: 1)
        )
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
            isPrivate: false     
            
        ))
    }
}
