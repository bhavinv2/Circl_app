import Foundation

struct ManufacturingQuizAnswers {
    var locationPref: String
    var productType: String
    var productionVolume: String
    var locationPreference: String
    var priority: String

    var keyword: String {
        return "\(productionVolume) \(productType) manufacturer \(locationPreference) focused on \(priority) in \(locationPref)"
    }
}
