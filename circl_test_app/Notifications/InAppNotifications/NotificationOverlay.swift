import SwiftUI

struct NotificationOverlay: ViewModifier {
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(
                notificationBannerView
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: notificationManager.isShowingNotification)
                , alignment: .top
            )
    }
    
    @ViewBuilder
    private var notificationBannerView: some View {
        if notificationManager.isShowingNotification,
           let notification = notificationManager.currentNotification {
            
            VStack {
                NotificationBanner(
                    notification: notification,
                    onTap: {
                        handleNotificationTap(notification)
                        notificationManager.dismissNotification()
                    },
                    onDismiss: {
                        notificationManager.dismissNotification()
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                
                Spacer()
            }
            .zIndex(999)
        }
    }
    
    private func handleNotificationTap(_ notification: InAppNotification) {
        // Handle navigation based on notification type
        switch notification.type {
        case .directMessage:
            // Navigate to chat with specific user
            if let messageId = notification.messageId {
                NavigationManager.shared.navigateToChat(messageId: messageId)
            } else {
                NavigationManager.shared.navigateToNetwork()
            }
            
        case .channelMessage:
            // Navigate to specific channel
            if let channelId = notification.channelId, let circleId = notification.circleId {
                NavigationManager.shared.navigateToChannel(channelId: channelId, circleId: circleId)
            } else {
                NavigationManager.shared.navigateToCircles()
            }
            
        case .connectionRequest:
            // Navigate to network page
            NavigationManager.shared.navigateToNetwork()
            
        case .circleInvite:
            // Navigate to specific circle or circles page
            if let circleId = notification.circleId {
                NavigationManager.shared.navigateToCircle(circleId: circleId)
            } else {
                NavigationManager.shared.navigateToCircles()
            }
            
        case .systemNotification:
            // Handle system notifications - could navigate to settings or stay put
            break
        }
    }
}

// Extension to easily apply notifications to any view
extension View {
    func withNotifications() -> some View {
        self.modifier(NotificationOverlay())
    }
}
