import SwiftUI
import Foundation

// MARK: - Event Models
struct CalendarEvent: Identifiable, Codable {
    let id: Int
    let name: String
    let event_type: String
    let date: String
    let points: Int
    let revenue: Int
    let circle_id: Int?
}

struct CheckInResponse: Codable {
    let message: String
    let user_id: Int
    let event_id: Int
}

// MARK: - Calendar View
struct CalendarView: View {
    let circle: CircleData
    @State private var selectedDate = Date()
    @State private var events: [CalendarEvent] = []
    @State private var isLoading = false
    @State private var showCreateEvent = false
    @State private var checkedInEvents: Set<Int> = []
    @AppStorage("user_id") private var userId: Int = 0
    
    // API Configuration
    private let baseURL = "http://localhost:8000/api/"
    
    // Create event form states
    @State private var newEventName: String = ""
    @State private var newEventType: String = "Workshop"
    @State private var newEventPoints: String = "10"
    @State private var newEventRevenue: String = "0"
    @State private var selectedEventDate = Date()
    
    let eventTypes = ["Workshop", "Speaker", "Social", "Meeting", "Conference"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(circle.name) Calendar")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Manage events and check-ins")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showCreateEvent = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "004aad"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar picker
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .onChange(of: selectedDate) { _ in
                            fetchEvents()
                        }
                    
                    // Events list for selected date
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Events for \(selectedDate, formatter: dateFormatter)")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        } else if events.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No events for this date")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text("Tap the + button to create an event")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(events) { event in
                                    EventCard(
                                        event: event,
                                        isCheckedIn: checkedInEvents.contains(event.id),
                                        onCheckIn: {
                                            checkInToEvent(event.id)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showCreateEvent) {
            CreateEventSheet(
                circle: circle,
                eventName: $newEventName,
                eventType: $newEventType,
                eventPoints: $newEventPoints,
                eventRevenue: $newEventRevenue,
                selectedDate: $selectedEventDate,
                eventTypes: eventTypes,
                onSave: { createEvent() },
                onCancel: { showCreateEvent = false }
            )
        }
        .onAppear {
            fetchEvents()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // MARK: - API Functions
    func fetchEvents() {
        isLoading = true
        
        guard let url = URL(string: "\(baseURL)circles/\(circle.id)/events/") else {
            print("❌ Invalid URL for fetchEvents")
            isLoading = false
            loadSampleEvents()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.loadSampleEvents()
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self.loadSampleEvents()
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Events API Response: \(responseString)")
                }
                
                do {
                    let decodedEvents = try JSONDecoder().decode([CalendarEvent].self, from: data)
                    // Filter events by selected date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let selectedDateString = formatter.string(from: self.selectedDate)
                    
                    self.events = decodedEvents.filter { event in
                        event.date.hasPrefix(selectedDateString)
                    }
                } catch {
                    print("❌ Failed to decode events: \(error)")
                    self.loadSampleEvents()
                }
            }
        }.resume()
    }
    
    func createEvent() {
        guard let url = URL(string: "\(baseURL)circles/\(circle.id)/events/") else {
            print("❌ Invalid URL for createEvent")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedEventDate)
        
        let parameters: [String: Any] = [
            "name": newEventName,
            "event_type": newEventType,
            "points": Int(newEventPoints) ?? 10,
            "revenue": Int(newEventRevenue) ?? 0,
            "date": dateString,
            "circle_id": circle.id
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("❌ Failed to serialize event data")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error creating event: \(error.localizedDescription)")
                    return
                }
                
                // Reset form
                newEventName = ""
                newEventType = "Workshop"
                newEventPoints = "10"
                newEventRevenue = "0"
                selectedEventDate = Date()
                showCreateEvent = false
                
                // Refresh events
                fetchEvents()
            }
        }.resume()
    }
    
    func checkInToEvent(_ eventId: Int) {
        guard let url = URL(string: "\(baseURL)events/\(eventId)/checkin/") else {
            print("❌ Invalid URL for checkIn")
            return
        }
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "event_id": eventId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("❌ Failed to serialize check-in data")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error checking in: \(error.localizedDescription)")
                    return
                }
                
                // Add to checked in events
                checkedInEvents.insert(eventId)
            }
        }.resume()
    }
    
    // Sample data for testing
    func loadSampleEvents() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: selectedDate)
        
        let sampleEvents = [
            CalendarEvent(id: 1, name: "Startup Kickoff Workshop", event_type: "Workshop", date: todayString, points: 15, revenue: 200, circle_id: circle.id),
            CalendarEvent(id: 2, name: "Tech Talk: AI in Business", event_type: "Speaker", date: todayString, points: 20, revenue: 100, circle_id: circle.id),
            CalendarEvent(id: 3, name: "Networking Social Hour", event_type: "Social", date: todayString, points: 10, revenue: 0, circle_id: circle.id)
        ]
        
        // Only show sample events if the selected date is today or in the future
        if selectedDate >= Date() {
            self.events = sampleEvents
        } else {
            self.events = []
        }
    }
}

// MARK: - Event Card Component
struct EventCard: View {
    let event: CalendarEvent
    let isCheckedIn: Bool
    let onCheckIn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        // Event type badge
                        Text(event.event_type)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(eventTypeColor.opacity(0.2))
                            .foregroundColor(eventTypeColor)
                            .cornerRadius(8)
                        
                        // Points badge
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("\(event.points) pts")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Check-in button
                Button(action: onCheckIn) {
                    HStack(spacing: 6) {
                        Image(systemName: isCheckedIn ? "checkmark.circle.fill" : "plus.circle")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(isCheckedIn ? "Checked In" : "Check In")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(isCheckedIn ? .green : Color(hex: "004aad"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isCheckedIn ? .green : Color(hex: "004aad"), lineWidth: 1)
                    )
                }
                .disabled(isCheckedIn)
            }
            
            if event.revenue > 0 {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Revenue: $\(event.revenue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var eventTypeColor: Color {
        switch event.event_type.lowercased() {
        case "workshop":
            return Color(hex: "004aad")
        case "speaker":
            return .purple
        case "social":
            return .orange
        case "meeting":
            return .blue
        case "conference":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Create Event Sheet
struct CreateEventSheet: View {
    let circle: CircleData
    @Binding var eventName: String
    @Binding var eventType: String
    @Binding var eventPoints: String
    @Binding var eventRevenue: String
    @Binding var selectedDate: Date
    
    let eventTypes: [String]
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Event for \(circle.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Add a new event to the circle calendar")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Event Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter event name", text: $eventName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Event Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Type")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(eventTypes, id: \.self) { type in
                                        Button(action: {
                                            eventType = type
                                        }) {
                                            Text(type)
                                                .font(.system(size: 14, weight: .medium))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(eventType == type ? Color(hex: "004aad") : Color(.systemGray6))
                                                )
                                                .foregroundColor(eventType == type ? .white : .primary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.horizontal, -20)
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Date")
                                .font(.headline)
                                .foregroundColor(.primary)
                            DatePicker("Event Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                        
                        // Points and Revenue
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Points Awarded")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                TextField("10", text: $eventPoints)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Revenue ($)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                TextField("0", text: $eventRevenue)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.secondary),
                trailing: Button("Create Event") {
                    onSave()
                }
                .disabled(eventName.isEmpty)
                .fontWeight(.semibold)
                .foregroundColor(eventName.isEmpty ? .secondary : Color(hex: "004aad"))
            )
        }
    }
}
