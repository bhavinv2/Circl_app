
import SwiftUI
import CoreImage.CIFilterBuiltins
import Foundation // For baseURL global constant

// MARK: - QR Management Models
struct CircleQRCodesResponse: Codable {
    let circle_id: Int
    let circle_name: String
    let total_events: Int
    let qr_codes: [EventQRCode]
}

struct EventQRCode: Codable, Identifiable {
    let event_id: Int
    let event_title: String
    let event_date: String?
    let qr_code: String
    let qr_code_url: String
    let requires_location: Bool
    let attendee_count: Int
    let points: Int
    let created_at: String
    let location_info: LocationInfo?
    
    var id: Int { event_id }
}

// MARK: - QR Management View
struct QRManagementView: View {
    let circle: CircleData
    @AppStorage("user_id") private var userId: Int = 0
    @State private var qrCodes: [EventQRCode] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedQRCode: EventQRCode?
    @State private var showingQRDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("QR Code Management")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Manage QR codes for \(circle.name)")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Refresh") {
                            fetchQRCodes()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                    }
                    
                    // Summary Stats
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Total Events",
                            value: "\(qrCodes.count)",
                            icon: "calendar.badge.plus"
                        )
                        
                        StatCard(
                            title: "Total Check-ins",
                            value: "\(qrCodes.reduce(0) { $0 + $1.attendee_count })",
                            icon: "person.2.badge.gearshape"
                        )
                        
                        StatCard(
                            title: "Total Points",
                            value: "\(qrCodes.reduce(0) { $0 + ($1.attendee_count * $1.points) })",
                            icon: "star.fill"
                        )
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading QR codes...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            fetchQRCodes()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "004aad"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                } else if qrCodes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No QR Codes Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Create events with QR check-in enabled to see them here.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                } else {
                    // QR Codes List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(qrCodes) { qrCode in
                                QRCodeCard(qrCode: qrCode) {
                                    selectedQRCode = qrCode
                                    showingQRDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingQRDetail) {
            if let qrCode = selectedQRCode {
                QRCodeDetailView(qrCode: qrCode)
            }
        }
        .onAppear {
            fetchQRCodes()
        }
    }
    
    private func fetchQRCodes() {
    guard let url = URL(string: "\(baseURL)circles/circles/\(circle.id)/qr_codes/?user_id=\(userId)") else {
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
                    let response = try JSONDecoder().decode(CircleQRCodesResponse.self, from: data)
                    qrCodes = response.qr_codes
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "004aad"))
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct QRCodeCard: View {
    let qrCode: EventQRCode
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // QR Code Preview
                VStack(spacing: 8) {
                    if let qrImage = generateQRCode(from: qrCode.qr_code_url) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .cornerRadius(8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "qrcode")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                // Event Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(qrCode.event_title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    // Removed event_type, as EventQRCode does not have this property
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("\(qrCode.attendee_count)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("\(qrCode.points)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        if qrCode.requires_location {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                Text("GPS")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 8, y: 8)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
    
    private func formatEventType(_ type: String) -> String {
        return type.capitalized
    }
}

// MARK: - QR Detail View
struct QRCodeDetailView: View {
    let qrCode: EventQRCode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // QR Code Display
                    QRCodeDisplaySection(qrCode: qrCode)
                    // Event Information
                    EventInfoSection(qrCode: qrCode)
                }
            }
        }
    }
    // MARK: - Subviews for type-checking
    private struct QRCodeDisplaySection: View {
        let qrCode: EventQRCode
        var body: some View {
            VStack(spacing: 16) {
                Text("Event QR Code")
                    .font(.headline)
                    .foregroundColor(.primary)
                if let qrImage = generateQRCode(from: qrCode.qr_code_url) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                VStack(spacing: 8) {
                    Text("QR Code: \(qrCode.qr_code)")
                        .font(.system(size: 14).monospaced())
                        .foregroundColor(.secondary)
                    Button("Copy QR Code") {
                        UIPasteboard.general.string = qrCode.qr_code
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    private struct EventInfoSection: View {
        let qrCode: EventQRCode
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Event Information")
                    .font(.headline)
                    .foregroundColor(.primary)
                VStack(spacing: 12) {
                    DetailRow(
                        icon: "calendar",
                        title: "Event",
                        value: qrCode.event_title
                    )
                    // Removed event_type row, as EventQRCode does not have this property
                    if let eventDate = qrCode.event_date {
                        DetailRow(
                            icon: "clock",
                            title: "Date",
                            value: formatDate(eventDate)
                        )
                    }
                    DetailRow(
                        icon: "star.fill",
                        title: "Points",
                        value: "\(qrCode.points) points"
                    )
                    DetailRow(
                        icon: "person.2",
                        title: "Check-ins",
                        value: "\(qrCode.attendee_count) people"
                    )
                    if qrCode.requires_location, let locationInfo = qrCode.location_info {
                        DetailRow(
                            icon: "location.circle",
                            title: "Location Required",
                            value: "Within \(locationInfo.radius)m radius"
                        )
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            Spacer(minLength: 100)
        }
    }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("QR Code Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
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
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}


// MARK: - Preview
struct QRManagementView_Previews: PreviewProvider {
    static var previews: some View {
        QRManagementView(circle: CircleData(
            id: 1,
            name: "Sample Circle",
            industry: "Tech",
            memberCount: 10,
            imageName: "",
            pricing: "Free",
            description: "A sample circle",
            joinType: .joinNow,
            channels: [],
            creatorId: 1,
            isModerator: true,
            isPrivate: false
        ))
    }
}
