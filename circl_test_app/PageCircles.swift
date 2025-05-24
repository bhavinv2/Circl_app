import SwiftUI

struct PageCircles: View {
    @State private var searchText: String = ""

    let circles = [
        ("Lean Startup-ists", "Technology", "1.2k+", "leanstartups"),
        ("Creative Hustlers", "Design", "900+", "creativehustlers"),
        ("Social Builders", "Community", "2.3k+", "socialbuilders")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

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

                // Search Bar
                HStack {
                    TextField("Search for a Circle (keywords or name)...", text: $searchText)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(15)

                    Button(action: {}) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .padding()

                // Circle Cards
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(circles, id: \ .0) { circle in
                            CircleCardView(name: circle.0, industry: circle.1, members: circle.2, imageName: circle.3)
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

struct CircleCardView: View {
    var name: String
    var industry: String
    var members: String
    var imageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(imageName)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Industry: ") + Text(industry).bold()
                    Text("\(members) Members")

                    NavigationLink(destination: AboutCirclePage()) {
                        Text("About")
                            .underline()
                    }

                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                        }

                        Button(action: {}) {
                            Text("Apply Now")
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
    }
}

struct AboutCirclePage: View {
    var body: some View {
        Text("Details about the circle go here.")
            .font(.title2)
            .padding()
    }
}

// MARK: - Color Extension
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

#Preview {
    PageCircles()
}
