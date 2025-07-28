import Foundation

// MARK: - Circle API Manager
class CircleAPIManager: ObservableObject {
    private let baseURL = "http://localhost:8000/api/"
    
    // MARK: - Fetch My Circles
    func fetchMyCircles(userId: Int, completion: @escaping ([CircleData]) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/my_circles/\(userId)/") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            if let decoded: [CircleData] = try? JSONDecoder().decode([CircleData].self, from: data) {
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } else {
                print("❌ Failed to decode my_circles")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Channels
    func fetchChannels(for circleId: Int, completion: @escaping ([Channel]) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/get_channels/\(circleId)/") else {
            print("❌ Invalid URL for fetchChannels")
            completion([])
            return
        }

        print("🌐 Fetching channels for circle: \(circleId)")
        print("📤 URL: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion([])
                    return
                }
                
                print("📊 Channels API Status code: \(httpResponse.statusCode)")
                
                guard let data = data else {
                    completion([])
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Channels Raw JSON: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    if let decoded = try? JSONDecoder().decode([Channel].self, from: data) {
                        completion(decoded)
                    } else {
                        print("❌ Failed to decode channels")
                        completion([])
                    }
                } else {
                    print("❌ Channels API error: \(httpResponse.statusCode)")
                    completion([])
                }
            }
        }.resume()
    }
    
    // MARK: - Create Thread
    func createThread(userId: Int, circleId: Int, content: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/create_thread/") else {
            completion(false)
            return
        }

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circleId,
            "content": content
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    print("Error creating thread: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Create Announcement
    func createAnnouncement(userId: Int, circleId: Int, title: String, content: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/create_announcement/") else {
            print("❌ Invalid URL for createAnnouncement")
            completion(false)
            return
        }

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circleId,
            "title": title,
            "content": content
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    print("❌ Error creating announcement: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Leave Circle
    func leaveCircle(userId: Int, circleId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/leave_circle/") else {
            completion(false)
            return
        }

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circleId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }
    
    // MARK: - Delete Circle
    func deleteCircle(userId: Int, circleId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/delete_circle/") else {
            completion(false)
            return
        }

        let payload: [String: Any] = [
            "circle_id": circleId,
            "user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                completion(true)
            }
        }.resume()
    }
    
    // MARK: - Fetch Threads
    func fetchThreads(for circleId: Int, completion: @escaping ([ThreadPost]) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/get_threads/\(circleId)/") else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                print("📥 Raw JSON:")
                print(String(data: data, encoding: .utf8) ?? "nil")

                if let decoded = try? JSONDecoder().decode([ThreadPost].self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                } else {
                    print("❌ Failed to decode threads")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Announcements
    func fetchAnnouncements(for circleId: Int, completion: @escaping ([AnnouncementModel]) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/get_announcements/\(circleId)/") else {
            // Load sample data if URL fails
            completion(loadSampleAnnouncements())
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching announcements: \(error)")
                DispatchQueue.main.async {
                    completion(self.loadSampleAnnouncements())
                }
                return
            }
            
            if let data = data {
                print("📥 Announcements Raw JSON:")
                print(String(data: data, encoding: .utf8) ?? "nil")

                if let decoded = try? JSONDecoder().decode([AnnouncementModel].self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                } else {
                    print("❌ Failed to decode announcements")
                    DispatchQueue.main.async {
                        completion(self.loadSampleAnnouncements())
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(self.loadSampleAnnouncements())
                }
            }
        }.resume()
    }
    
    // MARK: - Load Sample Announcements
    private func loadSampleAnnouncements() -> [AnnouncementModel] {
        return [
            AnnouncementModel(
                id: 1,
                user: "CirclModerator",
                title: "Welcome to our Circle! 🎉",
                content: "Hello everyone! We're excited to have you join our community. Please take a moment to introduce yourself in the introductions channel and read our community guidelines. Looking forward to great discussions!",
                announced_at: "2024-12-20T10:30:00Z"
            ),
            AnnouncementModel(
                id: 2,
                user: "TechLead",
                title: "Weekly Networking Event 🚀",
                content: "Join us this Friday at 6 PM PST for our weekly virtual networking session. We'll be discussing emerging technologies and sharing insights from industry leaders. Don't miss this opportunity to connect with fellow entrepreneurs and innovators!",
                announced_at: "2024-12-19T15:45:00Z"
            ),
            AnnouncementModel(
                id: 3,
                user: "EventCoordinator",
                title: "New Partnership Program Launch 🤝",
                content: "We're thrilled to announce our new partnership program! This initiative will connect startups with potential collaborators and mentors. Applications are now open through our partnerships channel. Limited spots available - apply today!",
                announced_at: "2024-12-18T09:15:00Z"
            )
        ]
    }
}
