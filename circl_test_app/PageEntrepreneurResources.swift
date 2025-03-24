import SwiftUI

struct PageEntrepreneurResources: View {
    var body: some View {
        NavigationView { // Add NavigationView to the root of the view
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Connect to Professional Resources Section
                        Text("Connect to professional resources")
                            .font(.headline)
                            .foregroundColor(.fromHex("004aad"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        // Categories List
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
                    .background(Color(UIColor.systemGray4)) // System Gray 4 Background
                }
                
                // Footer Section with Navigation Links
                footerSection
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        // Header Section
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // Action for Filter
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                            Text("Filter")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    // Add the Bubble and Person icons above "Hello, Fragne"
                    VStack {
                        HStack(spacing: 10) {
                            // Navigation Link for Bubble Symbol
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .frame(width: 50, height: 40)  // Adjust size
                                    .foregroundColor(.white)
                            }
                            
                            // Person Icon
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // "Hello, Fragne" text below the icons
                        Text("Hello, Fragne")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad")) // Updated blue color
        }
    }

    
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: 15) {
            NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
            }
            NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "briefcase.fill")
            }
            NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "captions.bubble.fill")
            }
            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "building.columns.fill")
            }
            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                CustomCircleButton(iconName: "newspaper")
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
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

// MARK: - Custom Circle Button
struct CustomCircleButton6: View {
    let iconName: String

    var body: some View {
        Button(action: {
            // Button action
        }) {
            ZStack {
                Circle()
                    .fill(Color.fromHex("004aad"))
                    .frame(width: 60, height: 60)
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Color from Hex
extension Color {
    static func fromHex6(_ hex: String) -> Color {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        guard hex.count == 6 else {
            return Color.gray
        }

        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

struct PageEntrepreneurResources_Previews: PreviewProvider {
    static var previews: some View {
        PageEntrepreneurResources()
    }
}
