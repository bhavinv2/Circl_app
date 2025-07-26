import SwiftUI

struct ManufacturingQuizView: View {
    @State private var locationPref = ""

    @State private var productType = ""
    @State private var productionVolume = ""
    @State private var locationPreference = ""
    @State private var priority = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Product Type (e.g., Apparel, Electronics)", text: $productType)
                TextField("Production Volume (Prototype, Small Batch, etc.)", text: $productionVolume)
                TextField("Location Preference (Domestic, Overseas)", text: $locationPreference)
                TextField("Speed vs. Cost Priority", text: $priority)

                Section {
                    NavigationLink(
                        destination: ManufacturingResources(
                            quizAnswers: ManufacturingQuizAnswers(
                                locationPref: locationPref,
                                productType: productType,
                                productionVolume: productionVolume,
                                locationPreference: locationPreference,
                                priority: priority
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Manufacturers") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Manufacturing Quiz")
        }
    }
}

struct ManufacturingQuizView_Previews: PreviewProvider {
    static var previews: some View {
        ManufacturingQuizView()
    }
}
