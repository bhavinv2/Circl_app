import SwiftUI

// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""
    @State private var showMenu = false // State for showing/hiding the menu

    // Sample data for circles
    let circles: [CircleData] = [
        CircleData(name: "Lean Startup-ists", industry: "Technology", members: "1.2k+", imageName: "leanstartups", pricing: "", description: "", joinType: .applyNow),
        CircleData(name: "Houston Landscaping Network", industry: "Home Services", members: "200+", imageName: "houstonlandscape", pricing: "", description: "", joinType: .joinNow),
        CircleData(name: "UH Marketing", industry: "Home Services", members: "300+", imageName: "uhmarketing", pricing: "$34.99", description: "", joinType: .joinNow),
        CircleData(name: "UH Marketing", industry: "Home Services", members: "300+", imageName: "uhmarketing", pricing: "$34.99", description: "", joinType: .joinNow)
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // MARK: Header Section
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

                    // MARK: Search Bar
                    HStack {
                        TextField("Search for a Circle (keywords or name)...", text: $searchText)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(25)

                        Button(action: {
                            // Search logic
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()

                    // MARK: Circle Cards List
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(circles, id: \.name) { circle in
                                CircleCardView(circle: circle)
                            }
                        }
                        .padding()
                    }

                    Spacer()
                }
                .navigationBarHidden(true)
                
                // Floating Assistive Touch Button with Enhanced Menu
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            // Menu Header
                            Text("Welcome to your resources")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                            
                            // Menu Items
                            MenuItem(icon: "person.2.fill", title: "Connect and Network")
                            MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
                            MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
                            MenuItem(icon: "briefcase.fill", title: "Professional Services")
                            MenuItem(icon: "envelope.fill", title: "Messages")
                            MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                            MenuItem(icon: "dollarsign.circle.fill", title: "Sell a Skill")
                            
                            Divider()
                            
                            MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 250)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Main floating button
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
}

// MARK: - Menu Item Component
struct MenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            // Action for each menu item
        }) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Circle Data Model
struct CircleData {
    let name: String
    let industry: String
    let members: String
    let imageName: String
    let pricing: String
    let description: String
    let joinType: JoinType

    enum JoinType: String {
        case applyNow = "Apply Now"
        case joinNow = "Join Now"
    }
}

// MARK: - Circle Card View
struct CircleCardView: View {
    var circle: CircleData

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(circle.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(circle.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    if !circle.pricing.isEmpty {
                        Text(circle.pricing)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }

                Text("Industry: \(circle.industry)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                Text("\(circle.members) Members")
                    .font(.system(size: 15))
                    .foregroundColor(.black)

                HStack(spacing: 10) {
                    Text("About")
                        .underline()
                        .font(.system(size: 16))
                        .foregroundColor(.blue)

                    Spacer()

                    Button(action: {
                        // Remove action
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.red)
                    }

                    Button(action: {
                        // Join or apply action
                    }) {
                        Text(circle.joinType.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Color Extension Helper
extension Color {
    static func fromHex9(_ hex: String) -> Color {
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
#Preview {
    PageCircles()
}
