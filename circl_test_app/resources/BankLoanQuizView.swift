import SwiftUI

struct BankLoanQuizView: View {
    @State private var locationPref = ""

    // Part 2
    @State private var loanPurpose = ""
    @State private var loanTerm = ""
    @State private var collateralAvailable = false

    @State private var navigateToResults = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Location", text: $locationPref)

                TextField("Loan Purpose (Startup capital, etc.)", text: $loanPurpose)
                TextField("Loan Term (Short or Long)", text: $loanTerm)
                Toggle("Collateral Available?", isOn: $collateralAvailable)

                Section {
                    NavigationLink(
                        destination: BankLoanResources(
                            quizAnswers: BankLoanQuizAnswers(
                                locationPref: locationPref,
                                loanPurpose: loanPurpose,
                                loanTerm: loanTerm,
                                collateralAvailable: collateralAvailable
                            )
                        ),
                        isActive: $navigateToResults
                    ) {
                        Button("Find Lenders") {
                            navigateToResults = true
                        }
                    }
                }
            }
            .navigationTitle("Bank Loan Quiz")
        }
    }
}

struct BankLoanQuizView_Previews: PreviewProvider {
    static var previews: some View {
        BankLoanQuizView()
    }
}
