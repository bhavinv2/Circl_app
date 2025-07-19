import SwiftUI

struct LoadingScreen: View {
    @State private var progressValue: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var selectedLoadingScreen: String = ""
    
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
            // Fullscreen background loading image (randomly selected)
            Image(selectedLoadingScreen)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea(.all)
            
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
            selectedLoadingScreen = loadingScreens.randomElement() ?? "Test_Loading_Screen_1"
            
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

// MARK: - App Launch Coordinator
struct AppLaunchView: View {
    @State private var showLoadingScreen = true
    @State private var isUserLoggedIn = false
    
    var body: some View {
        Group {
            if showLoadingScreen {
                LoadingScreen()
            } else if isUserLoggedIn {
                // User is logged in, go directly to main app
                PageForum()
            } else {
                // User not logged in, show login screen
                Page1()
            }
        }
        .onAppear {
            // Check authentication state
            checkAuthenticationState()
            
            // Show loading screen for exactly 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showLoadingScreen = false
            }
        }
    }
    
    private func checkAuthenticationState() {
        // Check if user has a valid auth token
        if let authToken = UserDefaults.standard.string(forKey: "auth_token"), 
           !authToken.isEmpty {
            // Additional check for user_id to ensure complete login state
            let userId = UserDefaults.standard.value(forKey: "user_id") as? Int ?? 0
            
            if userId > 0 {
                print("✅ User is authenticated - redirecting to main app")
                isUserLoggedIn = true
            } else {
                print("❌ Auth token exists but no user_id - showing login")
                isUserLoggedIn = false
            }
        } else {
            print("❌ No auth token found - showing login")
            isUserLoggedIn = false
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}
