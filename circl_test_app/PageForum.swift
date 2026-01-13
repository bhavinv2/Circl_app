import SwiftUI
import UIKit
import Foundation

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
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Profile Image - Twitter/X style
                Button(action: onTapProfile) {
                    AsyncImage(url: URL(string: profileImageName)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Image("default_image").resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                }
                
                // Main Tweet Content
                VStack(alignment: .leading, spacing: 8) {
                    // Header with name, verification, time, and menu
                    HStack(spacing: 4) {
                        Text(author)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if isMentor {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(hex: "004aad"))
                                .font(.system(size: 14))
                        }
                        
                        Text("·")
                            .foregroundColor(.secondary)
                            .font(.system(size: 15))
                        
                        Text(timeAgo(from: timestamp))
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
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
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .padding(4)
                        }
                    }
                    
                    // Tweet Content
                    Text(content)
                        .font(.system(size: 15))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.primary)
                    
                    // Category Tag (if exists)
                    if !category.trimmingCharacters(in: .whitespaces).isEmpty && category != "Category" {
                        Text(category)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "004aad").opacity(0.1))
                            .foregroundColor(Color(hex: "004aad"))
                            .clipShape(Capsule())
                    }
                    
                    // Action Buttons - Twitter/X style
                    HStack(spacing: 0) {
                        // Comment Button
                        Button(action: onComment) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 16))
                                Text("\(commentCount)")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Like Button
                        Button(action: toggleLike) {
                            HStack(spacing: 4) {
                                Image(systemName: likedByUser ? "heart.fill" : "heart")
                                    .font(.system(size: 16))
                                Text("\(likeCount)")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(likedByUser ? .red : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Separator line
            Divider()
                .background(Color.gray.opacity(0.3))
        }
        .background(Color.white)
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
    @EnvironmentObject var profilePreview: ProfilePreviewCoordinator
    
    @Binding var selectedFilter: String
    @Binding var visualSelectedTab: String
    @Binding var selectedCategory: String
    @Binding var posts: [ForumPostModel]
    @Binding var isLoading: Bool
    @Binding var isTabSwitchLoading: Bool
    @Binding var userFirstName: String
    @Binding var userProfileImageURL: String
    @Binding var unreadMessageCount: Int
    @Binding var postContent: String
    @Binding var selectedPrivacy: String
    @Binding var selectedPostIdForComments: ForumPostModel?
    @Binding var loggedInUserFullName: String
    @Binding var showCategoryAlert: Bool
    
    let onPost: () -> Void
    let fetcher: (String, String) -> Void
    let likeToggler: (ForumPostModel) -> Void
    let submitPost: () -> Void
    let toggleLike: (ForumPostModel) -> Void
    let deletePost: (Int) -> Void
    let fetchUserProfile: (Int, @escaping (FullProfile?) -> Void) -> Void
//    let selectedProfile: FullProfile?
//    let showProfileSheet: (FullProfile) -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            // Fixed Compose Area - Twitter/X style
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    // Profile Image
                    AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Main text input area with dynamic height
                        TextField("", text: $postContent, axis: .vertical)
                            .font(.system(size: 18, weight: .regular))
                            .lineLimit(1...5)
                            .textFieldStyle(PlainTextFieldStyle())
                            .placeholder(when: postContent.isEmpty) {
                                Text("What's happening?")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .frame(minHeight: 22)
                        
                        // Bottom action row
                        HStack(spacing: 0) {
                            // Left side buttons
                            HStack(spacing: 12) {
                                // Category/public button
                                Button(action: { showCategoryAlert = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "tag")
                                            .font(.system(size: 14, weight: .medium))
                                        Text(selectedCategory == "Category" ? "Tags" : selectedCategory)
                                            .font(.system(size: 13, weight: .medium))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .foregroundColor(Color(hex: "004aad"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == "Category" ? Color(hex: "e8f2ff") : Color(hex: "004aad").opacity(0.1))
                                    .cornerRadius(16)
                                }
                                
                                // Privacy button
                                Menu {
                                    Button("Public", action: { selectedPrivacy = "Public" })
                                    Button("My Network", action: { selectedPrivacy = "My Network" })
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: selectedPrivacy == "Public" ? "globe" : "lock")
                                            .font(.system(size: 14, weight: .medium))
                                        Text(selectedPrivacy)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(Color(hex: "004aad"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "e8f2ff"))
                                    .cornerRadius(16)
                                }
                            }
                            
                            Spacer()
                            
                            // Post button
                            Button(action: submitPost) {
                                Text("Post")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? Color.gray.opacity(0.4)
                                        : Color(hex: "004aad")
                                    )
                                    .clipShape(Capsule())
                            }
                            .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
            }
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)

            // Scrollable Feed Content Only
            if isLoading || isTabSwitchLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                        .font(.system(size: 16))
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
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
                                    profilePreview.present(userId: post.user_id)
                                },
                                isMentor: post.isMentor ?? false
                            )
                        }
                    }
                    .padding(.bottom, 80) // Add padding for bottom navigation
                }
                .tutorialHighlight(id: "home_feed_content")
                .background(Color.white)
                .dismissKeyboardOnScroll()
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }
}

struct PageForum: View {
    @EnvironmentObject var profilePreview: ProfilePreviewCoordinator
    
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
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @AppStorage("user_id") private var userId: Int = 0
    @State private var showPostCreationSheet = false
    @State private var selectedFilter: String = "public"
    @State private var visualSelectedTab: String = "public" // Visual state separate from API state
//    @State private var selectedProfile: FullProfile?
//    @State private var showProfileSheet = false
    @State private var isLoading = false
    @State private var showPageLoading = true
    @State private var isTabSwitchLoading = false
//    @State private var userNetworkIds: [Int] = []

    @State private var gradientOffset: CGFloat = 0
    @State private var backgroundRotationAngle: Double = 0

    @State private var profileUserId: Int? = nil
    @State private var showProfile: Bool = false
    @State private var postToShowComments: Int? = nil
    @State private var showCommentSheet: Bool = false
    @State private var showKeyboard: Bool = false
    @AppStorage("hasSeenForumTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false
    @State private var showCategoryAlert = false
    @State private var showMoreMenu = false

    @State private var animateArrow = false
    @State private var currentUserProfile: FullProfile?

    var body: some View {
        AdaptiveContentWrapper(
            configuration: AdaptivePageConfiguration(
                title: "Home",
                navigationItems: AdaptivePageConfiguration.defaultNavigation(currentPageTitle: "Home", unreadMessageCount: unreadMessageCount)
            ),
            customHeader: { layoutManager in
                headerSection(layoutManager: layoutManager)
            }
        ) {
            contentSection
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
//        .sheet(isPresented: $showProfileSheet) {
//            if let profile = selectedProfile {
//                DynamicProfilePreview(
//                    profileData: profile,
//                    isInNetwork: userNetworkIds.contains(profile.user_id)
//                )
//            }
//        }

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
            
            // Load saved filter preference
            selectedFilter = UserDefaults.standard.string(forKey: "selectedFilter") ?? "public"
            visualSelectedTab = selectedFilter // Sync visual state with saved preference
            
//            fetchUserNetworkIds()
            fetchPostsWithLoading()

            if !hasSeenTutorial {
                showTutorial = true
            }
            
            // Check if tutorial should be triggered after onboarding completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                TutorialManager.shared.checkAndTriggerTutorial()
            }
            
            // Check if tutorial should be triggered for new users
            TutorialManager.shared.checkAndTriggerTutorial()
        }
        .withNotifications() // ✅ Enable notifications on PageForum
        .withTutorialOverlay() // ✅ Enable tutorial system on PageForum
        .alert("Select a category for your post", isPresented: $showCategoryAlert) {
            Button("Growth & Marketing") {
                selectedCategory = "Growth & Marketing"
            }
            Button("Networking & Collaboration") {
                selectedCategory = "Networking & Collaboration"
            }
            Button("Funding & Finance") {
                selectedCategory = "Funding & Finance"
            }
            Button("Skills & Development") {
                selectedCategory = "Skills & Development"
            }
            Button("Challenges & Insights") {
                selectedCategory = "Challenges & Insights"
            }
            Button("Trends & Technology") {
                selectedCategory = "Trends & Technology"
            }
            Button("Cancel", role: .cancel) {
                selectedCategory = "Category"
            }
        } message: {
            Text("Choose a category that best describes your post")
        }
    }
    
    // MARK: - Header Section for iPad
    
    private func headerSection(layoutManager: AdaptiveLayoutManager) -> some View {
        VStack(spacing: 0) {
            HStack {
                // Sidebar toggle button (iPad only, when sidebar is collapsed)
                if UIDevice.current.userInterfaceIdiom == .pad && layoutManager.isSidebarCollapsed {
                    Button(action: layoutManager.toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                }
                
                // Left side - Enhanced Profile
                NavigationLink(destination: ProfileHubPage(initialTab: .profile).navigationBarBackButtonHidden(true)) {
                    ZStack {
                        if !userProfileImageURL.isEmpty {
                            AsyncImage(url: URL(string: userProfileImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        // Online indicator
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 12, y: -12)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                // Center - Logo
                VStack(spacing: 2) {
                    Text("Circl.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Right side - Enhanced Messages
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        if unreadMessageCount > 0 {
                            Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                                )
                                .offset(x: 12, y: -12)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
            .padding(.top, 8)
            
            // Clean tab design
            HStack(spacing: 0) {
                ForEach(["public", "my_network"], id: \.self) { tab in
                    VStack(spacing: 8) {
                        Text(tab == "public" ? "For you" : "Following")
                            .font(.system(size: 16, weight: visualSelectedTab == tab ? .bold : .medium))
                            .foregroundColor(.white)
                            .opacity(visualSelectedTab == tab ? 1.0 : 0.7)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: tab == "public" ? 60 : 80, height: visualSelectedTab == tab ? 3 : 0)
                            .animation(.easeInOut(duration: 0.2), value: visualSelectedTab)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTabSwitchLoading = true
                            visualSelectedTab = tab
                            selectedFilter = tab
                            selectedPrivacy = tab == "public" ? "Public" : "My Network"
                            UserDefaults.standard.set(tab, forKey: "selectedFilter")
                            fetchPostsWithParameters(tab, selectedCategory)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "004aad"),
                    Color(hex: "004aad").opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        ForumMainContent(
            selectedFilter: $selectedFilter,
            visualSelectedTab: $visualSelectedTab,
            selectedCategory: $selectedCategory,
            posts: $posts,
            isLoading: $isLoading,
            isTabSwitchLoading: $isTabSwitchLoading,
            userFirstName: $userFirstName,
            userProfileImageURL: $userProfileImageURL,
            unreadMessageCount: $unreadMessageCount,
            postContent: $postContent,
            selectedPrivacy: $selectedPrivacy,
            selectedPostIdForComments: $selectedPostIdForComments,
            loggedInUserFullName: $loggedInUserFullName,
            showCategoryAlert: $showCategoryAlert,
            onPost: submitPost,
            fetcher: fetchPostsWithParameters,
            likeToggler: { post in toggleLike(post) },
            submitPost: submitPost,
            toggleLike: { post in toggleLike(post) },
            deletePost: deletePost,
            fetchUserProfile: fetchUserProfile//,
//            selectedProfile: selectedProfile,
//            showProfileSheet: { profile in
//                selectedProfile = profile
//            }
        )
    }
    
    // MARK: - Fetch Posts Functions
    
    func fetchPostsWithLoading() {
        showPageLoading = true
        fetchPostsInternal()
    }
    
    func fetchPostsWithoutLoading() {
        fetchPostsInternal()
    }
    
    func fetchPostsWithParameters(_ filter: String, _ category: String) {
        selectedFilter = filter
        selectedCategory = category
        // Keep visual state in sync with actual filter
        visualSelectedTab = filter
        fetchPostsInternal()
    }
    
    private func fetchPostsInternal() {
        guard let url = URL(string: "https://circlapp.online/api/forum/get_posts/?filter=\(selectedFilter)") else {
            showPageLoading = false
            isTabSwitchLoading = false
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
                    isTabSwitchLoading = false
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
    
//    func fetchUserNetworkIds() {
//        let userId = UserDefaults.standard.integer(forKey: "user_id")
//        guard let url = URL(string: "https://circlapp.online/api/users/get_network/\(userId)/") else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        if let token = UserDefaults.standard.string(forKey: "auth_token") {
//            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
//
//            let ids = json.compactMap { $0["id"] as? Int }
//            DispatchQueue.main.async {
//                userNetworkIds = ids
//            }
//        }.resume()
//    }


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

// MARK: - Adaptive Components

struct AdaptiveMainContent: View {
    @EnvironmentObject var profilePreview: ProfilePreviewCoordinator
    @Binding var selectedFilter: String
    @Binding var visualSelectedTab: String
    @Binding var selectedCategory: String
    @Binding var posts: [ForumPostModel]
    @Binding var isLoading: Bool
    @Binding var isTabSwitchLoading: Bool
    @Binding var userFirstName: String
    @Binding var userProfileImageURL: String
    @Binding var unreadMessageCount: Int
    @Binding var postContent: String
    @Binding var selectedPrivacy: String
    @Binding var selectedPostIdForComments: ForumPostModel?
    @Binding var loggedInUserFullName: String
    @Binding var showCategoryAlert: Bool
    let shouldShowSidebar: Bool
    let shouldUse2ColumnLayout: Bool
    @Binding var isSidebarCollapsed: Bool
    
    let onPost: () -> Void
    let fetcher: (String, String) -> Void
    let likeToggler: (ForumPostModel) -> Void
    let submitPost: () -> Void
    let toggleLike: (ForumPostModel) -> Void
    let deletePost: (Int) -> Void
    let fetchUserProfile: (Int, @escaping (FullProfile?) -> Void) -> Void
//    let selectedProfile: FullProfile?
//    let showProfileSheet: (FullProfile) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Adaptive Header
            if shouldShowSidebar {
                AdaptiveHeaderView(
                    userProfileImageURL: userProfileImageURL,
                    unreadMessageCount: unreadMessageCount,
                    isSidebarCollapsed: $isSidebarCollapsed,
                    visualSelectedTab: $visualSelectedTab,
                    selectedFilter: $selectedFilter,
                    selectedCategory: $selectedCategory,
                    selectedPrivacy: $selectedPrivacy,
                    fetcher: fetcher
                )
            }
            
            // Compose Area (adapted for larger screens)
            AdaptiveComposeArea(
                userProfileImageURL: userProfileImageURL,
                postContent: $postContent,
                selectedCategory: $selectedCategory,
                selectedPrivacy: $selectedPrivacy,
                showCategoryAlert: $showCategoryAlert,
                submitPost: submitPost,
                shouldShowSidebar: shouldShowSidebar
            )
            
            // Content Feed
            if isLoading || isTabSwitchLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                        .font(.system(size: 16))
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                ScrollView {
                    if shouldUse2ColumnLayout {
                        // 2-Column Layout for iPad/Mac
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(posts) { post in
                                AdaptiveForumPost(
                                    post: post,
                                    loggedInUserFullName: loggedInUserFullName,
                                    onComment: { selectedPostIdForComments = post },
                                    toggleLike: { toggleLike(post) },
                                    deletePost: { deletePost(post.id) },
                                    onTapProfile: {
                                        profilePreview.present(userId: post.user_id)
                                    },
                                    isCompact: false
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    } else {
                        // Single Column Layout
                        LazyVStack(spacing: 0) {
                            ForEach(posts) { post in
                                ForumPost(
                                    content: post.content,
                                    author: post.user,
                                    timestamp: post.created_at,
                                    category: post.category,
                                    profileImageName: post.profileImage ?? "",
                                    company: "Circl",
                                    postID: post.id,
                                    onComment: { selectedPostIdForComments = post },
                                    commentCount: post.comment_count ?? 0,
                                    likeCount: post.like_count,
                                    likedByUser: post.liked_by_user,
                                    toggleLike: { toggleLike(post) },
                                    isCurrentUser: post.user == loggedInUserFullName,
                                    onDelete: { deletePost(post.id) },
                                    onTapProfile: {
                                        profilePreview.present(userId: post.user_id)
                                    },
                                    isMentor: post.isMentor ?? false
                                )
                            }
                        }
                        .padding(.bottom, shouldShowSidebar ? 20 : 80)
                    }
                }
                .tutorialHighlight(id: "home_feed_content")
                .background(Color(.systemBackground))
                .dismissKeyboardOnScroll()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SidebarNavigationItem: View {
    let icon: String
    let title: String
    let badgeCount: Int?
    let isActive: Bool
    
    init(icon: String, title: String, badgeCount: Int? = nil, isActive: Bool) {
        self.icon = icon
        self.title = title
        self.badgeCount = badgeCount
        self.isActive = isActive
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isActive ? .white : Color(hex: "004aad"))
                    .frame(width: 24, height: 24)
                
                if let count = badgeCount, count > 0 {
                    Text(count > 99 ? "99+" : "\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 12, y: -12)
                }
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isActive ? .white : .primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color(hex: "004aad") : Color.clear)
        )
        .contentShape(Rectangle())
    }
}

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
    
    private func refreshPosts() async {
        // Refresh posts using current filter and category values
        await MainActor.run {
            fetchPostsWithParameters(selectedFilter, selectedCategory)
        }
    }
}

// MARK: - View Extensions
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct CustomCircleButton: View {
    let iconName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "004aad"))
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
    @EnvironmentObject var profilePreview: ProfilePreviewCoordinator
    
    let postId: Int
    @Binding var isPresented: Bool
    var onDismiss: () -> Void = {}
    @State private var newComment = ""
    @State private var comments: [CommentModel] = []
    //var profile

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
//                    Button("Cancel") {
//                        isPresented = false
//                        onDismiss()
//                    }
//                    .foregroundColor(Color(hex: "004aad"))
                    
                    Spacer()
                    
                    Text("Comments")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button("Done") {
                        isPresented = false
                        onDismiss()
                    }
                    .foregroundColor(Color(hex: "004aad"))
                }
                .padding()
                .background(Color.white)
                
                Divider()
                
                // Comments List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(comments) { comment in
                            VStack(spacing: 0) {
                                HStack(alignment: .top, spacing: 12) {
                                    // Profile Image
                                    Button {
                                        profilePreview.present(userId: comment.id)
                                    } label: {
                                        if let urlString = comment.profile_image,
                                           let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                           let url = URL(string: encoded) {
                                            AsyncImage(url: url) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } else {
                                                    Image("image")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                }
                                            }
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                        } else {
                                            Image("image")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 32, height: 32)
                                                .clipShape(Circle())
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Text(comment.user)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            Text("·")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 15))
                                            
                                            Text(timeAgo(from: comment.created_at))
                                                .font(.system(size: 15))
                                                .foregroundColor(.secondary)
                                        }

                                        Text(comment.text)
                                            .font(.system(size: 15))
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                }
                .background(Color.white)

                // Comment Input
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        TextField("Post your reply", text: $newComment)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(20)

                        Button("Reply") {
                            submitComment()
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray.opacity(0.5)
                            : Color(hex: "004aad")
                        )
                        .cornerRadius(16)
                        .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .background(Color.white)
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

// MARK: - Adaptive Components

struct AdaptiveSidebar: View {
    @Binding var isCollapsed: Bool
    @Binding var visualSelectedTab: String
    @Binding var selectedFilter: String
    @Binding var selectedCategory: String
    @Binding var selectedPrivacy: String
    let unreadMessageCount: Int
    let fetcher: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCollapsed.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Navigation Items
            VStack(spacing: 8) {
                // Home / Forum
                SidebarMenuItem(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: true
                )
                
                // Network
                NavigationLink(destination: PageUnifiedNetworking().navigationBarBackButtonHidden(true)) {
                    SidebarMenuItem(
                        icon: "person.2",
                        title: "Network",
                        isSelected: false
                    )
                }
                
                // Circles
                NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                    SidebarMenuItem(
                        icon: "circle.grid.2x2",
                        title: "Circles",
                        isSelected: false
                    )
                }
                
                // Growth Hub
                NavigationLink(destination: PageSkillSellingPlaceholder().navigationBarBackButtonHidden(true)) {
                    SidebarMenuItem(
                        icon: "dollarsign.circle",
                        title: "Growth Hub",
                        isSelected: false
                    )
                }
                
                // Messages
                NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                    SidebarMenuItem(
                        icon: "envelope",
                        title: "Messages",
                        isSelected: false,
                        badge: unreadMessageCount > 0 ? "\(unreadMessageCount)" : nil
                    )
                }
                
                // Settings
                NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                    SidebarMenuItem(
                        icon: "gear",
                        title: "Settings",
                        isSelected: false
                    )
                }
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(width: 280)
        .background(Color(hex: "004aad"))
    }
}

struct SidebarMenuItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let badge: String?
    
    init(icon: String, title: String, isSelected: Bool, badge: String? = nil) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.badge = badge
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(3)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 12, y: -8)
                }
            }
            
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            isSelected ? Color.white.opacity(0.2) : Color.clear
        )
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

struct AdaptiveHeaderView: View {
    let userProfileImageURL: String
    let unreadMessageCount: Int
    @Binding var isSidebarCollapsed: Bool
    @Binding var visualSelectedTab: String
    @Binding var selectedFilter: String
    @Binding var selectedCategory: String
    @Binding var selectedPrivacy: String
    let fetcher: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Sidebar toggle (only show if collapsed)
                if isSidebarCollapsed {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSidebarCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    
                    Text("Circl.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Spacer()
                }
                
                Spacer()
                
                // Profile and Messages
                HStack(spacing: 16) {
                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            if unreadMessageCount > 0 {
                                Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    
                    NavigationLink(destination: ProfileHubPage(initialTab: .profile).navigationBarBackButtonHidden(true)) {
                        AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 28, height: 28)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .padding(.top, 8)
            
            // Tab Buttons Row for larger screens
            HStack(spacing: 0) {
                Spacer()
                
                // For You Tab
                Button(action: {
                    visualSelectedTab = "public"
                    selectedFilter = "public"
                    selectedPrivacy = "Public"
                    fetcher("public", selectedCategory)
                }) {
                    VStack(spacing: 6) {
                        Text("For you")
                            .font(.system(size: 15, weight: visualSelectedTab == "public" ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(visualSelectedTab == "public" ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: visualSelectedTab)
                    }
                    .frame(width: 80)
                }
                
                Spacer()
                
                // Following Tab
                Button(action: {
                    visualSelectedTab = "my_network"
                    selectedFilter = "my_network"
                    selectedPrivacy = "My Network"
                    fetcher("my_network", selectedCategory)
                }) {
                    VStack(spacing: 6) {
                        Text("Following")
                            .font(.system(size: 15, weight: visualSelectedTab == "my_network" ? .semibold : .regular))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(visualSelectedTab == "my_network" ? Color.white : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: visualSelectedTab)
                    }
                    .frame(width: 90)
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .background(Color(hex: "004aad"))
    }
}

struct AdaptiveComposeArea: View {
    let userProfileImageURL: String
    @Binding var postContent: String
    @Binding var selectedCategory: String
    @Binding var selectedPrivacy: String
    @Binding var showCategoryAlert: Bool
    let submitPost: () -> Void
    let shouldShowSidebar: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Profile Image
                AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    // Main text input area
                    TextField("", text: $postContent, axis: .vertical)
                        .font(.system(size: shouldShowSidebar ? 16 : 18, weight: .regular))
                        .lineLimit(1...5)
                        .textFieldStyle(PlainTextFieldStyle())
                        .placeholder(when: postContent.isEmpty) {
                            Text("What's happening?")
                                .font(.system(size: shouldShowSidebar ? 16 : 18, weight: .regular))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .frame(minHeight: 22)
                    
                    // Action row
                    HStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // Category button
                            Button(action: { showCategoryAlert = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "tag")
                                        .font(.system(size: 14, weight: .medium))
                                    Text(selectedCategory == "Category" ? "Tags" : selectedCategory)
                                        .font(.system(size: 13, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory == "Category" ? Color(hex: "e8f2ff") : Color(hex: "004aad").opacity(0.1))
                                .cornerRadius(16)
                            }
                            
                            // Privacy button
                            Menu {
                                Button("Public", action: { selectedPrivacy = "Public" })
                                Button("My Network", action: { selectedPrivacy = "My Network" })
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: selectedPrivacy == "Public" ? "globe" : "lock")
                                        .font(.system(size: 14, weight: .medium))
                                    Text(selectedPrivacy)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "e8f2ff"))
                                .cornerRadius(16)
                            }
                        }
                        
                        Spacer()
                        
                        // Post button
                        Button(action: submitPost) {
                            Text("Post")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.gray.opacity(0.4)
                                    : Color(hex: "004aad")
                                )
                                .clipShape(Capsule())
                        }
                        .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .padding(.horizontal, shouldShowSidebar ? 20 : 16)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.gray.opacity(0.2))
        }
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
    }
}

struct AdaptiveForumPost: View {
    let post: ForumPostModel
    let loggedInUserFullName: String
    let onComment: () -> Void
    let toggleLike: () -> Void
    let deletePost: () -> Void
    let onTapProfile: () -> Void
    let isCompact: Bool
    
    @State private var showDeleteConfirmation = false
    @State private var showReportSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with profile and menu
                HStack(alignment: .top, spacing: 12) {
                    Button(action: onTapProfile) {
                        AsyncImage(url: URL(string: post.profileImage ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Image("default_image").resizable().aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: isCompact ? 32 : 36, height: isCompact ? 32 : 36)
                        .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(post.user)
                                .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if post.isMentor ?? false {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color(hex: "004aad"))
                                    .font(.system(size: isCompact ? 12 : 14))
                            }
                            
                            Text("·")
                                .foregroundColor(.secondary)
                                .font(.system(size: isCompact ? 14 : 15))
                            
                            Text(timeAgo(from: post.created_at))
                                .font(.system(size: isCompact ? 14 : 15))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Menu {
                                if post.user == loggedInUserFullName {
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
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(4)
                            }
                        }
                    }
                }
                
                // Content
                Text(post.content)
                    .font(.system(size: isCompact ? 14 : 15))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.primary)
                
                // Category Tag
                if !post.category.trimmingCharacters(in: .whitespaces).isEmpty && post.category != "Category" {
                    Text(post.category)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "004aad").opacity(0.1))
                        .foregroundColor(Color(hex: "004aad"))
                        .clipShape(Capsule())
                }
                
                // Action Buttons
                HStack(spacing: 0) {
                    Button(action: onComment) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: isCompact ? 14 : 16))
                            Text("\(post.comment_count ?? 0)")
                                .font(.system(size: isCompact ? 12 : 13))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: toggleLike) {
                        HStack(spacing: 4) {
                            Image(systemName: post.liked_by_user ? "heart.fill" : "heart")
                                .font(.system(size: isCompact ? 14 : 16))
                            Text("\(post.like_count)")
                                .font(.system(size: isCompact ? 12 : 13))
                        }
                        .foregroundColor(post.liked_by_user ? .red : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .alert("Delete Post?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deletePost)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportPostView(postID: post.id, isPresented: $showReportSheet)
        }
    }
}


struct MoreMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "004aad"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Extensions


