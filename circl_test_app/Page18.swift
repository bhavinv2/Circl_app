import SwiftUI

struct Page18: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(hexCode: "004aad")
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

            VStack(spacing: 30) {
                Spacer()

                // Title and Separator Line
                VStack(spacing: 8) {
                    Text("Joining Circl")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))

                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                }

                // Scrollable Body Text
                ScrollView {
                    VStack(spacing: 20) {
                        Text("We are Circl, your partner in all aspects of your entrepreneurship journey.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("This is an exclusive community only allowing humble, honest, collaborative, diligent, resourceful, hardworking, and integrity-filled individuals that are eager to learn and grow.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("Creating an application and an account means you adhere to our virtues.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("We utilize community governance to ensure all standards are met.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                }
                .frame(maxHeight: 450) // Limit the scrollable height

                Spacer()

                // Next Button
                NavigationLink(destination: Page19()) {
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
                        .padding(.bottom, 40)
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
