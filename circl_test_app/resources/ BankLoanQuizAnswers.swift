struct BankLoanQuizAnswers {
    var locationPref: String
    var loanPurpose: String
    var loanTerm: String
    var collateralAvailable: Bool

    var keyword: String {
        var keyword = "\(loanPurpose) loan lender"
        if !loanTerm.isEmpty {
            keyword += " \(loanTerm.lowercased()) term"
        }
        if collateralAvailable {
            keyword += " with collateral"
        }
        return "\(keyword) in \(locationPref)"
    }
}
