import SwiftUI

// ✅ Updated model that matches JSON correctly
struct LegalResource: Codable, Identifiable {
    var id: String { displayName.text }  // Unique identifier
    let displayName: NameText
    let formattedAddress: String
    let rating: Double?
    
    struct NameText: Codable {
        let text: String  // ✅ Match "displayName.text"
    }
}

// ✅ Wrapper struct to match API response structure
struct LegalResourcesResponse: Codable {
    let places: [LegalResource]
}

struct LegalTeamResources: View {
    @State private var legalResources: [LegalResource] = []
    
    var body: some View {
        NavigationView {
            List(legalResources) { resource in
                VStack(alignment: .leading) {
                    Text(resource.displayName.text)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text(resource.formattedAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if let rating = resource.rating {
                        Text("⭐ \(rating, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Legal Resources")
            .onAppear {
                fetchLegalResources()
            }
        }
    }
    
    func fetchLegalResources() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/legal-resources/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching legal resources:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [LegalResource]].self, from: data)
                DispatchQueue.main.async {
                    self.legalResources = decodedResponse["places"] ?? []
                }
            } catch {
                print("❌ Error decoding JSON:", error.localizedDescription)
            }
        }.resume()
    }
}

struct LegalTeamResources_Previews: PreviewProvider {
    static var previews: some View {
        LegalTeamResources()
    }
}
