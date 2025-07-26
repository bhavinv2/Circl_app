import Foundation

struct MentalHealthQuizAnswers {
    var locationPref: String
    var supportType: String
    var serviceType: String
    var deliveryType: String
    var budget: String

    var keyword: String {
        return "\(supportType) mental health \(serviceType) \(deliveryType) in \(locationPref)"
    }
}
