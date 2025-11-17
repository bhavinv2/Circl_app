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
                    "Unlimited daily connections (vs 4/day free limit), mentor matches, and Circle creation",
                    "Earn more with 50% less transaction fee at 7% compared to 14% transaction fee",
                    "Full circles dashboard access: Task Manager, KPI Tracking, Calendar and Events feature",
                    "2 free marketplace boosts (30% more visibility, $15 value each)",
                    "Priority Access to future products such as CRM integration and Video call features",
                    "* Must validate student email via profile to qualify for Student+ pricing"
                ]
            ),
            SubscriptionPlan(
                title: "Entrepreneur+",
                price: "$29.99",
                period: "monthly",
                features: [
                    "Unlimited daily connections (vs 4/day free limit), mentor matches, and Circle creation",
                    "Earn more with 50% less transaction fee at 7% compared to 14% transaction fee", 
                    "Full circles dashboard access: Task Manager, KPI Tracking, Calendar and Events feature",
                    "Unlimited job and project listings and monetization (vs 2/month free limit)",
                    "Advanced circle dashboard: Real-time analytics, CRM import/API integration",
                    "2 free marketplace boosts + 1 monthly recurring boost (45% more visibility, $45 value)",
                    "Priority Access to future products such as CRM integration and Video call features",
                    "Advanced search filters: Industry, location, experience level, funding stage"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "FounderX",
                price: "$54.99",
                period: "monthly",
                features: [
                    "Unlimited daily connections (vs 4/day free limit), mentor matches, and Circle creation",
                    "Earn more with 50% less transaction fee at 7% compared to 14% transaction fee",
                    "Full circles dashboard access: Task Manager, KPI Tracking, Calendar and Events feature",
                    "Unlimited job and project listings and monetization (vs 2/month free limit)",
                    "Advanced circle dashboard: Real-time analytics, CRM import/API integration",
                    "2 free marketplace boosts + 2 monthly recurring boosts (60% more visibility, $60 value)",
                    "Early Access to new products including CRM integration and Video call features",
                    "Advanced search filters: Industry, location, experience level, funding stage",
                    "Priority support with 24-hour response guarantee",
                    "Access to 500+ verified investors and exclusive networking events"
                ]
            )
            // Enterprise Gold - Commented out for now
            /*
            SubscriptionPlan(
                title: "Enterprise Gold",
                price: "Pricing Varies",
                period: "", // Intentionally blank; UI hides period when empty
                features: [
                    "Custom ecosystem curation: mentors, investors, marketplace boosts",
                    "Tailored solutions for organizations and teams of 10+ members",
                    "Dedicated support with same-day response and advanced analytics dashboard",
                    "White-label branding options and custom domain setup",
                    "Advanced integrations: Salesforce, HubSpot APIs",
                    "Custom reporting: ROI tracking, team performance, engagement metrics",
                    "Full Access to all products including CRM integration and Video call features",
                    "Dedicated account manager and priority feature development requests"
                ]
            )
            */
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