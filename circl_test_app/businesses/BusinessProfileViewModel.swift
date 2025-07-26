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
        guard let url = URL(string: "\(baseURL)users/business-profile/\(userId)/") else { return }
        
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
}
