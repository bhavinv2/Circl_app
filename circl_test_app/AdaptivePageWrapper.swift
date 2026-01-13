import SwiftUI

// MARK: - Main Adaptive Page Wrapper

struct AdaptivePageWrapper<Content: View>: View {
    let title: String
    let navigationItems: [NavigationItem]
    let supportsCompose: Bool
    let supportsTabs: Bool
    let customHeaderActions: [HeaderAction]
    let content: Content
    
    private var configuration: AdaptivePageConfiguration {
        AdaptivePageConfiguration(
            title: title,
            navigationItems: navigationItems,
            supportsCompose: supportsCompose,
            supportsTabs: supportsTabs,
            customHeaderActions: customHeaderActions
        )
    }
    
    init(
        title: String,
        navigationItems: [NavigationItem]? = nil,
        supportsCompose: Bool = false,
        supportsTabs: Bool = false,
        customHeaderActions: [HeaderAction] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.navigationItems = navigationItems ?? AdaptivePageConfiguration.defaultNavigation(currentPageTitle: title)
        self.supportsCompose = supportsCompose
        self.supportsTabs = supportsTabs
        self.customHeaderActions = customHeaderActions
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            AdaptiveContentWrapper(configuration: configuration) {
                content
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}

// MARK: - Convenience Initializers

extension AdaptivePageWrapper {
    // Simple page wrapper with just title
    static func simple<T: View>(
        title: String,
        @ViewBuilder content: @escaping () -> T
    ) -> AdaptivePageWrapper<T> {
        AdaptivePageWrapper<T>(title: title) {
            content()
        }
    }
    
    // Page wrapper with custom navigation
    static func withNavigation<T: View>(
        title: String,
        navigationItems: [NavigationItem],
        @ViewBuilder content: @escaping () -> T
    ) -> AdaptivePageWrapper<T> {
        AdaptivePageWrapper<T>(
            title: title,
            navigationItems: navigationItems
        ) {
            content()
        }
    }
    
    // Forum-style page with compose support
    static func forum<T: View>(
        title: String,
        @ViewBuilder content: @escaping () -> T
    ) -> AdaptivePageWrapper<T> {
        AdaptivePageWrapper<T>(
            title: title,
            supportsCompose: true,
            supportsTabs: true
        ) {
            content()
        }
    }
    
    // Page with custom header actions
    static func withHeaderActions<T: View>(
        title: String,
        headerActions: [HeaderAction],
        @ViewBuilder content: @escaping () -> T
    ) -> AdaptivePageWrapper<T> {
        AdaptivePageWrapper<T>(
            title: title,
            customHeaderActions: headerActions
        ) {
            content()
        }
    }
}

// MARK: - Helper View for Easy Migration

struct AdaptivePage<Content: View>: View {
    let title: String
    let content: Content
    let unreadMessageCount: Int
    
    init(title: String, unreadMessageCount: Int = 0, @ViewBuilder content: () -> Content) {
        self.title = title
        self.unreadMessageCount = unreadMessageCount
        self.content = content()
    }
    
    var body: some View {
        AdaptivePageWrapper(
            title: title,
            customHeaderActions: unreadMessageCount > 0 ? [
                HeaderAction(
                    icon: "envelope",
                    badge: "\(unreadMessageCount)"
                ) {
                    // Navigate to messages
                }
            ] : []
        ) {
            content
        }
    }
}

// MARK: - Grid Layout Helper for Adaptive Content

struct AdaptiveGrid<Content: View>: View {
    let content: Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // Two-column layout for iPad/Mac
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                content
            }
            .padding(.horizontal, 20)
        } else {
            // Single column for iPhone
            LazyVStack(spacing: 0) {
                content
            }
        }
    }
}

// MARK: - Usage Examples (for documentation)

/*
// MARK: - Usage Examples

// 1. Simple page conversion:
struct MyPage: View {
    var body: some View {
        AdaptivePage(title: "My Page") {
            // Your existing content here
            Text("Page content")
        }
    }
}

// 2. Page with custom navigation:
struct MyCustomPage: View {
    var body: some View {
        AdaptivePageWrapper.withNavigation(
            title: "Custom Page",
            navigationItems: [
                NavigationItem(icon: "house", title: "Home", destination: HomePage()),
                NavigationItem(icon: "gear", title: "Settings", destination: SettingsPage())
            ]
        ) {
            Text("Custom navigation content")
        }
    }
}

// 3. Forum-style page:
struct MyForumPage: View {
    var body: some View {
        AdaptivePageWrapper.forum(title: "Forum") {
            // Your forum content with compose support
            ForumContentView()
        }
    }
}

// 4. Page with header actions:
struct MyActionPage: View {
    var body: some View {
        AdaptivePageWrapper.withHeaderActions(
            title: "Actions",
            headerActions: [
                HeaderAction(icon: "bell", badge: "3") {
                    // Handle notifications
                },
                HeaderAction(icon: "plus") {
                    // Add new item
                }
            ]
        ) {
            Text("Content with header actions")
        }
    }
}

// 5. Adaptive grid content:
struct MyGridPage: View {
    var body: some View {
        AdaptivePage(title: "Grid Page") {
            ScrollView {
                AdaptiveGrid {
                    ForEach(items) { item in
                        ItemView(item: item)
                    }
                }
            }
        }
    }
}
*/
