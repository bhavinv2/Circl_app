import SwiftUI
import Foundation

// MARK: - Subscription Plan Model
struct SubscriptionPlan: Identifiable, Codable {
    let id = UUID()
    let title: String
    let price: String
    let period: String // "monthly", "yearly"
    let features: [String]
    let isPopular: Bool
    let originalPrice: String?
    let discount: String?
    
    init(title: String, price: String, period: String, features: [String], isPopular: Bool = false, originalPrice: String? = nil, discount: String? = nil) {
        self.title = title
        self.price = price
        self.period = period
        self.features = features
        self.isPopular = isPopular
        self.originalPrice = originalPrice
        self.discount = discount
    }
}

// MARK: - Subscription Content Model
struct SubscriptionContent: Codable {
    let userType: UserType
    let backgroundImage: String
    let title: String
    let subtitle: String
    let benefits: [String]
    let plans: [SubscriptionPlan]
    
    init(userType: UserType, backgroundImage: String, title: String, subtitle: String, benefits: [String], plans: [SubscriptionPlan]) {
        self.userType = userType
        self.backgroundImage = backgroundImage
        self.title = title
        self.subtitle = subtitle
        self.benefits = benefits
        self.plans = plans
    }
}

// MARK: - Subscription State
enum SubscriptionState {
    case notShowing
    case showingBackground
    case showingContent
    case completed
    case dismissed
}

// MARK: - Subscription Manager
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isShowingPaywall: Bool = false
    @Published var subscriptionState: SubscriptionState = .notShowing
    @Published var currentContent: SubscriptionContent?
    @Published var selectedPlan: SubscriptionPlan?
    
    private let userDefaults = UserDefaults.standard
    private let hasSeenPaywallKey = "has_seen_paywall"
    private var contentShowWorkItem: DispatchWorkItem?
    
    private init() {
        loadPaywallStatus()
    }
    
    // MARK: - Paywall Management
    func showPaywall(for userType: UserType) {
        print("🎯 PAYWALL SHOW: Starting for \(userType.displayName)")
        print("🎯 PAYWALL SHOW: Current state before: \(subscriptionState)")
        print("🎯 PAYWALL SHOW: isShowingPaywall before: \(isShowingPaywall)")
        
        // Cancel any pending content show operations
        contentShowWorkItem?.cancel()
        
        // If paywall is already showing, just reset content without dismissing modal
        if isShowingPaywall {
            print("🎯 PAYWALL SHOW: Paywall already showing, just updating content")
            subscriptionState = .notShowing
            currentContent = nil
            selectedPlan = nil
            
            // Get new content for user type
            currentContent = createSubscriptionContent(for: userType)
            
            // Restart the sequence
            subscriptionState = .showingBackground
            
            // Create new work item for content showing
            contentShowWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                print("🎯 PAYWALL SHOW: Executing delayed content show (update)")
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.subscriptionState = .showingContent
                }
                print("🎯 PAYWALL SHOW: Set to showingContent (update)")
            }
            
            // Schedule content show after 0.6 seconds
            if let workItem = contentShowWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
            }
        } else {
            // Fresh paywall presentation
            print("🎯 PAYWALL SHOW: Fresh presentation")
            
            // Reset state properly before showing
            subscriptionState = .notShowing
            currentContent = nil
            selectedPlan = nil
            
            print("🎯 PAYWALL SHOW: State reset to notShowing")
            
            // Get content for user type
            currentContent = createSubscriptionContent(for: userType)
            
            // Instantly show full-screen paywall with background only
            subscriptionState = .showingBackground
            isShowingPaywall = true
            
            print("🎯 PAYWALL SHOW: Set to showingBackground, isShowingPaywall = true")
            
            // Create new work item for content showing
            contentShowWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                print("🎯 PAYWALL SHOW: Executing delayed content show (fresh)")
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.subscriptionState = .showingContent
                }
                print("🎯 PAYWALL SHOW: Set to showingContent (fresh)")
            }
            
            // Schedule content show after 0.6 seconds
            if let workItem = contentShowWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
            }
        }
    }
    
    func dismissPaywall() {
        print("🎯 PAYWALL DISMISS: Starting dismissal")
        print("🎯 PAYWALL DISMISS: Current state before: \(subscriptionState)")
        
        // Cancel any pending content show operations
        contentShowWorkItem?.cancel()
        contentShowWorkItem = nil
        
        subscriptionState = .notShowing
        isShowingPaywall = false
        markPaywallAsSeen()
        currentContent = nil
        selectedPlan = nil
        
        print("🎯 PAYWALL DISMISS: Completed, isShowingPaywall = false")
    }
    
    func completeSubscription() {
        subscriptionState = .completed
        isShowingPaywall = false
        markPaywallAsSeen()
        // Handle subscription completion logic here
        print("✅ Subscription completed for plan: \(selectedPlan?.title ?? "Unknown")")
    }
    
    // MARK: - Utility Methods
    func hasSeenPaywall() -> Bool {
        return userDefaults.bool(forKey: hasSeenPaywallKey)
    }
    
    private func markPaywallAsSeen() {
        userDefaults.set(true, forKey: hasSeenPaywallKey)
    }
    
    private func loadPaywallStatus() {
        // Load any saved paywall state if needed
    }
    
    func resetPaywallStatus() {
        userDefaults.removeObject(forKey: hasSeenPaywallKey)
        print("🔄 Paywall status reset")
    }
    
    // MARK: - Convenience Methods
    func showPaywall() {
        // Use the same user type detection as tutorial system
        let onboardingData = gatherOnboardingData()
        let userType = UserType.detectUserType(from: onboardingData)
        showPaywall(for: userType)
    }
    
    private func gatherOnboardingData() -> OnboardingData {
        let usageInterests = UserDefaults.standard.string(forKey: "selected_usage_interest") ?? ""
        let industryInterests = UserDefaults.standard.string(forKey: "selected_industry_interest") ?? ""
        
        return OnboardingData(
            usageInterests: usageInterests,
            industryInterests: industryInterests
        )
    }
}