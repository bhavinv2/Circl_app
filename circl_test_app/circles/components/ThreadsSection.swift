import SwiftUI

// MARK: - Threads Section Component
struct ThreadsSection: View {
    let threads: [ThreadPost]
    let circle: CircleData
    @Binding var showCreateThreadPopup: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Threads Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Threads")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Start meaningful conversations")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Create Thread Button
                Button(action: { showCreateThreadPopup = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("Thread")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "004aad"),
                                Color(hex: "0066ff")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            
            if !threads.isEmpty {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(threads, id: \.id) { thread in
                        ThreadCard(thread: thread)
                            .padding(.horizontal, 16)
                    }
                }
            } else {
                EmptyThreadsView()
            }
        }
        .padding(.bottom, 20) // Space between sections
    }
}

// MARK: - Thread Card Component
struct ThreadCard: View {
    let thread: ThreadPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Thread Header
            HStack(spacing: 12) {
                // Author Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "004aad"),
                                    Color(hex: "0066ff")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(String(thread.author.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(thread.author)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("2 hours ago")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // More options
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
            }
            
            // Thread Content
            Text(thread.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            // Thread Actions
            HStack(spacing: 24) {
                // Like Button
                HStack(spacing: 6) {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("\(thread.likes)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Comment Button
                HStack(spacing: 6) {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("\(thread.comments)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Share Button
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Empty Threads View Component
struct EmptyThreadsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "004aad").opacity(0.4))
            
            Text("No threads yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Start a conversation by creating the first thread")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "004aad").opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Thread Post Model
struct ThreadPost: Identifiable, Decodable {
    let id: Int
    let author: String
    let content: String
    let likes: Int
    let comments: Int
}

// MARK: - Preview
struct ThreadsSection_Previews: PreviewProvider {
    static var previews: some View {
        ThreadsSection(
            threads: [
                ThreadPost(id: 1, author: "John Doe", content: "What are your thoughts on the new AI developments in our industry?", likes: 5, comments: 3),
                ThreadPost(id: 2, author: "Jane Smith", content: "I'm looking for feedback on my startup idea. Anyone interested in discussing?", likes: 8, comments: 7)
            ],
            circle: CircleData(
                id: 1,
                name: "Test Circle",
                industry: "Tech",
                memberCount: 100,
                imageName: "test",
                pricing: "Free",
                description: "Test Description",
                joinType: .joinNow,
                channels: ["general"],
                creatorId: 1,
                isModerator: true
            ),
            showCreateThreadPopup: .constant(false)
        )
    }
}
