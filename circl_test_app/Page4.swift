import SwiftUI

struct Page4: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)

                // Clouds
                ZStack {
                    // Top Left Cloud
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 60, y: -UIScreen.main.bounds.height / 2 + 60)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 30, y: -UIScreen.main.bounds.height / 2 + 40)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 110, y: -UIScreen.main.bounds.height / 2 + 30)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 170, y: -UIScreen.main.bounds.height / 2 + 30)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 210, y: -UIScreen.main.bounds.height / 2 + 60)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 90, y: -UIScreen.main.bounds.height / 2 + 50)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 90, height: 90)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 50, y: -UIScreen.main.bounds.height / 2 + 30)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 110, height: 110)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 150, y: -UIScreen.main.bounds.height / 2 + 80)
                    }

                    // Bottom Left Cloud
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 60, y: UIScreen.main.bounds.height / 2 - 60)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 30, y: UIScreen.main.bounds.height / 2 - 40)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 110, y: UIScreen.main.bounds.height / 2 - 30)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 90, y: UIScreen.main.bounds.height / 2 - 50)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 90, height: 90)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 50, y: UIScreen.main.bounds.height / 2 - 30)
                    }
                }

                // Content
                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    Text("Create Your Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))
                        .padding(.top, -10)

                    // Separator
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)

                    // Description Text (Separated into Lines)
                    VStack(alignment: .center, spacing: 20) {
                        Text("We can't wait to welcome you to Circl, there are a few more steps.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("We will now ask you questions that will not just help us, but help you connect with the community much more effectively!")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("You can choose to show the information on your profile, it will help start the conversation process.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Let's Start!")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 35)

                    Spacer()

                    // Next Button with Navigation
                    NavigationLink(destination: Page5()) {
                        Text("Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hexCode: "004aad"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hexCode: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2) // White outline
                            )
                            .padding(.horizontal, 50)
                    }

                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Page4View_Previews: PreviewProvider {
    static var previews: some View {
        Page4()
    }
}


