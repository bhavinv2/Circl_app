import Foundation

struct BusinessProfileResponse: Codable {
    let business_name: String?
    let industry: String?
    let location: String?
    let revenue: String?
    let stage: String?
    let type: String?
    let looking_for: String?
    let mission: String?
    let about: String?
    let company_culture: String?
    let vision: String?
    let product_service: String?
    let traction: String?
    let unique_selling_proposition: String?
    let revenue_streams: String?
    let advisors_mentors: String?
    let cofounders: String?
    let key_hires: String?
    let amount_raised: String?
    let financial_projections: String?
    let funding_stage: String?
    let use_of_funds: String?
    let investment: String?
    let mentorship: String?
    let other: String?
    let roles_needed: String?
    let pricing_strategy: String?
    
}

class BusinessProfileViewModel: ObservableObject {
    @Published var profile: BusinessProfile?
    @Published var hasBusinessInfo: Bool = false
    
    func fetchProfile(for userId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/users/business-profile/\(userId)/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let profileResponse = try JSONDecoder().decode(BusinessProfile.self, from: data)
                        self.profile = profileResponse
                        // Check if any business info exists
                        self.hasBusinessInfo = profileResponse.industry != nil ||
                                              profileResponse.location != nil ||
                                              profileResponse.business_name != nil
                        print("✅ Profile fetched: \(profileResponse)")
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
            }
        }.resume()
    }

    func updateProfile(for userId: Int, with payload: [String: Any], completion: @escaping (Bool, String) -> Void) {
        let group = DispatchGroup()
        var anySuccess = false
        var messages: [String] = []

        // Core business info
        if let infoURL = URL(string: "\(baseURL)users/update-business-info/") {
            var infoBody: [String: Any] = [
                "user_id": userId,
                "business_name": payload["business_name"] ?? "",
                "business_stage": payload["stage"] ?? "",
                "business_revenue": payload["revenue"] ?? "",
                "industry": payload["industry"] ?? "",
                "business_location": payload["location"] ?? ""
            ]
            // Map type -> scale_type for API compatibility
            if let scaleType = payload["type"] as? String { infoBody["scale_type"] = scaleType }
            if infoBody["scale_type"] == nil { infoBody["scale_type"] = "" }
            if infoBody["is_legally_incorporated"] == nil { infoBody["is_legally_incorporated"] = false }

            var infoReq = URLRequest(url: infoURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            infoReq.httpMethod = "POST"
            infoReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = UserDefaults.standard.string(forKey: "auth_token"), !token.isEmpty {
                infoReq.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
            }
            infoReq.httpBody = try? JSONSerialization.data(withJSONObject: infoBody)

            group.enter()
            URLSession.shared.dataTask(with: infoReq) { data, response, error in
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("📩 update-business-info response (status=\(status)): \(body)")
                    messages.append("info: status=\(status) body=\(body)")
                }
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) { anySuccess = true }
                else { print("❌ update-business-info failed: status=\(status), error=\(error?.localizedDescription ?? "nil")") }
                group.leave()
            }.resume()
        }

        // Extended details
        if let detailsURL = URL(string: "\(baseURL)users/update-business-details/") {
            var details: [String: Any] = ["user_id": userId]
            let keys = [
                "about","mission","vision","company_culture","product_service","traction",
                "unique_selling_proposition","revenue_streams","pricing_strategy","cofounders",
                "key_hires","advisors_mentors","amount_raised","financial_projections","funding_stage",
                "use_of_funds","investment","mentorship","other","roles_needed","looking_for"
            ]
            for key in keys { if let value = payload[key] as? String { details[key] = value } }

            var detailsReq = URLRequest(url: detailsURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            detailsReq.httpMethod = "POST"
            detailsReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = UserDefaults.standard.string(forKey: "auth_token"), !token.isEmpty {
                detailsReq.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
            }
            detailsReq.httpBody = try? JSONSerialization.data(withJSONObject: details)

            group.enter()
            URLSession.shared.dataTask(with: detailsReq) { data, response, error in
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("📩 update-business-details response (status=\(status)): \(body)")
                    messages.append("details: status=\(status) body=\(body)")
                }
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) { anySuccess = true }
                else { print("❌ update-business-details failed: status=\(status), error=\(error?.localizedDescription ?? "nil")") }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            self.fetchProfile(for: userId)
            completion(anySuccess, messages.joined(separator: "\n"))
        }
    }
}
