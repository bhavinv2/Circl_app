import SwiftUI

struct CSRQuizView: View {
    @State private var locationPref = ""

    @State private var csrFocus = ""
    @State private var industryGoals = ""
    @State private var reportingMethod = ""
    @State private var budget = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("CSR Focus (e.g., Sustainability, DEI)", text: $csrFocus)
                TextField("Industry-Specific Social Goals", text: $industryGoals)
                TextField("Preferred Reporting Method", text: $reportingMethod)
                TextField("Budget Allocation", text: $budget)

                Section {
                    NavigationLink(
                        destination: CSRResources(
                            quizAnswers: CSRQuizAnswers(
                                locationPref: locationPref,
                                csrFocus: csrFocus,
                                industryGoals: industryGoals,
                                reportingMethod: reportingMethod,
                                budget: budget
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find CSR Teams") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("CSR Quiz")
        }
    }
}

struct CSRQuizView_Previews: PreviewProvider {
    static var previews: some View {
        CSRQuizView()
    }
}
