import SwiftUI

struct HRQuizView: View {
    @State private var locationPref = ""

    @State private var hrNeed = ""
    @State private var employeeCount = ""
    @State private var deliveryType = ""
    @State private var complianceNeed = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("HR Need (Hiring, Payroll, etc.)", text: $hrNeed)
                TextField("Number of Employees", text: $employeeCount)
                TextField("HR Type (In-house, Outsourced, Fractional)", text: $deliveryType)
                TextField("Compliance Needs (Local, Federal, etc.)", text: $complianceNeed)

                Section {
                    NavigationLink(
                        destination: HRResources(
                            quizAnswers: HRQuizAnswers(
                                locationPref: locationPref,
                                hrNeed: hrNeed,
                                employeeCount: employeeCount,
                                deliveryType: deliveryType,
                                complianceNeed: complianceNeed
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find HR Teams") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("HR Quiz")
        }
    }
}

struct HRQuizView_Previews: PreviewProvider {
    static var previews: some View {
        HRQuizView()
    }
}
