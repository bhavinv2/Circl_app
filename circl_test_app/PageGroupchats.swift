import SwiftUI
struct Channel: Identifiable, Decodable,Hashable {
    

    let id: Int
    let name: String
    let category: String? // example: "Community", "Learn", etc.
    let circleId: Int
}

struct PageGroupchats: View {
    let circle: CircleData
    
   
    @State private var myCircles: [CircleData] = []

    @Environment(\.presentationMode) var presentationMode
    @AppStorage("user_id") private var userId: Int = 0

    @State private var channels: [Channel] = []
    var groupedChannels: [String: [Channel]] {
        Dictionary(grouping: channels) { $0.category ?? "Other" }
    }


   
    @State private var selectedGroup: String
   

    
  
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

    init(circle: CircleData) {
            self.circle = circle
            _selectedGroup = State(initialValue: circle.name)
        }

    @State private var threads: [ThreadPost] = []
    @State private var showCreateThreadPopup = false
    @State private var newThreadContent: String = ""


    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    headerSection

                    // Group Selector
                    HStack {
                        NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.blue))
                        }



                        Spacer()

                        Menu {
                            ForEach(myCircles, id: \.id) { circl in
                                NavigationLink(destination: PageGroupchats(circle: circl).navigationBarBackButtonHidden(true)) {
                                    Text(circl.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(circle.name)
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

//                    // Announcement Banner
//                    Text("Announcements: Group Call Tonight 8:00 PM")
//                        .font(.subheadline)
//                        .foregroundColor(.white)
//                        .padding(8)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.fromHex("004aad"))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                        .padding(.vertical, 5)
                    // 🟨 2. Then Circle Threads
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Circle Threads")
                                .font(.title3)
                                .fontWeight(.bold)

                            if userId == circle.creatorId {
                                Text("Moderator")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(6)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Button(action: {
                                showCreateThreadPopup = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }

                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(threads) { thread in
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
                                            NavigationLink(destination: PageCircleMessages(channel: channel, circleName: circle.name)) {
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
                .sheet(isPresented: $showCreateThreadPopup) {
                    VStack(spacing: 16) {
                        Text("New Thread")
                            .font(.headline)
                        TextEditor(text: $newThreadContent)
                            .frame(height: 120)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

                        Button("Post") {
                            postNewThread()
                            showCreateThreadPopup = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Spacer()
                    }
                    .padding()
                }


                floatingButton
            }
        }
        
    

        .onAppear {
            fetchChannels(for: circle.id)
            fetchThreads(for: circle.id)
            fetchMyCircles(userId: userId)
            
            
            

            func fetchMyCircles(userId: Int) {
                guard let url = URL(string: "https://circlapp.online/api/circles/my_circles/\(userId)/") else { return }

                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        if let decoded = try? JSONDecoder().decode([APICircle].self, from: data) {
                            DispatchQueue.main.async {
                                self.myCircles = decoded.map {
                                    CircleData(
                                        id: $0.id,
                                        name: $0.name,
                                        industry: $0.industry,
                                        members: "1k+", // Or fetch real member data later
                                        imageName: "uhmarketing", // Or map image later
                                        pricing: $0.pricing,
                                        description: $0.description,
                                        joinType: $0.join_type == "apply_now" ? .applyNow : .joinNow,
                                        channels: $0.channels ?? [],
                                        creatorId: $0.creator_id
                                    )
                                }
                            }
                        } else {
                            print("❌ Failed to decode my_circles")
                        }
                    }
                }.resume()
            }

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
    
    
    func postNewThread() {
        guard let url = URL(string: "https://circlapp.online/api/circles/create_thread/") else { return }

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id,
            "content": newThreadContent
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let _ = data {
                DispatchQueue.main.async {
                    newThreadContent = ""
                    fetchThreads(for: circle.id)
                }
            } else {
                print("❌ Failed to post thread")
            }
        }.resume()
    }

    func fetchThreads(for circleId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/get_threads/\(circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                print("📥 Raw JSON:")
                print(String(data: data, encoding: .utf8) ?? "nil")

                if let decoded = try? JSONDecoder().decode([ThreadPost].self, from: data) {
                    DispatchQueue.main.async {
                        self.threads = decoded
                    }
                } else {
                    print("❌ Failed to decode threads")
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
                withAnimation(.easeInOut(duration: 0.4)) {
                    showMenu.toggle()
                    rotationAngle += 360 // spin the logo
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
                        .clipShape(Circle())
                        .rotationEffect(.degrees(rotationAngle))
                }
            }
            .shadow(radius: 4)
            .padding(.bottom, 3)
            .offset(x: -15)

        }
    }
}


// MARK: - Thread Post Model
struct ThreadPost: Identifiable, Decodable {
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
            channels: ["#Welcome", "#Founder-Chat", "#Introductions"],
            creatorId: 999 // 🔧 TEMPORARY just for SwiftUI preview
// ✅ Add this line
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
