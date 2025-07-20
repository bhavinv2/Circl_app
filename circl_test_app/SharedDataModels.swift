//
//  SharedDataModels.swift
//  circl_test_app
//
//  Shared data models used across multiple pages for consistent typing
//

import Foundation

// MARK: - Data Models

/// Model for mentor profile data from the mentors API
struct MentorProfileData: Identifiable, Codable {
    var id: Int { user_id }
    let user_id: Int
    let name: String
    let username: String
    let title: String
    let company: String
    let proficiency: String
    let tags: [String]
    let email: String
    let profileImage: String?
    
    // Standard initializer for manual creation
    init(user_id: Int, name: String, username: String, title: String, 
         company: String, proficiency: String, tags: [String], 
         email: String, profileImage: String?) {
        self.user_id = user_id
        self.name = name
        self.username = username
        self.title = title
        self.company = company
        self.proficiency = proficiency
        self.tags = tags
        self.email = email
        self.profileImage = profileImage
    }
}

/// Model for invite/friend request profile data
struct InviteProfileData: Identifiable, Codable {
    let id = UUID()
    let user_id: Int
    let name: String
    let username: String
    let email: String
    let title: String
    let company: String
    let proficiency: String
    let tags: [String]
    let profileImage: String?
    
    // Manual initializer
    init(user_id: Int, name: String, username: String, email: String, 
         title: String, company: String, proficiency: String, 
         tags: [String], profileImage: String?) {
        self.user_id = user_id
        self.name = name
        self.username = username
        self.email = email
        self.title = title
        self.company = company
        self.proficiency = proficiency
        self.tags = tags
        self.profileImage = profileImage
    }
    
    enum CodingKeys: String, CodingKey {
        case user_id, name, username, email, title, company, proficiency, tags, profileImage
    }
}

/// Model for entrepreneur profile data from the entrepreneurs API
struct SharedEntrepreneurProfileData: Identifiable, Codable {
    var id: Int { user_id }
    let user_id: Int
    let name: String
    let email: String
    let username: String
    let profileImage: String?
    let businessName: String
    let businessStage: String
    let businessIndustry: String
    let businessBio: String
    let fundingRaised: String
    let lookingFor: [String]
    let isMentor: Bool
    
    // Standard initializer for manual creation
    init(user_id: Int, name: String, email: String, username: String, profileImage: String?, 
         businessName: String, businessStage: String, businessIndustry: String, 
         businessBio: String, fundingRaised: String, lookingFor: [String], 
         isMentor: Bool) {
        self.user_id = user_id
        self.name = name
        self.email = email
        self.username = username
        self.profileImage = profileImage
        self.businessName = businessName
        self.businessStage = businessStage
        self.businessIndustry = businessIndustry
        self.businessBio = businessBio
        self.fundingRaised = fundingRaised
        self.lookingFor = lookingFor
        self.isMentor = isMentor
    }
    
    // Computed properties for compatibility with MentorProfileData  
    var title: String { businessStage }
    var company: String { businessName }
    var proficiency: String { businessIndustry }
    var tags: [String] { lookingFor }
    
    // Custom CodingKeys to exclude computed properties
    private enum CodingKeys: String, CodingKey {
        case user_id, name, email, username, profileImage, businessName, businessStage
        case businessIndustry, businessBio, fundingRaised, lookingFor, isMentor
    }
}

// MARK: - Response Models

/// API response model for network/friends data
struct NetworkResponseModel: Codable {
    let success: Bool
    let users: [InviteProfileData]
}

/// API response model for invite data
struct InviteResponseModel: Codable {
    let success: Bool
    let users: [InviteProfileData]
}

/// API response model for entrepreneurs data
struct EntrepreneurResponseModel: Codable {
    let success: Bool
    let entrepreneurs: [SharedEntrepreneurProfileData]
}

/// API response model for mentors data
struct MentorResponseModel: Codable {
    let success: Bool
    let mentors: [MentorProfileData]
}
