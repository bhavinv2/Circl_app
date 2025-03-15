import SwiftUI

struct Page7: View {
    @State private var navigateToPage8 = false
    @State private var navigateToPage18 = false

    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Title
                    Text("Your Business Profile")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))
                        .padding(.top, -10)
                    
                    // Separator
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    
                    // Description Text
                    ScrollView {
                        VStack(alignment: .center, spacing: 25) {
                            // Paragraph 1
                            Text("Let's talk business!")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Paragraph 2
                            Text("We are now going to ask about your business’ journey.")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Paragraph 3
                            Text("Circl will be the driving force to entrepreneurial success.")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Paragraph 4
                            Text("We will work together to bring your business to new heights by unlocking the full potential of entrepreneurship with all of the resources we will offer you.")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Let's start!
                            Text("Let's start!")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 35)
                        
                        Spacer()
                    }
                    
                    // Disclaimer
                    Text("*Only the CEO can make the Business Profile")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Next Button
                    Button(action: {
                        navigateToPage8 = true
                    }) {
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
                    
                    // Skip Hyperlink
                    Button(action: {
                        navigateToPage18 = true
                    }) {
                        Text("Skip - I am not the CEO, they will add me later")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding(.top, 5)

                    // Navigation to Page 8
                    NavigationLink(destination: Page8(), isActive: $navigateToPage8) {
                        EmptyView()
                    }

                    // Navigation to Page 18
                    NavigationLink(destination: Page18(), isActive: $navigateToPage18) {
                        EmptyView()
                    }

                    Spacer()
                }
            }
        }
    }
}

struct Page7View_Previews: PreviewProvider {
    static var previews: some View {
        Page7()
    }
}
