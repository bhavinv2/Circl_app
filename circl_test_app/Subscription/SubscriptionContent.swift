import SwiftUI
import Foundation

// MARK: - Subscription Content Factory
extension SubscriptionManager {
    
    // MARK: - Universal Plans (Student+, Entrepreneur+, FounderX, Enterprise)
    private func universalPlans() -> [SubscriptionPlan] {
        return [
            SubscriptionPlan(
                title: "Student+",
                price: "$7.99",
                period: "monthly",
                features: [
                    "Unlimited connections, mentor matches, and Circle creation",
                    "Lower marketplace commission: 7% transaction fee",
                    "Full dashboard access, including KPI tracking and CRM integration (for marketplace projects)",
                    "2 free marketplace boosts",
                    "1 free investor spotlight boost"
                ]
            ),
            SubscriptionPlan(
                title: "Entrepreneur+",
                price: "$29.99",
                period: "monthly",
                features: [
                    "Unlimited connections, mentor matches, and Circle creation",
                    "Lower marketplace commission: 7% transaction fee", 
                    "Full dashboard access, including KPI tracking and CRM integration",
                    "Unlimited job and project listings and monetization",
                    "Advanced circle dashboard: KPI tracking, CRM import/API",
                    "2 free marketplace boosts",
                    "1 free investor spotlight boost"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "FounderX",
                price: "$54.99",
                period: "monthly",
                features: [
                    "Unlimited connections, mentor matches, and Circle creation",
                    "Lower marketplace commission: 7% transaction fee",
                    "Full dashboard access, including KPI tracking and CRM integration", 
                    "Unlimited job and project listings and monetization",
                    "Advanced circle dashboard: KPI tracking, CRM import/API",
                    "2 free marketplace boosts",
                    "1 free investor spotlight boost",
                    "Priority support and exclusive founder resources",
                    "Enhanced investor access and networking opportunities"
                ]
            ),
            SubscriptionPlan(
                title: "Enterprise Gold",
                price: "Pricing Varies",
                period: "", // Intentionally blank; UI hides period when empty
                features: [
                    "Custom ecosystem curation: mentors, investors, marketplace boosts",
                    "Tailored solutions for organizations and businesses",
                    "Dedicated support and advanced analytics",
                    "White-label branding options",
                    "Advanced integrations and API access",
                    "Custom reporting and insights"
                ]
            )
        ]
    }
    
    // MARK: - Content Creation
    func createSubscriptionContent(for userType: UserType) -> SubscriptionContent {
        switch userType {
        case .entrepreneur:
            return createEntrepreneurSubscription()
        case .student:
            return createStudentSubscription()
        case .studentEntrepreneur:
            return createStudentEntrepreneurSubscription()
        case .mentor:
            return createMentorSubscription()
        case .communityBuilder:
            return createCommunityBuilderSubscription()
        case .investor:
            return createInvestorSubscription()
        case .other:
            // .other should not be used in normal flow - detectUserType() always returns a specific type
            // If this case is hit, there's a logic error. Log it and fallback to appropriate subscription
            print("⚠️ WARNING: .other user type detected in subscription flow - this should not happen")
            print("🔧 Check detectUserType() logic in TutorialModels.swift")
            return createCommunityBuilderSubscription() // Safe fallback, but investigate why this happened
        }
    }
    
    // MARK: - Entrepreneur Subscription (uses universal plans)
    private func createEntrepreneurSubscription() -> SubscriptionContent {
        let plans = universalPlans()
        
        return SubscriptionContent(
            userType: .entrepreneur,
            backgroundImage: "EntrepreneurPaywall",
            title: "Take Control Of Your Future",
            subtitle: "Circl is designed to be your success command center",
            benefits: [],
            plans: plans
        )
    }
    
    // MARK: - Student Subscription (uses universal plans)
    private func createStudentSubscription() -> SubscriptionContent {
        let plans = universalPlans()
        
        return SubscriptionContent(
            userType: .student,
            backgroundImage: "StudentPaywall",
            title: "Take Control Of Your Future",
            subtitle: "Circl is designed to be your success command center",
            benefits: [],
            plans: plans
        )
    }
    
    // MARK: - Student Entrepreneur Subscription (uses universal plans)
    private func createStudentEntrepreneurSubscription() -> SubscriptionContent {
        let plans = universalPlans()
        
        return SubscriptionContent(
            userType: .studentEntrepreneur,
            backgroundImage: "StudentEntrepreneurPaywall",
            title: "Take Control Of Your Future",
            subtitle: "Circl is designed to be your success command center",
            benefits: [],
            plans: plans
        )
    }
    
    // MARK: - Mentor Subscription (uses universal plans)
    private func createMentorSubscription() -> SubscriptionContent {
        let plans = universalPlans()
        
        return SubscriptionContent(
            userType: .mentor,
            backgroundImage: "MentorPaywall",
            title: "Take Control Of Your Future",
            subtitle: "Circl is designed to be your success command center",
            benefits: [],
            plans: plans
        )
    }
    
    // MARK: - Community Builder Subscription (uses universal plans)
    private func createCommunityBuilderSubscription() -> SubscriptionContent {
        let plans = universalPlans()
        
        return SubscriptionContent(
            userType: .communityBuilder,
            backgroundImage: "CommunityBuilderPaywall",
            title: "Take Control Of Your Future",
            subtitle: "Circl is designed to be your success command center",
            benefits: [],
            plans: plans
        )
    }
    
    // MARK: - Investor Subscription (temporarily uses universal plans)
    private func createInvestorSubscription() -> SubscriptionContent {
        // NOTE: Dedicated Investor plan is a future offering. For now, show universal plans.
        let plans = universalPlans()
        
        return SubscriptionContent(
            userType: .investor,
            backgroundImage: "InvestorPaywall",
            title: "Take Control Of Your Future",
            subtitle: "Circl is designed to be your success command center",
            benefits: [],
            plans: plans
        )
    }
}