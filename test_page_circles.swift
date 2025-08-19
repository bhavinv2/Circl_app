import SwiftUI
import Foundation

// MARK: - API Model
struct APICircle: Identifiable, Decodable {
    let id: Int
    let name: String
    let industry: String
    let pricing: String
    let description: String
    let join_type: String
    let channels: [String]?
    let creator_id: Int
    let is_moderator: Bool?
    let member_count: Int?
}

// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""
    
    var body: some View {
        Text("Test")
    }
}
