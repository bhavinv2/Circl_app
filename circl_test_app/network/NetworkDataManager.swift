import Foundation
import SwiftUI

// MARK: - Shared Network Data Manager
// Note: Uses data models from SharedDataModels.swift
class NetworkDataManager: ObservableObject {
    static let shared = NetworkDataManager()
    
    @Published var userNetworkEmails: [String] = []
    @Published var networkConnections: [InviteProfileData] = []
    @Published var friendRequests: [InviteProfileData] = []
    @Published var entrepreneurs: [SharedEntrepreneurProfileData] = []
    @Published var mentors: [MentorProfileData] = []
    @Published var sentRequests: [String] = []  // store emails you sent requests to
    @Published var userNetworkRaw: [[String: Any]] = []   // ✅ new

    /// Stable, equatable representation of the logged-in user's network membership.
    /// Use this for SwiftUI `onChange` observers instead of `userNetworkRaw` (which is not Equatable).
    var userNetworkIds: Set<Int> {
        Set(userNetworkRaw.compactMap { dict in
            (dict["id"] as? Int)
            ?? (dict["user_id"] as? Int)
            ?? (dict["friend_id"] as? Int)
        })
    }
    
    private var isNetworkLoading = false
    private var isFriendRequestsLoading = false
    
    private init() {
        // Load initial data when the manager is created
        loadAllData()
    }
    
    func loadAllData() {
        fetchUserNetwork()
        fetchNetworkConnections()
        fetchFriendRequests()
        fetchSentRequests()
        fetchEntrepreneursData()
        fetchMentorsData()
        
        // Add test data for demonstration
        addTestEntrepreneursAndMentors()
    }
    
    func fetchUserNetwork() {
        guard !isNetworkLoading else { return }
        isNetworkLoading = true
        
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ NetworkDataManager - No user_id found")
            isNetworkLoading = false
            return
        }
        
        guard let url = URL(string: "\(baseURL)users/get_network/\(userId)/") else {
            isNetworkLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isNetworkLoading = false
                }
            }
            
            if let error = error {
                print("❌ NetworkDataManager - Network fetch error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ NetworkDataManager - No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("🔎 NetworkDataManager - Raw Network Response: \(json)")
                
                var networkEmails: [String] = []
                
                // Try different response format possibilities
                if let networkArray = json as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self?.userNetworkRaw = networkArray   // ✅ safe update on main thread
                    }
                    networkEmails = networkArray.compactMap { $0["email"] as? String }
                    print("📧 NetworkDataManager - Parsed \(networkArray.count) users with ids")
                }

else if let dict = json as? [String: Any] {
                    // Check multiple possible nested structures
                    if let network = dict["network"] as? [[String: Any]] {
                        // Format: {"network": [{"email": "...", ...}, ...]}
                        networkEmails = network.compactMap { $0["email"] as? String }
                        print("📧 NetworkDataManager - Parsed from dict.network format: \(networkEmails)")
                    } else if let users = dict["users"] as? [[String: Any]] {
                        // Format: {"users": [{"email": "...", ...}, ...]}
                        networkEmails = users.compactMap { $0["email"] as? String }
                        print("📧 NetworkDataManager - Parsed from dict.users format: \(networkEmails)")
                    } else if let friends = dict["friends"] as? [[String: Any]] {
                        // Format: {"friends": [{"email": "...", ...}, ...]}
                        networkEmails = friends.compactMap { $0["email"] as? String }
                        print("📧 NetworkDataManager - Parsed from dict.friends format: \(networkEmails)")
                    } else if let success = dict["success"] as? Bool, success == true,
                              let data = dict["data"] as? [[String: Any]] {
                        // Format: {"success": true, "data": [{"email": "...", ...}, ...]}
                        networkEmails = data.compactMap { $0["email"] as? String }
                        print("📧 NetworkDataManager - Parsed from success.data format: \(networkEmails)")
                    } else {
                        // Try to extract emails from any nested arrays
                        for (key, value) in dict {
                            if let array = value as? [[String: Any]] {
                                let emails = array.compactMap { $0["email"] as? String }
                                if !emails.isEmpty {
                                    networkEmails = emails
                                    print("📧 NetworkDataManager - Parsed from key '\(key)': \(networkEmails)")
                                    break
                                }
                            }
                        }
                        
                        if networkEmails.isEmpty {
                            print("❌ NetworkDataManager - Could not find email array in response. Keys: \(dict.keys.sorted())")
                            if let rawString = String(data: data, encoding: .utf8) {
                                print("📄 NetworkDataManager - Full response: \(rawString)")
                            }
                        }
                    }
                } else {
                    print("❌ NetworkDataManager - Unknown format in network response: \(type(of: json))")
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("📄 NetworkDataManager - Full response: \(rawString)")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.userNetworkEmails = networkEmails
                    print("✅ NetworkDataManager - Updated network count: \(networkEmails.count)")
                    print("📧 NetworkDataManager - Network emails: \(networkEmails)")
                }
                
            } catch {
                if let rawString = String(data: data, encoding: .utf8) {
                    print("❌ NetworkDataManager - JSON Parsing Error – Raw text: \(rawString)")
                } else {
                    print("❌ NetworkDataManager - JSON Parsing Error: Could not decode response")
                }
            }
        }.resume()
    }
    // MARK: - Accept Friend Request
    func acceptFriendRequest(senderEmail: String, receiverId: Int) {
        guard let url = URL(string: "\(baseURL)users/accept_friend_request/") else { return }
        
        let body: [String: Any] = [
            "sender_email": senderEmail,
            "receiver_id": receiverId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Accept request error:", error)
                return
            }
            print("✅ Friend request accepted")
            DispatchQueue.main.async {
                self.fetchNetworkConnections()   // refresh accepted
                self.fetchFriendRequests()       // refresh pending
            }
        }.resume()
    }

    // MARK: - Decline Friend Request
    func declineFriendRequest(senderEmail: String, receiverId: Int) {
        guard let url = URL(string: "\(baseURL)users/decline_friend_request/") else { return }
        
        let body: [String: Any] = [
            "sender_email": senderEmail,
            "receiver_id": receiverId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Decline request error:", error)
                return
            }
            print("✅ Friend request declined")
            DispatchQueue.main.async {
                self.fetchFriendRequests()   // refresh pending
            }
        }.resume()
    }

    func fetchNetworkConnections() {
        print("🔄 NetworkDataManager - Fetching network connections")
        
        // First get the network emails
        fetchUserNetwork()
        
        // Then convert emails to profile data after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.convertNetworkEmailsToProfiles()
        }
        
        // Also get friend requests as additional network data
        fetchFriendRequests()
    }
    private func convertNetworkEmailsToProfiles() {
        var convertedProfiles: [InviteProfileData] = []
        for dict in userNetworkRaw {
            let id = (dict["id"] as? Int) ?? (dict["user_id"] as? Int) ?? -1
            guard id != -1, let email = dict["email"] as? String else { continue }

            // Use the same simple approach as mentors and entrepreneurs
            let firstName = dict["first_name"] as? String ?? ""
            let lastName = dict["last_name"] as? String ?? ""
            let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
            let username = (dict["username"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            let profile = InviteProfileData(
                user_id: id,   // ✅ real backend id
                name: name, // Use the properly constructed name
                username: username,
                email: email,
                title: dict["title"] as? String ?? "Professional",
                company: dict["company"] as? String ?? "Network",
                proficiency: dict["main_usage"] as? String ?? "Networking",
                tags: dict["tags"] as? [String] ?? ["Professional", "Network"],
                profileImage: (dict["profileImage"] as? String)
                           ?? (dict["profile_image"] as? String)
                           ?? ""
            )

            convertedProfiles.append(profile)
        }

        DispatchQueue.main.async {
            self.networkConnections = convertedProfiles
            print("✅ NetworkDataManager - Updated accepted network count: \(convertedProfiles.count)")
            // Debug output to verify names
            for profile in convertedProfiles.prefix(3) {
                print("📝 Network connection: \(profile.name) (\(profile.email))")
            }
        }
    }


    func fetchFriendRequests() {
        guard !isFriendRequestsLoading else { return }
        isFriendRequestsLoading = true
        
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ NetworkDataManager - No user_id found for friend requests")
            isFriendRequestsLoading = false
            return
        }
        
        guard let url = URL(string: "\(baseURL)users/get_friend_requests/\(userId)") else {
            isFriendRequestsLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isFriendRequestsLoading = false
                }
            }
            
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([InviteProfileData].self, from: data) {
                    DispatchQueue.main.async {
                        self?.friendRequests = decodedResponse
                        print("✅ NetworkDataManager - Updated friend requests count: \(decodedResponse.count)")
                    }
                }
            }
        }.resume()
    }
    func fetchSentRequests() {
        
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "\(baseURL)users/get_sent_requests/\(userId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([InviteProfileData].self, from: data) {
                    DispatchQueue.main.async {
                        self?.sentRequests = decoded.map { $0.email }
                        print("✅ NetworkDataManager - Updated sent requests count: \(decoded.count)")
                    }
                }
            }
        }.resume()
    }
    func addToNetwork(email: String) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ NetworkDataManager - Missing sender ID")
            return
        }

        // 1️⃣ If already an incoming request → accept and exit
        if let existingRequest = friendRequests.first(where: { $0.email == email }) {
            print("🔄 Found existing incoming request from \(email) — auto accepting")

            acceptFriendRequest(senderEmail: email, receiverId: senderId)

            // 🚨 IMPORTANT: Stop here, don’t send a new request
            return
        }

        // 2️⃣ Otherwise → normal send flow
        guard let url = URL(string: "\(baseURL)users/send_friend_request/") else {
            print("❌ Bad URL for send_friend_request")
            return
        }

        let body: [String: Any] = [
            "user_id": senderId,
            "receiver_email": email
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ NetworkDataManager - Error sending friend request:", error.localizedDescription)
                return
            }

            if let data = data {
                print("📡 NetworkDataManager - Friend Request Response:", String(data: data, encoding: .utf8) ?? "No response body")
            }

            DispatchQueue.main.async {
                if let strongSelf = self {
                    if !strongSelf.sentRequests.contains(email) {
                        strongSelf.sentRequests.append(email)
                    }
                    strongSelf.fetchSentRequests()
                    strongSelf.fetchUserNetwork()
                }
            }
        }.resume()
    }

    func refreshAllData() {
        print("🔄 NetworkDataManager - Manually refreshing all data...")
        loadAllData()
    }
    
    // MARK: - Manual refresh function for testing
    func forceRefreshNetwork() {
        print("🔄 NetworkDataManager - Force refreshing network data...")
        isNetworkLoading = false // Reset loading state
        fetchUserNetwork()
    }
    
    // MARK: - Entrepreneurs Data Fetching
    func fetchEntrepreneursData() {
        let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
        
        guard let url = URL(string: "\(baseURL)users/get-entrepreneurs/") else {
            print("❌ Invalid URL for entrepreneurs")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ NetworkDataManager - Entrepreneurs fetch error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ NetworkDataManager - No entrepreneurs data received")
                return
            }
            
            if let decodedResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let entrepreneurList = decodedResponse["entrepreneurs"] as? [[String: Any]] {
                
                DispatchQueue.main.async { [weak self] in
                    self?.processEntrepreneurData(entrepreneurList, currentUserEmail: currentUserEmail)
                }
            }
        }.resume()
    }
    
    // MARK: - Mentors Data Fetching
    func fetchMentorsData() {
        let currentUserEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
        
        guard let url = URL(string: "\(baseURL)users/approved_mentors/") else {
            print("❌ Invalid URL for mentors")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ NetworkDataManager - Mentors fetch error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ NetworkDataManager - No mentors data received")
                return
            }
            
            if let mentorList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.mentors = mentorList.compactMap { mentor in
                        let email = mentor["email"] as? String ?? ""
                        guard email != currentUserEmail,
                              !strongSelf.userNetworkEmails.contains(email),
                              let user_id = mentor["id"] as? Int else {
                            return nil
                        }

                        return MentorProfileData(
                            user_id: user_id,
                            name: "\(mentor["first_name"] ?? "") \(mentor["last_name"] ?? "")",
                            username: mentor["username"] as? String ?? email,
                            title: "Mentor",
                            company: mentor["industry_interest"] as? String ?? "Unknown Industry",
                            proficiency: mentor["main_usage"] as? String ?? "Unknown",
                            tags: mentor["tags"] as? [String] ?? [],
                            email: email,
                            profileImage: (mentor["profile_image"] as? String) ?? (mentor["profileImage"] as? String)

                        )
                    }
                    
                    print("✅ NetworkDataManager - Updated mentors count: \(strongSelf.mentors.count)")
                }
            }
        }.resume()
    }
    
    // MARK: - Helper Functions
    private func processEntrepreneurData(_ entrepreneurList: [[String: Any]], currentUserEmail: String) {
        let filteredEntrepreneurs: [SharedEntrepreneurProfileData] = entrepreneurList.compactMap { dict -> SharedEntrepreneurProfileData? in
            guard
                let id = dict["id"] as? Int,
                let firstName = dict["first_name"] as? String,
                let lastName = dict["last_name"] as? String,
                let email = dict["email"] as? String,
                let userId = dict["id"] as? Int
            else {
                return nil
            }
            
            let fullName = "\(firstName) \(lastName)"
            let username = dict["username"] as? String ?? email
            let profileImage = (dict["profile_image"] as? String) ?? (dict["profileImage"] as? String)

            let businessName = dict["business_name"] as? String ?? "Not specified"
            let businessStage = dict["business_stage"] as? String ?? "Startup"
            let businessIndustry = dict["industry_interest"] as? String ?? "Business"
            let businessBio = dict["business_bio"] as? String ?? "Entrepreneur"
            let fundingRaised = dict["funding_raised"] as? String ?? "0"
            let lookingFor = dict["looking_for"] as? [String] ?? ["Networking"]
            let isMentor = dict["is_mentor"] as? Bool ?? false
            
            return SharedEntrepreneurProfileData(
                user_id: userId,
                name: fullName,
                email: email,
                username: username,
                profileImage: profileImage,
                businessName: businessName,
                businessStage: businessStage,
                businessIndustry: businessIndustry,
                businessBio: businessBio,
                fundingRaised: fundingRaised,
                lookingFor: lookingFor,
                isMentor: isMentor
            )
        }
        
        // Filter out users already in network and current user
        self.entrepreneurs = filteredEntrepreneurs.filter { entrepreneur in
            return !self.userNetworkEmails.contains(entrepreneur.email) && entrepreneur.email != currentUserEmail
        }
        print("✅ NetworkDataManager - Updated entrepreneurs count: \(self.entrepreneurs.count)")
    }
    
    // MARK: - Test Data
    func addTestEntrepreneursAndMentors() {
        // Add test entrepreneurs with profile images
        let testEntrepreneurs = [
            SharedEntrepreneurProfileData(
                user_id: 9001,
                name: "Sarah Johnson",
                email: "sarah@testentrepreneur.com",
                username: "sarahj",
                profileImage: "https://picsum.photos/seed/sarah/200/200",
                businessName: "TechStartup Inc",
                businessStage: "Series A",
                businessIndustry: "Technology",
                businessBio: "Building the future of AI-powered solutions",
                fundingRaised: "$2.5M",
                lookingFor: ["Technical Co-founder"],
                isMentor: false
            ),
            SharedEntrepreneurProfileData(
                user_id: 9002,
                name: "Mike Chen",
                email: "mike@testentrepreneur.com",
                username: "mikec",
                profileImage: "https://picsum.photos/seed/mike/200/200",
                businessName: "GreenEnergy Solutions",
                businessStage: "Seed",
                businessIndustry: "Clean Energy",
                businessBio: "Revolutionizing renewable energy storage",
                fundingRaised: "$500K",
                lookingFor: ["Marketing Partner"],
                isMentor: false
            )
        ]
        
        // Add test mentors with profile images
        let testMentors = [
            MentorProfileData(
                user_id: 9003,
                name: "Dr. Emily Rodriguez",
                username: "emilyrod",
                title: "Partner",
                company: "TopTier Ventures",
                proficiency: "Venture Capital",
                tags: ["VC", "Funding", "Strategy"],
                email: "emily@testmentor.com",
                profileImage: "https://picsum.photos/seed/emily/200/200"
            ),
            MentorProfileData(
                user_id: 9004,
                name: "James Wilson",
                username: "jameswilson",
                title: "Former CMO",
                company: "Fortune 500 Corp",
                proficiency: "Marketing Strategy",
                tags: ["Marketing", "Digital", "Growth"],
                email: "james@testmentor.com",
                profileImage: "https://picsum.photos/seed/james/200/200"
            )
        ]
        
        // Add to existing arrays
        self.entrepreneurs.append(contentsOf: testEntrepreneurs)
        self.mentors.append(contentsOf: testMentors)
        
        print("✅ Added test entrepreneurs: \(testEntrepreneurs.count)")
        print("✅ Added test mentors: \(testMentors.count)")
    }
}
func uploadCircleImage(circleId: Int, image: UIImage) {
    let urlString = "\(baseURL)circles/upload_circle_image/"
    guard let url = URL(string: urlString) else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    if let token = UserDefaults.standard.string(forKey: "auth_token") {
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
    }

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var data = Data()

    // circle_id
    data.append("--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"circle_id\"\r\n\r\n".data(using: .utf8)!)
    data.append("\(circleId)\r\n".data(using: .utf8)!)

    // ✅ add user_id
    if let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(userId)\r\n".data(using: .utf8)!)
    }

    // profile_image
    if let imgData = image.jpegData(compressionQuality: 0.8) {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"profile_image\"; filename=\"circle.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imgData)
        data.append("\r\n".data(using: .utf8)!)
    }

    data.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = data

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ Circle image upload failed:", error.localizedDescription)
            return
        }
        if let data = data, let responseStr = String(data: data, encoding: .utf8) {
            print("✅ Upload response:", responseStr)

            // 🔄 Fetch updated circle details right after upload
            DispatchQueue.main.async {
                fetchCircleDetails(circleId: circleId) { updatedCircle in
                    if let updated = updatedCircle {
                        NotificationCenter.default.post(name: .circleUpdated, object: updated)
                    }
                }
            }
        }
    }.resume()
}
extension Notification.Name {
    static let circleUpdated = Notification.Name("circleUpdated")
}

func fetchCircleDetails(circleId: Int, completion: @escaping (CircleData?) -> Void) {
    guard let url = URL(string: "\(baseURL)circles/get_circle_details/?circle_id=\(circleId)&user_id=\(UserDefaults.standard.integer(forKey: "user_id"))") else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    if let token = UserDefaults.standard.string(forKey: "auth_token") {
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            completion(nil)
            return
        }
        do {
            let decoded = try JSONDecoder().decode(CircleData.self, from: data)
            DispatchQueue.main.async {
                completion(decoded)
            }
        } catch {
            print("❌ Decoding circle details failed:", error)
            completion(nil)
        }
    }.resume()
}
