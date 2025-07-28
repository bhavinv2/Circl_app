import SwiftUI

// MARK: - Circle Selector and Settings Component
struct CircleSelectorHeader: View {
    let circle: CircleData
    let myCircles: [CircleData]
    @Binding var showSettingsMenu: Bool
    let userId: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Group Selector
            HStack(spacing: 16) {
                // Enhanced Dropdown menu with gradient and shadow
                Menu {
                    ForEach(myCircles, id: \.id) { circl in
                        NavigationLink(destination: PageGroupchats(circle: circl).navigationBarBackButtonHidden(true)) {
                            Text(circl.name)
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(circle.name)
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))

                        Image(systemName: "chevron.down")
                            .foregroundColor(Color(hex: "004aad"))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                    )
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.72)

                // Enhanced Gear icon with modern styling
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showSettingsMenu.toggle()
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                        )
                }
                .scaleEffect(showSettingsMenu ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showSettingsMenu)
            }
            .padding(.horizontal, 16)
            
            // Circle Moderator Badge
            if userId == circle.creatorId {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "004aad"))
                    
                    Text("Circle Moderator")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(hex: "004aad").opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Preview
struct CircleSelectorHeader_Previews: PreviewProvider {
    static var previews: some View {
        CircleSelectorHeader(
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
            myCircles: [],
            showSettingsMenu: .constant(false),
            userId: 1
        )
    }
}
