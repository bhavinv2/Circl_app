import Foundation

struct HRQuizAnswers {
    var locationPref: String
    var hrNeed: String
    var employeeCount: String
    var deliveryType: String
    var complianceNeed: String

    var keyword: String {
        return "\(hrNeed) HR \(deliveryType) for \(complianceNeed) compliance in \(locationPref)"
    }
}
