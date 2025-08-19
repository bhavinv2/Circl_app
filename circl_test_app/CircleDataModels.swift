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
    var position: Int
    
    // For decoding from backend that might not include position
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        circleId = try container.decode(Int.self, forKey: .circleId)
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
    }
    
    // For manual creation
    init(id: Int, name: String, circleId: Int, position: Int = 0) {
        self.id = id
        self.name = name
        self.circleId = circleId
        self.position = position
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, position
        case circleId = "circle_id"
    }
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
<<<<<<< Updated upstream:circl_test_app/CircleDataModels.swift
=======
    let isPrivate: Bool
    let accessCode: String?
    var hasDashboard: Bool?
    let duesAmount: Int?
    let hasStripeAccount: Bool?
    let profileImageURL: String?



>>>>>>> Stashed changes:circl_test_app/circles/CircleDataModels.swift
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        industry = try container.decodeIfPresent(String.self, forKey: .industry) ?? ""
        memberCount = try container.decodeIfPresent(Int.self, forKey: .memberCount) ?? 0
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        pricing = try container.decodeIfPresent(String.self, forKey: .pricing) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        channels = try container.decodeIfPresent([String].self, forKey: .channels) ?? []
        creatorId = try container.decode(Int.self, forKey: .creatorId)
        isModerator = try container.decode(Bool.self, forKey: .isModerator)
<<<<<<< Updated upstream:circl_test_app/CircleDataModels.swift
        
        // Custom decoding for joinType
        let joinTypeString = try container.decode(String.self, forKey: .joinType)
        joinType = joinTypeString == "apply_now" ? JoinType.applyNow : JoinType.joinNow
    }
    
    // For manual creation (not from JSON)
    init(id: Int, name: String, industry: String, memberCount: Int, imageName: String, pricing: String, description: String, joinType: JoinType, channels: [String], creatorId: Int, isModerator: Bool) {
=======
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        accessCode = try container.decodeIfPresent(String.self, forKey: .accessCode)
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
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
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
        accessCode: String? = nil,
        hasDashboard: Bool? = false,
        duesAmount: Int? = nil,
        hasStripeAccount: Bool? = nil,
        profileImageURL: String? = nil
    ) {
>>>>>>> Stashed changes:circl_test_app/circles/CircleDataModels.swift
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
<<<<<<< Updated upstream:circl_test_app/CircleDataModels.swift
=======
        self.isPrivate = isPrivate  // ✅ THIS will now work
        self.accessCode = accessCode
        self.hasDashboard = hasDashboard  // ✅ this was missing
        self.duesAmount = duesAmount
        self.hasStripeAccount = hasStripeAccount
        self.profileImageURL = profileImageURL
>>>>>>> Stashed changes:circl_test_app/circles/CircleDataModels.swift
    }
    
    private enum CodingKeys: String, CodingKey {
<<<<<<< Updated upstream:circl_test_app/CircleDataModels.swift
        case id, name, industry, memberCount, imageName, pricing, description, joinType, channels, creatorId, isModerator
    }
}
=======
        case id, name, industry, pricing, description, channels
        case memberCount = "member_count"
        case imageName = "image_name"
        case joinType = "join_type"
        case creatorId = "creator_id"
        case isModerator = "is_moderator"
        case isPrivate = "is_private"
        case accessCode = "access_code"
        case hasDashboard = "has_dashboard"
        case duesAmount = "dues_amount"
        case hasStripeAccount = "has_stripe_account"
        case profileImageURL = "profile_image_url"
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
}
>>>>>>> Stashed changes:circl_test_app/circles/CircleDataModels.swift
