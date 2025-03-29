import SwiftUI

struct LegalResource: Codable, Identifiable {
    var id: String { displayName.text }
    let displayName: NameText
    let formattedAddress: String
    let rating: Double?

    struct NameText: Codable {
        let text: String
    }
}

struct LegalResourcesResponse: Codable {
    let places: [LegalResource]
}

struct LegalTeamResources: View {
    var quizAnswers: LegalQuizAnswers

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
                fetchLegalResources(keyword: quizAnswers.keyword)
            }
        }
    }

    func fetchLegalResources(keyword: String) {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://circlapp.online/api/legal-resources/?keyword=\(encodedKeyword)") else { return }

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
        LegalTeamResources(
            quizAnswers: LegalQuizAnswers(
                locationPref: "Los Angeles",
                legalNeeds: "Contracts",
                specialization: "Trademarks",
                startupExperience: true,
                pricingModel: "Flat fee"
            )
        )
    }
}
