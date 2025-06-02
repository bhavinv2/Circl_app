import SwiftUI

// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""
    @State private var showMenu = false
    @State private var showCreateCircleSheet = false
    @State private var circleName: String = ""
    @State private var circleIndustry: String = ""
    @State private var circleDescription: String = ""
    @State private var circlePricing: String = ""
    @State private var selectedJoinType: CircleData.JoinType = .joinNow

    let circles: [CircleData] = [
        CircleData(name: "Lean Startup-ists", industry: "Technology", members: "1.2k+", imageName: "leanstartups", pricing: "", description: "", joinType: .applyNow),
        CircleData(name: "Houston Landscaping Network", industry: "Home Services", members: "200+", imageName: "houstonlandscape", pricing: "", description: "", joinType: .joinNow),
        CircleData(name: "UH Marketing", industry: "Home Services", members: "300+", imageName: "uhmarketing", pricing: "$34.99", description: "", joinType: .joinNow),
        CircleData(name: "UH Marketing", industry: "Home Services", members: "300+", imageName: "uhmarketing", pricing: "$34.99", description: "", joinType: .joinNow)
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Background tap to dismiss
                if showCreateCircleSheet {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showCreateCircleSheet = false
                            }
                        }
                        .transition(.opacity)
                }
                
                VStack(spacing: 0) {
                    // Header Section
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

                    // Search Bar with + Button
                    HStack(spacing: 10) {
                        TextField("Search for a Circle (keywords or name)...", text: $searchText)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(25)

                        Button(action: {}) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }

                        Button(action: {
                            withAnimation(.spring()) {
                                showCreateCircleSheet.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()

                    // Circle Cards
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(circles, id: \.name) { circle in
                                NavigationLink(destination: PageGroupchats().navigationBarBackButtonHidden(true)) {
                                    CircleCardView(circle: circle)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                .navigationBarHidden(true)

                // MARK: Create Circle Popup
                if showCreateCircleSheet {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Create a New Circle")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.fromHex("004aad"))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InputField2(title: "Circle Name", placeholder: "Enter circle name", text: $circleName)
                            InputField2(title: "Industry", placeholder: "Enter industry", text: $circleIndustry)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Description")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                TextEditor(text: $circleDescription)
                                    .frame(height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                    .background(Color(.systemBackground))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Join Type")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Picker("Join Type", selection: $selectedJoinType) {
                                    Text("Join Now").tag(CircleData.JoinType.joinNow)
                                    Text("Apply Now").tag(CircleData.JoinType.applyNow)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            InputField2(title: "Pricing (optional)", placeholder: "e.g. $34.99", text: $circlePricing)
                                .keyboardType(.decimalPad)
                            
                            // Image Upload Placeholder
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Circle Image")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .foregroundColor(Color.fromHex("004aad"))
                                    Text("Tap to upload image")
                                        .foregroundColor(.gray)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    showCreateCircleSheet = false
                                }
                                // Create circle action here
                            }) {
                                Text("Create Circle")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.fromHex("004aad"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                    }
                    .frame(width: 300)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                    .offset(y: -50)
                    .padding(.trailing, 20) // 20px space from right side
                }

                // MARK: Floating Hammer Menu
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
                                MenuItem(icon: "dollarsign.circle.fill", title: "Sell a Skill")
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
                        .padding(.trailing, 20) // 20px space from right side
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
                    .padding(.trailing, 20) // 20px space from right side
                }
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Input Field Component
struct InputField2: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

// MARK: - Menu Item
struct MenuItem: View {
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

// MARK: - Circle Data
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

                    Button(action: {}) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.red)
                    }

                    Button(action: {}) {
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

// MARK: - Color Helper
extension Color {
    static func fromHex2(_ hex: String) -> Color {
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
struct PageCircles_Previews: PreviewProvider {
    static var previews: some View {
        PageCircles()
    }
}
