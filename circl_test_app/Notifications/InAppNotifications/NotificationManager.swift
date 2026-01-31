import SwiftUI
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var currentNotification: InAppNotification?
    @Published var notificationQueue: [InAppNotification] = []
    @Published var isShowingNotification = false
    
    private var notificationTimer: Timer?
    private let notificationDuration: TimeInterval = 4.0
    
    // Track which messages we've already shown notifications for
    private var shownMessageIds: Set<String> = []
    
    private init() {}
    
    // MARK: - Public Methods
    func showNotification(_ notification: InAppNotification) {
        DispatchQueue.main.async {
            // Add to queue if notification is currently showing
            if self.isShowingNotification {
                self.notificationQueue.append(notification)
                return
            }
            
            // Show notification immediately
            self.displayNotification(notification)
        }
    }
    
    func showMessageNotification(
        senderName: String,
        message: String,
        profileImageURL: String? = nil,
        messageId: Int? = nil,
        channelId: Int? = nil,
        circleId: Int? = nil
    ) {
        // Only show notification if we haven't shown it for this message already
        if let messageId = messageId, !shouldShowNotificationForMessage(messageId: String(messageId)) {
            return
        }
        
        let notification = InAppNotification(
            type: channelId != nil ? .channelMessage : .directMessage,
            title: senderName,
            subtitle: message,
            senderName: senderName,
            profileImageURL: profileImageURL,
            messageId: messageId,
            channelId: channelId,
            circleId: circleId
        )
        
        // Mark this message as notified
        if let messageId = messageId {
            markMessageNotificationAsShown(messageId: String(messageId))
        }
        
        showNotification(notification)
    }
    
    func showConnectionRequest(fromUserName: String, title: String, subtitle: String, profileImageURL: String? = nil) {
        let notification = InAppNotification(
            type: .connectionRequest,
            title: title,
            subtitle: subtitle,
            senderName: fromUserName,
            profileImageURL: profileImageURL
        )
        
        showNotification(notification)
    }
    
    func showCircleInvite(senderName: String, circleName: String, circleId: Int, profileImageURL: String? = nil) {
        let notification = InAppNotification(
            type: .circleInvite,
            title: "Circle Invitation",
            subtitle: "\(senderName) invited you to join \(circleName)",
            senderName: senderName,
            profileImageURL: profileImageURL,
            circleId: circleId
        )
        
        showNotification(notification)
    }
    
    func showSystemNotification(title: String, message: String) {
        let notification = InAppNotification(
            type: .systemNotification,
            title: title,
            subtitle: message,
            senderName: nil,
            profileImageURL: nil
        )
        
        showNotification(notification)
    }
    
    // MARK: - Handle Push Payloads
    /// Accepts a push payload (parsed from APNs userInfo) and displays an in-app notification mapping.
    func handlePushPayload(type: String, payload: [String: Any]) {
        DispatchQueue.main.async {
            switch type {
            case "message":
                let messageId = payload["message_id"] as? Int
                let channelId = payload["channel_id"] as? Int
                let circleId = payload["circle_id"] as? Int
                let senderName = payload["sender_name"] as? String ?? "Someone"
                let excerpt = payload["excerpt"] as? String ?? ""

                // Dedupe by message id
                if let mid = messageId, !self.shouldShowNotificationForMessage(messageId: String(mid)) {
                    return
                }

                self.showMessageNotification(senderName: senderName,
                                             message: excerpt,
                                             profileImageURL: nil,
                                             messageId: messageId,
                                             channelId: channelId,
                                             circleId: circleId)

            case "connection_request":
                let senderName = payload["sender_name"] as? String ?? "Someone"
                let title = "New Connection Request"
                let subtitle = "\(senderName) wants to connect"
                self.showConnectionRequest(fromUserName: senderName, title: title, subtitle: subtitle)

            case "connection_accepted":
                let accepterName = payload["accepter_name"] as? String ?? "Someone"
                self.showSystemNotification(title: "Connection Accepted", message: "\(accepterName) accepted your request")

            case "announcement":
                let title = payload["title"] as? String ?? "Announcement"
                let excerpt = payload["excerpt"] as? String ?? ""
                self.showSystemNotification(title: title, message: excerpt)

            case "event_reminder":
                let title = payload["title"] as? String ?? "Event Reminder"
                let start = payload["start_time"] as? String ?? ""
                self.showSystemNotification(title: title, message: "Starts at \(start)")

            case "events_tomorrow_summary":
                if let events = payload["events"] as? [[String: Any]] {
                    let count = events.count
                    let titles = events.prefix(3).compactMap { e -> String? in
                        if let t = e["title"] as? String, let time = e["time_local"] as? String {
                            return "\(t) at \(time)"
                        }
                        return nil
                    }.joined(separator: ", ")
                    let title = "\(count) Events Tomorrow"
                    self.showSystemNotification(title: title, message: titles)
                } else {
                    self.showSystemNotification(title: "Events Tomorrow", message: "You have events tomorrow.")
                }

            default:
                // For unknown types, do nothing (or log)
                break
            }
        }
    }
    
    // MARK: - General Notification Method
    func showNotification(type: NotificationType, title: String, subtitle: String? = nil, 
                         senderName: String? = nil, profileImageURL: String? = nil,
                         messageId: Int? = nil, channelId: Int? = nil, circleId: Int? = nil) {
        let notification = InAppNotification(
            type: type,
            title: title,
            subtitle: subtitle,
            senderName: senderName,
            profileImageURL: profileImageURL,
            messageId: messageId,
            channelId: channelId,
            circleId: circleId
        )
        
        showNotification(notification)
    }
    
    func dismissNotification() {
        DispatchQueue.main.async {
            self.isShowingNotification = false
            self.currentNotification = nil
            self.notificationTimer?.invalidate()
            
            // Show next notification in queue
            if !self.notificationQueue.isEmpty {
                let nextNotification = self.notificationQueue.removeFirst()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.displayNotification(nextNotification)
                }
            }
        }
    }
    
    // MARK: - Message Tracking Methods
    func shouldShowNotificationForMessage(messageId: String) -> Bool {
        return !shownMessageIds.contains(messageId)
    }
    
    func markMessageNotificationAsShown(messageId: String) {
        shownMessageIds.insert(messageId)
    }
    
    func clearShownMessageIds() {
        shownMessageIds.removeAll()
    }
    
    // MARK: - Private Methods
    private func displayNotification(_ notification: InAppNotification) {
        currentNotification = notification
        isShowingNotification = true
        
        // Auto-dismiss after duration
        notificationTimer = Timer.scheduledTimer(withTimeInterval: notificationDuration, repeats: false) { _ in
            self.dismissNotification()
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}
