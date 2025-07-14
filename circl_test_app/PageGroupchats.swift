import SwiftUI
import Foundation

// Add reference to CircleDataModels.swift for data types

struct PageGroupchats: View {
    @State private var showSettingsMenu = false
    @State private var showLeaveConfirmation = false
    @State private var navigateToMembers = false

    let circle: CircleData
    
    @State private var showDeleteConfirmation = false
    @State private var deleteInputText = ""

    @State private var myCircles: [CircleData] = []

    @Environment(\.presentationMode) var presentationMode
    @AppStorage("user_id") private var userId: Int = 0
    @State private var loading = true
    @AppStorage("last_circle_id") private var lastCircleId: Int = 0

    @State private var circles: [CircleData] = []
    @State private var channels: [Channel] = []
    var groupedChannels: [String: [Channel]] {
        Dictionary(grouping: channels) { $0.name.prefix(1).uppercased() }
    }



   
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
                        HStack(spacing: 6) {
                            if userId == circle.creatorId {
                                Spacer()
                                Text("You are a moderator for this Circl")
                                    .font(.footnote)
                                    .foregroundColor(.gray)

                                
                                Spacer()
                            } else {
                                Spacer()
                            }
                        }
                        .frame(height: 20)
                        .padding(.bottom, 16)
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
                            Text("Circle Threads")
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
                                                    .background(Color(hex: "004aad").opacity(0.1))
                                                    .foregroundColor(Color(hex: "004aad"))
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
                .sheet(isPresented: $showCircleAboutPopup) {
                    CirclPopupCard(circle: circle, isMember: true)
                }



                Button(action: {
                    // Navigate to Explore Circles
                    presentationMode.wrappedValue.dismiss() // Optional: if you want to pop this view
                }) {
                    NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true)) {
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

                            if userId == circle.creatorId {
                                Divider()

                                Text("Moderator Options")
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
            destination: MemberListPage(circleName: circle.name, circleId: circle.id),
            isActive: $navigateToMembers
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
                URLSession.shared.dataTask(with: URL(string: "https://circlapp.online/api/circles/get_my_circles/")!) { data, _, _ in
                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.loading = false
                        }
                        return
                    }
                    if let decoded: [CircleData] = try? JSONDecoder().decode([CircleData].self, from: data) {
                        DispatchQueue.main.async {
                            self.myCircles = decoded
                            self.loading = false
                        }
                    } else {
                        print("❌ Failed to decode my_circles")
                        DispatchQueue.main.async {
                            self.loading = false
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

        // Explicitly define the type of the URLSession data task
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the response and error
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                newThreadContent = ""
                fetchThreads(for: circle.id)
            }
        }

        // Start the task
        task.resume()
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

        // Added explicit type annotation to resolve ambiguity
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Optional: navigate back or reload UI
                presentationMode.wrappedValue.dismiss()
            }
        }
        task.resume()
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

        // Added explicit type annotation to resolve ambiguity
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                // Navigate back to PageCircles after deletion
                presentationMode.wrappedValue.dismiss()
            }
        }
        task.resume()
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
            .background(Color(hex: "004aad"))
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

                    NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true)) {
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
                        .fill(Color(hex: "004aad"))
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
                        Image(systemName: "hand.thumbsup")
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
                    .foregroundColor(Color(hex: "004aad"))
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

// MARK: - Preview
struct PageGroupchats_Previews: PreviewProvider {
    static var previews: some View {
        // Fixed: CircleData expects channels as [String], not [Channel]
        let sampleChannels = ["#Welcome", "#Founder-Chat", "#Introductions"]

        PageGroupchats(circle: CircleData(
            id: 1,
            name: "Lean Startup-lists",
            industry: "Tech",
            memberCount: 1200,
            imageName: "leanstartups",
            pricing: "Free",
            description: "A community of founders",
            joinType: .joinNow,
            channels: sampleChannels,
            creatorId: 999,
            isModerator: false
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
                    CirclHeader()

                    Spacer()

                    VStack(spacing: 16) {
                        Text("You're not in any Circls yet!")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true)) {
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
        // Local API model for this function
        struct LocalAPICircle: Identifiable, Decodable {
            let id: Int
            let name: String
            let industry: String
            let pricing: String
            let description: String
            let join_type: String
            let channels: [String]?
            let creator_id: Int
            let is_moderator: Bool?
            let member_count: Int?
        }
        
        guard let url = URL(string: "https://circlapp.online/api/circles/my_circles/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([LocalAPICircle].self, from: data) {
                DispatchQueue.main.async {
                    self.myCircles = decoded.map { apiCircle in
                        return CircleData(
                            id: apiCircle.id,
                            name: apiCircle.name,
                            industry: apiCircle.industry,
                            memberCount: apiCircle.member_count ?? 0,
                            imageName: "uhmarketing",
                            pricing: apiCircle.pricing,
                            description: apiCircle.description,
                            joinType: apiCircle.join_type == "apply_now" ? JoinType.applyNow : JoinType.joinNow,
                            channels: apiCircle.channels ?? [],
                            creatorId: apiCircle.creator_id,
                            isModerator: apiCircle.is_moderator ?? false
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
            .background(Color(hex: "004aad"))
        }
    }
}
