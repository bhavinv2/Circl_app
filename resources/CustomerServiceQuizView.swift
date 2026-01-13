import SwiftUI

struct CustomerServiceQuizView: View {
    @State private var locationPref = ""

    @State private var serviceType = ""
    @State private var volume = ""
    @State private var availability24_7 = false
    @State private var languageSupport = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Service Type (e.g., Call Center, Chatbot)", text: $serviceType)
                TextField("Expected Customer Volume (Low, Medium, High)", text: $volume)
                Toggle("24/7 Availability Required?", isOn: $availability24_7)
                TextField("Language or Multilingual Needs", text: $languageSupport)

                Section {
                    NavigationLink(
                        destination: CustomerServiceResources(
                            quizAnswers: CustomerServiceQuizAnswers(
                                locationPref: locationPref,
                                serviceType: serviceType,
                                volume: volume,
                                availability24_7: availability24_7,
                                languageSupport: languageSupport
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Support Teams") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Customer Service Quiz")
        }
    }
}

struct CustomerServiceQuizView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerServiceQuizView()
    }
}
