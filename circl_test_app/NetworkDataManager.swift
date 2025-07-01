import Foundation
import SwiftUI

// MARK: - Shared Network Data Manager
// Note: Uses data models from SharedDataModels.swift
class NetworkDataManager: ObservableObject {
    static let shared = NetworkDataManager()
    
    @Published var userNetworkEmails: [String] = []
    @Published var friendRequests: [InviteProfileData] = []
    @Published var entrepreneurs: [SharedEntrepreneurProfileData] = []
    @Published var mentors: [MentorProfileData] = []
    
    // Computed property for total potential matches across all pages
    var totalPotentialMatches: Int {
        return entrepreneurs.count + mentors.count
    }
    
    private var isNetworkLoading = false
    private var isFriendRequestsLoading = false
    
    private init() {
        // Load initial data when the manager is created
        loadAllData()
    }
    
    func loadAllData() {
        fetchUserNetwork()
        fetchFriendRequests()
        fetchEntrepreneursData()
        fetchMentorsData()
    }
    
    func fetchUserNetwork() {
        guard !isNetworkLoading else { return }
        isNetworkLoading = true
        
        guard let url = URL(string: "https://circlapp.online/api/my-network/") else {
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
                    // Format: [{"email": "...", ...}, ...]
                    networkEmails = networkArray.compactMap { $0["email"] as? String }
                    print("📧 NetworkDataManager - Parsed from array format: \(networkEmails)")
                } else if let dict = json as? [String: Any] {
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
    
    func fetchFriendRequests() {
        guard !isFriendRequestsLoading else { return }
        isFriendRequestsLoading = true
        
        guard let url = URL(string: "https://circlapp.online/api/friend-requests/") else {
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
    
    func addToNetwork(email: String) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "https://circlapp.online/api/users/send_friend_request/") else {
            print("❌ NetworkDataManager - Missing sender ID or bad URL")
            return
        }
        
        let body: [String: Any] = [
            "user_id": senderId,
            "receiver_email": email
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ NetworkDataManager - Error sending friend request:", error.localizedDescription)
                return
            }
            
            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8)
                print("📡 NetworkDataManager - Friend Request Response:", rawResponse ?? "No response body")
            }
            
            DispatchQueue.main.async {
                if let strongSelf = self {
                    // Update local state immediately for better UX
                    if !strongSelf.userNetworkEmails.contains(email) {
                        strongSelf.userNetworkEmails.append(email)
                    }
                    
                    // Remove from entrepreneurs and mentors lists
                    strongSelf.entrepreneurs.removeAll { $0.email == email }
                    strongSelf.mentors.removeAll { $0.email == email }
                    
                    // Refresh data from server
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
        
        guard let url = URL(string: "https://circlapp.online/api/users/get-entrepreneurs/") else { 
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
        
        guard let url = URL(string: "https://circlapp.online/api/users/get-mentors/") else {
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
            
            if let decodedResponse = try? JSONDecoder().decode([MentorProfileData].self, from: data) {
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        strongSelf.mentors = decodedResponse.filter { mentor in
                            return !strongSelf.userNetworkEmails.contains(mentor.email) && mentor.email != currentUserEmail
                        }
                        print("✅ NetworkDataManager - Updated mentors count: \(strongSelf.mentors.count)")
                    }
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
            let profileImage = dict["profileImage"] as? String
            let businessName = dict["business_name"] as? String ?? "Not specified"
            let businessStage = dict["business_stage"] as? String ?? "Startup"
            let businessIndustry = dict["industry_interest"] as? String ?? "Business"
            let businessBio = dict["business_bio"] as? String ?? "Entrepreneur"
            let fundingRaised = dict["funding_raised"] as? String ?? "0"
            let lookingFor = dict["looking_for"] as? [String] ?? ["Networking"]
            let isMentor = dict["is_mentor"] as? Bool ?? false
            
            return SharedEntrepreneurProfileData(
                id: id,
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
                isMentor: isMentor,
                user_id: userId
            )
        }
        
        // Filter out users already in network and current user
        self.entrepreneurs = filteredEntrepreneurs.filter { entrepreneur in
            return !self.userNetworkEmails.contains(entrepreneur.email) && entrepreneur.email != currentUserEmail
        }
        print("✅ NetworkDataManager - Updated entrepreneurs count: \(self.entrepreneurs.count)")
    }
}
