import SwiftUI

struct Page2: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(hexCode: "004aad")
                .edgesIgnoringSafeArea(.all)
            
            // Top Left Cloud
            ZStack {
                // Main Cloud
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
                
                // Additional Cloud
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .offset(x: -UIScreen.main.bounds.width / 2 + 150, y: -UIScreen.main.bounds.height / 2 + 80)
            }
            
            // Bottom Right Cloud
            ZStack {
                // Main Cloud
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 60)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 40)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: UIScreen.main.bounds.width / 2 - 90, y: UIScreen.main.bounds.height / 2 - 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height / 2 - 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 110)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .offset(x: UIScreen.main.bounds.width / 2 - 155, y: UIScreen.main.bounds.height / 2 - 30)
                
                // Additional Cloud
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .offset(x: UIScreen.main.bounds.width / 2 - 150, y: UIScreen.main.bounds.height / 2 - 80)
            }
            
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
                
                // Description Text (Separated into Paragraphs)
                VStack(alignment: .center, spacing: 35) {
                    // Paragraph 1
                    Text("So you want to be an entrepreneur.")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Paragraph 2
                    Text("""
                    Is it because you want to pursue your passions? Buy your own time? Remove the problem of money? Or maybe is it because you're tired of the uncertainty of tomorrow – the increasing inflation and the competitive job market?
                    """)
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Paragraph 3
                    Text("Congratulations, you found us, and we found you.")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Paragraph 4
                    Text("Let's get to know each other.")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.top, 35)
                
                Spacer()
                
                // Next Button
                NavigationLink(destination: Page3()) {
                    // Add navigation action here
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
}

struct Page2View_Previews: PreviewProvider {
    static var previews: some View {
        Page2()
    }
}
