import SwiftUI

// MARK: - Message Model
struct MessageModel: Identifiable, Codable {
    let id: Int
    let sender_id: Int
    let receiver_id: Int
    let content: String
    let timestamp: String
    let is_read: Bool
    var mediaURL: String?  // ✅ Add this
}

// MARK: - Channel Model
struct Channel: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let circleId: Int
    var position: Int
    var isModeratorOnly: Bool? = false
    
    // For decoding from backend that might not include position
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        circleId = try container.decode(Int.self, forKey: .circleId)
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
        isModeratorOnly = try container.decodeIfPresent(Bool.self, forKey: .isModeratorOnly) ?? false  // ✅ decode


    }
    
    // For manual creation
    init(id: Int, name: String, circleId: Int, position: Int = 0, isModeratorOnly: Bool? = false) {
        self.id = id
        self.name = name
        self.circleId = circleId
        self.position = position
        self.isModeratorOnly = isModeratorOnly  // ✅ now it works
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, position
        case circleId = "circle_id"
        case isModeratorOnly = "is_moderator_only"
    }
}

struct ChannelCategoryResponse: Decodable, Identifiable {
    let id: Int?   // null for Uncategorized
    let name: String
    let position: Int
    let channels: [Channel]
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
    let isPrivate: Bool
    var hasDashboard: Bool?
    let duesAmount: Int?
    let hasStripeAccount: Bool?
    let accessCode: String?   // ✅ add this


    
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
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        hasDashboard = try container.decodeIfPresent(Bool.self, forKey: .hasDashboard)


        // Custom decoding for joinType
        let joinTypeString = try container.decode(String.self, forKey: .joinType)
        switch joinTypeString {
        case "apply_now":
            joinType = .applyNow
        case "request_to_join":
            joinType = .requestToJoin
        default:
            joinType = .joinNow
        }

        duesAmount = try container.decodeIfPresent(Int.self, forKey: .duesAmount)
        hasStripeAccount = try container.decodeIfPresent(Bool.self, forKey: .hasStripeAccount)
        accessCode = try container.decodeIfPresent(String.self, forKey: .accessCode)

     

    }
    
    // For manual creation (not from JSON)
    init(
        id: Int,
        name: String,
        industry: String,
        memberCount: Int,
        imageName: String,
        pricing: String,
        description: String,
        joinType: JoinType,
        channels: [String],
        creatorId: Int,
        isModerator: Bool,
        isPrivate: Bool,   // ✅ ADD THIS
        hasDashboard: Bool? = false,
        duesAmount: Int? = nil,
        hasStripeAccount: Bool? = nil,
        accessCode: String? = nil
    ) {
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
        self.isPrivate = isPrivate  // ✅ THIS will now work
        self.hasDashboard = hasDashboard  // ✅ this was missing
        self.duesAmount = duesAmount
        self.hasStripeAccount = hasStripeAccount
        self.accessCode = accessCode   // ✅ assign it
    }

    
    private enum CodingKeys: String, CodingKey {
        case id, name, industry, memberCount, imageName, pricing, description, joinType, channels, creatorId, isModerator, isPrivate, hasDashboard
        case duesAmount = "dues_amount"  // ✅ FIXED HERE
        case hasStripeAccount = "has_stripe_account"
        case accessCode = "access_code"   // ✅ match backend key
    }


}

struct CategoryWithChannels: Identifiable {
    let id: Int?   // nil for "Uncategorized"
    let name: String
    let position: Int
    var channels: [Channel]
}

struct ChannelCategory: Identifiable, Codable {
    let id: Int?
    let name: String
    let position: Int
    let channels: [Channel]
    
    // Manual initializer for creating updated instances
    init(id: Int?, name: String, position: Int, channels: [Channel]) {
        self.id = id
        self.name = name
        self.position = position
        self.channels = channels
    }
}
