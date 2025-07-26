import Foundation

struct InsuranceQuizAnswers {
    var locationPref: String
    var typeOfCoverage: String
    var industryRisks: String
    var budget: String
    var levelOfCoverage: String

    var keyword: String {
        var keyword = "\(typeOfCoverage) insurance"
        if !industryRisks.isEmpty {
            keyword += " for \(industryRisks) business"
        }
        if !levelOfCoverage.isEmpty {
            keyword += " \(levelOfCoverage.lowercased())"
        }
        return "\(keyword) in \(locationPref)"
    }
}
