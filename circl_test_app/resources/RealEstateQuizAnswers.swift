import Foundation

struct RealEstateQuizAnswers {
    var locationPref: String
    var spaceType: String
    var leaseOrBuy: String
    var regionPreference: String
    var squareFootage: String

    var keyword: String {
        var keyword = "\(spaceType) space real estate \(leaseOrBuy) in \(locationPref)"
        return keyword
    }
}
