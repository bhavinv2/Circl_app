import Foundation

struct MarketingQuizAnswers {
    var locationPref: String
    var marketingNeed: String
    var targetAudience: String
    var serviceType: String
    var monthlyBudget: String

    var keyword: String {
        return "\(marketingNeed) marketing \(serviceType) for \(targetAudience) in \(locationPref)"
    }
}
