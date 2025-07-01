import SwiftUI
import UIKit

struct MessageModel: Identifiable, Codable {
    let id: Int
    let sender_id: Int
    let receiver_id: Int
    let content: String
    let timestamp: String
    let is_read: Bool
}

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

    @State private var showDeleteConfirmation = false
    @State private var showReportSheet = false


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Post Header
            HStack(spacing: 12) {
                Button(action: onTapProfile) {
                    AsyncImage(url: URL(string: profileImageName)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Image("default_image").resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(author).font(.system(size: 16, weight: .bold))
                        if isMentor {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(hexCode: "004aad"))
                                .font(.system(size: 14))
                        }
                    }
                    Text(timeAgo(from: timestamp))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Menu {
                    if isCurrentUser {
                        Button("Delete Post", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    } else {
                        Button("Report Post", role: .destructive) {
                            showReportSheet = true
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Circle())
                }
            }

            Text(content)
                .font(.system(size: 15))
                .lineSpacing(4)

            if !category.trimmingCharacters(in: .whitespaces).isEmpty && category != "Category" {
                Text(category)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hexCode: "004aad").opacity(0.1))
                    .foregroundColor(Color(hexCode: "004aad"))
                    .clipShape(Capsule())
            }

            Divider().padding(.vertical, 4)

            HStack(spacing: 24) {
                Button(action: toggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: likedByUser ? "heart.fill" : "heart")
                            .foregroundColor(likedByUser ? .red : .secondary)
                        Text("\(likeCount) Likes")
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                        Text("\(commentCount) Comments")
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .alert("Delete Post?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive, action: onDelete)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportPostView(postID: postID, isPresented: $showReportSheet)
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
    @Binding var userFirstName: String
    @Binding var userProfileImageURL: String
    @Binding var unreadMessageCount: Int
    @Binding var selectedProfile: FullProfile?
    @Binding var showProfileSheet: Bool
    @Binding var showCategoryAlert: Bool
    @Binding var isLoading: Bool
    @Binding var showPageLoading: Bool
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false

    @AppStorage("hasSeenForumTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false

    var fetchPosts: () -> Void
    var submitPost: () -> Void
    var deletePost: (Int) -> Void
    var toggleLike: (ForumPostModel) -> Void
    var fetchUserProfile: (Int, @escaping (FullProfile?) -> Void) -> Void

    private var animatedBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hexCode: "001a3d"),
                    Color(hexCode: "004aad"),
                    Color(hexCode: "0066ff"),
                    Color(hexCode: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // First flowing layer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.2),
                    Color.clear,
                    Color(hexCode: "004aad").opacity(0.15),
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? -0.3 : 1.3,
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 1.0 : 0.0,
                    y: 1.0
                )
            )
            
            // Second flowing layer (opposite direction)
            LinearGradient(
                colors: [
                    Color(hexCode: "002d5a").opacity(0.1),
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.18),
                    Color.clear,
                    Color(hexCode: "001a3d").opacity(0.12)
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 1.2 : -0.2,
                    y: 0.3
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 0.1 : 0.9,
                    y: 0.7
                )
            )
            
            // Third subtle wave layer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.1),
                    Color.clear,
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? 0.2 : 0.8,
                    y: isAnimating ? 0.0 : 1.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 0.9 : 0.1,
                    y: isAnimating ? 1.0 : 0.0
                )
            )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                        .background(Color(hexCode: "004aad"))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, -12)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        VStack {
                            HStack(spacing: 10) {
                                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                    ZStack {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)
                                            .foregroundColor(.white)
                                        
                                        // Notification badge - positioned more precisely
                                        if unreadMessageCount > 0 {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 18, height: 18)
                                                
                                                Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .offset(x: 20, y: -15)
                                        }
                                    }
                                }

                                NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                    if !userProfileImageURL.isEmpty {
                                        AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                                            switch phase {
                                            case .empty:
                                                // Loading state
                                                ProgressView()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.white)
                                            case .success(let image):
                                                // Successfully loaded image
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                                    )
                                            case .failure(_):
                                                // Failed to load, show default
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.white)
                                            @unknown default:
                                                // Fallback
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                            
                            // Welcome message with improved styling
                            if !userFirstName.isEmpty {
                                VStack(spacing: 2) {
                                    Text("Welcome back,")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 0.5)
                                    
                                    Text("\(userFirstName)!")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 15)
            .background(animatedBackground.ignoresSafeArea())
            .clipped()

            // ScrollView for content
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
                        // New Post Creation UI
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Image(systemName: "person.circle.fill").resizable().aspectRatio(contentMode: .fill).foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                                Text("The floor is yours, \(userFirstName)!")
                                    .foregroundColor(.secondary)
                            }

                            TextField("Pitch an idea, share a win, or ask the community for advice...", text: $postContent, axis: .vertical)
                                .lineLimit(4...)
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    postContent.isEmpty ?
                                    Text("Pitch an idea, share a win, or ask the community for advice...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                    : nil, alignment: .topLeading
                                )

                            HStack {
                                Button(action: { showCategoryAlert = true }) {
                                    HStack {
                                        Image(systemName: "tag")
                                        Text(selectedCategory.isEmpty ? "Category" : selectedCategory)
                                    }
                                }

                                Button(action: { /* Action for privacy */ }) {
                                    HStack {
                                        Image(systemName: "globe")
                                        Text(selectedPrivacy)
                                    }
                                }

                                Spacer()

                                Button(action: submitPost) {
                                    Text("Post")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 24)
                                        .background(Color(hexCode: "004aad"))
                                        .clipShape(Capsule())
                                }
                                .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .foregroundColor(Color(hexCode: "004aad"))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        ForEach(posts) { post in
                            ForumPost(
                                content: post.content,
                                author: post.user,
                                timestamp: post.created_at,
                                category: post.category,
                                profileImageName: post.profileImage ?? "",
                                company: "Circl",
                                postID: post.id,
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
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGray6))
            .dismissKeyboardOnScroll()
        }
        .ignoresSafeArea(edges: .top)
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
    @State private var userFirstName: String = ""
    @State private var userProfileImageURL: String = ""
    @State private var currentUserProfile: FullProfile?
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @State private var showCategoryAlert = false
    @State private var selectedFilter: String = "public"
    @State private var selectedProfile: FullProfile?
    @State private var showProfileSheet = false
    @State private var isLoading = false
    @State private var showPageLoading = true
    @State private var userNetworkIds: [Int] = []
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var gradientOffset: CGFloat = 0
    @State private var backgroundRotationAngle: Double = 0

    @State private var profileUserId: Int? = nil
    @State private var showProfile: Bool = false
    @State private var postToShowComments: Int? = nil
    @State private var showCommentSheet: Bool = false
    @State private var showKeyboard: Bool = false
    @AppStorage("hasSeenForumTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false

    @State private var animateArrow = false



    
    

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
                userFirstName: $userFirstName,
                userProfileImageURL: $userProfileImageURL,
                unreadMessageCount: $unreadMessageCount,
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
                        // Tappable backdrop layer to dismiss the menu
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showMenu = false
                                }
                            }
                            .zIndex(1) // under the menu, over the rest
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

                                NavigationLink(destination: PageGroupchatsWrapper().navigationBarBackButtonHidden(true))
 {
                                                                MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                                                            }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .frame(width: 250)
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(2) // show menu on top
                        }

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showMenu.toggle()
                                rotationAngle += 360
                            }

                            // ✅ Dismiss comment sheet too
                            selectedPostIdForComments = nil
                            showTutorial = false
                            hasSeenTutorial = true
                        }) {

                            ZStack {
                                Circle()
                                    .fill(Color(hexCode: "004aad"))
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
                        .padding(.bottom, -10)
                        .zIndex(3) // always tappable
                    }
                    .padding()



                    
                }
                .padding()
                .zIndex(2)
                
                
            }
            
            if showTutorial {
                // Dim background only behind the tutorial content
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .ignoresSafeArea()
                        .allowsHitTesting(false) // ✅ lets touches pass through

                    VStack(spacing: 20) {
                        Spacer()

                        VStack(spacing: 20) {
                            Text("👋 Welcome to Circl!")
                                .font(.largeTitle)
                                .bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)

                            Text("Click the circl button in the bottom-right to access the menu and get started.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)

                        Spacer()

                        HStack {
                            Spacer()
                            Image(systemName: "arrow.turn.down.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(animateArrow ? -20 : 0))
                                .scaleEffect(x: -1, y: 1)
                                .foregroundColor(.white)
                                .padding(.trailing, 40)
                                .padding(.bottom, 40)
                                .onAppear {
                                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                        animateArrow.toggle()
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .transition(.opacity)
                .zIndex(11)
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
            // Extract first name
            if !loggedInUserFullName.isEmpty {
                userFirstName = loggedInUserFullName.components(separatedBy: " ").first ?? ""
            }
            
            // Fetch current user's profile to get profile image
            fetchCurrentUserProfile()
            
            // Fetch messages for notification count
            fetchMessagesForNotification()
            
            selectedFilter = UserDefaults.standard.string(forKey: "selectedFilter") ?? "public"
            fetchUserNetworkIds()
            fetchPostsWithLoading()

            if !hasSeenTutorial {
                showTutorial = true
            }
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
    
    func fetchCurrentUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        print("🌐 Fetching current user profile from:", urlString)

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
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
                return
            }

            if let data = data {
                print("📦 Received current user data:", String(data: data, encoding: .utf8) ?? "No string")

                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        print("✅ Decoded current user:", decoded.full_name)
                        self.currentUserProfile = decoded
                        
                        // Update profile image URL
                        if let profileImage = decoded.profile_image, !profileImage.isEmpty {
                            self.userProfileImageURL = profileImage
                            print("✅ Profile image loaded: \(profileImage)")
                        } else {
                            self.userProfileImageURL = ""
                            print("❌ No profile image found for current user")
                        }
                        
                        // Update user name info
                        self.loggedInUserFullName = decoded.full_name
                        self.userFirstName = decoded.first_name
                    }
                } else {
                    print("❌ Failed to decode current user profile")
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

// MARK: - Message Functions for Notification Badge

extension PageForum {
    func fetchMessagesForNotification() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }

        guard let url = URL(string: "https://circlapp.online/api/users/get_messages/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: [MessageModel]].self, from: data)
                    DispatchQueue.main.async {
                        let allMessages = response["messages"] ?? []
                        self.messages = allMessages
                        self.calculateUnreadMessageCount()
                    }
                } catch {
                    print("Error decoding messages:", error)
                }
            }
        }.resume()
    }
    
    func calculateUnreadMessageCount() {
        guard let myId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        let unreadMessages = messages.filter { message in
            message.receiver_id == myId && !message.is_read && message.sender_id != myId
        }
        
        unreadMessageCount = unreadMessages.count
    }
}

struct CustomCircleButton: View {
    let iconName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hexCode: "004aad"))
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

struct CommentSheet: View {
    let postId: Int
    @Binding var isPresented: Bool
    var onDismiss: () -> Void = {}
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
        guard let url = URL(string: "https://circlapp.online/api/forum/comments/add/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["post_id": postId, "text": newComment]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                newComment = ""
                fetchComments()
            }
        }.resume()
    }
}
