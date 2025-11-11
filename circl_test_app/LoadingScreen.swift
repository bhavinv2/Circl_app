import SwiftUI

struct LoadingScreen: View {
    @State private var progressValue: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var selectedLoadingScreen: String = "Test_Loading_Screen_1" // Default to ensure image shows
    
    // Array of available loading screens
    private let loadingScreens = [
        "Test_Loading_Screen_1", 
        "Test_Loading_Screen_4",
        "Test_Loading_Screen_5",
        "Test_Loading_Screen_6",
        "Test_Loading_Screen_7",
        "Test_Loading_Screen_8",
        "Test_Loading_Screen_9"
    ]
    
    var body: some View {
        ZStack {
            // Fallback background color in case image fails to load
            Color(.systemGray4)
                .ignoresSafeArea(.all)
            
            // Fullscreen background loading image (randomly selected)
            Image(selectedLoadingScreen)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea(.all)
                .onAppear {
                    print("🖼️ LoadingScreen: Attempting to load image: \(selectedLoadingScreen)")
                }
            
            // Dark overlay for better logo visibility
            Color.black.opacity(0.3)
                .ignoresSafeArea(.all)
            
            // Centered CIRCL logo
            VStack {
                Spacer()
                    .frame(height: 50) // Even smaller spacer to move logo farther up
                
                Image("Circl._1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 300)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Spacer() // Larger spacer below logo
                
                // Loading indicator at the bottom
                VStack(spacing: 20) {
                    Text("LOADING")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.9)
                        .tracking(3)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    
                    // Custom progress bar with shadow for visibility
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 250, height: 6)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 250 * CGFloat(progressValue), height: 6)
                            .animation(.easeInOut(duration: 3.0), value: progressValue)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Randomly select a loading screen
            let newScreen = loadingScreens.randomElement() ?? "Test_Loading_Screen_1"
            selectedLoadingScreen = newScreen
            print("🖼️ LoadingScreen: Selected background image: \(newScreen)")
            
            // Animate logo appearance
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animate the progress bar
            withAnimation(.easeInOut(duration: 3.0).delay(0.3)) {
                progressValue = 1.0
            }
        }
    }
}

// MARK: - App Launch Coordinator (moved to TutorialNavigation.swift)
// This struct is now defined in TutorialNavigation.swift with tutorial integration

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}
