import SwiftUI
import UIKit

struct ForumPostModel: Identifiable, Codable {
    let id: Int
    let user: String
    let user_id: Int
    let profileImage: String?

    let content: String
    let category: String
    let privacy: String
    let image: String?
    let created_at: String
    let comment_count: Int?
    let like_count: Int
    let liked_by_user: Bool
    let isMentor: Bool?

    enum CodingKeys: String, CodingKey {
        case id, user, user_id, content, category, privacy, image, created_at
        case comment_count, like_count, liked_by_user
        case profileImage = "profile_image"
        case isMentor = "is_mentor"
    }
}

struct CommentModel: Identifiable, Codable {
    let id: Int
    let user: String
    let text: String
    let created_at: String
    let like_count: Int
    let liked_by_user: Bool
    let profile_image: String?
}
    
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
    let company: String
    let postID: Int
    var onComment: () -> Void
    let commentCount: Int
    let likeCount: Int
    let likedByUser: Bool
    let toggleLike: () -> Void
    let isCurrentUser: Bool
    let onDelete: () -> Void
    let onTapProfile: () -> Void
    let isMentor: Bool

    @State private var showOptionsBox = false
    @State private var showDeleteConfirmation = false
    @State private var showReportSheet = false


    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    Button(action: {
                        onTapProfile()
                    }) {
                        AsyncImage(url: URL(string: profileImageName)) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Image("default_image").resizable().aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(author).font(.headline)
                            Text(isMentor ? "Mentor" : "Entrepreneur").font(.subheadline).foregroundColor(.gray)
                        }

                        Text(timeAgo(from: timestamp))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    if !category.trimmingCharacters(in: .whitespaces).isEmpty && category != "Category" {
                        Text(category)
                            .font(.caption)
                            .padding(8)
                            .background(Color.fromHex("ffde59"))
                            .foregroundColor(.black)
                            .cornerRadius(5)
                            .offset(y: 25)
                    }
                }

                Text(content).font(.body).lineLimit(3).foregroundColor(.black)

                // Buttons (Like, Comment)
                HStack {
                    Button(action: { toggleLike() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundColor(likedByUser ? .red : .gray)
                            Text("Like")
                            Text("(\(likeCount))").foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }

                    Spacer()

                    Button(action: { onComment() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "message")
                            Text("Comment")
                            Text("(\(commentCount))").foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }

                    Spacer()
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)

            ZStack(alignment: .topTrailing) {
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
                                if isCurrentUser {
                                    Button("Delete Post") {
                                        showOptionsBox = false
                                        showDeleteConfirmation = true
                                    }
                                    .foregroundColor(.red)
                                } else {
                                    Button("Report Post") {
                                        showOptionsBox = false
                                        showReportSheet = true
                                    }
                                    .foregroundColor(.red)
                                }
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
            }
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
            .sheet(isPresented: $showReportSheet) {
                ReportPostView(postID: postID, isPresented: $showReportSheet)
            }

        }

    }
}


struct ReportPostView: View {
    let postID: Int
    @Binding var isPresented: Bool
    @State private var selectedReason = ""
    @State private var submitting = false

    let reasons = [
        "Spam or misleading",
        "Harassment or hate speech",
        "Explicit content",
        "Violence or harmful behavior",
        "Other"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Why are you reporting this post?")) {
                    Picker("Select reason", selection: $selectedReason) {
                        ForEach(reasons, id: \.self) { Text($0) }
                    }
                }

                if submitting {
                    ProgressView("Submitting...")
                }

                Button("Submit Report") {
                    submitReport()
                }
                .disabled(selectedReason.isEmpty)
            }
            .navigationTitle("Report Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }

    func submitReport() {
        guard let url = URL(string: "https://circlapp.online/api/report_post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: [String: Any] = [
            "post_id": postID,
            "reason": selectedReason
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                isPresented = false
            }
        }.resume()
    }
}


struct ForumMainContent: View {
    @Binding var selectedFilter: String
    @Binding var selectedCategory: String
    @Binding var selectedPrivacy: String
    @Binding var postContent: String
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var posts: [ForumPostModel]
    @Binding var selectedPostIdForComments: ForumPostModel?
    @Binding var loggedInUserFullName: String
    @Binding var selectedProfile: FullProfile?
    @Binding var showProfileSheet: Bool
    @Binding var showCategoryAlert: Bool
    @Binding var isLoading: Bool
    @Binding var showPageLoading: Bool
    @State private var showMenu = false



    var fetchPosts: () -> Void
    var submitPost: () -> Void
    var deletePost: (Int) -> Void
    var toggleLike: (ForumPostModel) -> Void
    var fetchUserProfile: (Int, @escaping (FullProfile?) -> Void) -> Void

    var body: some View {
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
                        .padding(.leading, -12)
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
            
            ScrollView {
                if showPageLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading Posts...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                                                    Text("Write a Post")
                                                        .font(.headline)
                                                        .foregroundColor(.black)
                                                    
                                                    HStack {
                                                        TextField("Ask a question, or share some knowledge", text: $postContent)
                                                            .padding()
                                                            .background(Color(UIColor.systemGray4))
                                                            .cornerRadius(5)
                                                        Button(action: {
                                                            submitPost()
                                                        }) {
                                                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                                                                .foregroundColor(Color.fromHex("004aad"))
                                                        }

                                                    }
                                                    
//                                                    if let selectedImage = selectedImage {
//                                                        Image(uiImage: selectedImage)
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .frame(height: 200)
//                                                            .cornerRadius(10)
//                                                            .padding(.top, 10)
//                                                    }
                                                    
                                                    HStack(spacing: 10) {
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
                                                            .frame(width: 120)
                                                        }
                                                        
//                                                        Menu {
//                                                            Button("Upload from Camera") {
//                                                                sourceType = .camera
//                                                                isImagePickerPresented = true
//                                                            }
//                                                            Button("Upload from Gallery") {
//                                                                sourceType = .photoLibrary
//                                                                isImagePickerPresented = true
//                                                            }
//                                                        } label: {
//                                                            HStack {
//                                                                Text("Pictures")
//                                                                    .font(.subheadline)
//                                                                Spacer()
//                                                                Image(systemName: "plus")
//                                                            }
//                                                            .padding(.horizontal, 8)
//                                                            .padding(.vertical, 6)
//                                                            .background(Color(UIColor.systemGray4))
//                                                            .cornerRadius(5)
//                                                            .frame(width: 120)
//                                                        }
                                                        
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
                                                            .frame(width: 120)
                                                        }
                                                    }
                                                }
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                .shadow(radius: 3)
                                                
                                                ForEach(posts) { post in
                                                    ForumPost(
                                                        content: post.content,
                                                        author: post.user,
                                                        timestamp: post.created_at,
                                                        category: post.category,
                                                        profileImageName: post.profileImage ?? "",
                                                        company: "Circl",
                                                        postID: post.id,  // ✅ Moved here
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
                                                        },
                                                        onTapProfile: {
                                                            fetchUserProfile(post.user_id) { profile in
                                                                if let profile = profile {
                                                                    selectedProfile = profile
                                                                    showProfileSheet = true
                                                                }
                                                            }
                                                        },
                                                        isMentor: post.isMentor ?? false
                                                    )

                                                    .onAppear {
                                                        print("🧠 profileImage for \(post.user): \(post.profileImage ?? "nil")")
                                                    }
                                                    .padding(.bottom, 10)
                                                }
                        // your posts go here
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGray6))
            .dismissKeyboardOnScroll()

            
            
        }
    }
}

// [Previous code remains exactly the same until the PageForum struct]

struct PageForum: View {
    @State private var selectedCategory = "Category"
    @State private var selectedPrivacy = "Public"
    @State private var postContent = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var posts: [ForumPostModel] = []
    @State private var selectedPostIdForComments: ForumPostModel?
    @State private var loggedInUserFullName: String = ""
    @State private var showCategoryAlert = false
    @State private var selectedFilter: String = "public"
    @State private var selectedProfile: FullProfile?
    @State private var showProfileSheet = false
    @State private var isLoading = false
    @State private var showPageLoading = true
    @State private var userNetworkIds: [Int] = []
    @State private var showMenu = false
    @State private var profileUserId: Int? = nil
    @State private var showProfile: Bool = false
    @State private var postToShowComments: Int? = nil
    @State private var showCommentSheet: Bool = false
    @State private var showKeyboard: Bool = false



    
    

    var body: some View {
        // Remove NavigationView from here and just use ForumMainContent directly
        ZStack(alignment: .bottomTrailing) {
            ForumMainContent(
                selectedFilter: $selectedFilter,
                selectedCategory: $selectedCategory,
                selectedPrivacy: $selectedPrivacy,
                postContent: $postContent,
                selectedImage: $selectedImage,
                isImagePickerPresented: $isImagePickerPresented,
                sourceType: $sourceType,
                posts: $posts,
                selectedPostIdForComments: $selectedPostIdForComments,
                loggedInUserFullName: $loggedInUserFullName,
                selectedProfile: $selectedProfile,
                showProfileSheet: $showProfileSheet,
                showCategoryAlert: $showCategoryAlert,
                isLoading: $isLoading,
                showPageLoading: $showPageLoading,
             
                fetchPosts: fetchPostsWithoutLoading,
                submitPost: submitPost,
                deletePost: deletePost,
                toggleLike: toggleLike,
                fetchUserProfile: fetchUserProfile
            )


            // 🟦 Floating Ellipsis Menu (with tap-away dismiss)
            // Floating Ellipsis Menu (fixed position, tap away to close)
            ZStack(alignment: .bottomTrailing) {
                if showMenu {
                    Color.black.opacity(0.001) // invisible but tappable
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }
                        .zIndex(1)
                }

                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Navigate")
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
                    .padding(.bottom, -12)
                    
                }
                .padding()
                .zIndex(2)
            }





        }
        .sheet(item: $selectedPostIdForComments) { selectedPost in
            CommentSheet(
                postId: selectedPost.id,
                isPresented: Binding(
                    get: { selectedPostIdForComments != nil },
                    set: { if !$0 { selectedPostIdForComments = nil } }
                )
            )
        }


            


        .onAppear {
            loggedInUserFullName = UserDefaults.standard.string(forKey: "user_fullname") ?? ""
            selectedFilter = UserDefaults.standard.string(forKey: "selectedFilter") ?? "public"
            fetchUserNetworkIds()
            fetchPostsWithLoading()
        }

        .alert("Please select a category to post.", isPresented: $showCategoryAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - Fetch Posts Functions
    
    func fetchPostsWithLoading() {
        showPageLoading = true
        fetchPostsInternal()
    }
    
    func fetchPostsWithoutLoading() {
        fetchPostsInternal()
    }
    
    private func fetchPostsInternal() {
        guard let url = URL(string: "https://circlapp.online/api/forum/get_posts/?filter=\(selectedFilter)") else {
            showPageLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    showPageLoading = false
                }
            }

            if let data = data {
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
    
    // MARK: - Other Network Functions
    
    func fetchUserProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/profile/\(userId)/") else {
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
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(FullProfile.self, from: data)
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } catch {
                print("❌ Error decoding profile:", error)
                completion(nil)
            }
        }.resume()
    }

    func submitPost() {
        guard let url = URL(string: "https://circlapp.online/api/forum/create_post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "content": postContent,
            "category": selectedCategory == "Category" ? "" : selectedCategory,
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

                do {
                    let _ = try JSONDecoder().decode(ForumPostModel.self, from: data)
                    print("✅ Post decoded successfully")
                } catch {
                    print("❌ Decoding single post error:", error)
                }

                DispatchQueue.main.async {
                    postContent = ""
                    fetchPostsWithoutLoading()
                }
            }
        }.resume()
    }
    
    func fetchUserNetworkIds() {
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        guard let url = URL(string: "https://circlapp.online/api/users/get_network/\(userId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }

            let ids = json.compactMap { $0["id"] as? Int }
            DispatchQueue.main.async {
                userNetworkIds = ids
            }
        }.resume()
    }


    func toggleLike(_ post: ForumPostModel) {
        let endpoint = post.liked_by_user ? "unlike" : "like"
        guard let url = URL(string: "https://circlapp.online/api/forum/posts/\(post.id)/\(endpoint)/") else { return }

        // 🔁 Immediately update the UI locally
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = ForumPostModel(
                id: post.id,
                user: post.user,
                user_id: post.user_id,
                profileImage: post.profileImage,
                content: post.content,
                category: post.category,
                privacy: post.privacy,
                image: post.image,
                created_at: post.created_at,
                comment_count: post.comment_count,
                like_count: post.liked_by_user ? post.like_count - 1 : post.like_count + 1,
                liked_by_user: !post.liked_by_user,
                isMentor: post.isMentor
            )
        }

        // ✅ Then make the request in the background
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request).resume()
    }

    func deletePost(_ postId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/forum/delete_post/\(postId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchPostsWithoutLoading()
            }
        }.resume()
    }
}

// [Rest of the code remains exactly the same]

struct CommentSheet: View {
    let postId: Int
    @Binding var isPresented: Bool
    var onDismiss: () -> Void = {}
    @State private var showMenu = false

    @State private var newComment = ""
    @State private var comments: [CommentModel] = []

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(comments) { comment in
                            HStack(alignment: .top, spacing: 12) {
                                // Profile Image
                                if let urlString = comment.profile_image,
                                   let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: encoded) {
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
                                    .frame(width: 34, height: 34)
                                    .clipShape(Circle())
                                    .shadow(radius: 1)
                                } else {
                                    Image("default_image")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 34, height: 34)
                                        .clipShape(Circle())
                                        .shadow(radius: 1)
                                }

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
                    // Floating Hammer Menu
                    

                    .padding()
                }

                .dismissKeyboardOnScroll()
                

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
        guard let url = URL(string: "https://circlapp.online/api/forum/comments/\(postId)/") else { return }

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

        guard let url = URL(string: "https://circlapp.online/api/forum/comments/add/") else {
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
        guard let url = URL(string: "https://circlapp.online/api/forum/comments/\(comment.id)/\(comment.liked_by_user ? "unlike" : "like")/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchComments()
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

struct PageForum_Previews: PreviewProvider {
    static var previews: some View {
        PageForum()
    }
}

