import SwiftUI
import Foundation

// MARK: - Subscription Content Factory
extension SubscriptionManager {
    
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
    
    // MARK: - Entrepreneur Subscription
    private func createEntrepreneurSubscription() -> SubscriptionContent {
        let plans = [
            SubscriptionPlan(
                title: "Entrepreneur Pro",
                price: "$29",
                period: "monthly",
                features: [
                    "Unlimited co-founder searches",
                    "Advanced business profile features",
                    "Priority mentor matching",
                    "Exclusive investor network access",
                    "Business analytics dashboard",
                    "Premium circle creation tools"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "Entrepreneur Pro Annual",
                price: "$249",
                period: "yearly",
                features: [
                    "Everything in Pro Monthly",
                    "2 months free (save $99)",
                    "Exclusive annual events",
                    "1-on-1 strategy sessions",
                    "Advanced pitch deck reviews"
                ],
                originalPrice: "$348",
                discount: "Save 28%"
            )
        ]
        
        return SubscriptionContent(
            userType: .entrepreneur,
            backgroundImage: "EntrepreneurPaywall",
            title: "Unlock Your Startup Potential",
            subtitle: "Join thousands of successful entrepreneurs who've accelerated their journey with Circl Pro",
            benefits: [
                "🚀 Find the perfect co-founder faster",
                "💰 Connect with qualified investors",
                "🎯 Access exclusive startup resources",
                "📈 Track your networking ROI",
                "🏆 Join elite founder communities"
            ],
            plans: plans
        )
    }
    
    // MARK: - Student Subscription
    private func createStudentSubscription() -> SubscriptionContent {
        let plans = [
            SubscriptionPlan(
                title: "Student Plus",
                price: "$9",
                period: "monthly",
                features: [
                    "Unlimited mentor matching",
                    "Access to real company projects",
                    "Higher commission rates",
                    "Business & startup job board",
                    "Unlimited circle networking"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "Student Plus Annual",
                price: "$79",
                period: "yearly",
                features: [
                    "Everything in Student Monthly",
                    "3 months free (save $27)",
                    "Priority project assignments",
                    "Career coaching sessions",
                    "Portfolio building workshops"
                ],
                originalPrice: "$108",
                discount: "Save 27%"
            )
        ]
        
        return SubscriptionContent(
            userType: .student,
            backgroundImage: "StudentPaywall",
            title: "Accelerate Your Future",
            subtitle: "Build your future with relevant experience, not just a degree",
            benefits: [
                "💼 Work on real company projects",
                "💰 Higher commission on paid projects",
                "� Business & startup job search access",
                "🌐 Unlimited circle access for networking",
                "👥 Match with unlimited mentors",
                "� Build an impressive project portfolio"
            ],
            plans: plans
        )
    }
    
    // MARK: - Student Entrepreneur Subscription
    private func createStudentEntrepreneurSubscription() -> SubscriptionContent {
        let plans = [
            SubscriptionPlan(
                title: "Student Entrepreneur Pro",
                price: "$19",
                period: "monthly",
                features: [
                    "Unlimited co-founder searches",
                    "Student startup resources",
                    "Mentor matching system",
                    "Campus entrepreneurship events",
                    "Pitch competition access",
                    "Student discount marketplace"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "Student Entrepreneur Annual",
                price: "$179",
                period: "yearly",
                features: [
                    "Everything in Monthly Pro",
                    "4 months free (save $57)",
                    "Summer accelerator program",
                    "Exclusive founder workshops",
                    "1-on-1 mentorship sessions"
                ],
                originalPrice: "$228",
                discount: "Save 21%"
            )
        ]
        
        return SubscriptionContent(
            userType: .studentEntrepreneur,
            backgroundImage: "StudentEntrepreneurPaywall",
            title: "Launch Your Startup Journey",
            subtitle: "Bridge the gap between student life and entrepreneurial success",
            benefits: [
                "🎓 Student-focused entrepreneurship tools",
                "� Find co-founders on campus",
                "💡 Access startup competitions",
                "🤝 Connect with fellow student founders",
                "📈 Build your venture while studying"
            ],
            plans: plans
        )
    }
    
    // MARK: - Mentor Subscription
    private func createMentorSubscription() -> SubscriptionContent {
        let plans = [
            SubscriptionPlan(
                title: "Mentor Elite",
                price: "$39",
                period: "monthly",
                features: [
                    "Enhanced mentee matching",
                    "Monetization tools",
                    "Session scheduling system",
                    "Impact analytics",
                    "Mentor community access"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "Mentor Elite Annual",
                price: "$349",
                period: "yearly",
                features: [
                    "Everything in Elite Monthly",
                    "4 months free (save $119)",
                    "Speaking opportunities",
                    "Thought leadership platform"
                ],
                originalPrice: "$468",
                discount: "Save 25%"
            )
        ]
        
        return SubscriptionContent(
            userType: .mentor,
            backgroundImage: "MentorPaywall",
            title: "Amplify Your Impact",
            subtitle: "Help more entrepreneurs succeed while growing your influence",
            benefits: [
                "🎯 Find ideal mentees efficiently",
                "💰 Monetize your expertise",
                "📈 Track your mentoring impact",
                "🏆 Join elite mentor network",
                "📢 Expand your thought leadership"
            ],
            plans: plans
        )
    }
    
    // MARK: - Community Builder Subscription
    private func createCommunityBuilderSubscription() -> SubscriptionContent {
        let plans = [
            SubscriptionPlan(
                title: "Community Builder Pro",
                price: "$25",
                period: "monthly",
                features: [
                    "Unlimited circle creation",
                    "Advanced community tools",
                    "Event management system",
                    "Community analytics dashboard",
                    "Priority community support",
                    "Custom branding options"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "Community Builder Annual",
                price: "$249",
                period: "yearly",
                features: [
                    "Everything in Pro Monthly",
                    "3 months free (save $51)",
                    "Exclusive builder workshops",
                    "Advanced moderation tools",
                    "White-label options"
                ],
                originalPrice: "$300",
                discount: "Save 17%"
            )
        ]
        
        return SubscriptionContent(
            userType: .communityBuilder,
            backgroundImage: "CommunityBuilderPaywall",
            title: "Build Thriving Communities",
            subtitle: "Create and manage powerful professional communities",
            benefits: [
                "🏗️ Build unlimited communities",
                "📊 Track community engagement",
                "� Advanced member management",
                "🎪 Host exclusive events",
                "� Monetize your community"
            ],
            plans: plans
        )
    }
    
    // MARK: - Investor Subscription
    private func createInvestorSubscription() -> SubscriptionContent {
        let plans = [
            SubscriptionPlan(
                title: "Investor Pro",
                price: "$39",
                period: "monthly",
                features: [
                    "Premium deal flow access",
                    "Advanced founder search filters",
                    "Direct messaging with founders",
                    "Investment analytics dashboard",
                    "Due diligence collaboration tools",
                    "Priority support"
                ],
                isPopular: true
            ),
            SubscriptionPlan(
                title: "Investor Annual",
                price: "$390",
                period: "yearly",
                features: [
                    "Everything in Pro Monthly",
                    "3 months free (save $78)",
                    "Exclusive investor events",
                    "Advanced portfolio tracking",
                    "Custom investment reports"
                ],
                originalPrice: "$468",
                discount: "Save 17%"
            )
        ]
        
        return SubscriptionContent(
            userType: .investor,
            backgroundImage: "InvestorPaywall",
            title: "Discover Quality Deal Flow",
            subtitle: "Connect directly with vetted entrepreneurs and startups",
            benefits: [
                "💼 Access curated startup deals",
                "🎯 Connect with verified founders", 
                "📈 Track investment opportunities",
                "🤝 Collaborate with co-investors",
                "📊 Get comprehensive analytics"
            ],
            plans: plans
        )
    }
}