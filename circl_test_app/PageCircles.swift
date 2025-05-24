import SwiftUI

// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""

    // Sample data for circles
    let circles = [
        ("Lean Startup-ists", "Technology", "1.2k+", "leanstartups", "Free"),
        ("Creative Hustlers", "Design", "900+", "creativehustlers", "$50"),
        ("Social Builders", "Community", "2.3k+", "socialbuilders", "Free")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // MARK: Header Section
                VStack(spacing: 0) {
                    HStack {
                        // Left side: App name and filter button
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Circl.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Button(action: {
                                // TODO: Add filter action
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

                        // Right side: Navigation buttons and greeting
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
                        ForEach(circles, id: \ .0) { circle in
                            CircleCardView(
                                name: circle.0,
                                industry: circle.1,
                                members: circle.2,
                                imageName: circle.3,
                                pricing: circle.4
                            )
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

// MARK: - Circle Card View
struct CircleCardView: View {
    var name: String
    var industry: String
    var members: String
    var imageName: String
    var pricing: String

    var body: some View {
        HStack(spacing: 12) {
            // Circle logo only
            Image(imageName)
                .resizable()
                .frame(width: 100, height: 80)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 8) {
                // Circle information
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Industry: \(industry)")
                        .font(.subheadline)
                    Text("\(members) Members")
                        .font(.subheadline)
                    HStack(spacing: 10) {
                        NavigationLink(destination: AboutCirclePage()) {
                            Text("About")
                                .underline()
                                .font(.subheadline)
                        }
                        Text(pricing)
                            .font(.subheadline)
                    }
                }

                // Action buttons
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
                        // TODO: Add apply action
                    }) {
                        Text("Apply Now")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
            }
        }
        .frame(width: 360, height: 180)
        .padding(5)
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
