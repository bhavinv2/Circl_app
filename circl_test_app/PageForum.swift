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


    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with author, position, company, and timestamp
            HStack {
                Image(profileImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                
                VStack(alignment: .leading) {
                    Text(author)
                        .font(.headline)
                    
                    // Position and Company - New Added Element
                    HStack {
                        Text(position)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("-")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        NavigationLink(destination: Text("Company Page")) { // Replace with actual company page view
                            Text(company)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.fromHex("004aad"))
                        }
                    }
                    
                    Text(timestamp)
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
    }
}

struct PageForum: View {
    @State private var selectedCategory = "Category"
    @State private var selectedPrivacy = "Privacy"
    @State private var postContent = ""
    @State private var selectedImage: UIImage? = nil // Image picker state
    
    // State to control the image picker
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var posts: [ForumPostModel] = []
    @State private var selectedPostIdForComments: ForumPostModel? = nil

    
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
                                    submitPost()
                                }) {
                                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                                        .foregroundColor(Color.fromHex("004aad")) // Updated blue color
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
                                        toggleLike(post) // ✅ This links everything
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
                fetchPosts()
            }
        }
    }
    
    func fetchPosts() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/forum/get_posts/") else { return }

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
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 34, height: 34)
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
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Send") {
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
