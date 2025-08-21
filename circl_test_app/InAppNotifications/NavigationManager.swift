import SwiftUI

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var selectedTab: Int = 0
    @Published var navigationTrigger = NavigationTrigger()
    
    private init() {}
    
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
}

struct NavigationTrigger {
    var chatMessageId: Int?
    var channelId: Int?
    var circleId: Int?
    var triggerTime: Date?
}
