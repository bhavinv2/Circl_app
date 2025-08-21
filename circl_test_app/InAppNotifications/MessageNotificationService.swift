import SwiftUI
import Foundation

// Global background service for checking new messages and triggering notifications
class MessageNotificationService: ObservableObject {
    static let shared = MessageNotificationService()
    
    private var timer: Timer?
    private let checkInterval: TimeInterval = 25.0 // Check every 25 seconds
    
    private init() {}
    
    // Start the background message checking service
    func startBackgroundMessageChecking() {
        // Stop any existing timer first to prevent duplicates
        if timer != nil {
            print("🔔 Background service already running - restarting...")
            stopBackgroundMessageChecking()
        }
        
        print("🔔 Starting background message notification service")
        
        // Check immediately
        checkForNewMessages()
        
        // Set up repeating timer
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { _ in
            self.checkForNewMessages()
        }
        
        print("🔔 Background service started successfully - checking every \(checkInterval) seconds")
    }
    
    // Stop the background service
    func stopBackgroundMessageChecking() {
        print("🔔 Stopping background message notification service")
        timer?.invalidate()
        timer = nil
    }
    
    // Check for new messages and trigger notifications
    private func checkForNewMessages() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found for background message checking")
            return
        }
        
        guard let url = URL(string: "https://circlapp.online/api/users/get_messages/\(userId)/") else {
            print("❌ Invalid messages URL for background checking")
            return
        }
        
        print("🔔 Background checking for new messages...")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Background message check network error:", error.localizedDescription)
                return
            }
            
            if let data = data {
                do {
                    // Try different response formats (same logic as PageMessages)
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Format 1: {"messages": [...]}
                        if let messagesArray = jsonObject["messages"] as? [[String: Any]] {
                            let apiMessages = try JSONSerialization.data(withJSONObject: messagesArray)
                            let decodedMessages = try JSONDecoder().decode([APIMessage].self, from: apiMessages)
                            
                            let convertedMessages = decodedMessages.map { apiMessage in
                                Message(
                                    id: String(apiMessage.id),
                                    sender_id: String(apiMessage.sender_id),
                                    receiver_id: String(apiMessage.receiver_id),
                                    content: apiMessage.content,
                                    timestamp: apiMessage.timestamp,
                                    is_read: apiMessage.is_read
                                )
                            }
                            
                            DispatchQueue.main.async {
                                self.processNewMessages(convertedMessages, userId: userId)
                            }
                        }
                    } else {
                        // Format 2: Direct array
                        let decodedMessages = try JSONDecoder().decode([APIMessage].self, from: data)
                        let convertedMessages = decodedMessages.map { apiMessage in
                            Message(
                                id: String(apiMessage.id),
                                sender_id: String(apiMessage.sender_id),
                                receiver_id: String(apiMessage.receiver_id),
                                content: apiMessage.content,
                                timestamp: apiMessage.timestamp,
                                is_read: apiMessage.is_read
                            )
                        }
                        
                        DispatchQueue.main.async {
                            self.processNewMessages(convertedMessages, userId: userId)
                        }
                    }
                } catch {
                    print("❌ Background message parsing error:", error)
                }
            }
        }.resume()
    }
    
    // Process messages and trigger notifications for new unread ones
    private func processNewMessages(_ messages: [Message], userId: Int) {
        let userIdString = String(userId)
        let newUnreadMessages = messages.filter { message in
            message.receiver_id == userIdString && !message.is_read
        }
        
        // Show notifications for new messages (limit to avoid spam)
        for message in newUnreadMessages.prefix(3) {
            // Only show notification if we haven't shown it for this message ID already
            if NotificationManager.shared.shouldShowNotificationForMessage(messageId: message.id) {
                fetchUserProfile(userId: Int(message.sender_id) ?? 0) { profile in
                    let senderName = profile?.first_name ?? "Someone"
                    NotificationManager.shared.showMessageNotification(
                        senderName: senderName,
                        message: message.content,
                        profileImageURL: profile?.profile_image,
                        messageId: Int(message.id)
                    )
                }
            }
        }
    }
    
    // Helper function to fetch user profile (copied from PageMessages)
    private func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid profile URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Profile fetch failed:", error)
                completion(nil)
                return
            }

            if let data = data {
                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                    return
                } else {
                    print("❌ Failed to decode profile JSON")
                }
            }
            completion(nil)
        }.resume()
    }
}
