import SwiftUI

struct Poll: Identifiable, Codable {
    let id: Int
    let title: String
    let options: [String]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case options
        case createdAt = "created_at"
    }
}

class PollsViewModel: ObservableObject {
    @Published var polls: [Poll] = []
    private let baseURL = "http://localhost:8000" // Django development server URL
    
    func fetchPolls(for circleId: Int) {
        print("Fetching polls for circle: \(circleId)")
        guard let url = URL(string: "\(baseURL)/api/polls/\(circleId)/") else {
            print("❌ Invalid URL constructed")
            return
        }
        
        print("Making request to URL: \(url)")
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Add CORS headers
        request.setValue("*", forHTTPHeaderField: "Access-Control-Allow-Origin")
        
        // Add authentication token if available
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add authentication if needed
        // request.setValue("Bearer \(yourAuthToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching polls: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status code: \(httpResponse.statusCode)")
                print("📡 Response headers: \(httpResponse.allHeaderFields)")
                
                // Check if we're getting HTML instead of JSON
                if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String,
                   contentType.contains("text/html") {
                    print("❌ Received HTML instead of JSON. Server might be returning an error page.")
                    return
                }
            }
            
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Received data: \(jsonString)")
                }
                
                do {
                    let decodedPolls = try JSONDecoder().decode([Poll].self, from: data)
                    print("✅ Successfully decoded \(decodedPolls.count) polls")
                    DispatchQueue.main.async {
                        self.polls = decodedPolls
                        print("📊 Updated polls in ViewModel: \(self.polls.count) polls")
                    }
                } catch {
                    print("❌ Error decoding polls: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("Type mismatch: expected \(type) at path: \(context.codingPath)")
                        case .valueNotFound(let type, let context):
                            print("Value not found: expected \(type) at path: \(context.codingPath)")
                        case .keyNotFound(let key, let context):
                            print("Key not found: \(key) at path: \(context.codingPath)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context)")
                        @unknown default:
                            print("Unknown decoding error")
                        }
                    }
                }
            } else {
                print("⚠️ No data received from server")
            }
        }.resume()
    }
    
    func vote(poll: Poll, option: String) {
        guard let url = URL(string: "\(baseURL)/api/polls/\(poll.id)/vote/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let voteData = ["option": option]
        
        do {
            request.httpBody = try JSONEncoder().encode(voteData)
        } catch {
            print("Error encoding vote data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error voting: \(error)")
                return
            }
            
            // Refresh polls after voting
            self.fetchPolls(for: poll.id)
        }.resume()
    }
    
    func createPoll(title: String, options: [String], circleId: Int) {
        guard let url = URL(string: "\(baseURL)/api/polls/") else {
            print("❌ Invalid URL for creating poll")
            return
        }
        
        print("📝 Creating poll - Title: \(title), Options: \(options), Circle ID: \(circleId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let pollData = [
            "title": title,
            "options": options,
            "circle_id": circleId
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: pollData)
        } catch {
            print("Error encoding poll data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating poll: \(error)")
                return
            }
            
            // Refresh polls after creating new one
            self.fetchPolls(for: circleId)
        }.resume()
    }
}
