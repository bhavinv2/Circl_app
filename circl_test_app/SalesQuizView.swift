import SwiftUI

struct SalesQuizView: View {
    @State private var locationPref = ""

    @State private var salesModel = ""
    @State private var salesApproach = ""
    @State private var crmExperience = ""
    @State private var compensationType = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Sales Model (B2B, B2C, Online, etc.)", text: $salesModel)
                TextField("Sales Type (Inbound, Outbound, Both)", text: $salesApproach)
                TextField("CRM/Platform Experience (e.g., Salesforce)", text: $crmExperience)
                TextField("Compensation Type (Commission or Salary)", text: $compensationType)

                Section {
                    NavigationLink(
                        destination: SalesResources(
                            quizAnswers: SalesQuizAnswers(
                                locationPref: locationPref,
                                salesModel: salesModel,
                                salesApproach: salesApproach,
                                crmExperience: crmExperience,
                                compensationType: compensationType
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Sales Teams") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Sales Quiz")
        }
    }
}

struct SalesQuizView_Previews: PreviewProvider {
    static var previews: some View {
        SalesQuizView()
    }
}
