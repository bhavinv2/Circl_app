import SwiftUI

struct MentalHealthQuizView: View {
    @State private var locationPref = ""

    @State private var supportType = ""
    @State private var serviceType = ""
    @State private var deliveryType = ""
    @State private var budget = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Support Type (Individual or Team)", text: $supportType)
                TextField("Service Type (Therapy, Coaching, etc.)", text: $serviceType)
                TextField("Delivery (In-person or Virtual)", text: $deliveryType)
                TextField("Budget", text: $budget)

                Section {
                    NavigationLink(
                        destination: MentalHealthResources(
                            quizAnswers: MentalHealthQuizAnswers(
                                locationPref: locationPref,
                                supportType: supportType,
                                serviceType: serviceType,
                                deliveryType: deliveryType,
                                budget: budget
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Mental Health Support") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Mental Health Quiz")
        }
    }
}

struct MentalHealthQuizView_Previews: PreviewProvider {
    static var previews: some View {
        MentalHealthQuizView()
    }
}
