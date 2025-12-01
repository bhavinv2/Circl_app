import SwiftUI

struct LegalQuizView: View {
    @State private var locationPref = ""

    @State private var legalNeeds = ""
    @State private var specialization = ""
    @State private var hasStartupExperience = false
    @State private var pricingModel = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Legal Needs", text: $legalNeeds)
                TextField("Specialization", text: $specialization)
                Toggle("Experience with Startups/Industry?", isOn: $hasStartupExperience)
                TextField("Pricing Model", text: $pricingModel)

                Section {
                    NavigationLink(
                        destination: LegalTeamResources(
                            quizAnswers: LegalQuizAnswers(
                                locationPref: locationPref,
                                legalNeeds: legalNeeds,
                                specialization: specialization,
                                startupExperience: hasStartupExperience,
                                pricingModel: pricingModel
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Legal Resources") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Legal Resource Quiz")
        }
    }
}

struct LegalQuizView_Previews: PreviewProvider {
    static var previews: some View {
        LegalQuizView()
    }
}
