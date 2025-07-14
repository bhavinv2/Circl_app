import SwiftUI

// MARK: - Data Models
struct UnreadMessagesCountResponse: Codable {
    let unread_count: Int
}

struct PageInvites: View {
    @State private var showMenu = false
    @State private var rotationAngle: Double = 0
    @State private var unreadMessageCount = 0

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // 🧼 Tap outside to close menu
                if showMenu {
                    Color.black.opacity(0.001) // invisible but tappable
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }
                        .zIndex(1) // sit above content but below menu button
                }

                VStack(spacing: 0) {
                    // Header Section
                    headerSection

                    // Main Content
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Manage your professional network")
                                .font(.headline)
                                .foregroundColor(Color(hex: "004aad"))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.yellow)
                                .cornerRadius(10)
                                .padding(.horizontal)

                            VStack(spacing: 15) {
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Connection Requests")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "My Connections")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Business Partners")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Industry Contacts")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Mentorship Network")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Collaboration Groups")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Professional References")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Alumni Network")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Investment Network")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Advisory Board")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Strategic Partnerships")
                                }
                                NavigationLink(destination: PageForum()) {
                                    NetworkResourceItem(title: "Cross-Industry Connections")
                                }
                            }
                            .padding(.horizontal)
                            .foregroundColor(Color(hex: "004aad"))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .background(Color(UIColor.systemGray4))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea([.top, .bottom])

                // Floating Ellipsis Menu
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Welcome to your resources")
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
                                MenuItem(icon: "envelope.fill", title: "Messages", badgeCount: unreadMessageCount)
                            }
                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                            }
                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
                            }

                            Divider()

                            NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true)) {
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
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showMenu.toggle()
                            rotationAngle += 360
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "004aad"))
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
                    .padding(.bottom, -12)
                    .zIndex(2)
                }
                .padding()
                .zIndex(1)
            }
            .onAppear(perform: fetchUnreadMessageCount)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
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
            .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 15)
            .padding(.bottom, 20)
        }
        .background(
            Color(hex: "004aad")
                .ignoresSafeArea(.all, edges: .top)
        )
        .clipped()
    }

    private func fetchUnreadMessageCount() {
        guard let url = URL(string: "https://circlapp.online/api/unread-messages/count/") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(UnreadMessagesCountResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.unreadMessageCount = decodedResponse.unread_count
                    }
                } catch {
                    // It's possible the response is just a number
                    if let countString = String(data: data, encoding: .utf8), let count = Int(countString) {
                        DispatchQueue.main.async {
                            self.unreadMessageCount = count
                        }
                    } else {
                        print("Failed to decode unread message count: \(error)")
                    }
                }
            } else if let error = error {
                print("Error fetching unread message count: \(error)")
            }
        }.resume()
    }

    // MARK: - Network Resource Item
    private struct NetworkResourceItem: View {
        let title: String

        var body: some View {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

struct PageInvites_Previews: PreviewProvider {
    static var previews: some View {
        PageInvites()
    }
}
