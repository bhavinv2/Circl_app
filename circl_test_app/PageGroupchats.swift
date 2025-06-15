import SwiftUI
struct Channel: Identifiable, Decodable,Hashable {
    
  


    let id: Int
    let name: String
    let category: String? // example: "Community", "Learn", etc.
}

struct PageGroupchats: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var channels: [Channel] = []
    var groupedChannels: [String: [Channel]] {
        Dictionary(grouping: channels) { $0.category ?? "Other" }
    }


    let circle: CircleData  // 🧠 gets passed in from NavigationLink
    @State private var selectedGroup: String
    
  
    @State private var showMenu = false
    init(circle: CircleData) {
            self.circle = circle
            _selectedGroup = State(initialValue: circle.name)
        }

    let trendingThreads = [
        ThreadPost(id: 1, author: "Alice", content: "Check out this amazing resource for founders! 🚀", likes: 24, comments: 5),
        ThreadPost(id: 2, author: "Bob", content: "What's everyone's biggest challenge this month?", likes: 18, comments: 12),
        ThreadPost(id: 3, author: "Charlie", content: "We just closed our seed round! AMA.", likes: 35, comments: 20),
        ThreadPost(id: 4, author: "Diana", content: "Looking for a cofounder! Message me.", likes: 12, comments: 3),
        ThreadPost(id: 5, author: "Eve", content: "Check out my startup's landing page!", likes: 29, comments: 7)
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    headerSection

                    // Group Selector
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.blue))
                        }


                        Spacer()

                        Menu {
                            Button(selectedGroup, action: { selectedGroup = selectedGroup })
                            Button("Other Group", action: { selectedGroup = "Other Group" })
                        } label: {
                            HStack {
                                Text(selectedGroup)
                                    .foregroundColor(.black)
                                    .font(.headline)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray5))
                            .cornerRadius(20)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Announcement Banner
                    Text("Announcements: Group Call Tonight 8:00 PM")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.fromHex("004aad"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    // 🟨 2. Then Circle Threads
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Circle Threads")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(trendingThreads) { thread in
                                    ThreadCard(thread: thread)
                                        .frame(width: 280)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    Divider().padding(.horizontal)
                    // ✅ Show grouped + tappable channels
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            // 🟦 1. Channels first
                            if !channels.isEmpty {
                                ForEach(groupedChannels.keys.sorted(), id: \.self) { category in
                                    if let categoryChannels = groupedChannels[category] {
                                        Text(category)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)

                                        ForEach(categoryChannels) { channel in
                                            NavigationLink(destination: PageCircleMessages(channel: channel)) {
                                                Text(channel.name)
                                                    .font(.subheadline)
                                                    .padding(.vertical, 6)
                                                    .padding(.horizontal, 12)
                                                    .background(Color.fromHex("004aad").opacity(0.1))
                                                    .foregroundColor(Color.fromHex("004aad"))
                                                    .cornerRadius(12)
                                                    .padding(.horizontal)
                                            }
                                        }

                                        Divider().padding(.horizontal)
                                    }
                                }
                            } else {
                                Text("No channels available.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }

                            
                        }
                        .padding(.top)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    }


                    Spacer()
                }

                floatingButton
            }
        }
        .onAppear {
            fetchChannels(for: circle.id)
        }
    }

    func fetchChannels(for circleId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/get_channels/\(circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([Channel].self, from: data) {
                    DispatchQueue.main.async {
                        self.channels = decoded
                    }
                } else {
                    print("❌ Failed to decode channels")
                }
            }
        }.resume()
    }


    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Button(action: {
                        // Filter action
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
                    HStack(spacing: 10) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 40, height: 30)
                                .foregroundColor(.white)
                        }

                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }

                   
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.fromHex12("004aad"))
        }
    }

    private var floatingButton: some View {
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
                .contentShape(Rectangle()) // 👈 absorbs taps inside the menu
                .onTapGesture {}           // 👈 prevents menu from closing on self tap
            }

            Button(action: {
                withAnimation(.spring()) {
                    showMenu.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.fromHex("004aad"))
                        .frame(width: 60, height: 60)

                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .shadow(radius: 4)
            .padding(.bottom, -7)
        }
    }
}


// MARK: - Thread Post Model
struct ThreadPost: Identifiable {
    let id: Int
    let author: String
    let content: String
    let likes: Int
    let comments: Int
}

// MARK: - Thread Card View
struct ThreadCard: View {
    let thread: ThreadPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(thread.author)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                        Text("\(thread.likes)")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("\(thread.comments)")
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }

            Text(thread.content)
                .font(.body)

            Divider()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Menu Item Component
struct MenuItem2: View {
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

// MARK: - Color Extension Helper
extension Color {
    static func fromHex12(_ hex: String) -> Color {
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
struct PageGroupchats_Previews: PreviewProvider {
    static var previews: some View {
        PageGroupchats(circle: CircleData(
            id: 1,
            name: "Lean Startup-ists",
            industry: "Tech",
            members: "1.2k+",
            imageName: "leanstartups",
            pricing: "Free",
            description: "A community of founders",
            joinType: .joinNow,
            channels: ["#Welcome", "#Founder-Chat", "#Introductions"] // ✅ Add this line
        ))
    }
}



// Placeholder views for navigation destinations
struct PageMessages2: View {
    var body: some View {
        Text("Messages View")
    }
}

struct ProfilePage2: View {
    var body: some View {
        Text("Profile View")
    }
}

struct PageCircleMessages2: View {
    var body: some View {
        Text("Channel Messages View")
    }
}
