import SwiftUI

struct PageEntrepreneurKnowledge: View {
    @State private var showMenu = false // State for showing/hiding the menu
    @State private var rotationAngle: Double = 0

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {

                // Tap outside to close menu
                if showMenu {
                    Color.clear
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }
                        .zIndex(1) // Ensure it's above content
                }


                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                    Text("Circl.")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }


                                Button(action: {
                                    // Action for Filter
                                }) {
                                    HStack {
                                        Image(systemName: "slider.horizontal.3")
                                            .foregroundColor(.white)
                                        Text("Filter")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
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
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                        .background(Color(hex: "004aad"))
                    }

                    // Scrollable Section
                    ScrollView {
                        VStack(spacing: 20) {
                            Image(systemName: "hammer.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(hex: "004aad"))

                            Text("Thank you for your patience with Circl! We are currently working on creating the \"News\" feature - an opportunity for you to learn more about general news about your industry from news sources and fellow entrepreneurs in the community. Keep your notifications on and stay tuned in the discord server to know when we release it!")
                                .font(.body)
                                .foregroundColor(Color(hex: "004aad"))
                                .padding()
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(10)
                                .padding(.top)

                            Spacer()
                        }
                        .padding()
                    }
                }
                .navigationBarHidden(true)

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
                                MenuItem(icon: "envelope.fill", title: "Messages")
                            }

                            NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                            }

                            NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
                            }

                            Divider()

                            NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true))
 {
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
                            rotationAngle += 360 // spin the logo
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
                    .padding(.bottom, -10)

                }
                .padding()
                .zIndex(1)
            }
        }
    }
}

// MARK: - Menu Item Component
struct MenuItem10: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "004aad"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    PageEntrepreneurKnowledge()
}
