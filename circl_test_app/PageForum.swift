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
    let selectedProfile: FullProfile?
    let showProfileSheet: (FullProfile) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header - Twitter/X style layout
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
                    
                    // For You Tab
                    HStack {
                        VStack(spacing: 8) {
                            Text("For you")
                                .font(.system(size: 15, weight: visualSelectedTab == "public" ? .semibold : .regular))
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(visualSelectedTab == "public" ? Color.white : Color.clear)
                                .frame(height: 3)
                                .animation(.easeInOut(duration: 0.2), value: visualSelectedTab)
                        }
                        .frame(width: 70)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("🔄 For you tab tapped")
                        // Show loading immediately for better UX
                        isTabSwitchLoading = true
                        // Update states immediately without animation wrapper
                        visualSelectedTab = "public"
                        selectedFilter = "public"
                        selectedPrivacy = "Public"
                        UserDefaults.standard.set("public", forKey: "selectedFilter")
                        print("✅ visualSelectedTab set to: \(visualSelectedTab)")
                        // Fetch posts using the fetcher closure
                        fetcher("public", selectedCategory)
                    }
                    
                    Spacer()
                    
                    // Following Tab
                    HStack {
                        VStack(spacing: 8) {
                            Text("Following")
                                .font(.system(size: 15, weight: visualSelectedTab == "my_network" ? .semibold : .regular))
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(visualSelectedTab == "my_network" ? Color.white : Color.clear)
                                .frame(height: 3)
                                .animation(.easeInOut(duration: 0.2), value: visualSelectedTab)
                        }
                        .frame(width: 80)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("🔄 Following tab tapped")
                        // Show loading immediately for better UX
                        isTabSwitchLoading = true
                        // Update states immediately without animation wrapper
                        visualSelectedTab = "my_network"
                        selectedFilter = "my_network"
                        selectedPrivacy = "My Network"
                        UserDefaults.standard.set("my_network", forKey: "selectedFilter")
                        print("✅ visualSelectedTab set to: \(visualSelectedTab)")
                        // Fetch posts using the fetcher closure
                        fetcher("my_network", selectedCategory)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 8)
            }
            .padding(.top, 50) // Add safe area padding for status bar and notch
            .background(Color(hex: "004aad"))
            .ignoresSafeArea(edges: .top)
            
            // Compose Area - Twitter/X style
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
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // Main text input area
                        TextField("", text: $postContent)
                            .font(.system(size: 20, weight: .regular))
                            .lineLimit(6...)
                            .textFieldStyle(PlainTextFieldStyle())
                            .placeholder(when: postContent.isEmpty) {
                                Text("What's happening?")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.vertical, 4)
                        
                        Spacer(minLength: 12)
                        
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
                .padding(.vertical, 12)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
            }
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)

            // Feed Content
            if isLoading || isTabSwitchLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                        .font(.system(size: 16))
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                    fetchUserProfile(post.user_id) { profile in
                                        if let profile = profile {
                                            showProfileSheet(profile)
                                        }
                                    }
                                },
                                isMentor: post.isMentor ?? false
                            )
                        }
                    }
                    .padding(.bottom, 80) // Add padding for bottom navigation
                }
                .background(Color.white)
            }
        }
        .background(Color.white)
        .dismissKeyboardOnScroll()
        .ignoresSafeArea(edges: .top)
    }
}

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
    @State private var unreadMessageCount: Int = 0
    @State private var messages: [MessageModel] = []
    @AppStorage("user_id") private var userId: Int = 0
    @State private var showPostCreationSheet = false
    @State private var selectedFilter: String = "public"
    @State private var visualSelectedTab: String = "public" // Visual state separate from API state
    @State private var selectedProfile: FullProfile?
    @State private var showProfileSheet = false
    @State private var isLoading = false
    @State private var showPageLoading = true
    @State private var isTabSwitchLoading = false
    @State private var userNetworkIds: [Int] = []

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
        NavigationView {
            ZStack {
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
                    fetchUserProfile: fetchUserProfile,
                    selectedProfile: selectedProfile,
                    showProfileSheet: { profile in
                        selectedProfile = profile
                        showProfileSheet = true
                    }
                )

            
            // MARK: - Twitter/X Style Bottom Navigation
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Forum / Home (Current page - highlighted)
                    VStack(spacing: 4) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                        Text("Home")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                    }
                    .frame(maxWidth: .infinity)
                    
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
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
                    // Circles
                    NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            Image(systemName: "circle.grid.2x2")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("Circles")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
                    // Business Profile
                    NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            Image(systemName: "building.2")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("Business")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
                    // More / Additional Resources
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMoreMenu.toggle()
                        }
                    }) {
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

            // MARK: - More Menu Popup
            if showMoreMenu {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("More Options")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .foregroundColor(.primary)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 0) {
                            // Professional Services
                            NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                HStack(spacing: 16) {
                                    Image(systemName: "briefcase.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Professional Services")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text("Find business services and experts")
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
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // News & Knowledge
                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                HStack(spacing: 16) {
                                    Image(systemName: "newspaper.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("News & Knowledge")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text("Stay updated with industry insights")
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
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Circl Exchange
                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                HStack(spacing: 16) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("The Circl Exchange")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text("Buy and sell skills and services")
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
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Settings
                            NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                                HStack(spacing: 16) {
                                    Image(systemName: "gear.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Settings")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text("Manage your account and preferences")
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
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                        }
                        
                        // Close button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu = false
                            }
                        }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .background(Color(UIColor.systemGray6))
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Leave space for bottom navigation
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(2)
            }

            // Tap-out-to-dismiss layer
            if showMoreMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMoreMenu = false
                        }
                    }
                    .zIndex(1)
            }
            

            }
        }
        .navigationBarHidden(true)

        .sheet(item: $selectedPostIdForComments) { selectedPost in
            CommentSheet(
                postId: selectedPost.id,
                isPresented: Binding(
                    get: { selectedPostIdForComments != nil },
                    set: { if !$0 { selectedPostIdForComments = nil } }
                )
            )
        }
        .sheet(isPresented: $showProfileSheet) {
            if let profile = selectedProfile {
                DynamicProfilePreview(
                    profileData: profile,
                    isInNetwork: userNetworkIds.contains(profile.user_id)
                )
            }
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
            
            // Load saved filter preference
            selectedFilter = UserDefaults.standard.string(forKey: "selectedFilter") ?? "public"
            visualSelectedTab = selectedFilter // Sync visual state with saved preference
            
            fetchUserNetworkIds()
            fetchPostsWithLoading()

            if !hasSeenTutorial {
                showTutorial = true
            }
        }
        .withNotifications() // ✅ Enable notifications on PageForum
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
    let postId: Int
    @Binding var isPresented: Bool
    var onDismiss: () -> Void = {}
    @State private var newComment = ""
    @State private var comments: [CommentModel] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                        onDismiss()
                    }
                    .foregroundColor(Color(hex: "004aad"))
                    
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
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                    } else {
                                        Image("default_image")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
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
