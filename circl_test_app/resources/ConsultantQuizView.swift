import SwiftUI

struct ConsultantQuizView: View {
    @State private var locationPref = ""

    @State private var areaOfFocus = ""
    @State private var industry = ""
    @State private var startupExperience = false
    @State private var engagementLength = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Area of Focus (Strategy, Ops, etc.)", text: $areaOfFocus)
                TextField("Industry Specialization", text: $industry)
                Toggle("Startup/Scaling Experience?", isOn: $startupExperience)
                TextField("Engagement Length (Short or Long-term)", text: $engagementLength)

                Section {
                    NavigationLink(
                        destination: ConsultantResources(
                            quizAnswers: ConsultantQuizAnswers(
                                locationPref: locationPref,
                                areaOfFocus: areaOfFocus,
                                industry: industry,
                                startupExperience: startupExperience,
                                engagementLength: engagementLength
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Consultants") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Consultants Quiz")
        }
    }
}

struct ConsultantQuizView_Previews: PreviewProvider {
    static var previews: some View {
        ConsultantQuizView()
    }
}
