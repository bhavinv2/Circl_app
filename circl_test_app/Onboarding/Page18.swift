import SwiftUI

struct Page18: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "004aad")
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 80), y: -UIScreen.main.bounds.height / 2 + 0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 130), y: -UIScreen.main.bounds.height / 2 + 0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: -UIScreen.main.bounds.height / 2 + 40)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 110), y: -UIScreen.main.bounds.height / 2 + 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 170), y: -UIScreen.main.bounds.height / 2 + 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 210), y: -UIScreen.main.bounds.height / 2 + 60)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 90), y: -UIScreen.main.bounds.height / 2 + 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 50), y: -UIScreen.main.bounds.height / 2 + 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 150), y: -UIScreen.main.bounds.height / 2 + 80)
            }

            // Bottom Left Cloud (Flipped from Bottom Right Cloud)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 40)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 100), y: UIScreen.main.bounds.height / 2 - 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 50), y: UIScreen.main.bounds.height / 2 - 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 40), y: UIScreen.main.bounds.height / 2 - 70)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 140), y: UIScreen.main.bounds.height / 2 - 30)
            }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    // Title and Separator Line
                    VStack(spacing: 8) {
                        Text("Joining Circl")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "ffde59"))

                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                    }

                    // Body Text
                    VStack(spacing: 20) {
                        (Text("Circl is ")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                        + Text("the ecosystem")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .underline()
                        + Text(" to build on your potential.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("From landing your first real project with a local business, getting hired, or launching your own startup, this is where momentum begins.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("Here, you don't build alone, you build with people who mean it.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 10)

                    // Next Button
                    NavigationLink(destination: Page19()) {
                        Text("Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hex: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2) // White outline
                            )
                            .padding(.horizontal, 50)
                    }
                    .padding(.top, 30)
                }

                Spacer()
            }
        }
    }
}

struct Page18_Previews: PreviewProvider {
    static var previews: some View {
        Page18()
    }
}
