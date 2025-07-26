import SwiftUI

struct InsuranceQuizView: View {
    @State private var locationPref = ""

    @State private var typeOfCoverage = ""
    @State private var industryRisks = ""
    @State private var budget = ""
    @State private var levelOfCoverage = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Type of Coverage (e.g. General Liability, Cyber)", text: $typeOfCoverage)
                TextField("Industry-Specific Risks", text: $industryRisks)
                TextField("Budget for Premiums", text: $budget)
                TextField("Level of Coverage (Basic, Full, etc.)", text: $levelOfCoverage)

                Section {
                    NavigationLink(
                        destination: InsuranceResources(
                            quizAnswers: InsuranceQuizAnswers(
                                locationPref: locationPref,
                                typeOfCoverage: typeOfCoverage,
                                industryRisks: industryRisks,
                                budget: budget,
                                levelOfCoverage: levelOfCoverage
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Insurance Providers") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Insurance Quiz")
        }
    }
}

struct InsuranceQuizView_Previews: PreviewProvider {
    static var previews: some View {
        InsuranceQuizView()
    }
}
