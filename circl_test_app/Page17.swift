import SwiftUI

struct Page17: View {
    @State private var navigateToPage18 = false
    
    var body: some View {
        ZStack {
            // Background Color
            Color(hexCode: "004aad")
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Spacer()

                    // Title and Separator Line
                    VStack(spacing: 8) {
                        Text("Circl Ethics")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hexCode: "ffde59"))

                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                    }

                    // Body Text
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("We will not allow businesses to be created here that produce, supply, or use: tobacco/nicotine products, unethical health, cannabis, gambling activities, casinos/online casinos, adult entertainment, predatory lending, counterfeit/knockoff products, miracle health products, whatever is deemed unethical/exploitative by Circl.")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 25) // Move body text down by 25 pixels
                            
                            Text("We have the right to remove you from our platform if any of these are met or deemed by Circl.")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }

                    Spacer()

                    // Next Button
                    Button(action: {
                        navigateToPage18 = true
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
                            .padding(.bottom, 40)
                    }

                    Spacer()
                }
                
                NavigationLink(destination: Page18(), isActive: $navigateToPage18) {
                    EmptyView()
                }
            }
        }
    }



struct Page17_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Page17()
        }
    }
}
