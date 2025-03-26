import SwiftUI

struct MentalHealthResources: View {
    var quizAnswers: MentalHealthQuizAnswers
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
            .navigationTitle("Mental Health Teams")
            .onAppear {
                fetchResources(keyword: quizAnswers.keyword)
            }
        }
    }

    func fetchResources(keyword: String) {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedLocation = quizAnswers.locationPref.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://34.136.164.254:8000/api/legal-resources/?keyword=\(encodedKeyword)&location=\(encodedLocation)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching mental health resources:", error?.localizedDescription ?? "Unknown error")
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

struct MentalHealthResources_Previews: PreviewProvider {
    static var previews: some View {
        MentalHealthResources(
            quizAnswers: MentalHealthQuizAnswers(
                locationPref: "Remote",
                supportType: "Individual",
                serviceType: "Therapy",
                deliveryType: "Virtual",
                budget: "$150/session"
            )
        )
    }
}
