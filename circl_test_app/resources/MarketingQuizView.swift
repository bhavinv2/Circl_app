import SwiftUI

struct MarketingQuizView: View {
    @State private var locationPref = ""

    @State private var marketingNeed = ""
    @State private var targetAudience = ""
    @State private var serviceType = ""
    @State private var monthlyBudget = ""

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Marketing Need (e.g., SEO, Branding)", text: $marketingNeed)
                TextField("Target Audience (B2B, B2C, etc.)", text: $targetAudience)
                TextField("Preferred Service Type (Agency, Freelancer, DIY)", text: $serviceType)
                TextField("Monthly Budget Range", text: $monthlyBudget)

                Section {
                    NavigationLink(
                        destination: MarketingResources(
                            quizAnswers: MarketingQuizAnswers(
                                locationPref: locationPref,
                                marketingNeed: marketingNeed,
                                targetAudience: targetAudience,
                                serviceType: serviceType,
                                monthlyBudget: monthlyBudget
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Marketing Companies") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Marketing Quiz")
        }
    }
}

struct MarketingQuizView_Previews: PreviewProvider {
    static var previews: some View {
        MarketingQuizView()
    }
}
