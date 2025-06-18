import Foundation

struct Channel: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let circleId: Int
}
