import SwiftUI

struct Page17: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "004aad")
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
                    .offset(x: UIScreen.main.bounds.width / 2 - 90, y: UIScreen.main.bounds.height / 2 - 90)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height / 2 - 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: UIScreen.main.bounds.width / 2 - 20, y: UIScreen.main.bounds.height / 2 - 110)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .offset(x: UIScreen.main.bounds.width / 2 - 145, y: UIScreen.main.bounds.height / 2 - 50)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title and Separator Line
                VStack(spacing: 8) {
                    Text("Circl Ethics")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "ffde59"))
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                }
                
                // Body Text
                ScrollView {
                    VStack(spacing: 22) {
                        Text("Circl will not tolerate businesses that use unethical, exploitative, hatemongering, illegal, or other harmful practices or products. If a business is reported as such, it will be handled on a case-by-case basis, and we reserve the right to remove or suspend the offending parties if we determine it to be necessary.")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 22) // Move body text down by 25 pixels
                        
//                        Text("We have the right to remove you from our platform if any of these are met or deemed by Circl.")
//                            .font(.system(size: 23, weight: .bold))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Next Button
                NavigationLink(destination: Page14()) {
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
                        .padding(.bottom, 40)
                }
                
                Spacer()
            }
        }
    }
}

struct Page17_Previews: PreviewProvider {
    static var previews: some View {
        Page17()
    }
}
