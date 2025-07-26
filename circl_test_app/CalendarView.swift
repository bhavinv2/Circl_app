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
}

struct CheckInResponse: Codable {
    let message: String
    let user_id: Int
    let event_id: Int
}

// MARK: - Calendar View
struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var events: [CalendarEvent] = []
    @State private var isLoading = false
    @State private var showCreateEvent = false
    @State private var checkedInEvents: Set<Int> = []
    @AppStorage("user_id") private var userId: Int = 0
    
    // Create event form states
    @State private var newEventName: String = ""
    @State private var newEventType: String = "Workshop"
    @State private var newEventPoints: String = "10"
    @State private var newEventRevenue: String = "0"
    @State private var selectedEventDate = Date()
    
    let eventTypes = ["Workshop", "Speaker", "Social", "Meeting", "Conference"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar picker
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .onChange(of: selectedDate) { _ in
                        fetchEvents()
                    }
                
                // Events list for selected date
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Events for \(selectedDate, formatter: dateFormatter)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showCreateEvent = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "004aad"))
                        }
                    }
                    .padding(.horizontal)
                    
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
                        ScrollView {
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
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreateEvent) {
            CreateEventSheet(
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
        
        // For now, fetch all events and filter by date locally
        // In a real implementation, you'd want to modify the backend to support date filtering
        guard let url = URL(string: "http://localhost:8000/events/") else {
            print("❌ Invalid URL for fetchEvents")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    // Load sample events for demo
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
                    // Filter events by selected date (simple date comparison for demo)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let selectedDateString = formatter.string(from: self.selectedDate)
                    
                    self.events = decodedEvents.filter { event in
                        event.date.hasPrefix(selectedDateString)
                    }
                } catch {
                    print("❌ Failed to decode events: \(error)")
                    // For demo purposes, load sample data
                    self.loadSampleEvents()
                }
            }
        }.resume()
    }
    
    func createEvent() {
        guard let url = URL(string: "http://localhost:8000/events/") else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedEventDate)
        
        let parameters: [String: Any] = [
            "name": newEventName,
            "event_type": newEventType,
            "points": Int(newEventPoints) ?? 10,
            "revenue": Int(newEventRevenue) ?? 0,
            "date": dateString
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
        guard let url = URL(string: "http://localhost:8000/checkin/") else { return }
        
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
        let sampleEvents = [
            CalendarEvent(id: 1, name: "Startup Kickoff", event_type: "Workshop", date: "", points: 10, revenue: 200),
            CalendarEvent(id: 2, name: "Tech Talk: AI in Business", event_type: "Speaker", date: "", points: 15, revenue: 100),
            CalendarEvent(id: 3, name: "Networking Social", event_type: "Social", date: "", points: 5, revenue: 0)
        ]
        self.events = sampleEvents
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
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    // Event Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Name")
                            .font(.headline)
                        TextField("Enter event name", text: $eventName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Event Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Type")
                            .font(.headline)
                        Picker("Event Type", selection: $eventType) {
                            ForEach(eventTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.headline)
                        DatePicker("Event Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    // Points and Revenue
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Points")
                                .font(.headline)
                            TextField("10", text: $eventPoints)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Revenue ($)")
                                .font(.headline)
                            TextField("0", text: $eventRevenue)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { onCancel() },
                trailing: Button("Save") { onSave() }
                    .disabled(eventName.isEmpty)
                    .fontWeight(.semibold)
            )
        }
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
