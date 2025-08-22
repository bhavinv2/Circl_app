import SwiftUI
import Foundation

// Copy this from PageCircleMessages.swift
struct Member: Identifiable, Decodable, Hashable {
    let id: Int
    let full_name: String
    let profile_image: String?
    let user_id: Int
    let is_moderator: Bool   // ✅ Add this
}


struct MemberListPage: View {
    let circleName: String
    let circleId: Int

    @State private var members: [Member] = []
    @State private var selectedMember: Member? = nil
    @State private var showingReportDialog = false
    @State private var showingBlockConfirmation = false
    @State private var selectedReportReason = ""
    @State private var blockReason = ""
    @State private var shouldReportAndBlock = false
    @State private var memberToReport: Member? = nil
    @State private var memberToBlock: Member? = nil
    @AppStorage("user_id") private var currentUserId: Int = 0

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Members in \(circleName)")
                    .font(.title2)
                    .bold()

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(members) { member in
                            Button(action: {
                                selectedMember = member
                            }) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: member.profile_image ?? "")) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())

                                    Text(member.full_name)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    // Show 3 dots for all members except current user
                                    if member.user_id != currentUserId {
                                        Menu {
                                            // Show moderation options only for non-moderators
                                            if !member.is_moderator {
                                                Button("Make Moderator") {
                                                    promoteToModerator(memberId: member.user_id)
                                                }
                                                Divider()
                                            }
                                            
                                            // Show report option for all users (including moderators)
                                            Button("Report User", role: .destructive) {
                                                memberToReport = member
                                                showingReportDialog = true
                                            }
                                            
                                            // Show block option for all users (including moderators)
                                            Button("Block User", role: .destructive) {
                                                memberToBlock = member
                                                showingBlockConfirmation = true
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .rotationEffect(.degrees(90))
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(.gray)
                                        }
                                        .onAppear {
                                            // Debug prints moved to onAppear
                                            print("🔍 Member: \(member.full_name)")
                                            print("🔍 User ID: \(member.user_id), Current: \(currentUserId)")
                                            print("🔍 Is Moderator: \(member.is_moderator)")
                                        }
                                    } else {
                                        // Debug: Show why 3 dots aren't visible
                                        Text("(You)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)

                            }
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Members")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedMember) { member in
                DynamicProfilePreview(
                    profileData: convertToFullProfile(from: member),
                    isInNetwork: true
                )
            }
            .onAppear {
                fetchMembers()
            }
            
            // Report Dialog Overlay
            if showingReportDialog {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showingReportDialog = false
                        selectedReportReason = ""
                    }
                
                VStack {
                    Spacer()
                    reportDialogView
                    Spacer()
                }
            }

            // Block Confirmation Overlay
            if showingBlockConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showingBlockConfirmation = false
                        blockReason = ""
                        shouldReportAndBlock = false
                    }
                
                VStack {
                    Spacer()
                    blockConfirmationView
                    Spacer()
                }
            }
        }
    }
    func convertToFullProfile(from member: Member) -> FullProfile {
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
    
    // MARK: - Report and Block Constants (ChatView Style)
    private let reportReasons = [
        "Harassment or threatening behavior",
        "Spam or unwanted messages",
        "Inappropriate content",
        "Fake profile or impersonation",
        "Scam or fraud",
        "Other"
    ]

    private let blockReasons = [
        "I don't want to hear from this person",
        "This person is harassing me", 
        "This is spam",
        "I don't know this person",
        "Something else"
    ]
    
    // MARK: - Report and Block UI Views
    var reportDialogView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Report \(memberToReport?.full_name ?? "User")")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button("Cancel") {
                    showingReportDialog = false
                    selectedReportReason = ""
                }
                .foregroundColor(Color(hex: "004aad"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Why are you reporting this person?")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Single list of all report reasons
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(reportReasons, id: \.self) { reason in
                            Button(action: {
                                selectedReportReason = reason
                                submitReport()
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.red)
                                        .frame(width: 20)
                                    
                                    Text(reason)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 300)
                
                Text("Reports are anonymous. We'll review this and take appropriate action.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 30)
    }

    var blockConfirmationView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Block \(memberToBlock?.full_name ?? "User")?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button("Cancel") {
                    showingBlockConfirmation = false
                    blockReason = ""
                    shouldReportAndBlock = false
                }
                .foregroundColor(Color(hex: "004aad"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("They won't be able to message you or see your posts. They won't be notified that you blocked them.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Block reason selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reason for blocking (optional)")
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 20)
                    
                    ForEach(blockReasons, id: \.self) { reason in
                        Button(action: {
                            blockReason = reason
                        }) {
                            HStack {
                                Image(systemName: blockReason == reason ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(blockReason == reason ? Color(hex: "004aad") : .secondary)
                                
                                Text(reason)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Report and block option
                Button(action: {
                    shouldReportAndBlock.toggle()
                }) {
                    HStack {
                        Image(systemName: shouldReportAndBlock ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundColor(shouldReportAndBlock ? Color(hex: "004aad") : .secondary)
                        
                        Text("Also report this person")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        confirmBlock()
                    }) {
                        Text("Block")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingBlockConfirmation = false
                        blockReason = ""
                        shouldReportAndBlock = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 30)
    }
    
    // MARK: - Report and Block Functions (ChatView Style)
    private func submitReport() {
        guard let member = memberToReport else { return }
        
        let reportData: [String: Any] = [
            "reported_user_id": member.user_id,
            "reporter_id": currentUserId,
            "reason": selectedReportReason,
            "report_type": "user_report"
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/report_user/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: reportData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print("✅ User reported successfully")
                self.showingReportDialog = false
                self.selectedReportReason = ""
                self.memberToReport = nil
            }
        }.resume()
    }
    
    private func confirmBlock() {
        guard let member = memberToBlock else { return }
        
        let blockData: [String: Any] = [
            "blocked_user_id": member.user_id,
            "blocker_id": currentUserId,
            "reason": blockReason,
            "should_report": shouldReportAndBlock
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/block_user/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: blockData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print("✅ User blocked successfully")
                self.showingBlockConfirmation = false
                self.blockReason = ""
                self.shouldReportAndBlock = false
                self.memberToBlock = nil
            }
        }.resume()
    }


    func promoteToModerator(memberId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/make_moderator/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = [
            "user_id": memberId,
            "circle_id": circleId,
            "requesting_user_id": currentUserId
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error promoting moderator:", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                fetchMembers()
            }
        }.resume()
    }


    func fetchMembers() {
        guard let url = URL(string: "https://circlapp.online/api/circles/members/\(circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch members:", error?.localizedDescription ?? "unknown")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                DispatchQueue.main.async {
                    self.members = decoded
                }
            } catch {
                print("❌ Failed to decode members:", error)
            }
        }.resume()
    }
}


