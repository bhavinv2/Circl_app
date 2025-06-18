import SwiftUI

struct PageEntrepreneurResources: View {
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

   


    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // 🧼 Tap outside to close menu
                if showMenu {
                    Color.black.opacity(0.001) // invisible but tappable
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }
                        .zIndex(1) // sit above content but below menu button
                }


                VStack(spacing: 0) {
                    // Header Section
                    headerSection

                    // Main Content
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Connect to professional resources")
                                .font(.headline)
                                .foregroundColor(.fromHex("004aad"))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.yellow)
                                .cornerRadius(10)
                                .padding(.horizontal)

                            VStack(spacing: 15) {
                                NavigationLink(destination: AccountantsQuizView()) {
                                    EntrepreneurResourceItem(title: "Accountants/Tax Advisors")
                                }
                                NavigationLink(destination: LegalQuizView()) {
                                    EntrepreneurResourceItem(title: "Legal Team")
                                }
                                NavigationLink(destination: BankLoanQuizView()) {
                                    EntrepreneurResourceItem(title: "Bank Loans")
                                }
                                NavigationLink(destination: ConsultantQuizView()) {
                                    EntrepreneurResourceItem(title: "Business Consultants")
                                }
                                NavigationLink(destination: InsuranceQuizView()) {
                                    EntrepreneurResourceItem(title: "Business Insurance")
                                }
                                NavigationLink(destination: MarketingQuizView()) {
                                    EntrepreneurResourceItem(title: "Marketing Companies")
                                }
                                NavigationLink(destination: RealEstateQuizView()) {
                                    EntrepreneurResourceItem(title: "Real Estate Teams")
                                }
                                NavigationLink(destination: HRQuizView()) {
                                    EntrepreneurResourceItem(title: "HR Teams")
                                }
                                NavigationLink(destination: ManufacturingQuizView()) {
                                    EntrepreneurResourceItem(title: "Manufacturing Firms")
                                }
                                NavigationLink(destination: CustomerServiceQuizView()) {
                                    EntrepreneurResourceItem(title: "Customer Service Teams")
                                }
                                NavigationLink(destination: SalesQuizView()) {
                                    EntrepreneurResourceItem(title: "Sales Teams")
                                }
                                NavigationLink(destination: CSRQuizView()) {
                                    EntrepreneurResourceItem(title: "CSR Teams")
                                }
                                NavigationLink(destination: MentalHealthQuizView()) {
                                    EntrepreneurResourceItem(title: "Mental Health Teams")
                                }
                            }
                            .padding(.horizontal)
                            .foregroundColor(.fromHex("004aad"))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .background(Color(UIColor.systemGray4))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden(true)

                // Floating Ellipsis Menu
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Welcome to your resources")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))

                            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "person.2.fill", title: "Connect and Network")
                            }
                            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
                            }
                            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
                            }
                            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "briefcase.fill", title: "Professional Services")
                            }
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "envelope.fill", title: "Messages")
                            }
                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                            }
                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
                            }

                            Divider()

                            NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                            }

                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 250)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                                showMenu.toggle()
                                rotationAngle += 360
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.fromHex("004aad"))
                                .frame(width: 60, height: 60)

                            Image("CirclLogoButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle()) // 👈 hides square corners
                                .rotationEffect(.degrees(rotationAngle))



                        }
                    }
                    .shadow(radius: 4)
                    .padding(.bottom, -12)
                    .zIndex(2) // make sure it's above the clear tap layer

                }
                .padding()
                .zIndex(1)
            }


        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        Text("Circl.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    VStack {
                        HStack(spacing: 10) {
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .frame(width: 50, height: 40)
                                    .foregroundColor(.white)
                            }

                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }
    }

    // MARK: - Entrepreneur Resource Item
    private struct EntrepreneurResourceItem: View {
        let title: String

        var body: some View {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }

}

// MARK: - Color from Hex


struct PageEntrepreneurResources_Previews: PreviewProvider {
    static var previews: some View {
        PageEntrepreneurResources()
    }
}
