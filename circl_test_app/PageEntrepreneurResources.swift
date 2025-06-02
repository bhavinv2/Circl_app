import SwiftUI

struct PageEntrepreneurResources: View {
    @State private var showMenu = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Header
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
                                EntrepreneurResourceItem(title: "Investors")
                                EntrepreneurResourceItem(title: "Accountants/Tax Advisors")
                                EntrepreneurResourceItem(title: "Legal Team")
                                EntrepreneurResourceItem(title: "Bank Business Loans")
                                EntrepreneurResourceItem(title: "Business Consultants")
                                EntrepreneurResourceItem(title: "Business Insurance")
                                EntrepreneurResourceItem(title: "Marketing/Branding/PR Company")
                                EntrepreneurResourceItem(title: "Real Estate Team")
                                EntrepreneurResourceItem(title: "Human Resources")
                                EntrepreneurResourceItem(title: "Operations and Supply Chain")
                                EntrepreneurResourceItem(title: "Customer Service and Support Team")
                                EntrepreneurResourceItem(title: "Data Analytics and Business Intelligence")
                                EntrepreneurResourceItem(title: "Sales Team")
                                EntrepreneurResourceItem(title: "Social Media Team")
                                EntrepreneurResourceItem(title: "Corporate Social Responsibility Advisors")
                                EntrepreneurResourceItem(title: "Mental Health")
                            }
                            .padding(.horizontal)
                            .foregroundColor(.fromHex("004aad"))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .background(Color(UIColor.systemGray4))
                    }
                }
                .navigationBarHidden(true)

                // Floating Hammer Menu
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
                            
                            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
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
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "hammer.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.fromHex("004aad"))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Button(action: {}) {
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

                        Text("Hello, Fragne")
                            .foregroundColor(.white)
                            .font(.headline)
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
            Button(action: {
                // Action
            }) {
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

    // MARK: - Menu Item Component
    private struct MenuItem: View {
        let icon: String
        let title: String
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.fromHex("004aad"))
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Color Extension
extension Color {
    static func fromHex11(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Preview
struct PageEntrepreneurResources_Previews: PreviewProvider {
    static var previews: some View {
        PageEntrepreneurResources()
    }
}
