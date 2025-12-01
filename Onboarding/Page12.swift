import SwiftUI

struct Page12: View {
    @State private var navigateToPage13 = false
    
    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "004aad")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Text("Your Business Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "ffde59"))
                    .padding(.top, 4) // Adjusted for 3-pixel drop and 8-pixel reduced spacing
                
                // Separator
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.top, 6) // Further reduced spacing by 8 pixels
                
                // Body Text
                ScrollView {
                    VStack(alignment: .center, spacing: 35) {
                        Text("We now have your business profile set up with basic information.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("We will show you how to complete the business profile later.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("With its completion, we will understand how to guide you to the path of success.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("If you're interested in getting funding, it is also the information we will pass to investors to aid them in making a decision.")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 35)
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: {
                        navigateToPage13 = true
                    }) {
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
                            .padding(.bottom, 40) // Ensures consistent positioning
                    }
                    
                    Spacer()
                }
                
                NavigationLink(destination: Page17(), isActive: $navigateToPage13) {
                    EmptyView()
                }
            }
        }
    }


struct Page12View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Page12()
        }
    }
}

