import SwiftUI

struct CSRResources: View {
    var quizAnswers: CSRQuizAnswers
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
            .navigationTitle("CSR Teams")
            .onAppear {
                fetchResources(keyword: quizAnswers.keyword)
            }
        }
    }

    func fetchResources(keyword: String) {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedLocation = quizAnswers.locationPref.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://circlapp.online/api/legal-resources/?keyword=\(encodedKeyword)&location=\(encodedLocation)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching CSR resources:", error?.localizedDescription ?? "Unknown error")
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

struct CSRResources_Previews: PreviewProvider {
    static var previews: some View {
        CSRResources(
            quizAnswers: CSRQuizAnswers(
                locationPref: "San Francisco",
                csrFocus: "Sustainability",
                industryGoals: "Green logistics",
                reportingMethod: "GRI",
                budget: "$10,000"
            )
        )
    }
}
