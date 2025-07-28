import SwiftUI

// MARK: - Settings Menu Overlay Component
struct SettingsMenuOverlay: View {
    @Binding var showSettingsMenu: Bool
    @Binding var showCircleAboutPopup: Bool
    @Binding var navigateToMembers: Bool
    @Binding var showLeaveConfirmation: Bool
    @Binding var showManageChannels: Bool
    @Binding var showDeleteConfirmation: Bool
    
    let circle: CircleData
    let userId: Int
    
    var body: some View {
        ZStack {
            // FULL invisible blocker
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        showSettingsMenu = false
                    }
                }

            // Dimmed background that can't pass touches
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .allowsHitTesting(false) // 🔐 block interaction passing

            // Floating menu under gear icon
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    showCircleAboutPopup = true
                }) {
                    GroupMenuItem(icon: "info.circle.fill", title: "About This Circle")
                }
                .buttonStyle(PlainButtonStyle())

              
                Button(action: {
                    navigateToMembers = true
                    showSettingsMenu = false
                }) {
                    GroupMenuItem(icon: "person.2.fill", title: "Members List")
                }
                .buttonStyle(PlainButtonStyle())

              

                Divider()

                Button(action: {
                    showLeaveConfirmation = true
                    showSettingsMenu = false
                }) {
                    GroupMenuItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Leave Circle", isDestructive: true)
                }
                .buttonStyle(PlainButtonStyle())

                if userId == circle.creatorId {
                    Divider()

                    Text("Moderator Options")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Button(action: {
                        showManageChannels = true
                        showSettingsMenu = false
                    }) {
                        GroupMenuItem(icon: "slider.horizontal.3", title: "Manage Channels")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showDeleteConfirmation = true
                        showSettingsMenu = false
                    }) {
                        GroupMenuItem(icon: "trash.fill", title: "Delete Circle", isDestructive: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 5)
            .frame(width: 250)
            .padding(.top, -150)  // 🔁 adjust to move under gear
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
        .zIndex(999)
    }
}

// MARK: - Preview
struct SettingsMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenuOverlay(
            showSettingsMenu: .constant(true),
            showCircleAboutPopup: .constant(false),
            navigateToMembers: .constant(false),
            showLeaveConfirmation: .constant(false),
            showManageChannels: .constant(false),
            showDeleteConfirmation: .constant(false),
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
            userId: 1
        )
    }
}
