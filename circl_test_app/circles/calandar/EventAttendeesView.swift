import SwiftUI
import Foundation

// MARK: - Event Attendee Models
struct EventAttendee: Identifiable, Codable {
    let user_id: Int
    let username: String
    let first_name: String
    let last_name: String
    let email: String
    let checked_in_at: String
    let points_earned: Int
    
    var id: Int { user_id }
    
    var fullName: String {
        return "\(first_name) \(last_name)".trimmingCharacters(in: .whitespaces)
    }
    
    var displayName: String {
        return fullName.isEmpty ? username : fullName
    }
}

struct EventAttendeesResponse: Codable {
    let event_id: Int
    let event_title: String
    let attendee_count: Int
    let attendees: [EventAttendee]
}

// MARK: - Event Attendees View
struct EventAttendeesView: View {
    let event: CalendarEvent
    @State private var attendeesData: EventAttendeesResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Event Attendees")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                if let attendeesData = attendeesData {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(Color(hex: "004aad"))
                        
                        Text("\(attendeesData.attendee_count) attendees")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                            
                            Text("\(event.points) pts each")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Content
            if isLoading {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading attendees...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Error Loading Attendees")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Try Again") {
                        fetchEventAttendees()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "004aad"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let attendeesData = attendeesData {
                if attendeesData.attendees.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "person.3.sequence")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Check-ins Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("No one has checked into this event yet.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(attendeesData.attendees) { attendee in
                                AttendeeCard(attendee: attendee)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Space for bottom navigation
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            fetchEventAttendees()
        }
    }
    
    // MARK: - API Functions
    func fetchEventAttendees() {
        guard let url = URL(string: "\(baseURL)circles/events/\(event.id)/attendees/") else {
            print("❌ Invalid URL for event attendees")
            errorMessage = "Invalid request URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    errorMessage = "No data received from server"
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Event Attendees API Response: \(responseString)")
                }
                
                do {
                    let response = try JSONDecoder().decode(EventAttendeesResponse.self, from: data)
                    self.attendeesData = response
                } catch {
                    print("❌ Failed to decode attendees: \(error)")
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - Attendee Card Component
struct AttendeeCard: View {
    let attendee: EventAttendee
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(Color(hex: "004aad").opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(attendee.displayName.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "004aad"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attendee.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(attendee.email)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Checked in: \(formatCheckinTime(attendee.checked_in_at))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("\(attendee.points_earned)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Text("points")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
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

// MARK: - Preview
struct EventAttendeesView_Previews: PreviewProvider {
    static var previews: some View {
        EventAttendeesView(event: CalendarEvent(
            id: 1,
            title: "Sample Workshop",
            description: "A sample workshop event",
            event_type: "Workshop",
            date: "2025-01-15T10:00:00Z",
            start_time: "10:00:00",
            end_time: "11:00:00",
            points: 15,
            revenue: 100,
            circle_id: 1
        ))
    }
}
