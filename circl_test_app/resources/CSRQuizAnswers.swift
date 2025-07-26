import Foundation

struct CSRQuizAnswers {
    var locationPref: String
    var csrFocus: String
    var industryGoals: String
    var reportingMethod: String
    var budget: String

    var keyword: String {
        return "\(csrFocus) CSR team for \(industryGoals) with \(reportingMethod) reporting in \(locationPref)"
    }
}
