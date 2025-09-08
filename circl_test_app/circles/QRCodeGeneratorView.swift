
import SwiftUI
import Foundation
import CoreImage.CIFilterBuiltins
// Use baseURL from APIConfig.swift
// Use Color(hex:) from ColorExtensions.swift

// MARK: - QR Code Models
struct EventQRData: Codable {
    let event_id: Int
    let event_title: String
    let qr_code: String
    let qr_code_url: String
    let requires_location: Bool
    let location_info: LocationInfo?
}

struct LocationInfo: Codable {
    let latitude: Double?
    let longitude: Double?
    let radius: Int
}

// MARK: - QR Code Generator View
struct QRCodeGeneratorView: View {
    let event: CalendarEvent
    @AppStorage("user_id") private var userId: Int = 0
    @State private var qrData: EventQRData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showLocationSettings = false
    @State private var requiresLocation = false
    @State private var eventLatitude: String = ""
    @State private var eventLongitude: String = ""
    @State private var locationRadius: String = "100"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("QR Code Check-in")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Generate a QR code for \(event.title)")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Generating QR Code...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Error")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            fetchQRCode()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "004aad"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(40)
                } else if let qrData = qrData {
                    VStack(spacing: 24) {
                        // QR Code Card
                        VStack(spacing: 20) {
                            Text("Scan to Check In")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            // QR Code Image
                            if let qrImage = generateQRCode(from: qrData.qr_code_url) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            VStack(spacing: 8) {
                                Text("QR Code: \(qrData.qr_code)")
                                    .font(.system(size: 14).monospaced())
                                    .foregroundColor(.secondary)
                                
                                if qrData.requires_location {
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.orange)
                                        Text("Location Required")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        // Event Details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Event Details")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                DetailRow(
                                    icon: "calendar",
                                    title: "Event",
                                    value: qrData.event_title
                                )
                                
                                DetailRow(
                                    icon: "star.fill",
                                    title: "Points",
                                    value: "\(event.points) points"
                                )
                                
                                if let locationInfo = qrData.location_info,
                                   qrData.requires_location {
                                    DetailRow(
                                        icon: "location.circle",
                                        title: "Location",
                                        value: "Required within \(locationInfo.radius)m"
                                    )
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        // Location Settings
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Location Settings")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(showLocationSettings ? "Done" : "Edit") {
                                    showLocationSettings.toggle()
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            }
                            
                            if showLocationSettings {
                                VStack(spacing: 16) {
                                    Toggle("Require Location Verification", isOn: $requiresLocation)
                                        .font(.system(size: 16))
                                    
                                    if requiresLocation {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Event Location")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Latitude")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    TextField("37.7749", text: $eventLatitude)
                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                        .keyboardType(.decimalPad)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Longitude")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    TextField("-122.4194", text: $eventLongitude)
                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                        .keyboardType(.decimalPad)
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Radius (meters)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                TextField("100", text: $locationRadius)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .keyboardType(.numberPad)
                                            }
                                            
                                            Button("Update Location Settings") {
                                                updateLocationSettings()
                                            }
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(hex: "004aad"))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            } else {
                                Text(qrData.requires_location ? "Location verification is enabled" : "Location verification is disabled")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to Use")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InstructionRow(
                                    number: "1",
                                    text: "Display this QR code at your event location"
                                )
                                
                                InstructionRow(
                                    number: "2", 
                                    text: "Attendees scan the code using the Circl app"
                                )
                                
                                InstructionRow(
                                    number: "3",
                                    text: "They automatically earn \(event.points) points when they check in"
                                )
                                
                                if qrData.requires_location {
                                    InstructionRow(
                                        number: "4",
                                        text: "Location verification ensures they're at the event"
                                    )
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            fetchQRCode()
            loadLocationSettings()
        }
    }
    
    // MARK: - API Functions
    private func fetchQRCode() {
        guard let url = URL(string: "\(baseURL)circles/events/\(event.id)/qr_code/?user_id=\(userId)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let qrData = try JSONDecoder().decode(EventQRData.self, from: data)
                    self.qrData = qrData
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func loadLocationSettings() {
        guard let qrData = qrData else { return }
        
        requiresLocation = qrData.requires_location
        if let locationInfo = qrData.location_info {
            eventLatitude = locationInfo.latitude.map { String($0) } ?? ""
            eventLongitude = locationInfo.longitude.map { String($0) } ?? ""
            locationRadius = String(locationInfo.radius)
        }
    }
    
    private func updateLocationSettings() {
        guard let url = URL(string: "\(baseURL)circles/events/\(event.id)/location/") else {
            return
        }
        
        var requestData: [String: Any] = [
            "user_id": userId,
            "requires_location": requiresLocation,
            "radius": Int(locationRadius) ?? 100
        ]
        
        if let lat = Double(eventLatitude) {
            requestData["latitude"] = lat
        }
        if let lng = Double(eventLongitude) {
            requestData["longitude"] = lng
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        } catch {
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    // Refresh QR data
                    fetchQRCode()
                    showLocationSettings = false
                }
            }
        }.resume()
    }
    
    // MARK: - QR Code Generation
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "004aad"))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "004aad"))
                    .frame(width: 24, height: 24)
                
                Text(number)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}



// MARK: - Preview
struct QRCodeGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeGeneratorView(event: CalendarEvent(
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
