import SwiftUI

struct AccountantsResources: View {
    var quizAnswers: AccountantsQuizAnswers
    @State private var accountantResources: [LegalResource] = []

    var body: some View {
        NavigationView {
            List(accountantResources) { resource in
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
            .navigationTitle("Accountants Near You")
            .onAppear {
                fetchAccountantResources(keyword: quizAnswers.keyword)
            }
        }
    }

    func fetchAccountantResources(keyword: String) {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedLocation = quizAnswers.locationPref.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://34.136.164.254:8000/api/legal-resources/?keyword=\(encodedKeyword)&location=\(encodedLocation)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching accountant resources:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([String: [LegalResource]].self, from: data)
                DispatchQueue.main.async {
                    self.accountantResources = decodedResponse["places"] ?? []
                }
            } catch {
                print("❌ Error decoding JSON:", error.localizedDescription)
            }
        }.resume()
    }
}

struct AccountantsResources_Previews: PreviewProvider {
    static var previews: some View {
        AccountantsResources(
            quizAnswers: AccountantsQuizAnswers(
                locationPref: "Miami",
                businessStructure: "LLC",
                serviceNeed: "Tax filing",
                industryExperience: true,
                serviceFrequency: "Ongoing"
            )
        )
    }
}
