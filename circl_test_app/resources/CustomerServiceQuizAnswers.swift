import Foundation

struct CustomerServiceQuizAnswers {
    var locationPref: String
    var serviceType: String
    var volume: String
    var availability24_7: Bool
    var languageSupport: String

    var keyword: String {
        var keyword = "\(serviceType) customer service for \(volume) volume"
        if !languageSupport.isEmpty {
            keyword += " with \(languageSupport) support"
        }
        if availability24_7 {
            keyword += " 24/7"
        }
        return "\(keyword) in \(locationPref)"
    }
}
