import SwiftUI

// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""

    // Sample data for circles
    let circles: [CircleData] = [
        CircleData(name: "Lean Startup-ists", industry: "Technology", members: "1.2k+", imageName: "leanstartups", pricing: "", description: "", joinType: .applyNow),
        CircleData(name: "Houston Landscaping Network", industry: "Home Services", members: "200+", imageName: "houstonlandscape", pricing: "", description: "", joinType: .joinNow),
        CircleData(name: "UH Marketing", industry: "Home Services", members: "300+", imageName: "uhmarketing", pricing: "$34.99", description: "", joinType: .joinNow),
        CircleData(name: "UH Marketing", industry: "Home Services", members: "300+", imageName: "uhmarketing", pricing: "$34.99", description: "", joinType: .joinNow)
    ]

    var body: some View {
        NavigationView {
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
                            // Add the Bubble and Person icons above "Hello, Fragne"
                            VStack {
                                HStack(spacing: 10) {
                                    // Navigation Link for Bubble Symbol
                                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)
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
                        ForEach(circles, id: \ .name) { circle in
                            CircleCardView(circle: circle)
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationBarHidden(true)
        }
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
