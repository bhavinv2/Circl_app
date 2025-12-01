import SwiftUI

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var selectedTab: Int = 0 {
        didSet {
            print("🧭 NavigationManager: selectedTab changed from \(oldValue) to \(selectedTab)")
            // Force objectWillChange to ensure SwiftUI updates
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    @Published var navigationTrigger = NavigationTrigger()
    
    private init() {
        print("🧭 NavigationManager initialized with selectedTab = \(selectedTab)")
    }
    
    func navigateToChat(messageId: Int) {
        selectedTab = 1 // Assuming messages tab is index 1
        navigationTrigger.chatMessageId = messageId
        navigationTrigger.triggerTime = Date()
    }
    
    func navigateToChannel(channelId: Int, circleId: Int) {
        selectedTab = 2 // Assuming circles tab is index 2
        navigationTrigger.channelId = channelId
        navigationTrigger.circleId = circleId
        navigationTrigger.triggerTime = Date()
    }
    
    func navigateToNetwork() {
        selectedTab = 1 // Network tab
        navigationTrigger.triggerTime = Date()
    }
    
    func navigateToCircles() {
        selectedTab = 2 // Circles tab
        navigationTrigger.triggerTime = Date()
    }
    
    func navigateToCircle(circleId: Int) {
        selectedTab = 2 // Circles tab
        navigationTrigger.circleId = circleId
        navigationTrigger.triggerTime = Date()
    }
    
    func navigateToForum() {
        print("🧭 NavigateToForum called - setting selectedTab to 0")
        selectedTab = 0 // Forum tab (assuming it's the first tab)
        navigationTrigger.shouldNavigateToForum = true
        navigationTrigger.triggerTime = Date()
    }
    
    // Debug method to check NavigationManager state
    func debugNavigationState() {
        print("🧭 NavigationManager Debug State:")
        print("   • selectedTab: \(selectedTab)")
        print("   • navigationTrigger.shouldNavigateToForum: \(navigationTrigger.shouldNavigateToForum)")
        print("   • navigationTrigger.triggerTime: \(navigationTrigger.triggerTime?.description ?? "nil")")
    }
    
    // Reset navigation state (for troubleshooting)
    func resetNavigationState() {
        print("🔄 Resetting NavigationManager state")
        selectedTab = 0
        navigationTrigger = NavigationTrigger()
        print("✅ NavigationManager reset complete - selectedTab = \(selectedTab)")
    }
    
    // Force navigation with SwiftUI refresh
    func forceNavigateTo(tab: Int) {
        print("🔄 Force navigating to tab \(tab)")
        
        // Update on main thread
        DispatchQueue.main.async {
            self.selectedTab = tab
            
            // Additional force refresh
            self.objectWillChange.send()
            
            // Update navigation trigger to ensure UI refresh
            self.navigationTrigger.triggerTime = Date()
        }
    }
}

struct NavigationTrigger {
    var chatMessageId: Int?
    var channelId: Int?
    var circleId: Int?
    var shouldNavigateToForum: Bool = false
    var triggerTime: Date?
}
