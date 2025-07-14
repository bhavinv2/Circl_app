import SwiftUI


// MARK: - API Model
struct APICircle: Identifiable, Decodable {
    let id: Int
    let name: String
    let industry: String
    let pricing: String
    let description: String
    let join_type: String
    let channels: [String]?
    let creator_id: Int
    let is_moderator: Bool?  // ✅ Add this (optional for safety)
    let member_count: Int?
}



// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""
    @State private var selectedCircleToOpen: CircleData? = nil
    @State private var triggerOpenGroupChat = false
    @State private var showAboutPopup = false

    @State private var showCreateCircleSheet = false
    @State private var circleName: String = ""
    @State private var circleIndustry: String = ""
    @State private var circleDescription: String = ""
    @State private var selectedJoinType: JoinType = JoinType.joinNow

    @State private var showMyCircles = false
    @State private var myCircles: [CircleData] = []
    @State private var exploreCircles: [CircleData] = []
    @AppStorage("user_id") private var userId: Int = 0

    @State private var selectedChannels: [String] = []
    let allChannelOptions = ["#Welcome", "#Founder-Chat", "#Introductions", "#Case-Studies"]
    
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0

    init(showMyCircles: Bool = false) {
        self._showMyCircles = State(initialValue: showMyCircles)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if showCreateCircleSheet {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showCreateCircleSheet = false }
                        }
                        .transition(.opacity)
                }

                VStack(spacing: 0) {
                    // MARK: Header - Twitter/X style layout matching Forum
                    VStack(spacing: 0) {
                        HStack {
                            // Left side - Profile
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                    default:
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Center - Logo
                            Text("Circl.")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Right side - Messages
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                ZStack {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                    
                                    if unreadMessageCount > 0 {
                                        Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 10, y: -10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .padding(.top, 8)
                        
                        // Tab Buttons Row - Twitter/X style tabs
                        HStack(spacing: 0) {
                            Spacer()
                            
                            // Explore Tab
                            HStack {
                                VStack(spacing: 8) {
                                    Text("Explore")
                                        .font(.system(size: 15, weight: !showMyCircles ? .semibold : .regular))
                                        .foregroundColor(.white)
                                    
                                    Rectangle()
                                        .fill(!showMyCircles ? Color.white : Color.clear)
                                        .frame(height: 3)
                                        .animation(.easeInOut(duration: 0.2), value: showMyCircles)
                                }
                                .frame(width: 70)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showMyCircles = false
                                }
                            }
                            
                            Spacer()
                            
                            // My Circles Tab
                            HStack {
                                VStack(spacing: 8) {
                                    Text("My Circles")
                                        .font(.system(size: 15, weight: showMyCircles ? .semibold : .regular))
                                        .foregroundColor(.white)
                                    
                                    Rectangle()
                                        .fill(showMyCircles ? Color.white : Color.clear)
                                        .frame(height: 3)
                                        .animation(.easeInOut(duration: 0.2), value: showMyCircles)
                                }
                                .frame(width: 90)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showMyCircles = true
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.top, 50)
                    .background(Color(hex: "004aad"))
                    .ignoresSafeArea(edges: .top)

                    // MARK: Search + Add
                    VStack(spacing: 0) {
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
                        }
                        // ▼︙ suggestions list – OUTSIDE the HStack
                        if !searchText.isEmpty {
                            // 1. Filter once
                            let allCircles = exploreCircles + myCircles
                            let filtered = allCircles.filter {
                                $0.name.lowercased().contains(searchText.lowercased())
                            }

                            // 2. Show results
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filtered) { circle in
                                        Button {
                                            selectedCircleToOpen = circle
                                            searchText = ""

                                            let isMember = myCircles.contains(where: { $0.id == circle.id })
                                            if isMember {
                                                triggerOpenGroupChat = true
                                            } else {
                                                showAboutPopup = true
                                            }
                                        } label: {

                                            HStack {
                                                Text(circle.name)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 16)
                                        }

                                        Divider()                     // thin separator
                                    }
                                }
                            }
                            .frame(maxHeight: 180)                   // keeps list compact
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                            .zIndex(1)                               // sit above other views
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Circle List
                    ScrollView {
                        VStack(spacing: 20) {
                            if showMyCircles {
                                Text("My Circles")
                                    .font(.title2).bold()
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if myCircles.isEmpty {
                                    Text("You haven't joined any Circles yet.")
                                        .foregroundColor(.gray)
                                        .padding(.top, 40)
                                } else {
                                    ForEach(myCircles) { circle in
                                        renderMyCircleCard(for: circle)
                                    }

                                }
                            } else {
                                HStack {
                                    Text("Explore")
                                        .font(.title2).bold()

                                    Spacer()

                                    Button(action: {
                                        withAnimation(.spring()) {
                                            showCreateCircleSheet.toggle()
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.horizontal)
                                if exploreCircles.isEmpty {
                                    Text("No Circls? Create one!")
                                        .foregroundColor(.gray)
                                        .font(.headline)
                                        .padding(.top, 40)
                                }




                                ForEach(exploreCircles) { circle in
                                    CircleCardView(
                                        circle: circle,
                                        onJoinPressed: {
                                            joinCircleAndOpen(circle: circle)
                                        },
                                        showButtons: true,
                                        isMember: myCircles.contains(where: { $0.id == circle.id }) // ✅ Dynamic check
                                    )

                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            
            // MARK: - Twitter/X Style Bottom Navigation
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Forum / Home
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            Image(systemName: "house")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("Home")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Connect and Network
                    NavigationLink(destination: PageMyNetwork().navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("Network")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Circles (Current page - highlighted)
                    VStack(spacing: 4) {
                        Image(systemName: "circle.grid.2x2.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                        Text("Circles")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Messages
                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            ZStack {
                                Image(systemName: "envelope")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                
                                if unreadMessageCount > 0 {
                                    Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(minWidth: 16, minHeight: 16)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 12, y: -12)
                                }
                            }
                            Text("Messages")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // More / Additional Resources
                    NavigationLink(destination: PageMore(
                        userFirstName: .constant(""),
                        userProfileImageURL: .constant(""),
                        unreadMessageCount: .constant(0)
                    ).navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("More")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 8)
                .background(
                    Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                        .ignoresSafeArea(edges: .bottom)
                )
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(UIColor.separator))
                        .padding(.horizontal, 16),
                    alignment: .top
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .zIndex(1)
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCircles()
            loadUserData()
        }
        .onChange(of: showMyCircles) { newValue in
            print("🔄 showMyCircles changed:", newValue)
            loadCircles()
        }
       

        NavigationLink(
            destination: GroupChatWrapper(circle: selectedCircleToOpen),
            isActive: $triggerOpenGroupChat
        ) {
            EmptyView()
        }

        NavigationLink(
            destination: GroupChatWrapper(circle: selectedCircleToOpen),
            isActive: $triggerOpenGroupChat
        ) {
            EmptyView()
        }
        .sheet(isPresented: $showAboutPopup) {
            if let circle = selectedCircleToOpen {
                NavigationView {
                    CirclPopupCard(
                        circle: circle,
                        isMember: myCircles.contains(where: { $0.id == circle.id }),
                        onJoinPressed: {
                            joinCircleAndOpen(circle: circle)
                            showAboutPopup = false
                        },
                        onOpenCircle: {
                            selectedCircleToOpen = circle
                            triggerOpenGroupChat = true
                            showAboutPopup = false
                        }
                    )
                    .navigationBarHidden(true)
                }
            }
        }


    }

    // MARK: - Load User Data
    func loadUserData() {
        // Load user profile image
        guard let profileUrl = URL(string: "https://circlapp.online/api/users/profile/\(userId)/") else { return }
        
        URLSession.shared.dataTask(with: profileUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load user profile:", error?.localizedDescription ?? "unknown")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let profileImage = json["profile_image"] as? String {
                    DispatchQueue.main.async {
                        self.userProfileImageURL = profileImage
                    }
                }
            } catch {
                print("❌ Failed to parse user profile:", error)
            }
        }.resume()
        
        // Load unread message count
        guard let messagesUrl = URL(string: "https://circlapp.online/api/messages/unread_count/\(userId)/") else { return }
        
        URLSession.shared.dataTask(with: messagesUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load unread messages:", error?.localizedDescription ?? "unknown")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let count = json["unread_count"] as? Int {
                    DispatchQueue.main.async {
                        self.unreadMessageCount = count
                    }
                }
            } catch {
                print("❌ Failed to parse unread messages:", error)
            }
        }.resume()
    }

    // MARK: - Helpers
    func imageName(for name: String) -> String {
        switch name {
        case "Lean Startup-ists": return "leanstartups"
        case "Houston Landscaping Network": return "houstonlandscape"
        case "UH Marketing": return "uhmarketing"
        default: return "uhmarketing"
        }
    }

    func membersString(for name: String) -> String {
        switch name {
        case "Lean Startup-ists": return "1.2k+"
        case "Houston Landscaping Network": return "200+"
        case "UH Marketing": return "300+"
        default: return "100+"
        }
    }
    func joinCircleAndOpen(circle: CircleData) {
        guard let url = URL(string: "https://circlapp.online/api/circles/join_circle/") else { return }

        let payload = [
            "user_id": userId,
            "circle_id": circle.id
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Join Circle error:", error.localizedDescription)
                return
            }

            print("✅ Joined circle:", circle.id)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                selectedCircleToOpen = circle
                triggerOpenGroupChat = true
            }

            loadCircles() // Refresh list
        }.resume()
    }

    func joinCircle(circleId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/join_circle/") else { return }
        let payload = [
            "user_id": userId,
            "circle_id": circleId
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Join Circle error:", error.localizedDescription)
                return
            }

            print("✅ Joined circle:", circleId)
            print("🧠 PageCircles now sees userId:", userId)
            print("🧠 Loaded userId from UserDefaults:", userId)
            loadCircles() // Refresh both tabs
        }.resume()
    }
    func createCircle() {
        guard let url = URL(string: "https://circlapp.online/api/circles/create_with_channels/") else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "name": circleName,
            "industry": circleIndustry,
         
            "description": circleDescription,
            "join_type": selectedJoinType.rawValue.lowercased(),
            "channels": selectedChannels
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                // ✅ Reset form fields here
                circleName = ""
                circleIndustry = ""
             
                circleDescription = ""
                selectedJoinType = JoinType.joinNow
                selectedChannels = []

                showCreateCircleSheet = false
                loadCircles()
            }
        }.resume()
    }



    func loadCircles() {
        print("🔍 loadCircles() called with userId:", userId)

        guard let urlMy = URL(string: "https://circlapp.online/api/circles/my_circles/\(userId)/"),
              let urlExplore = URL(string: "https://circlapp.online/api/circles/explore_circles/\(userId)/") else { return }

        func convert(_ data: [APICircle]) -> [CircleData] {
            data.map {
                CircleData(
                    id: $0.id,
                    name: $0.name,
                    industry: $0.industry,
                    memberCount: $0.member_count ?? 0,
                    imageName: imageName(for: $0.name),
                    pricing: $0.pricing,
                    description: $0.description,
                    joinType: $0.join_type == "apply_now" ? JoinType.applyNow : JoinType.joinNow,
                    channels: $0.channels ?? [],
                    creatorId: $0.creator_id,
                    isModerator: $0.is_moderator ?? false
                )
            }
        }

        URLSession.shared.dataTask(with: urlMy) { data, response, error in
            if let error = error {
                print("❌ Error loading MY circles:", error.localizedDescription)
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 MyCircles status code:", httpResponse.statusCode)
            }

            if let data = data {
                print("📥 MyCircles raw JSON:", String(data: data, encoding: .utf8) ?? "nil")

                if let decoded = try? JSONDecoder().decode([APICircle].self, from: data) {
                    DispatchQueue.main.async {
                        self.myCircles = convert(decoded)
                        print("✅ Loaded My Circles:", self.myCircles.map { $0.name })

                        for i in self.myCircles.indices {
                            let circleId = self.myCircles[i].id
                            self.fetchMembers(for: circleId) { count in
                                DispatchQueue.main.async {
                                    self.myCircles[i].memberCount = count
                                }
                            }
                        }
                    }
                } else {
                    print("❌ Failed to decode My Circles JSON")
                }
            }
        }.resume()


        URLSession.shared.dataTask(with: urlExplore) { data, response, error in
            if let error = error {
                print("❌ Error loading EXPLORE circles:", error.localizedDescription)
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 ExploreCircles status code:", httpResponse.statusCode)
            }

            if let data = data {
                print("📥 ExploreCircles raw JSON:", String(data: data, encoding: .utf8) ?? "nil")

                do {
                    let decoded = try JSONDecoder().decode([APICircle].self, from: data)
                    DispatchQueue.main.async {
                        self.exploreCircles = convert(decoded)
                        for i in self.exploreCircles.indices {
                            let circleId = self.exploreCircles[i].id
                            self.fetchMembers(for: circleId) { count in
                                DispatchQueue.main.async {
                                    self.exploreCircles[i].memberCount = count
                                }
                            }
                        }

                        print("✅ Loaded Explore Circles:", self.exploreCircles.map { $0.name })
                    }
                } catch {
                    print("❌ Failed to decode Explore Circles:", error.localizedDescription)
                }
            }
        }.resume()

    }
    func fetchMembers(for circleId: Int, completion: @escaping (Int) -> Void) {
        
        struct Member: Identifiable, Decodable, Hashable {
            let id: Int
            let full_name: String
            let profile_image: String?
            let user_id: Int
        }
        guard let url = URL(string: "https://circlapp.online/api/circles/members/\(circleId)/") else {
            completion(0)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load members for \(circleId):", error?.localizedDescription ?? "unknown")
                completion(0)
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                completion(decoded.count)
            } catch {
                print("❌ Failed to decode members for \(circleId):", error)
                completion(0)
            }
        }.resume()
    }


    

    @ViewBuilder
    func renderMyCircleCard(for circle: CircleData) -> some View {
        CircleCardView(
            onOpenCircle: {
                selectedCircleToOpen = circle
                triggerOpenGroupChat = true
            },
            circle: circle,
            showButtons: false,
            isMember: true
        )
        .padding(.horizontal) // ✅ This makes spacing match Explore
    }


}

struct GroupChatWrapper: View {
    let circle: CircleData?

    var body: some View {
        if let circle = circle {
            PageGroupchats(circle: circle).navigationBarBackButtonHidden(true)
        } else {
            EmptyView()
        }
    }
}


    
    
    // MARK: - Circle Card View (template preserved)
struct CircleCardView: View {
    var onOpenCircle: (() -> Void)? = nil

    var circle: CircleData
    @State private var showAbout = false
    @State private var selectedCircleToOpen: CircleData? = nil
    @State private var triggerOpenGroupChat = false
    var onJoinPressed: (() -> Void)? = nil
    var showButtons: Bool = true // ✅ Default to true for explore
    var isMember: Bool = false
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Image("CirclLogoButton") // Your blue circle logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .opacity(0.15)

                Image(circle.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }


            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(circle.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
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

                Text("\(circle.memberCount) Members")

                    .font(.system(size: 15))
                    .foregroundColor(.black)

                HStack(spacing: 10) {
                    Button(action: {
                        showAbout = true
                    }) {
                        Text("About")
                            .underline()
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    if showButtons {
//                        Button(action: {}) {
//                            Image(systemName: "xmark.circle.fill")
//                                .resizable()
//                                .frame(width: 22, height: 22)
//                                .foregroundColor(.red)
//                        }

                        Button(action: {
                            onJoinPressed?()
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

            // ✅ Blue arrow on the far right, vertically centered
            if isMember {
                Spacer()
                Button(action: {
                    onOpenCircle?()
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 4)
            }
        }

        .padding()
        .frame(height: 150) // ✅ Consistent card height for all
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showAbout) {
                                    NavigationView {
                                        CirclPopupCard(
                                            circle: circle,
                                            isMember: isMember,
                                            onJoinPressed: onJoinPressed,
                                            onOpenCircle: {
                                                showAbout = false
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                    onOpenCircle?()
                                                }
                                            }
                                        )
                                        .navigationBarHidden(true)
                                    }
                                }

    }
}

    
    // MARK: - Preview
    struct PageCircles_Previews: PreviewProvider {
        static var previews: some View {
            PageCircles()
        }
    }

