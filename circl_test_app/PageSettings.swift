import SwiftUI

// MARK: - Main View
struct PageSettings: View {
    @State private var showMenu = false // State for hammer menu

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection

                    // Middle Section: Settings Options
                    ScrollView {
                        VStack(spacing: 20) {
                            // Invite a Friend
                            SectionHeader(title: "Invite a Friend")

                            // Account Settings
                            SectionHeader(title: "Account Settings")

                            // Feedback & Suggestions
                            SectionHeader(title: "Feedback & Suggestions")

                            // Legal & Policies
                            SectionHeader(title: "Legal & Policies")

                            // Help & Support
                            SectionHeader(title: "Help & Support")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .navigationBarHidden(true)

                // Hammer Menu
                VStack(alignment: .trailing, spacing: 8) {
                    if showMenu {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Welcome to your resources")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))

                            Divider()
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
                        Image(systemName: "hammer.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.fromHex("004aad"))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Circl.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .frame(width: 50, height: 40)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color.fromHex("004aad"))
        }
    }

    // MARK: - Section Header
    private func SectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, 20)
    }

    // MARK: - Settings Option
    private func settingsOption(title: String, iconName: String) -> some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.fromHex("004aad"))
                .cornerRadius(8)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.leading, 10)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct PageSettings_Previews: PreviewProvider {
    static var previews: some View {
        PageSettings()
    }
}

