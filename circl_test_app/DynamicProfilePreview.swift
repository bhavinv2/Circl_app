import SwiftUI
import Foundation

struct DynamicProfilePreview: View {
    var profileData: FullProfile
    let isInNetwork: Bool
    
    @State private var showRemoveFriendConfirmation = false
    @Environment(\.dismiss) var dismiss
    @State private var showBlockConfirmation = false
    
    
    let loggedInUserId = UserDefaults.standard.integer(forKey: "user_id")
    
    var body: some View {
        return ZStack(alignment: .topTrailing) {
            // Background matching ProfilePage.swift
            LinearGradient(
                colors: [Color(.systemGray6).opacity(0.3), Color(.systemGray5).opacity(0.5)], 
                startPoint: .top, 
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    // Elegant close button
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 40, height: 40)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                    }
                    
                    VStack(spacing: 30) {
                        // MARK: - Header Card with ProfilePage gradient
                        ZStack {
                            // Background with animated gradient matching ProfilePage
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.customHex("001a3d"),
                                            Color.customHex("004aad"),
                                            Color.customHex("0066ff")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            if loggedInUserId != profileData.user_id {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Menu {
                                            if isInNetwork {
                                                Button(role: .destructive) {
                                                    showRemoveFriendConfirmation = true
                                                } label: {
                                                    Label("Remove user", systemImage: "person.fill.xmark")
                                                }
                                            }
                                            
                                            Button(role: .destructive) {
                                                showBlockConfirmation = true
                                            } label: {
                                                Label("Block user", systemImage: "hand.raised.fill")
                                            }
                                            
                                        } label: {
                                            Image(systemName: "ellipsis.circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top, 8)
                                        .padding(.trailing, 8)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .confirmationDialog("Remove this user from your network?", isPresented: $showRemoveFriendConfirmation) {
                                    Button("Remove user", role: .destructive) {
                                        removeFriend()
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                                .confirmationDialog("Block this user?", isPresented: $showBlockConfirmation) {
                                    Button("Block user", role: .destructive) {
                                        blockUser()
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                            }
                            
                            VStack(spacing: 25) {
                                // Premium Profile Image with Sophisticated Border
                                ZStack {
                                    // Outer glow ring
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color.customHex("0066ff").opacity(0.3),
                                                    Color.customHex("004aad").opacity(0.4),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 60,
                                                endRadius: 90
                                            )
                                        )
                                        .frame(width: 140, height: 140)
                                    
                                    // Main profile image
                                    AsyncImage(url: URL(string: profileData.profile_image ?? "")) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.gray.opacity(0.3),
                                                            Color.gray.opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                            
                                            Image(systemName: "person.crop.circle")
                                                .font(.system(size: 40, weight: .light))
                                                .foregroundColor(.gray.opacity(0.6))
                                        }
                                    }
                                    .frame(width: 130, height: 130)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                AngularGradient(
                                                    colors: [
                                                        Color.customHex("0066ff").opacity(0.9),
                                                        Color.customHex("ffde59").opacity(0.9),
                                                        Color.customHex("004aad").opacity(0.8),
                                                        Color.customHex("003d7a").opacity(0.6),
                                                        Color.customHex("0066ff").opacity(0.9)
                                                    ],
                                                    center: .center
                                                ),
                                                lineWidth: 4
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                                    .shadow(color: Color.customHex("0066ff").opacity(0.4), radius: 5, x: 0, y: 2)
                                }
                                
                                // User Name with elegant typography
                                VStack(spacing: 8) {
                                    Text("\(profileData.first_name ?? "Unknown") \(profileData.last_name ?? "User")")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    if let locations = profileData.locations, !locations.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "location.fill")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white.opacity(0.9))
                                            
                                            Text(locations.joined(separator: ", "))
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    }
                                }
                                
                                // Enhanced Stats Cards with Premium Design
                                HStack(spacing: 16) {
                                    // Connections Card - Premium Design
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.customHex("1e40af").opacity(0.9),
                                                            Color.customHex("3b82f6").opacity(0.8),
                                                            Color.customHex("60a5fa").opacity(0.7)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                                .frame(width: 70, height: 70)
                                            
                                            VStack(spacing: 4) {
                                                Image(systemName: "person.2.fill")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                
                                                Text("\(profileData.connections_count ?? 0)")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        Text("Connections")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    // Circles Card - Premium Design
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.customHex("7c3aed").opacity(0.9),
                                                            Color.customHex("a855f7").opacity(0.8),
                                                            Color.customHex("c084fc").opacity(0.7)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                                .frame(width: 70, height: 70)
                                            
                                            VStack(spacing: 4) {
                                                Image(systemName: "circle.grid.2x2.fill")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                
                                                Text("0")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        Text("Circles")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    // Circs Card - Premium Design
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.customHex("059669").opacity(0.9),
                                                            Color.customHex("10b981").opacity(0.8),
                                                            Color.customHex("34d399").opacity(0.7)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                                .frame(width: 70, height: 70)
                                            
                                            VStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                
                                                Text("\(profileData.circs ?? 0)")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        Text("Circs")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                
                            }
                            .padding(.vertical, 30)
                            .padding(.horizontal, 25)
                        }
                        .padding(.horizontal, 20)
                        
                        // Bio Section - Matching ProfilePage ModernCard style
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Bio")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(profileData.bio?.isEmpty == true ? "This entrepreneur prefers to keep their story mysterious for now..." : (profileData.bio ?? "This entrepreneur prefers to keep their story mysterious for now..."))
                                .font(.body)
                                .foregroundColor(profileData.bio?.isEmpty == true ? .secondary : .primary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(nil)
                            
                            if let type = profileData.personality_type, !type.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Personality Type")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(type)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // About Section - Matching ProfilePage ModernCard style
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About \(profileData.first_name ?? "") \(profileData.last_name ?? "")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 16) {
                                if let birthday = profileData.birthday {
                                    ProfileFieldDisplay(label: "Age", value: calculateAge(from: birthday))
                                }

                                if let level = profileData.education_level {
                                    ProfileFieldDisplay(label: "Education Level", value: level)
                                }

                                if let institution = profileData.institution_attended {
                                    ProfileFieldDisplay(label: "Institution", value: institution)
                                }

                                if let locations = profileData.locations, !locations.isEmpty {
                                    ProfileFieldDisplay(label: "Location(s)", value: locations.joined(separator: ", "))
                                }

                                if let type = profileData.personality_type, !type.isEmpty {
                                    ProfileFieldDisplay(label: "Personality Type", value: type)
                                }
                                
                                if (profileData.education_level?.isEmpty ?? true) &&
                                   (profileData.institution_attended?.isEmpty ?? true) &&
                                   (profileData.locations?.isEmpty ?? true) &&
                                   (profileData.personality_type?.isEmpty ?? true) {
                                    Text("No additional information listed yet.")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                        .italic()
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Technical Side Section - Matching ProfilePage ModernCard style
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Technical Side")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 16) {
                                if let skills = profileData.skillsets, !skills.isEmpty {
                                    ProfileFieldDisplay(label: "Skills", value: skills.joined(separator: ", "))
                                }

                                if let certs = profileData.certificates, !certs.isEmpty {
                                    ProfileFieldDisplay(label: "Certificates", value: certs.joined(separator: ", "))
                                }

                                if let years = profileData.years_of_experience {
                                    ProfileFieldDisplay(label: "Experience", value: "\(years) years")
                                }

                                if (profileData.skillsets?.isEmpty ?? true) &&
                                    (profileData.certificates?.isEmpty ?? true) &&
                                    profileData.years_of_experience == nil {
                                    Text("No technical information listed yet.")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                        .italic()
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )

                        // Interests Section - Matching ProfilePage ModernCard style
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Interests")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 16) {
                                if let clubs = profileData.clubs, !clubs.isEmpty {
                                    ProfileFieldDisplay(label: "Clubs", value: clubs.joined(separator: ", "))
                                }

                                if let hobbies = profileData.hobbies, !hobbies.isEmpty {
                                    ProfileFieldDisplay(label: "Hobbies", value: hobbies.joined(separator: ", "))
                                }

                                if (profileData.clubs?.isEmpty ?? true) && (profileData.hobbies?.isEmpty ?? true) {
                                    Text("No interests listed yet.")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                        .italic()
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )

                        // Entrepreneurial History Section - Matching ProfilePage ModernCard style
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Entrepreneurial History")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                             
                            if let history = profileData.entrepreneurial_history, !history.isEmpty {
                                Text(history)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(nil)
                            } else {
                                Text("No entrepreneurial history listed yet.")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                    .italic()
                                    .padding(.top, 8)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func calculateAge(from birthday: String) -> String {
        guard !birthday.isEmpty else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: birthday) else { return "N/A" }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return "\(ageComponents.year ?? 0)"
    }
    
    func blockUser() {
        print("🚨 blockUser() called")
        guard let url = URL(string: "https://circlapp.online/api/users/block_user/") else {
            print("❌ Invalid block URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let payload: [String: Any] = [
            "blocked_id": profileData.user_id
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Block user error: \(error)")
                return
            }
            
            print("✅ User blocked successfully")
            DispatchQueue.main.async {
                dismiss()
            }
        }.resume()
    }
    
    func removeFriend() {
        print("🚨 removeFriend() called")
        print("🔥 Remove friend called with user_id=\(loggedInUserId), friend_id=\(profileData.user_id)")
        
        guard let url = URL(string: "https://circlapp.online/api/users/remove_friend/") else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token set: Token \(token)")
        } else {
            print("⚠️ No auth token found")
        }
        
        let payload: [String: Any] = [
            "user_id": loggedInUserId,
            "friend_id": profileData.user_id
        ]
        
        print("📤 Payload: \(payload)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Error creating JSON payload: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            print("📡 Request completed — checking HTTP response")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response object")
                return
            }
            
            print("✅ Status code: \(httpResponse.statusCode)")
            
            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode"
                print("📦 Response data: \(responseString)")
                
                // Handle the response based on status code
                DispatchQueue.main.async {
                    switch httpResponse.statusCode {
                    case 200:
                        print("✅ Friend removed successfully, closing sheet")
                        self.dismiss()
                    case 404:
                        print("❌ Friendship not found — no action taken")
                    default:
                        print("❌ Unexpected status code: \(httpResponse.statusCode)")
                    }
                }
            } else {
                print("⚠️ No data returned")
            }
        }.resume()
    }
}

// Helper component matching ProfilePage's ProfileField style
struct ProfileFieldDisplay: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(value.isEmpty ? "Not set" : value)
                .font(.body)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
