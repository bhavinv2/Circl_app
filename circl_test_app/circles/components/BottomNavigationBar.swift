import SwiftUI

// MARK: - Bottom Navigation Bar Component
struct BottomNavigationBar: View {
    @Binding var showMoreMenu: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 0) {
                // Forum / Home
                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 4) {
                        Image(systemName: "house")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                        Text("Home")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(UIColor.label).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                
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
                
                // Circles (Current page - highlighted)
                VStack(spacing: 4) {
                    Image(systemName: "circle.grid.2x2.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                    Text("Circles")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                }
                .frame(maxWidth: .infinity)
                
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
            .padding(.vertical, 16)
            .padding(.bottom, 6)
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
    }
}

// MARK: - Preview
struct BottomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationBar(showMoreMenu: .constant(false))
    }
}
