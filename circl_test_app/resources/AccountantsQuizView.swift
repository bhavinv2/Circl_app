import SwiftUI

struct AccountantsQuizView: View {
    @State private var locationPref = ""

    @State private var businessStructure = ""
    @State private var serviceNeed = ""
    @State private var industryExperience = false
    @State private var serviceFrequency = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Business Structure (LLC, Corp, etc.)", text: $businessStructure)
                TextField("Service Need (Bookkeeping, Tax Filing, Strategy)", text: $serviceNeed)
                Toggle("Need industry-specific tax experience?", isOn: $industryExperience)
                TextField("Service Frequency (Ongoing or One-time)", text: $serviceFrequency)

                Section {
                    NavigationLink(
                        destination: AccountantsResources(
                            quizAnswers: AccountantsQuizAnswers(
                                locationPref: locationPref,
                                businessStructure: businessStructure,
                                serviceNeed: serviceNeed,
                                industryExperience: industryExperience,
                                serviceFrequency: serviceFrequency
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Accountants") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Accountants Quiz")
        }
    }
}

struct AccountantsQuizView_Previews: PreviewProvider {
    static var previews: some View {
        AccountantsQuizView()
    }
}
