import Foundation

struct SalesQuizAnswers {
    var locationPref: String
    var salesModel: String
    var salesApproach: String
    var crmExperience: String
    var compensationType: String

    var keyword: String {
        var keyword = "\(salesModel) sales team \(salesApproach)"
        if !crmExperience.isEmpty {
            keyword += " with \(crmExperience) experience"
        }
        if !compensationType.isEmpty {
            keyword += " \(compensationType.lowercased())"
        }
        return "\(keyword) in \(locationPref)"
    }
}
