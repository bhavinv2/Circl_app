import SwiftUI
import Foundation


// MARK: - InviteProfileTemplate
struct InviteProfileTemplate: View {
    @State private var requestHandled = false
    @Binding var friendRequests: [PageInvites.InviteProfileData]
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    
    func acceptFriendRequest() {
        guard let receiverId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ receiverId not found")
            return
        }

        let requestBody: [String: Any] = [
            "sender_email": email,
            "receiver_id": receiverId
        ]

        guard let url = URL(string: "https://circlapp.online/api/users/accept_friend_request/"),
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
                friendRequests.removeAll { $0.email == self.email }
                alertMessage = "Friend request accepted"
                showAlert = true
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

        guard let url = URL(string: "https://circlapp.online/api/users/decline_friend_request/"),
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
                friendRequests.removeAll { $0.email == self.email }
                alertMessage = "Friend request rejected"
                showAlert = true
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
    var profileImage: String?
    var showAcceptDeclineButtons: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                // Profile Image
                if let imageURL = profileImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image("default_image")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } else {
                    Image("default_image")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                }

                
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
    var username: String
    var email: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String?

    
    var body: some View {
        VStack {
            if let imageURL = profileImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image("default_image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .padding()
            } else {
                Image("default_image")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .padding()
            }

            
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
    @Binding var friendRequests: [PageInvites.InviteProfileData]
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    var name: String
    var username: String
    var email: String
    var title: String
    var company: String
    var proficiency: String
    var tags: [String]
    var profileImage: String?
    var showAcceptDeclineButtons: Bool
    
    var body: some View {
        NavigationLink(destination: InviteProfileDetailPage(
            name: name,
            username: username,
            email: email,
            title: title,
            company: company,
            proficiency: proficiency,
            tags: tags,
            profileImage: profileImage
        )) {
            InviteProfileTemplate(
                friendRequests: $friendRequests,
                showAlert: $showAlert,
                alertMessage: $alertMessage,
                name: name,
                username: username,
                email: email,
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
    @State private var searchText: String = ""
    @State private var searchedUser: InviteProfileData?
    @State private var friendRequests: [InviteProfileData] = []
    @State private var myNetwork: [InviteProfileData] = []
    @State private var selectedUserForPreview: InviteProfileData?
    @State private var showProfilePreview: Bool = false
    @State private var selectedFullProfile: FullProfile? // Step 2: Added state for detailed profile
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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

//                            Button(action: {
//                                // Action for Filter
//                            }) {
//                                HStack {
//                                    Image(systemName: "slider.horizontal.3")
//                                        .foregroundColor(.white)
//                                    Text("Filter")
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                }
//                            }
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
                                    friendRequests: $friendRequests,
                                    showAlert: $showAlert,
                                    alertMessage: $alertMessage,
                                    name: user.name,
                                    username: user.username,
                                    email: user.email,
                                    title: user.title,
                                    company: user.company,
                                    proficiency: user.proficiency,
                                    tags: user.tags,
                                    profileImage: user.profileImage,
                                    showAcceptDeclineButtons: false
                                )

                                
                                Button(action: {
                                    sendFriendRequest(to: user.email)
                                    searchedUser = nil // ❌ clear it immediately
                                    alertMessage = "Friend request sent"
                                    showAlert = true
                                }) {
                                    Text("Send Friend Request")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hexCode: "004aad"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }

                                .padding(.horizontal)
                            }
                        }
                        
                        // Networking Requests Section
                        Text("Networking Requests")
                            .font(.headline)
                            .padding(.top)

                        if friendRequests.isEmpty {
                            Text("You have no new networking requests.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(friendRequests) { profile in
                                InviteProfileLink(
                                    friendRequests: $friendRequests,
                                    showAlert: $showAlert,
                                    alertMessage: $alertMessage,
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
                        
                        // My Network Section (Step 2: Updated with fetchUserProfile)
                        Text("My Network")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(myNetwork) { profile in
                            InviteProfileTemplate(
                                friendRequests: $friendRequests,
                                showAlert: $showAlert,
                                alertMessage: $alertMessage,
                                name: profile.name,
                                username: profile.username,
                                email: profile.email,
                                title: profile.title,
                                company: profile.company,
                                proficiency: profile.proficiency,
                                tags: profile.tags,
                                profileImage: profile.profileImage,
                                showAcceptDeclineButtons: false
                            )

                            .onTapGesture {
                                self.selectedFullProfile = nil  // Clear old data explicitly
                                fetchUserProfile(userId: profile.user_id) { profileData in
                                    DispatchQueue.main.async {
                                        if let profileData = profileData {
                                            self.selectedFullProfile = profileData
                                            self.showProfilePreview = true
                                        }
                                    }
                                }
                            }




                        }

                    }
                    .padding()
                }
                .dismissKeyboardOnScroll()
                .dismissKeyboardOnScroll()
                .sheet(isPresented: Binding(
                    get: { showProfilePreview && selectedFullProfile != nil },
                    set: { newValue in showProfilePreview = newValue }
                )) {
                    if let profile = selectedFullProfile {
                        DynamicProfilePreview(profileData: profile, isInNetwork: true)
                    }
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage))
            }

            .onAppear {
                fetchFriendRequests()
                fetchNetwork()
            }
        }
    }
    
    // MARK: - Functions
    func fetchNetwork() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        guard let url = URL(string: "https://circlapp.online/api/users/get_network/\(userId)") else {
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
        
        let urlString = "https://circlapp.online/api/users/search_user/?username=\(searchText)"
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
        
        guard let url = URL(string: "https://circlapp.online/api/users/send_friend_request/"),
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
        
        guard let url = URL(string: "https://circlapp.online/api/users/get_friend_requests/\(userId)") else {
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
    
    // Step 1: Added fetchUserProfile function
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed:", error)
                completion(nil)
                return
            }

            if let data = data {
                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                } else {
                    print("❌ Failed to decode JSON")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }


    
    // MARK: - CustomCircleButton
    struct CustomCircleButton: View {
        let iconName: String
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.fromHex("004aad"))
                    .frame(width: 60, height: 60)
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Data Model
    struct InviteProfileData: Identifiable, Codable {
        let id = UUID()
        let user_id: Int
        let name: String
        let username: String
        let email: String
        let title: String
        let company: String
        let proficiency: String
        let tags: [String]
        let profileImage: String?
    }
    
    // MARK: - FullProfile Model (Required for decoding detailed profile)
    
    
    // MARK: - Helper Function for Age Calculation
    func calculateAge(from birthday: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Assuming this format from API
        guard let birthDate = dateFormatter.date(from: birthday) else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year
    }
    
    // MARK: - Preview
    struct PageInvite_Previews: PreviewProvider {
        static var previews: some View {
            PageInvites()
        }
    }
}

