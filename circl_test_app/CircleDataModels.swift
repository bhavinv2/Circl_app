import SwiftUI

// MARK: - Message Model
struct MessageModel: Identifiable, Codable {
    let id: Int
    let sender_id: Int
    let receiver_id: Int
    let content: String
    let timestamp: String
    let is_read: Bool
}

// MARK: - Channel Model
struct Channel: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let circleId: Int
}

// MARK: - Circle Data
enum JoinType: String, CaseIterable {
    case applyNow = "Apply Now"
    case joinNow = "Join Now"
    case requestToJoin = "Request to Join"
}

struct CircleData: Identifiable, Decodable {
    let id: Int
    let name: String
    let industry: String
    var memberCount: Int
    let imageName: String
    let pricing: String
    let description: String
    let joinType: JoinType
    let channels: [String]
    let creatorId: Int
    let isModerator: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        industry = try container.decode(String.self, forKey: .industry)
        memberCount = try container.decode(Int.self, forKey: .memberCount)
        imageName = try container.decode(String.self, forKey: .imageName)
        pricing = try container.decode(String.self, forKey: .pricing)
        description = try container.decode(String.self, forKey: .description)
        channels = try container.decode([String].self, forKey: .channels)
        creatorId = try container.decode(Int.self, forKey: .creatorId)
        isModerator = try container.decode(Bool.self, forKey: .isModerator)
        
        // Custom decoding for joinType
        let joinTypeString = try container.decode(String.self, forKey: .joinType)
        joinType = joinTypeString == "apply_now" ? JoinType.applyNow : JoinType.joinNow
    }
    
    // For manual creation (not from JSON)
    init(id: Int, name: String, industry: String, memberCount: Int, imageName: String, pricing: String, description: String, joinType: JoinType, channels: [String], creatorId: Int, isModerator: Bool) {
        self.id = id
        self.name = name
        self.industry = industry
        self.memberCount = memberCount
        self.imageName = imageName
        self.pricing = pricing
        self.description = description
        self.joinType = joinType
        self.channels = channels
        self.creatorId = creatorId
        self.isModerator = isModerator
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, industry, memberCount, imageName, pricing, description, joinType, channels, creatorId, isModerator
    }
}