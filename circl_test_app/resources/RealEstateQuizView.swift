import SwiftUI

struct RealEstateQuizView: View {
    @State private var locationPref = ""

    @State private var spaceType = ""
    @State private var leaseOrBuy = ""
    @State private var regionPreference = ""
    @State private var squareFootage = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Type of Space (Office, Retail, etc.)", text: $spaceType)
                TextField("Lease or Purchase?", text: $leaseOrBuy)
                TextField("Region Preference (City, Suburbs, etc.)", text: $regionPreference)
                TextField("Square Footage or Growth Notes", text: $squareFootage)

                Section {
                    NavigationLink(
                        destination: RealEstateResources(
                            quizAnswers: RealEstateQuizAnswers(
                                locationPref: locationPref,
                                spaceType: spaceType,
                                leaseOrBuy: leaseOrBuy,
                                regionPreference: regionPreference,
                                squareFootage: squareFootage
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Real Estate Teams") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Real Estate Quiz")
        }
    }
}

struct RealEstateQuizView_Previews: PreviewProvider {
    static var previews: some View {
        RealEstateQuizView()
    }
}
