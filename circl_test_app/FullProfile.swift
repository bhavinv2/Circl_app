import Foundation

struct FullProfile: Codable {
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
    let certificates: [String]?         // ✅ now handles null or missing
    let years_of_experience: Int?
    let personality_type: String?
    let locations: [String]?            // ✅ now handles null or missing
    let achievements: [String]?         // ✅ same here
    let skillsets: [String]?            // ✅ and here
    let availability: String?
    let clubs: [String]?                // ✅ here too
    let hobbies: [String]?              // ✅ and here
    let connections_count: Int?
}



extension FullProfile {
    var full_name: String {
        "\(first_name) \(last_name)"
    }
}
