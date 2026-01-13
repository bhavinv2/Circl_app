import SwiftUI
import Foundation

// MARK: - Device Detection & Layout Management

class AdaptiveLayoutManager: ObservableObject {
    @Published var horizontalSizeClass: UserInterfaceSizeClass?
    @Published var isSidebarCollapsed: Bool = false
    
    // Device type detection
    var isCompactDevice: Bool {
        horizontalSizeClass == .compact
    }
    
    var isRegularDevice: Bool {
        horizontalSizeClass == .regular
    }
    
    var shouldUseSidebar: Bool {
        isRegularDevice
    }
    
    var shouldUse2ColumnLayout: Bool {
        isRegularDevice
    }
    
    var shouldShowBottomNavigation: Bool {
        isCompactDevice
    }
    
    // Update size class from environment
    func updateSizeClass(_ sizeClass: UserInterfaceSizeClass?) {
        horizontalSizeClass = sizeClass
    }
    
    // Toggle sidebar for regular devices
    func toggleSidebar() {
        guard shouldUseSidebar else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            isSidebarCollapsed.toggle()
        }
    }
}

// MARK: - Navigation Configuration

struct NavigationItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let destination: AnyView
    let badge: String?
    let isCurrentPage: Bool
    
    init<T: View>(
        icon: String,
        title: String,
        destination: T,
        badge: String? = nil,
        isCurrentPage: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.destination = AnyView(destination)
        self.badge = badge
        self.isCurrentPage = isCurrentPage
    }
}

struct AdaptivePageConfiguration {
    let title: String
    let navigationItems: [NavigationItem]
    let supportsCompose: Bool
    let supportsTabs: Bool
    let customHeaderActions: [HeaderAction]
    let showsBottomNavigation: Bool
    
    init(
        title: String,
        navigationItems: [NavigationItem] = [],
        supportsCompose: Bool = false,
        supportsTabs: Bool = false,
        customHeaderActions: [HeaderAction] = [],
        showsBottomNavigation: Bool = true
    ) {
        self.title = title
        self.navigationItems = navigationItems
        self.supportsCompose = supportsCompose
        self.supportsTabs = supportsTabs
        self.customHeaderActions = customHeaderActions
        self.showsBottomNavigation = showsBottomNavigation
    }
}

struct HeaderAction: Identifiable {
    let id = UUID()
    let icon: String
    let action: () -> Void
    let badge: String?
    
    init(icon: String, badge: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.badge = badge
        self.action = action
    }
}

// MARK: - Default Navigation Items

extension AdaptivePageConfiguration {
    static func defaultNavigation(
        currentPageTitle: String,
        unreadMessageCount: Int = 0
    ) -> [NavigationItem] {
        return [
            NavigationItem(
                icon: "house.fill",
                title: "Home",
                destination: PageForum().navigationBarBackButtonHidden(true),
                isCurrentPage: currentPageTitle == "Home"
            ),
            NavigationItem(
                icon: "person.2",
                title: "Network",
                destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true),
                isCurrentPage: currentPageTitle == "Network"
            ),
            NavigationItem(
                icon: "circle.grid.2x2",
                title: "Circles",
                destination: PageCircles().navigationBarBackButtonHidden(true),
                isCurrentPage: currentPageTitle == "Circles"
            ),
            NavigationItem(
                icon: "dollarsign.circle",
                title: "Growth Hub",
                destination: PageSkillSellingPlaceholder().navigationBarBackButtonHidden(true),
                isCurrentPage: currentPageTitle == "Growth Hub"
            ),
            NavigationItem(
                icon: "envelope",
                title: "Messages",
                destination: PageMessages().navigationBarBackButtonHidden(true),
                badge: unreadMessageCount > 0 ? "\(unreadMessageCount)" : nil,
                isCurrentPage: currentPageTitle == "Messages"
            ),
            NavigationItem(
                icon: "gear",
                title: "Settings",
                destination: PageSettings().navigationBarBackButtonHidden(true),
                isCurrentPage: currentPageTitle == "Settings"
            )
        ]
    }
}
