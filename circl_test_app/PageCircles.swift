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
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var selectedCircleToOpen: CircleData? = nil
    @State private var triggerOpenGroupChat = false
   
    @State private var showAddChannelPopup = false
    @State private var newChannelName = "#"

    @State private var showCreateCircleSheet = false
    @State private var circleName: String = ""
    @State private var circleIndustry: String = ""
    @State private var circleDescription: String = ""
    @State private var selectedJoinType: JoinType = .joinNow

    @State private var showMyCircles = false
    @State private var myCircles: [CircleData] = []
    @State private var exploreCircles: [CircleData] = []
    @AppStorage("user_id") private var userId: Int = 0

    @State private var selectedChannels: [String] = []
    let allChannelOptions = ["#Welcome", "#Founder-Chat", "#Introductions", "#Case-Studies"]



    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if showMenu {
                            withAnimation(.spring()) {
                                showMenu = false
                            }
                        }
                    }

                if showCreateCircleSheet {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showCreateCircleSheet = false }
                        }
                        .transition(.opacity)
                }

                VStack(spacing: 0) {
                    // MARK: Header
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

                    // MARK: Search + Add
                    VStack(spacing: 10) {
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
                            
                            if !searchText.isEmpty {
                                let allCircles = exploreCircles + myCircles
                                let filtered = allCircles.filter { $0.name.lowercased().contains(searchText.lowercased()) }

                                ScrollView {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(filtered) { circle in
                                           
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }


                            
                        }

                        Picker("View", selection: $showMyCircles) {
                            Text("Explore").tag(false)
                            Text("My Circles").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    .padding()

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

                // MARK: - Floating Ellipsis Menu
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

//                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
//                            }
//
//                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
//                                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
//                            }

                            Divider()

                            NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true)) {
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
                    .padding(.bottom, -15)

                }
                .sheet(isPresented: $showCreateCircleSheet) {
                    VStack(spacing: 16) {
                        Text("Create a Circl")
                            .font(.title2)
                            .bold()

                        TextField("Circle Name", text: $circleName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        TextField("Industry", text: $circleIndustry)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        TextField("About", text: $circleDescription)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)


                    

                        


                        Divider()

                        // ✅ Channel Selector Here
                        HStack {
                            Text("Select Channels")
                                .font(.headline)

                        }


                        ForEach(allChannelOptions, id: \.self) { channel in
                            if channel == "#Welcome" {
                                Toggle(channel, isOn: .constant(true))
                                    .disabled(true) // 🔒 Always selected
                                    .foregroundColor(.gray)
                            } else {
                                Toggle(channel, isOn: Binding(
                                    get: { selectedChannels.contains(channel) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedChannels.append(channel)
                                        } else {
                                            selectedChannels.removeAll { $0 == channel }
                                        }
                                    }
                                ))
                            }
                        }


                        Spacer()

                        Button(action: {
                            createCircle()
                        }) {
                            Text("Create Circl")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                
                


                .padding()
                .zIndex(1)
                .navigationBarHidden(true)
                .onAppear { loadCircles() }
                .onAppear {
                    loadCircles()
                }
                .onChange(of: showMyCircles) { newValue in
                    print("🔄 showMyCircles changed:", newValue)
                    loadCircles()
                }
            }

            .background(
                Color.clear
                    .contentShape(Rectangle()) // makes the whole area tappable
                    .onTapGesture {
                        if showMenu {
                            withAnimation(.spring()) {
                                showMenu = false
                            }
                        }
                    }
            )
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
                selectedJoinType = .joinNow
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
                    joinType: $0.join_type == "apply_now" ? .applyNow : .joinNow,
                    channels: $0.channels ?? [],
                    creatorId: $0.creator_id, // 👈 Add this// ✅ Fallback to empty
                    isModerator: $0.is_moderator ?? false

 // 🆕 Add this
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
                print("📥 MyCircles raw JSON:", String(data: data, encoding: .utf8) ?? "nil")


                if let decoded = try? JSONDecoder().decode([APICircle].self, from: data) {
                    DispatchQueue.main.async {
                        myCircles = convert(decoded)
                        print("✅ Loaded My Circles:", myCircles.map { $0.name })

                        for i in myCircles.indices {
                            let circleId = myCircles[i].id
                            fetchMembers(for: circleId) { count in
                                DispatchQueue.main.async {
                                    myCircles[i].memberCount = count
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
                        exploreCircles = convert(decoded)
                        for i in exploreCircles.indices {
                            let circleId = exploreCircles[i].id
                            fetchMembers(for: circleId) { count in
                                DispatchQueue.main.async {
                                    exploreCircles[i].memberCount = count
                                }
                            }
                        }

                        print("✅ Loaded Explore Circles:", exploreCircles.map { $0.name })
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


// MARK: - Circle Data (template preserved)
enum JoinType: String {
    case applyNow = "Apply Now"
    case joinNow = "Join Now"
}

struct CircleData: Identifiable {
    let id: Int
    let name: String
    let industry: String
    var memberCount: Int
   // ✅ <-- instead of String
    let imageName: String
    let pricing: String
    let description: String
    let joinType: JoinType
    let channels: [String]
    let creatorId: Int
    let isModerator: Bool
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
            Image(circle.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

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

