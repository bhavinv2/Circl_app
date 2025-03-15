import SwiftUI

struct Page8: View {
    @State private var navigateToPage9 = false

    var body: some View {
        NavigationView { // ✅ Ensures navigation works properly
            ZStack {
                // Background Color
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    Text("Your Business Profile")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))

                    // Separator
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)

                    // Main Text Content
                    ScrollView {
                        VStack(alignment: .center, spacing: 25) {
                            Text("WAIT! One last thing.")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)

                            Text("90% of businesses fail because entrepreneurs simply don’t understand how to properly start a business.")
                                .font(.system(size: 23))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("They don’t understand how to create a business strategy, business plan, business tactics; they don’t know how to create a go-to-market strategy; they don’t know the power of continuous knowledge and the true value of partnership.")
                                .font(.system(size: 23))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Let’s now actually begin...")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 43) // Adjusted padding
                    }

                    Spacer()

                    // Next Button
                    Button(action: {
                        DispatchQueue.main.async {
                            navigateToPage9 = true // ✅ Ensures navigation happens in the main thread
                        }
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
                            .padding(.bottom, 20)
                    }

                    // ✅ Navigation to Page 9
                    NavigationLink(destination: Page9(), isActive: $navigateToPage9) {
                        EmptyView()
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true) // ✅ Hides default navigation bar
        }
    }
}

struct Page8View_Previews: PreviewProvider {
    static var previews: some View {
        Page8()
    }
}
