struct AccountantsQuizAnswers {
    var locationPref: String
    var businessStructure: String
    var serviceNeed: String
    var industryExperience: Bool
    var serviceFrequency: String

    var keyword: String {
        var base = "\(serviceNeed) accountant for \(businessStructure) in \(locationPref)"
        if industryExperience {
            base += " with industry tax experience"
        }
        return base
    }
}
