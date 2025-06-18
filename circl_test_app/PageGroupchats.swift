import SwiftUI

struct MessageChannel: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let circle_id: Int
    
}


struct PageGroupchats: View {
    @State private var showSettingsMenu = false
    @State private var showLeaveConfirmation = false
    @State private var navigateToMembers = false
    @State private var navigateBackToCircles = false
    @State private var navigateToManageUsers = false
    @State private var navigateToManageChannels = false

    let circle: CircleData
    
    @State private var showDeleteConfirmation = false
    @State private var deleteInputText = ""

    @State private var myCircles: [CircleData] = []
    @State private var navigateToPageCircles = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("user_id") private var userId: Int = 0
    @State private var loading = true
    @AppStorage("last_circle_id") private var lastCircleId: Int = 0

    @State private var circles: [CircleData] = []
    @State private var channels: [Channel] = []
    var groupedChannels: [String: [Channel]] {
        Dictionary(grouping: channels) { $0.name.prefix(1).uppercased() }
    }


    @State private var selectedThreadId: Int? = nil
    @State private var goToThreadPage = false

   
    @State private var selectedGroup: String
   
    @State private var showCircleAboutPopup = false

    
  
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

    init(circle: CircleData) {
            self.circle = circle
            _selectedGroup = State(initialValue: circle.name)
            lastCircleId = circle.id // 👈 Save the visited circle ID

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
                    // Group Selector
                    VStack(alignment: .center, spacing: 6) {
                        HStack(spacing: 12) {
                            // ⬇️ Dropdown menu (resized, but still big and clean)
                            Menu {
                                ForEach(myCircles, id: \.id) { circl in
                                    NavigationLink(destination: PageGroupchats(circle: circl).navigationBarBackButtonHidden(true)) {
                                        Text(circl.name)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(circle.name)
                                        .foregroundColor(.black)
                                        .font(.headline)

                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.75) // ✅ about 75% width

                            // ⬇️ Gear icon on right
                            Button(action: {
                                withAnimation(.spring()) {
                                    showSettingsMenu.toggle()
                                }
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }

                        }
                        .padding(.horizontal)
                        .padding(.top, 10)



                        // Moderator label row (centered)
                        // Moderator label row (centered)
                        if circle.isModerator {
                            HStack {
                                Spacer()
                                Text("You are an admin for this Circl")
                                    .font(.footnote)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .frame(height: 20)
                            .padding(.bottom, 16)
                        }
                        else {
                            Spacer().frame(height: 16) // ✅ adds same bottom padding when no admin label
                        }


                    }
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
                            Text("Circl Threads")
                                .font(.title3)
                                .fontWeight(.bold)

                            

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
                                    ThreadCard(
                                        thread: thread,
                                        onLikeTapped: {
                                            likeThread(threadId: thread.id)
                                        },
                                        onCommentTapped: {
                                            selectedThreadId = thread.id
                                            goToThreadPage = true
                                        }
                                    )
                                    .onTapGesture {
                                        selectedThreadId = thread.id
                                        goToThreadPage = true
                                    }

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
                                        Text("Circl Channels")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)


                                        ForEach(categoryChannels) { channel in
                                            NavigationLink(destination: PageCircleMessages(channel: channel, circleName: circle.name)) {
                                                HStack {
                                                    Text(channel.name)
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.fromHex("004aad"))

                                                    Spacer()

                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.blue)
                                                }
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 12)
                                                .background(Color.fromHex("004aad").opacity(0.1))
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
                NavigationLink(
                    destination: CirclThreadsPage(circleId: circle.id, highlightedThreadId: selectedThreadId),
                    isActive: $goToThreadPage
                ) {
                    EmptyView()
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
                .sheet(isPresented: $showCircleAboutPopup) {
                    CirclPopupCard(circle: circle, isMember: true)
                }



                Button(action: {
                    // Navigate to Explore Circles
                    presentationMode.wrappedValue.dismiss() // Optional: if you want to pop this view
                }) {
                    NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                        Text("Explore Circles")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                }
                // 🔻 Add this just ABOVE `floatingButton` inside the ZStack
                if showSettingsMenu {
                    ZStack {
                        // FULL invisible blocker
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showSettingsMenu = false
                                }
                            }

                        // Dimmed background that can't pass touches
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .allowsHitTesting(false) // 🔐 block interaction passing

                        // Floating menu under gear icon
                        VStack(alignment: .leading, spacing: 0) {
                            Button(action: {
                                showCircleAboutPopup = true
                            }) {
                                GroupMenuItem(icon: "info.circle.fill", title: "About This Circle")
                            }
                            .buttonStyle(PlainButtonStyle())

                          
                            Button(action: {
                                navigateToMembers = true
                                showSettingsMenu = false
                            }) {
                                GroupMenuItem(icon: "person.2.fill", title: "Members List")
                            }
                            .buttonStyle(PlainButtonStyle())

                          

                            Divider()

                            Button(action: {
                                showLeaveConfirmation = true
                                showSettingsMenu = false
                            }) {
                                GroupMenuItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Leave Circle", isDestructive: true)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if circle.isModerator {
                                Divider()

                                Text("Admin Options")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                               
                                
                                Button(action: {
                                    showDeleteConfirmation = true
                                    showSettingsMenu = false
                                }) {
                                    GroupMenuItem(icon: "trash.fill", title: "Delete Circle", isDestructive: true)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button(action: {
                                    navigateToManageUsers = true
                                    showSettingsMenu = false
                                }) {
                                    GroupMenuItem(icon: "person.crop.circle.badge.minus", title: "Manage Users")
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button(action: {
                                    navigateToManageChannels = true
                                    showSettingsMenu = false
                                }) {
                                    GroupMenuItem(icon: "slider.horizontal.3", title: "Manage Channels")
                                }
                                .buttonStyle(PlainButtonStyle())



                            }

                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 250)
                        .padding(.top, -150)  // 🔁 adjust to move under gear
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .topTrailing)

                    }
                    .zIndex(999)
                }







                floatingButton
            }
        }
        
        NavigationLink(
            destination: MemberListPage(circleName: circle.name, circleId: circle.id, isModerator: false),
            isActive: $navigateToMembers
        ) {
            EmptyView()
        }





        NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true), isActive: $navigateBackToCircles) {
            EmptyView()
        }
        NavigationLink(
            destination: MemberListPage(circleName: circle.name, circleId: circle.id, isModerator: true),
            isActive: $navigateToManageUsers
        ) {
            EmptyView()
        }
        NavigationLink(
            destination: ManageChannelsPage(circleId: circle.id),
            isActive: $navigateToManageChannels
        ) {
            EmptyView()
        }



        .alert("Leave Circle?", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                leaveCircle()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this circle?")
        }
        
        .alert("Delete Circle", isPresented: $showDeleteConfirmation) {
            TextField("Type CIRCL to confirm", text: $deleteInputText)

            Button("Delete", role: .destructive) {
                if deleteInputText == "CIRCL" {
                    deleteCircle()
                }
            }

            Button("Cancel", role: .cancel) {
                deleteInputText = ""
            }
        } message: {
            Text("Are you sure? This action will permanently delete the circle and all its data.")
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
                                        memberCount: $0.member_count ?? 0, // ✅ match new CircleData model
 // Or fetch real member data later
                                        imageName: "uhmarketing", // Or map image later
                                        pricing: $0.pricing,
                                        description: $0.description,
                                        joinType: $0.join_type == "apply_now" ? .applyNow : .joinNow,
                                        channels: $0.channels ?? [],
                                        creatorId: $0.creator_id,
                                        isModerator: $0.is_moderator ?? false

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
    func likeThread(threadId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/toggle_like/") else { return }

        let body: [String: Any] = [
            "user_id": userId,
            "thread_id": threadId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode([String: Int].self, from: data),
               let updatedLikes = response["likes"] {
                DispatchQueue.main.async {
                    if let index = threads.firstIndex(where: { $0.id == threadId }) {
                        threads[index].likes = updatedLikes
                        threads[index].liked_by_user.toggle()
                    }
                }
            }
        }.resume()
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

    
    func leaveCircle() {
        guard let url = URL(string: "https://circlapp.online/api/circles/leave_circle/") else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                navigateBackToCircles = true  // 👈 Navigate explicitly
            }
        }.resume()
    }

    
    func deleteCircle() {
        guard let url = URL(string: "https://circlapp.online/api/circles/delete_circle/") else { return }

        let payload: [String: Any] = [
            "circle_id": circle.id,
            "user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                // Navigate back to PageCircles after deletion
                navigateBackToCircles = true

            }
        }.resume()
    }


    func fetchThreads(for circleId: Int) {
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        guard let url = URL(string: "https://circlapp.online/api/circles/get_threads/\(circleId)/?user_id=\(userId)") else { return }

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
        // Header Section (copied from working screen)
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        Text("Circl.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
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
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }

    }

    private var floatingButton: some View {
        ZStack {
            // Background tap to dismiss
            if showMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
            }

            // Menu (top-right corner)
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

                    Divider()

                    NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true)) {
                        MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 5)
                .frame(width: 250)
                .padding(.trailing, 20)
                .offset(x: 65, y: 125) // 👈 adjust as needed

                .alignmentGuide(.bottom) { d in d[.bottom] }
                .alignmentGuide(.trailing) { d in d[.trailing] }

              
                .onTapGesture {} // Don’t dismiss if tapping inside menu
            }

            // Stationary Button (bottom-right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showMenu.toggle()
                            rotationAngle += 360
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
                    .padding(.trailing, 20)
                    .padding(.bottom, 2)
                }
            }
        }
    }


}


// MARK: - Thread Post Model
struct ThreadPost: Identifiable, Decodable {
    let id: Int
    let author_id: Int
    let author: String
    let content: String
    var likes: Int
    var comments: Int
    var liked_by_user: Bool
}


// MARK: - Thread Card View
struct ThreadCard: View {
    @State var thread: ThreadPost
    @AppStorage("user_id") var userId: Int = 0

    let onLikeTapped: () -> Void
    let onCommentTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(thread.author).fontWeight(.bold)
                Spacer()
                Button(action: onLikeTapped) {
                    HStack {
                        Image(systemName: thread.liked_by_user ? "heart.fill" : "heart")
                            .foregroundColor(thread.liked_by_user ? .red : .gray)
                        Text("\(thread.likes)")
                    }
                }

                Button(action: onCommentTapped) {
                    HStack {
                        Image(systemName: "bubble.right")
                        Text("\(thread.comments)")
                    }
                }
            }
            .font(.caption)
            .foregroundColor(.gray)

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
            memberCount: 1200,
            imageName: "leanstartups",
            pricing: "Free",
            description: "A community of founders",
            joinType: .joinNow,
            channels: ["#Welcome", "#Founder-Chat", "#Introductions"],
            creatorId: 999,
            isModerator: true // ✅ or false, depending on what you want in the preview

// 🔧 TEMPORARY just for SwiftUI preview
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




struct PageGroupchatsWrapper: View {
    @State private var myCircles: [CircleData] = []
    @AppStorage("user_id") private var userId: Int = 0
    @State private var loading = true
    @AppStorage("last_circle_id") private var lastCircleId: Int = 0


    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else if myCircles.isEmpty {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                    Text("Circl.")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 5) {
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
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                        .background(Color.fromHex("004aad"))
                    }


                    Spacer()

                    VStack(spacing: 16) {
                        Text("You're not in any Circls yet!")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                            Text("Explore Circls")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }

                    Spacer()
                }
            }
 else {
                if let savedCircle = myCircles.first(where: { $0.id == lastCircleId }) {
                    PageGroupchats(circle: savedCircle)
                } else {
                    PageGroupchats(circle: myCircles[0]) // fallback
                }
 // default to first circle
            }
        }
        .onAppear {
            fetchMyCircles()
        }
        
    }

    func fetchMyCircles() {
        guard let url = URL(string: "https://circlapp.online/api/circles/my_circles/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([APICircle].self, from: data) {
                DispatchQueue.main.async {
                    self.myCircles = decoded.map {
                        CircleData(
                            id: $0.id,
                            name: $0.name,
                            industry: $0.industry,
                            memberCount: $0.member_count ?? 0, // ✅ match new CircleData model

                            imageName: "uhmarketing",
                            pricing: $0.pricing,
                            description: $0.description,
                            joinType: $0.join_type == "apply_now" ? .applyNow : .joinNow,
                            channels: $0.channels ?? [],
                            creatorId: $0.creator_id,
                            isModerator: $0.is_moderator ?? false

                        )
                    }
                    self.loading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.loading = false
                }
            }
        }.resume()
    }
}



struct CirclHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    
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
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }
    }
}
