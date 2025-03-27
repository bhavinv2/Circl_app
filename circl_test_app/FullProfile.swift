import Foundation

struct FullProfile: Identifiable, Codable {
    var id: Int { user_id }

    let user_id: Int
    let profile_image: String?
    let first_name: String
    let last_name: String
    let email: String
    let main_usage: String?
    let industry_interest: String?
    let title: String?
    let bio: String?
    let birthday: String?
    let education_level: String?
    let institution_attended: String?
    let certificates: [String]?
    let years_of_experience: Int?
    let personality_type: String?
    let locations: [String]?
    let achievements: [String]?
    let skillsets: [String]?
    let availability: String?
    let clubs: [String]?
    let hobbies: [String]?
    let connections_count: Int?
    let circs: Int?  // ✅ Add this line

}

extension FullProfile {
    var full_name: String {
        "\(first_name) \(last_name)"
    }
}
