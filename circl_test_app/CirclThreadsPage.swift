import SwiftUI

struct CircleThreadCommentModel: Identifiable, Codable {
    let id: Int
    let user: String
    let text: String
    let created_at: String
}

struct CirclThreadsPage: View {
    let circleId: Int
    let highlightedThreadId: Int?
    @Environment(\.presentationMode) var presentationMode

    @AppStorage("user_id") var userId: Int = 0
    @State private var threadToDelete: ThreadPost? = nil
    @State private var showDeleteConfirmation = false
    @State private var threads: [ThreadPost] = []
    @State private var scrollTarget: Int? = nil
    @State private var selectedThreadForComments: ThreadPost? = nil
    @State private var showCommentSheet = false
    @State private var newCommentText = ""
    @State private var comments: [CircleThreadCommentModel] = []

    @State private var showMenu = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 0) {

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
                // Back button under the header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.fromHex("004aad"))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.fromHex("004aad"), lineWidth: 1.5)
                        )
                    }

                    Spacer() // Push it left
                }
                .padding(.horizontal)
          

                .padding(.top, 12)

            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(threads) { thread in
                            ThreadCardExpanded(
                                thread: thread,
                                onCommentTapped: {
                                    selectedThreadForComments = thread
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        showCommentSheet = true
                                    }
                                },
                                onLikeTapped: {
                                    likeThread(threadId: thread.id)
                                },
                                onDeleteTapped: thread.author_id == userId ? {
                                    threadToDelete = thread
                                    showDeleteConfirmation = true
                                } : nil
                            )
                            .id(thread.id)
                        }
                    }
                    .padding()
                }
                .alert("Delete Thread?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        if let thread = threadToDelete {
                            deleteThread(thread.id)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete this thread?")
                }
                .sheet(isPresented: $showCommentSheet) {
                    VStack(spacing: 12) {
                        Text("Comments")
                            .font(.headline)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(comments, id: \.id) { comment in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(comment.user).fontWeight(.semibold)
                                        Text(comment.text)
                                            .font(.body)
                                        Divider()
                                    }
                                }
                            }
                        }

                        HStack {
                            TextField("Add a comment...", text: $newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button("Send") {
                                if let thread = selectedThreadForComments {
                                    postComment(to: thread.id, text: newCommentText)
                                }
                            }
                            .padding(.leading, 8)
                        }
                        .padding()

                        Spacer()
                    }
                    .padding()
                    .task {
                        if let thread = selectedThreadForComments {
                            fetchComments(for: thread.id)
                        }
                    }
                }
                .onAppear {
                    fetchThreads()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        if let id = highlightedThreadId {
                            scrollTarget = id
                            proxy.scrollTo(id, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    func deleteThread(_ threadId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/delete_thread/") else { return }

        let body: [String: Any] = [
            "user_id": userId,
            "thread_id": threadId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                threads.removeAll { $0.id == threadId }
            }
        }.resume()
    }

    func fetchComments(for threadId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/get_comments/\(threadId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([CircleThreadCommentModel].self, from: data) {
                DispatchQueue.main.async {
                    comments = decoded
                }
            }
        }.resume()
    }

    func postComment(to threadId: Int, text: String) {
        guard let url = URL(string: "https://circlapp.online/api/circles/post_comment/") else { return }

        let body: [String: Any] = [
            "user_id": userId,
            "thread_id": threadId,
            "text": text
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                newCommentText = ""
                fetchComments(for: threadId)
            }
        }.resume()
    }

    func likeThread(threadId: Int) {
        guard let url = URL(string: "https://circlapp.online/api/circles/toggle_like/") else { return }

        let body: [String: Any] = [
            "user_id": userId,
            "thread_id": threadId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let response = try? JSONDecoder().decode([String: Int].self, from: data),
               let updatedLikes = response["likes"] {
                DispatchQueue.main.async {
                    if let index = threads.firstIndex(where: { $0.id == threadId }) {
                        threads[index].likes = updatedLikes
                        threads[index].liked_by_user.toggle()
                    }
                }
            }
        }.resume()
    }

    func fetchThreads() {
        guard let url = URL(string: "https://circlapp.online/api/circles/get_threads/\(circleId)/?user_id=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([ThreadPost].self, from: data) {
                DispatchQueue.main.async {
                    self.threads = decoded
                }
            }
        }.resume()
    }
}

struct ThreadCardExpanded: View {
    let thread: ThreadPost
    let onCommentTapped: () -> Void
    let onLikeTapped: () -> Void
    let onDeleteTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(thread.author).fontWeight(.bold)
                Spacer()
                HStack(spacing: 16) {
                    if let onDeleteTapped = onDeleteTapped {
                        Menu {
                            Button(role: .destructive) {
                                onDeleteTapped()
                            } label: {
                                Label("Delete Thread", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }

                    Button(action: onLikeTapped) {
                        HStack(spacing: 6) {
                            Image(systemName: thread.liked_by_user ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 20, height: 18)
                                .foregroundColor(thread.liked_by_user ? .red : .gray)
                            Text("\(thread.likes)")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }

                    Button(action: onCommentTapped) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .resizable()
                                .frame(width: 20, height: 18)
                            Text("\(thread.comments)")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }

                }
                .font(.caption)
                .foregroundColor(.gray)
            }

            Text(thread.content)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
