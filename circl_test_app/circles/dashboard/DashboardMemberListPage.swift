/*
 BACKEND IMPLEMENTATION INSTRUCTIONS FOR DashboardMemberListPage
 ================================================================
 
 This file implements an admin-only dashboard for managing circle member payments.
 The frontend is complete and ready for backend integration. Please implement the following:
 
 1. API ENDPOINT SETUP
 -------------------
 Create endpoint: GET /circles/dashboard_members/{circle_id}/
 - Requires admin/moderator authentication
 - Returns array of DashboardMember objects with payment information
 - Should be restricted to circle admins only
 
 2. DATABASE SCHEMA REQUIREMENTS
 ------------------------------
 Extend existing Member/User tables to include:
 - has_paid: Boolean (default: false)
 - payment_date: Date (nullable)
 - payment_amount: Decimal (nullable)
 - email: String (for contacting unpaid members)
 - phone_number: String (for contacting unpaid members)
 
 3. API RESPONSE FORMAT
 ---------------------
 Return JSON array matching DashboardMember struct:
 [
   {
     "id": 1,
     "full_name": "Sarah Johnson",
     "profile_image": "https://...",
     "user_id": 101,
     "is_moderator": false,
     "has_paid": true,
     "payment_date": "2025-01-15",
     "payment_amount": 75.00,
     "email": "sarah.johnson@example.com",
     "phone_number": "+1-555-123-4567"
   }
 ]
 
 4. ADMIN ACTION ENDPOINTS
 ------------------------
 Implement these endpoints for admin actions:
 - PUT /circles/{circle_id}/members/{user_id}/promote/ (promote to moderator)
 - PUT /circles/{circle_id}/members/{user_id}/mark_paid/ (mark as paid)
 - POST /circles/{circle_id}/members/{user_id}/payment_reminder/ (send reminder)
 
 5. AUTHENTICATION & PERMISSIONS
 ------------------------------
 - Verify user is admin/moderator of the circle
 - Include auth token validation: "Token {token}" header
 - Return 403 Forbidden for non-admin users
 
 6. PAYMENT INTEGRATION
 ---------------------
 Consider integrating with:
 - Stripe for payment processing
 - Email service for payment reminders
 - SMS service for text notifications
 
 7. SECURITY CONSIDERATIONS
 -------------------------
 - Admin-only access to payment information
 - Secure storage of contact information
 - Rate limiting for reminder sends
 - Input validation for all endpoints
 
 8. TESTING REQUIREMENTS
 ----------------------
 - Test with various payment states
 - Verify admin permission restrictions
 - Test contact information privacy
 - Validate payment amount calculations
 
 9. FRONTEND INTEGRATION STEPS
 -----------------------------
 Once backend is implemented, update the frontend:
 1. Replace the dummy data in fetchDashboardMembers()
 2. Add the base URL configuration (import APIConfig if available)
 3. Test the real API calls with proper error handling
 4. Validate response data matches DashboardMember struct
 5. Test admin action endpoints (promote, mark paid, send reminder)
 
 CURRENT STATE: Frontend complete, using dummy data in fetchDashboardMembers()
 TODO: Replace dummy data with actual API calls when backend is ready
*/

import SwiftUI
import Foundation

// Dashboard-specific member model with payment information
struct DashboardMember: Identifiable, Decodable, Hashable {
    let id: Int
    let full_name: String
    let profile_image: String?
    let user_id: Int
    let is_moderator: Bool
    let has_paid: Bool?          // Payment status visible to admins only
    let payment_date: String?    // Optional: when payment was made
    let payment_amount: Double?  // Optional: amount paid
    let email: String?           // Email for contacting unpaid members
    let phone_number: String?    // Phone number for contacting unpaid members
}

// Enum for tab selection
enum MemberTab: String, CaseIterable {
    case paid = "Paid Members"
    case free = "Free Members"
}

struct DashboardMemberListPage: View {
    let circleName: String
    let circleId: Int

    @State private var members: [DashboardMember] = []
    @State private var selectedMember: DashboardMember? = nil
    @AppStorage("user_id") private var currentUserId: Int = 0
    @State private var paidMembersCount: Int = 0
    @State private var totalRevenue: Double = 0
    @State private var selectedTab: MemberTab = .paid  // Tab selection state
    
    // Computed properties for filtered members
    var paidMembers: [DashboardMember] {
        members.filter { $0.has_paid == true }
    }
    
    var freeMembers: [DashboardMember] {
        members.filter { $0.has_paid != true }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header section with circle name - similar to "Circle Dues" header
            VStack(spacing: 16) {
                Text(circleName)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                // Stats card - similar to the dues page card design
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        VStack(spacing: 4) {
                            Text("\(paidMembersCount)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Paid Members")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(freeMembers.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Free Members")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("$\(Int(totalRevenue))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Total Revenue")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                
                // Tab Selector - cleaner design similar to dues page
                HStack(spacing: 0) {
                    ForEach(MemberTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    selectedTab == tab ? Color(hex: "004aad") : Color.clear
                                )
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 24)
            .background(Color(.systemGray6))
            
            // Content section
            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == .paid {
                        paidMembersView
                    } else {
                        freeMembersView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Dashboard Members")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6))
        .sheet(item: $selectedMember) { member in
            DynamicProfilePreview(
                profileData: convertToFullProfile(from: member),
                isInNetwork: true
            )
        }
        .onAppear {
            fetchDashboardMembers()
        }
    }
    
    // MARK: - Paid Members View
    var paidMembersView: some View {
        VStack(spacing: 12) {
            ForEach(paidMembers) { member in
                Button(action: {
                    selectedMember = member
                }) {
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            // Profile image
                            AsyncImage(url: URL(string: member.profile_image ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                            // Member info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.full_name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if let paymentDate = member.payment_date {
                                    Text("Paid on \(formatDate(paymentDate))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Payment status
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 20))
                                    
                                    Text("Paid")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                                
                                if let amount = member.payment_amount {
                                    Text("$\(Int(amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.medium)
                                }
                            }

                            // Admin menu
                            if member.user_id != currentUserId && !member.is_moderator {
                                Menu {
                                    Button("Make Moderator") {
                                        promoteToModerator(memberId: member.user_id)
                                    }
                                    
                                    Button("View Profile") {
                                        selectedMember = member
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .rotationEffect(.degrees(90))
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Free Members View
    var freeMembersView: some View {
        VStack(spacing: 12) {
            ForEach(freeMembers) { member in
                Button(action: {
                    selectedMember = member
                }) {
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            // Profile image
                            AsyncImage(url: URL(string: member.profile_image ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                            // Member info with contact details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.full_name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    if let email = member.email {
                                        HStack(spacing: 6) {
                                            Image(systemName: "envelope.fill")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            Text(email)
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    if let phone = member.phone_number {
                                        HStack(spacing: 6) {
                                            Image(systemName: "phone.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            Text(phone)
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }

                            Spacer()

                            // Pending status
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 20))
                                    
                                    Text("Pending")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                        .fontWeight(.semibold)
                                }
                            }

                            // Contact actions menu
                            if member.user_id != currentUserId && !member.is_moderator {
                                Menu {
                                    if let email = member.email {
                                        Button("Email Member") {
                                            openEmail(to: email)
                                        }
                                    }
                                    
                                    if let phone = member.phone_number {
                                        Button("Call Member") {
                                            callMember(phone: phone)
                                        }
                                        
                                        Button("Text Member") {
                                            textMember(phone: phone)
                                        }
                                    }
                                    
                                    Button("Mark as Paid") {
                                        markAsPaid(memberId: member.user_id)
                                    }
                                    
                                    Button("Send Payment Reminder") {
                                        sendPaymentReminder(memberId: member.user_id)
                                    }
                                    
                                    Button("Make Moderator") {
                                        promoteToModerator(memberId: member.user_id)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .rotationEffect(.degrees(90))
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // Convert DashboardMember to FullProfile for profile preview
    func convertToFullProfile(from member: DashboardMember) -> FullProfile {
        return FullProfile(
            user_id: member.user_id,
            profile_image: member.profile_image,
            first_name: member.full_name,
            last_name: "",
            email: "",
            main_usage: "",
            industry_interest: "",
            title: "",
            bio: nil,
            birthday: nil,
            education_level: nil,
            institution_attended: nil,
            certificates: nil,
            years_of_experience: nil,
            personality_type: nil,
            locations: nil,
            achievements: [],
            skillsets: nil,
            availability: "",
            clubs: nil,
            hobbies: nil,
            connections_count: 0,
            circs: 0,
            entrepreneurial_history: nil
        )
    }

    // Fetch members with payment information (admin-only endpoint)
    func fetchDashboardMembers() {
        // TODO: Replace with actual API call later
        // For now, using dummy data to demonstrate functionality
        
        let dummyMembers = [
            // Paid member example
            DashboardMember(
                id: 1,
                full_name: "Sarah Johnson",
                profile_image: "https://via.placeholder.com/150/00FF00/FFFFFF?text=SJ",
                user_id: 101,
                is_moderator: false,
                has_paid: true,
                payment_date: "2025-01-15",
                payment_amount: 75.00,
                email: "sarah.johnson@example.com",
                phone_number: "+1-555-123-4567"
            ),
            
            // Free member example
            DashboardMember(
                id: 2,
                full_name: "Mike Davis",
                profile_image: "https://via.placeholder.com/150/FF0000/FFFFFF?text=MD",
                user_id: 102,
                is_moderator: false,
                has_paid: false,
                payment_date: nil,
                payment_amount: nil,
                email: "mike.davis@example.com",
                phone_number: "+1-555-987-6543"
            )
        ]
        
        DispatchQueue.main.async {
            self.members = dummyMembers
            self.calculateStats()
        }
        
        /* TODO: Uncomment this when backend is ready
        guard let url = URL(string: "\(baseURL)circles/dashboard_members/\(circleId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch dashboard members:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([DashboardMember].self, from: data)
                DispatchQueue.main.async {
                    self.members = decoded
                    self.calculateStats()
                }
            } catch {
                print("❌ Failed to decode dashboard members:", error)
            }
        }.resume()
        */
    }
    
    // Calculate payment statistics
    func calculateStats() {
        paidMembersCount = members.filter { $0.has_paid == true }.count
        totalRevenue = members.compactMap { $0.payment_amount }.reduce(0, +)
    }
    
    // Admin actions
    func promoteToModerator(memberId: Int) {
        // Implement promote to moderator functionality
        print("Promoting member \(memberId) to moderator")
        
        DispatchQueue.main.async {
            fetchDashboardMembers()
        }
    }
    
    func markAsPaid(memberId: Int) {
        // Implement mark as paid functionality
        print("Marking member \(memberId) as paid")
        
        DispatchQueue.main.async {
            fetchDashboardMembers()
        }
    }
    
    func sendPaymentReminder(memberId: Int) {
        // Implement payment reminder functionality
        print("Sending payment reminder to member \(memberId)")
    }
    
    // Helper function to format date
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    // MARK: - Contact Actions
    func openEmail(to email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    func callMember(phone: String) {
        let cleanPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    func textMember(phone: String) {
        let cleanPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "sms:\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
}
