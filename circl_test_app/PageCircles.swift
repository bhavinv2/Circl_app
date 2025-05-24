import SwiftUI

// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""

    // Sample data for circles
    let circles: [CircleData] = [
        CircleData(name: "Lean Startup-ists", industry: "Technology", members: "1.2k+", imageName: "leanstartups", pricing: "Free", description: "A group for startup enthusiasts following lean principles.", joinType: .applyNow),
        CircleData(name: "Creative Hustlers", industry: "Design", members: "900+", imageName: "creativehustlers", pricing: "$50", description: "A space for designers to share and grow.", joinType: .inviteOnly),
        CircleData(name: "Social Builders", industry: "Community", members: "2.3k+", imageName: "socialbuilders", pricing: "Free", description: "Builders of impactful communities unite!", joinType: .joinNow)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // MARK: Header Section
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Circl.")
                                .font(.system(size: 39))
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Button(action: {
                                // TODO: Add filter action
                            }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.white)
                                    Text("Filter")
                                        .font(.system(size: 22))
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
                                    .font(.system(size: 22))
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
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(15)

                    Button(action: {
                        // TODO: Add search action
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
                    VStack(spacing: 16) {
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
        case inviteOnly = "Invite Only"
        case joinNow = "Join Now"
    }
}

// MARK: - Circle Card View
struct CircleCardView: View {
    var circle: CircleData

    var body: some View {
        HStack(spacing: 12) {
            Image(circle.imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.gray)
                .frame(width: 100, height: 80)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(circle.name)
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                    Text("Industry: \(circle.industry)")
                        .font(.system(size: 17))
                    Text("\(circle.members) Members")
                        .font(.system(size: 17))
                    Text(circle.description)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    HStack(spacing: 10) {
                        NavigationLink(destination: AboutCirclePage()) {
                            Text("About")
                                .underline()
                                .font(.system(size: 17))
                        }
                        Text(circle.pricing)
                            .font(.system(size: 17))
                    }
                }

                HStack(spacing: 10) {
                    Button(action: {
                        // TODO: Add remove action
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    Button(action: {
                        // TODO: Add join action
                    }) {
                        Text(circle.joinType.rawValue)
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(0)
        }
        .frame(width: 360, height: 200)
        .padding(0)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}

// MARK: - Placeholder About Page
struct AboutCirclePage: View {
    var body: some View {
        Text("Details about the circle go here.")
            .font(.title2)
            .padding()
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
