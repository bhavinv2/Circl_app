import SwiftUI
import Foundation

struct SalesResources: View {
    var quizAnswers: SalesQuizAnswers
    @State private var resources: [LegalResource] = []

    var body: some View {
        NavigationView {
            List(resources) { resource in
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
            .navigationTitle("Sales Teams")
            .onAppear {
                fetchResources(keyword: quizAnswers.keyword)
            }
        }
    }

    func fetchResources(keyword: String) {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedLocation = quizAnswers.locationPref.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)legal-resources/?keyword=\(encodedKeyword)&location=\(encodedLocation)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching sales resources:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([String: [LegalResource]].self, from: data)
                DispatchQueue.main.async {
                    self.resources = decodedResponse["places"] ?? []
                }
            } catch {
                print("❌ Error decoding JSON:", error.localizedDescription)
            }
        }.resume()
    }
}

struct SalesResources_Previews: PreviewProvider {
    static var previews: some View {
        SalesResources(
            quizAnswers: SalesQuizAnswers(
                locationPref: "Miami",
                salesModel: "B2B",
                salesApproach: "outbound",
                crmExperience: "HubSpot",
                compensationType: "commission"
            )
        )
    }
}
