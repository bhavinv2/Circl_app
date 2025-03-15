import SwiftUI
import Foundation

// MARK: - InviteProfileTemplate
struct InviteProfileTemplate: View {
    @State private var requestHandled = false
    
    func acceptFriendRequest() {
        guard let receiverId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ receiverId not found")
            return
        }

        let requestBody: [String: Any] = [
            "sender_email": email,
            "receiver_id": receiverId
        ]

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/accept_friend_request/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Invalid URL or JSON Encoding Failed")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📡 Response:", responseString)
            }

            DispatchQueue.main.async {
                self.requestHandled = true
            }
        }.resume()
    }

    func declineFriendRequest() {
        guard let receiverId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ receiverId not found")
            return
        }

        let requestBody: [String: Any] = [
            "sender_email": email,
            "receiver_id": receiverId
        ]

        guard let url = URL(string: "http://34.44.204.172:8000/api/users/decline_friend_request/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Invalid URL or JSON Encoding Failed")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.requestHandled = true
            }
        }.resume()
    }

    var name: String
    var username: String
    var email: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    var showAcceptDeclineButtons: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                // Profile Image
                Image(profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.headline)
                    
                    HStack(spacing: 5) {
                        Text(title)
                            .font(.subheadline)
                        Text("-")
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    Text("Proficient in: \(proficiency)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Conditionally show the buttons
                if showAcceptDeclineButtons {
                    HStack(spacing: 10) {
                        // MARK: Accept button action
                        Button(action: {
                            acceptFriendRequest()
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.green)
                        }

                        // MARK: Decline button action
                        Button(action: {
                            declineFriendRequest()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.red)
                        }
                    }
                }
            }

            // Tags Section
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}


// MARK: - InviteProfileDetailPage
struct InviteProfileDetailPage: View {
    var name: String
    var username: String // ✅ Add username
    var email: String    // ✅ Add email
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    
    var body: some View {
        VStack {
            Image(profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .padding()
            
            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(title)
                .font(.title2)
                .foregroundColor(.gray)
            
            Text(company)
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.bottom)
            
            Text("Proficient in: \(proficiency)")
                .font(.body)
                .foregroundColor(.gray)
            
            // Tags Section
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .padding()
    }
}

// MARK: - InviteProfileLink
struct InviteProfileLink: View {
    var name: String
    var username: String // ✅ Ensure username exists
    var email: String // ✅ Ensure email exists
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String
    var showAcceptDeclineButtons: Bool
    
    var body: some View {
        NavigationLink(destination: InviteProfileDetailPage(
            name: name,
            username: username, // ✅ Pass username
            email: email, // ✅ Pass email
            title: title,
            company: company,
            proficiency: proficiency,
            tags: tags,
            profileImage: profileImage
        )) {
            InviteProfileTemplate(
                name: name,
                username: username, // ✅ Pass username
                email: email, // ✅ Pass email
                title: title,
                company: company,
                proficiency: proficiency,
                tags: tags,
                profileImage: profileImage,
                showAcceptDeclineButtons: showAcceptDeclineButtons
            )
        }
    }
}

// MARK: - PageInvites
struct PageInvites: View {
    @State private var searchText: String = "" // Stores the entered username
    @State private var searchedUser: InviteProfileData? // Stores the searched user
    @State private var friendRequests: [InviteProfileData] = [] // Now dynamic
    @State private var myNetwork: [InviteProfileData] = []
    
    
    
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
                
                // Navigation Bar (tabNavigation)
                HStack(spacing: 10) {
                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                        Text("Messages")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                        Text("Circles")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: PageInvites().navigationBarBackButtonHidden(true)) {
                        Text("Friends")
                            .font(.system(size: 12))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.fromHex("ffde59"))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // Scrollable Section
                ScrollView {
                    VStack(spacing: 20) {
                        // Search Bar with Search Button
                        HStack {
                            TextField("Enter unique username...", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: searchUserByUsername) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        
                        // Display Searched User
                        if let user = searchedUser {
                            VStack {
                                InviteProfileLink(
                                    name: user.name,
                                    username: user.username,  // ✅ Add username
                                    email: user.email,  // ✅ Ensure email is passed
                                    title: user.title,
                                    company: user.company,
                                    proficiency: user.proficiency,
                                    tags: user.tags,
                                    profileImage: user.profileImage,
                                    showAcceptDeclineButtons: false
                                )
                                
                                Button(action: { sendFriendRequest(to: user.email) }) {
                                    Text("Send Friend Request")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Networking Requests Section
                        Text("Networking Requests")
                            .font(.headline)
                            .padding(.top)

                        // ✅ Show message if there are no requests
                        if friendRequests.isEmpty {
                            Text("You have no new networking requests.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            // ✅ Show the list of networking requests when available
                            ForEach(friendRequests) { profile in
                                InviteProfileLink(
                                    name: profile.name,
                                    username: profile.username,
                                    email: profile.email,
                                    title: profile.title,
                                    company: profile.company,
                                    proficiency: profile.proficiency,
                                    tags: profile.tags,
                                    profileImage: profile.profileImage,
                                    showAcceptDeclineButtons: true
                                )
                            }
                        }

                        
                        Divider()
                            .padding(.vertical)
                        
                        // My Network Section
                        Text("My Network")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(myNetwork) { profile in
                            InviteProfileLink(
                                name: profile.name,
                                username: profile.username,  // ✅ Ensure username is passed
                                email: profile.email,        // ✅ Ensure email is passed
                                title: profile.title,
                                company: profile.company,
                                proficiency: profile.proficiency,
                                tags: profile.tags,
                                profileImage: profile.profileImage,
                                showAcceptDeclineButtons: false
                            )
                        }
                    }
                    .padding()
                }
                
                // Footer Section
                HStack(spacing: 15) {
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
                    }
                    NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "briefcase.fill")
                    }
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "captions.bubble.fill")
                    }
                    NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "building.columns.fill")
                    }
                    NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "newspaper")
                    }
                }
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchFriendRequests()
                fetchNetwork()            }
        }
    }
    
    // MARK: - Functions
    func fetchNetwork() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get_network/\(userId)") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("❌ Server error:", httpResponse.statusCode)
                return
            }
            
            if let data = data {
                do {
                    let network = try JSONDecoder().decode([InviteProfileData].self, from: data)
                    DispatchQueue.main.async {
                        self.myNetwork = network.isEmpty ? [] : network
                    }
                } catch {
                    print("❌ Error decoding network:", error)
                }
            }
        }.resume()
    }
    
    
    
    func searchUserByUsername() {
        guard !searchText.isEmpty else { return }
        
        let urlString = "http://34.44.204.172:8000/api/users/search_user/?username=\(searchText)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                // Log the raw API response
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("📡 RAW RESPONSE:", rawResponse)
                }
                
                do {
                    let user = try JSONDecoder().decode(InviteProfileData.self, from: data)
                    DispatchQueue.main.async {
                        self.searchedUser = user
                    }
                } catch {
                    print("❌ Error decoding user:", error)
                }
            }
        }.resume()
    }
    
    func sendFriendRequest(to email: String) {
        guard let senderId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user ID found in UserDefaults.")
            return
        }
        
        let requestBody: [String: Any] = [
            "user_id": senderId,
            "receiver_email": email
        ]
        
        guard let url = URL(string: "http://34.44.204.172:8000/api/users/send_friend_request/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Invalid URL or JSON Encoding Failed")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // ✅ Explicitly set POST method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP Response")
                return
            }
            
            print("📡 HTTP Status Code:", httpResponse.statusCode)
            
            if let data = data {
                let rawResponse = String(data: data, encoding: .utf8)
                print("📡 RAW RESPONSE:", rawResponse ?? "No response data")
                
                if httpResponse.statusCode == 201 {
                    DispatchQueue.main.async {
                        print("✅ Friend request sent successfully!")
                    }
                } else {
                    DispatchQueue.main.async {
                        print("❌ Failed to send friend request.")
                    }
                }
            }
        }.resume()
    }
    
    
    func fetchFriendRequests() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        guard let url = URL(string: "http://34.44.204.172:8000/api/users/get_friend_requests/\(userId)") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("❌ Server error:", httpResponse.statusCode)
                return
            }
            
            if let data = data {
                do {
                    let requests = try JSONDecoder().decode([InviteProfileData].self, from: data)
                    DispatchQueue.main.async {
                        self.friendRequests = requests.isEmpty ? [] : requests
                    }
                } catch {
                    print("❌ Error decoding friend requests:", error)
                }
            }
        }.resume()
    }
    
    
    
    
    // MARK: - CustomCircleButton
    
    
    // MARK: - Data Model
    struct InviteProfileData: Identifiable, Codable {
        let id = UUID()
        let name: String
        let username: String  // ✅ Ensure username exists
        let email: String     // ✅ Ensure email exists
        let title: String
        let company: String
        let proficiency: String
        let tags: [String]
        let profileImage: String
    }
    
    // MARK: - Preview
    struct PageInvite_Previews: PreviewProvider {
        static var previews: some View {
            PageInvites()
        }
    }
}
