struct LegalQuizAnswers {
    var locationPref: String
    var legalNeeds: String
    var specialization: String
    var startupExperience: Bool
    var pricingModel: String

    var keyword: String {
        var base = ""

        if legalNeeds.lowercased().contains("ip") || specialization.lowercased().contains("trademark") || specialization.lowercased().contains("patent") {
            base = "IP law firm"
        } else if legalNeeds.lowercased().contains("compliance") {
            base = "business compliance attorney"
        } else if legalNeeds.lowercased().contains("contracts") {
            base = "business contract lawyer"
        } else if legalNeeds.lowercased().contains("formation") {
            base = "startup formation lawyer"
        } else {
            base = "business lawyer"
        }

        return "\(base) \(locationPref)"
    }
}
