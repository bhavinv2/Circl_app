import Foundation

struct ConsultantQuizAnswers {
    var locationPref: String
    var areaOfFocus: String
    var industry: String
    var startupExperience: Bool
    var engagementLength: String

    var keyword: String {
        var keyword = "\(areaOfFocus) business consultant"
        if !industry.isEmpty {
            keyword += " for \(industry)"
        }
        if !engagementLength.isEmpty {
            keyword += " \(engagementLength.lowercased())"
        }
        if startupExperience {
            keyword += " with startup experience"
        }
        return "\(keyword) in \(locationPref)"
    }
}
