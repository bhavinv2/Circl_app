import SwiftUI
import UIKit

struct ForumPostModel: Identifiable, Codable {
    let id: Int
    let user: String
    let content: String
    let category: String
    let privacy: String
    let created_at: String
    let comment_count: Int? // already added

    // ✅ Add these two missing fields
    let like_count: Int
    let liked_by_user: Bool
}

struct CommentModel: Identifiable, Codable {
    let id: Int
    let user: String
    let text: String
    let created_at: String
    let like_count: Int
    let liked_by_user: Bool
}
    
// ✅ Added timeAgo function
func timeAgo(from dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    guard let postDate = formatter.date(from: dateString) else {
        return "Just now"
    }

    let secondsAgo = Int(Date().timeIntervalSince(postDate))

    let minute = 60
    let hour = 3600
    let day = 86400
    let week = 604800
    let month = 2592000
    let year = 31536000

    switch secondsAgo {
    case 0..<10:
        return "Just now"
    case 10..<minute:
        return "\(secondsAgo) sec\(secondsAgo > 1 ? "s" : "") ago"
    case minute..<hour:
        return "\(secondsAgo / minute) min ago"
    case hour..<day:
        return "\(secondsAgo / hour) hour\(secondsAgo / hour > 1 ? "s" : "") ago"
    case day..<week:
        return "\(secondsAgo / day) day\(secondsAgo / day > 1 ? "s" : "") ago"
    case week..<month:
        return "\(secondsAgo / week) week\(secondsAgo / week > 1 ? "s" : "") ago"
    case month..<year:
        return "\(secondsAgo / month) month\(secondsAgo / month > 1 ? "s" : "") ago"
    default:
        return "\(secondsAgo / year) year\(secondsAgo / year > 1 ? "s" : "") ago"
    }
}



struct ForumPost: View {
    let content: String
    let author: String
    let timestamp: String
    let category: String
    let profileImageName: String
    let position: String // Added position
    let company: String // Added company
    var onComment: () -> Void // 👈 Added callback for comment action
    let commentCount: Int
    let likeCount: Int
    let likedByUser: Bool
    let toggleLike: () -> Void
    let isCurrentUser: Bool
    let onDelete: () -> Void

    @State private var showOptionsBox = false
    @State private var showDeleteConfirmation = false



    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                // Header with author, position, company, and timestamp
                HStack(alignment: .top, spacing: 12) {
                    Image("default_image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 1)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(author)
                                .font(.headline)
                            Text(position)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Text(timeAgo(from: timestamp))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }



                    Spacer()

                    Text(category)
                        .font(.caption)
                        .padding(8)
                        .background(Color.fromHex("ffde59"))
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .offset(y: 25)
                }

                // Post Content
                Text(content)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.black)
                
                // Actions: Like, Comment, Share
                HStack {
                    // ✅ Like Button (dynamic icon + count)
                    Button(action: {
                        toggleLike()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundColor(likedByUser ? .red : .gray)
                            Text("Like")
                            Text("(\(likeCount))")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }

                    Spacer()

                    // ✅ Comment Button
                    Button(action: {
                        onComment()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "message")
                            Text("Comment")
                            Text("(\(commentCount))")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }

                    Spacer()

                    // ✅ Share Button
                    Button(action: {
                        // TODO: Add share functionality
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)

            // ✅ Floating delete button
            if isCurrentUser {
                ZStack(alignment: .topTrailing) {
                    // Tapping outside closes the popup
                    if showOptionsBox {
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showOptionsBox = false
                            }
                    }

                    HStack(spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            Button(action: {
                                showOptionsBox.toggle()
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 25, weight: .regular))
                            }

                            if showOptionsBox {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Button("Delete Post") {
                                        showOptionsBox = false
                                        showDeleteConfirmation = true
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(25)
                                .shadow(radius: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                                .offset(x: -25, y: 0)
                            }
                        }
                    }
                    .offset(x: -25, y: 20)

                    .alert(isPresented: $showDeleteConfirmation) {
                        Alert(
                            title: Text("Delete Post?"),
                            message: Text("Are you sure you want to delete this post?"),
                            primaryButton: .destructive(Text("Delete")) {
                                onDelete()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }


        }
    }
}

struct PageForum: View {
    @State private var selectedCategory = "Category"
    @State private var selectedPrivacy = "Public"



    @State private var postContent = ""
    @State private var selectedImage: UIImage? = nil // Image picker state
    
    // State to control the image picker
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var posts: [ForumPostModel] = []
    @State private var selectedPostIdForComments: ForumPostModel? = nil

    @State private var loggedInUserFullName: String = "" // ✅ Added state for logged-in user's full name
    
    @State private var showCategoryAlert = false
    @State private var selectedFilter: String = "public"




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
                            
                            HStack(spacing: 0) {
                                Button(action: {
                                    withAnimation {
                                        selectedFilter = "public"
                                        UserDefaults.standard.set("public", forKey: "selectedFilter")
                                        fetchPosts()
                                    }
                                }) {
                                    Text("Public")
                                        .fontWeight(selectedFilter == "public" ? .bold : .regular)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedFilter == "public" ? Color.white.opacity(0.15) : Color.clear)
                                        .cornerRadius(8)
                                        .animation(.easeInOut(duration: 0.2), value: selectedFilter)
                                }

                                Button(action: {
                                    withAnimation {
                                        selectedFilter = "my_network"
                                        UserDefaults.standard.set("my_network", forKey: "selectedFilter")
                                        fetchPosts()
                                    }
                                }) {
                                    Text("My Network")
                                        .fontWeight(selectedFilter == "my_network" ? .bold : .regular)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedFilter == "my_network" ? Color.white.opacity(0.15) : Color.clear)
                                        .cornerRadius(8)
                                        .animation(.easeInOut(duration: 0.2), value: selectedFilter)
                                }
                            }
                            .background(Color.fromHex("004aad"))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, -12) // 👈 Try 8 or even 4 for more tightness






                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            // Add the Bubble and Person icons above "Hello, Fragne"
                            VStack {
                                HStack(spacing: 10) {
                                    // Navigation Link for Bubble Symbol
                                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)  // Adjust size
                                            .foregroundColor(.white)
                                    }

                                    // Person Icon
                                    NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.white)
                                    }
                                }

                                // "Hello, Fragne" text below the icons
                                Text("Hello, Fragne")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad")) // Updated blue color
                }
                
                // Scrollable View Section
                ScrollView {
                    VStack(spacing: 20) {
                        // Write a Post Section with White Background
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Write a Post")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            // Text Box for Post Content
                            HStack {
                                TextField("Ask a question, or share some knowledge", text: $postContent)
                                    .padding()
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                             //Submit button to backend
                                Button(action: {
                                    if selectedCategory == "Category" {
                                        showCategoryAlert = true
                                    } else {
                                        submitPost()
                                    }

                                }) {
                                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                                        .foregroundColor(Color.fromHex("004aad"))
                                }



                            }
                            
                            // Image Preview
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .padding(.top, 10)
                            }
                            
                            // Dropdown and Buttons in a Smaller Frame
                            HStack(spacing: 10) {
                                // Category Dropdown
                                Menu {
                                    Button("Advice & Tips", action: { selectedCategory = "Advice & Tips" })
                                    Button("Personal Development", action: { selectedCategory = "Personal Development" })
                                    Button("Experience", action: { selectedCategory = "Experience" })
                                    Button("Product Launch", action: { selectedCategory = "Product Launch" })
                                    Button("Funding", action: { selectedCategory = "Funding" })
                                    Button("Investment", action: { selectedCategory = "Investment" })
                                    Button("Networking", action: { selectedCategory = "Networking" })
                                    Button("Collaboration", action: { selectedCategory = "Collaboration" })
                                    Button("News & Trends", action: { selectedCategory = "News & Trends" })
                                    Button("Challenges", action: { selectedCategory = "Challenges" })
                                    Button("Marketing", action: { selectedCategory = "Marketing" })
                                    Button("Growth", action: { selectedCategory = "Growth" })
                                    Button("Sales", action: { selectedCategory = "Sales" })
                                    Button("Technology", action: { selectedCategory = "Technology" })
                                    Button("Legal & Compliance", action: { selectedCategory = "Legal & Compliance" })
                                    Button("Productivity", action: { selectedCategory = "Productivity" })
                                    
                                } label: {
                                    HStack {
                                        Text(selectedCategory)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                    .frame(width: 120) // Minimized width
                                }
                                
                                // Add Pictures Dropdown
                                Menu {
                                    Button("Upload from Camera") {
                                        sourceType = .camera
                                        isImagePickerPresented = true
                                    }
                                    Button("Upload from Gallery") {
                                        sourceType = .photoLibrary
                                        isImagePickerPresented = true
                                    }
                                } label: {
                                    HStack {
                                        Text("Pictures")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "plus")
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                    .frame(width: 120) // Minimized width
                                }
                                
                                // Privacy Dropdown
                                Menu {
                                    Button("Public", action: { selectedPrivacy = "Public" })
                                    Button("My Network", action: { selectedPrivacy = "My Network" })
                                } label: {
                                    HStack {
                                        Text(selectedPrivacy)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                    .frame(width: 120) // Minimized width
                                }
                            }
                        }
                        .padding()
                        .background(Color.white) // White background for the "Write a Post" section
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                        // Forum Posts List
                        VStack(spacing: 10) {
                            ForEach(posts) { post in
                               

                                ForumPost(
                                    content: post.content,
                                    author: post.user,
                                    timestamp: post.created_at,
                                    category: post.category,
                                    profileImageName: "profile_image",
                                    position: "Entrepreneur",
                                    company: "Circl",
                                    onComment: {
                                        selectedPostIdForComments = post
                                    },
                                    commentCount: post.comment_count ?? 0,
                                    likeCount: post.like_count,
                                    likedByUser: post.liked_by_user,
                                    toggleLike: {
                                        toggleLike(post)
                                    },
                                    isCurrentUser: post.user == loggedInUserFullName,
                                    onDelete: {
                                        deletePost(post.id)
                                    }
                                )
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray6))
                
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
                .frame(height: 80) // Fixed height for footer
                .frame(maxWidth: .infinity) // Ensure footer spans full width
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
            .sheet(item: $selectedPostIdForComments) { post in
                CommentSheet(
                    postId: post.id,
                    isPresented: Binding(
                        get: { selectedPostIdForComments != nil },
                        set: { newValue in
                            if !newValue {
                                selectedPostIdForComments = nil
                            }
                        }
                    ),
                    onDismiss: {
                        fetchPosts() // ✅ Refresh posts after comment view closes
                    }
                )
            }
            .onAppear {
                loggedInUserFullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
                selectedFilter = UserDefaults.standard.string(forKey: "selectedFilter") ?? "public"
                fetchPosts()
            }

            .alert("Please select a category to post.", isPresented: $showCategoryAlert) {
                Button("OK", role: .cancel) { }
            }
            


        }
    }
    
    func fetchPosts() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/get_posts/?filter=\(selectedFilter)") else { return }


        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Error fetching posts:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 GET Status Code:", httpResponse.statusCode)
            }

            if let data = data {
                let raw = String(data: data, encoding: .utf8) ?? "No response"
                print("📡 GET Raw Response:", raw)

                do {
                    let decoded = try JSONDecoder().decode([ForumPostModel].self, from: data)
                    DispatchQueue.main.async {
                        self.posts = decoded
                    }
                } catch {
                    print("❌ Decoding error:", error)
                }
            }
        }.resume()
    }

    func submitPost() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/create_post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "content": postContent,
            "category": selectedCategory,
            "privacy": selectedPrivacy
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error submitting post:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code:", httpResponse.statusCode)
            }

            if let data = data {
                let raw = String(data: data, encoding: .utf8) ?? "No response"
                print("📡 Raw Response:", raw)

                // ✅ Decode single post (optional)
                do {
                    let _ = try JSONDecoder().decode(ForumPostModel.self, from: data)
                    print("✅ Post decoded successfully")
                } catch {
                    print("❌ Decoding single post error:", error)
                }

                DispatchQueue.main.async {
                    postContent = ""
                    fetchPosts()
                }
            }
        }.resume()
    }

    func toggleLike(_ post: ForumPostModel) {
        let endpoint = post.liked_by_user ? "unlike" : "like"
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/posts/\(post.id)/\(endpoint)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchPosts() // ✅ Refresh post list
            }
        }.resume()
    }

    func deletePost(_ postId: Int) {
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/delete_post/\(postId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchPosts() // ✅ Refresh posts after deletion
            }
        }.resume()
    }
}

struct CommentSheet: View {
    let postId: Int
    @Binding var isPresented: Bool
    var onDismiss: () -> Void = {} // ✅ New callback

    @State private var newComment = ""
    @State private var comments: [CommentModel] = []

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(comments) { comment in
                            HStack(alignment: .top, spacing: 12) {
                                Image("default_image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 34, height: 34)
                                    .clipShape(Circle())
                                    .shadow(radius: 1)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(comment.user)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)

                                    Text(comment.text)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }

                                Spacer()
                            }
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(25)

                    Button("Post") {
                        submitComment()
                    }
                }
                .padding()
            }
            .navigationBarTitle("Comments", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    isPresented = false
                    onDismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
            )
            .onAppear {
                fetchComments()
            }
        }
    }

    func fetchComments() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/comments/\(postId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([CommentModel].self, from: data) {
                    DispatchQueue.main.async {
                        comments = decoded
                    }
                }
            }
        }.resume()
    }

    func submitComment() {
        print("🟡 Trying to submit comment: \(newComment)")

        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/comments/add/") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            print("🔐 Auth Token found: \(token.prefix(10))...")
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ No auth token found")
        }

        let body: [String: Any] = ["post_id": postId, "text": newComment]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 COMMENT Status Code:", httpResponse.statusCode)
            }

            if let data = data {
                let raw = String(data: data, encoding: .utf8) ?? "No response"
                print("📡 COMMENT Raw Response:", raw)

                DispatchQueue.main.async {
                    newComment = ""
                    fetchComments()
                }
            }
        }.resume()
    }
    
    func toggleLike(_ comment: CommentModel) {
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/comments/\(comment.id)/\(comment.liked_by_user ? "unlike" : "like")/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchComments() // Refresh after like/unlike
            }
        }.resume()
    }
}

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

// Extension to add hex color support in SwiftUI as a static method
extension Color {
    static func fromHexCode(_ hex: String) -> Color {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}

// Image Picker View
struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    var body: some View {
        ImagePickerController(selectedImage: $selectedImage, sourceType: sourceType)
    }
}

// ImagePickerController Bridge for UIKit to SwiftUI
struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerController
        
        init(parent: ImagePickerController) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct PageForum_Previews: PreviewProvider {
    static var previews: some View {
        PageForum()
    }
}
