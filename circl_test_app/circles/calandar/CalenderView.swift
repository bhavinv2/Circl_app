import SwiftUI
import Foundation

// MARK: - Event Models
struct CalendarEvent: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String?
    let event_type: String
    let date: String?
    let start_time: String?
    let end_time: String?
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
    var defaultShowAllEvents: Bool = false
    @State private var selectedDate = Date()
    @State private var events: [CalendarEvent] = []
    @State private var isLoading = false
    @State private var showCreateEvent = false
    @State private var checkedInEvents: Set<Int> = []
    @AppStorage("user_id") private var userId: Int = 0
    @State private var showAllEvents: Bool = false
    @State private var allEvents: [CalendarEvent] = []
    @State private var newDescription: String = ""
    @State private var newStartTime: Date = Date()
    @State private var newEndTime: Date = Date()


    
    // API Configuration
 
    
    // Create event form states
    @State private var newEventName: String = ""
    @State private var newEventType: String = "Workshop"
    @State private var newEventPoints: String = "10"
    @State private var newEventRevenue: String = "0"
    @State private var selectedEventDate = Date()
    @State private var isExpanded: Bool = false
    

    let eventTypes = ["Workshop", "Meeting", "Fundraiser", "Social", "Other", "Speaker"]

    var isModerator: Bool {
        return circle.isModerator
    }

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
                    
                    if isModerator {
                        Button(action: {
                            showCreateEvent = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "004aad"))
                        }
                    }

                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            ScrollViewReader { scrollProxy in
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
                                showAllEvents = false
                                fetchEvents()
                            }
                        
                        
                        // Events list for selected date
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(showAllEvents ? "All Events" : "Events for \(selectedDate, formatter: dateFormatter)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    showAllEvents.toggle()
                                    if showAllEvents {
                                        events = allEvents
                                    } else {
                                        // Filter events for selected date again
                                        let calendar = Calendar.current
                                        let isoParser = ISO8601DateFormatter()

                                        events = allEvents.filter { event in
                                            guard let eventDateString = event.date,
                                                  let eventDate = isoParser.date(from: eventDateString) else {
                                                return false
                                            }
                                            return calendar.isDate(eventDate, inSameDayAs: selectedDate)
                                        }

                                    }
                                }) {
                                    Text(showAllEvents ? "Back to Date" : "Show All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "004aad"))
                                }
                            }
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
                                            },
                                            isModerator: isModerator,                      // ✅ add this
                                            onDelete: {
                                                deleteEvent(event.id)                      // ✅ add this
                                            }
                                        )
                                    }

                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .id("eventList")
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
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
                description: $newDescription,              // ✅ new
                selectedStartTime: $newStartTime,          // ✅ new
                selectedEndTime: $newEndTime,              // ✅ new
                eventTypes: eventTypes,
                onSave: { createEvent() },
                onCancel: { showCreateEvent = false }
            )
        }
        .onAppear {
            if defaultShowAllEvents {
                showAllEvents = true
            }
            fetchCheckedInEvents()  // ✅ load check-ins first
            fetchEvents()
        }


    }
    func fetchCheckedInEvents() {
        guard let url = URL(string: "\(baseURL)circles/get_user_checkins/?user_id=\(userId)") else {
            print("❌ Invalid URL for check-ins")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error fetching check-ins: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("❌ No check-in data received")
                    return
                }

                do {
                    struct CheckInResult: Codable {
                        let checked_in_event_ids: [Int]
                    }

                    let result = try JSONDecoder().decode(CheckInResult.self, from: data)
                    self.checkedInEvents = Set(result.checked_in_event_ids)
                } catch {
                    print("❌ Failed to decode check-ins: \(error)")
                }
            }
        }.resume()
    }

    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // MARK: - API Functions
    func fetchEvents() {
        isLoading = true

        guard let url = URL(string: "\(baseURL)circles/get_events/?circle_id=\(circle.id)") else {
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

                    // Filter events to match selectedDate (ignoring time)
                    // Filter events to match selectedDate (ignoring time)
                    let calendar = Calendar.current

                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"

                    let filtered = decodedEvents.filter { event in
                        guard let eventDateString = event.date,
                              let eventDate = df.date(from: eventDateString) else {
                            return false
                        }
                        return calendar.isDate(eventDate, inSameDayAs: selectedDate)
                    }

                    self.allEvents = decodedEvents
                    self.events = filtered



                    self.allEvents = decodedEvents
                    self.events = filtered


                } catch {
                    print("❌ Failed to decode events: \(error)")
                    self.loadSampleEvents()
                }
            }
        }.resume()
    }

    func createEvent() {
        guard let url = URL(string: "\(baseURL)circles/create_event/") else {
            print("❌ Invalid URL for createEvent")
            return
        }

        // Correct date format for Django DateField
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: selectedEventDate)



        // Correct time format
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        // Correct parameters
        let parameters: [String: Any] = [
            "title": newEventName,
            "description": newDescription,
            "event_type": newEventType.lowercased(),
            "points": Int(newEventPoints) ?? 10,
            "revenue": Int(newEventRevenue) ?? 0,
            "date": dateString,                                        // ✅ FIXED
            "start_time": timeFormatter.string(from: newStartTime),
            "end_time": timeFormatter.string(from: newEndTime),
            "circle_id": circle.id                                     // ✅ FIXED
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
                if let http = response as? HTTPURLResponse {
                    print("📡 createEvent() status:", http.statusCode)
                }
                if let data = data,
                   let body = String(data: data, encoding: .utf8) {
                    print("🧾 createEvent() body:", body)
                }

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

                // Refresh
                fetchEvents()
            }
        }.resume()
    }

    
    func deleteEvent(_ eventId: Int) {
        guard let url = URL(string: "\(baseURL)circles/delete_event/\(eventId)/?user_id=\(userId)") else {
            print("❌ Invalid URL for deleteEvent")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"   // ✅ must match backend

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error deleting event: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Delete response status:", httpResponse.statusCode)
                }

                // ✅ Refresh events after delete
                fetchEvents()
            }
        }.resume()
    }

    
    func checkInToEvent(_ eventId: Int) {
        guard let url = URL(string: "\(baseURL)circles/checkin_event/") else {
            print("❌ Invalid URL for checkIn")
            return
        }
        
        let parameters: [String: Any] = [
            "user": userId,
            "event": eventId
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
            CalendarEvent(
                id: 1,
                title: "Startup Kickoff Workshop",
                description: "Kick off the semester with an inspiring workshop!",
                event_type: "Workshop",
                date: todayString,
                start_time: "10:00:00",
                end_time: "11:30:00",
                points: 15,
                revenue: 200,
                circle_id: circle.id
            ),
            CalendarEvent(
                id: 2,
                title: "Tech Talk: AI in Business",
                description: "Explore how AI is transforming modern businesses.",
                event_type: "Speaker",
                date: todayString,
                start_time: "13:00:00",
                end_time: "14:00:00",
                points: 20,
                revenue: 100,
                circle_id: circle.id
            ),
            CalendarEvent(
                id: 3,
                title: "Networking Social Hour",
                description: "Meet other members and network casually.",
                event_type: "Social",
                date: todayString,
                start_time: "17:00:00",
                end_time: "18:00:00",
                points: 10,
                revenue: 0,
                circle_id: circle.id
            )
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
    let isModerator: Bool          // ✅ new
    let onDelete: () -> Void

    @State private var isExpanded = false  // ✅ Properly scoped per card
    @State private var showDeleteConfirm = false   // ✅ new state
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(event.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "chevron.up.circle" : "info.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }

                    HStack(spacing: 8) {
                        Text(event.event_type)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(eventTypeColor.opacity(0.2))
                            .foregroundColor(eventTypeColor)
                            .cornerRadius(8)

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("\(event.points) pts")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.orange)
                    }

                    // ✅ Expanded Info
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 6) {
                            if let description = event.description, !description.isEmpty {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let start = event.start_time, let end = event.end_time {
                                Text("🕒 \(start) - \(end)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            // ✅ Delete button (only for moderators)
                            // ✅ Delete button (only for moderators)
                            if isModerator {
                                Button(role: .destructive) {
                                    showDeleteConfirm = true   // 👈 trigger alert
                                } label: {
                                    Label("Delete Event", systemImage: "trash")
                                        .font(.caption)
                                }
                                .padding(.top, 4)
                                .alert("Are you sure you want to delete this event?",
                                       isPresented: $showDeleteConfirm) {
                                    Button("Cancel", role: .cancel) {}
                                    Button("Delete", role: .destructive) {
                                        onDelete()   // 👈 actually delete
                                    }
                                }
                            }

                        }
                        .transition(.opacity.combined(with: .slide))
                    }

                }

                Spacer()

                // ✅ Check-in button
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
    @Binding var description: String
    @Binding var selectedStartTime: Date
    @Binding var selectedEndTime: Date

    
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
                        // Date
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            DatePicker("Event Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .font(.headline) // 👈 this makes "Event Date" bold
                                .foregroundColor(.primary)
                        }
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextEditor(text: $description)
                                .frame(height: 80)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }

                        // Start Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Time")
                                .font(.headline)
                                .foregroundColor(.primary)
                            DatePicker("", selection: $selectedStartTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
                        }

                        // End Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End Time")
                                .font(.headline)
                                .foregroundColor(.primary)
                            DatePicker("", selection: $selectedEndTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
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
                            
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Revenue ($)")
//                                    .font(.headline)
//                                    .foregroundColor(.primary)
//                                TextField("0", text: $eventRevenue)
//                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                                    .keyboardType(.numberPad)
//                            }
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
