import SwiftUI

struct Page2: View {
    // Animation states from Page3
    @State private var gradientOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0
    @State private var textOpacity: Double = 0.0

    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced Animated Background from Page3
                animatedBackground
                
                // Enhanced Top Left Cloud with animations (no vertical movement)
                topLeftCloudGroup
                
                // Enhanced Bottom Right Cloud with animations (no vertical movement)
                bottomRightCloudGroup
                
                // Main content from Page2, now scrollable and responsive
                ScrollView {
                    VStack(spacing: 15) {
                        titleSection
                            .padding(.top, 60) // Ensure space from top
                        
                        separatorSection
                        
                        descriptionSection
                        
                        buttonSection
                            .padding(.bottom, 40) // Ensure space from bottom
                    }
                    .padding(.horizontal, 20)
                }
            }
            .onAppear {
                startAnimations()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // To avoid constraints warnings
    }
    
    // MARK: - Background Component (from Page3)
    private var animatedBackground: some View {
        ZStack {
            // Base gradient layer with multiple blues
            LinearGradient(
                colors: [
                    Color(hexCode: "001a3d"),
                    Color(hexCode: "004aad"),
                    Color(hexCode: "0066ff"),
                    Color(hexCode: "003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Moving radial gradients for depth
            RadialGradient(
                colors: [
                    Color(hexCode: "0066ff").opacity(0.4),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 350
            )
            .offset(x: gradientOffset * 0.8, y: -gradientOffset * 0.3)
            .rotationEffect(.degrees(rotationAngle * 0.5))
            
            RadialGradient(
                colors: [
                    Color(hexCode: "002d5a").opacity(0.6),
                    Color.clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: 250
            )
            .offset(x: -gradientOffset * 0.5, y: gradientOffset * 0.6)
            .rotationEffect(.degrees(-rotationAngle * 0.3))
            
            // Flowing wave-like gradient
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hexCode: "004aad").opacity(0.2),
                    Color.clear,
                    Color(hexCode: "0066ff").opacity(0.3),
                    Color.clear
                ],
                startPoint: UnitPoint(x: 0.2 + gradientOffset * 0.001, y: 0),
                endPoint: UnitPoint(x: 0.8 - gradientOffset * 0.001, y: 1)
            )
            
            // Subtle overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    Color.clear,
                    Color.black.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Cloud Components (from Page3, with vertical movement removed)
    private var topLeftCloudGroup: some View {
        ZStack {
            createCloudCircle(size: 120, opacity: 0.9, 
                            x: -UIScreen.main.bounds.width / 2 + 60 + cloudOffset1 * 0.3,
                            y: -UIScreen.main.bounds.height / 2 + 60)
            
            createCloudCircle(size: 100, opacity: 0.85,
                            x: -UIScreen.main.bounds.width / 2 + 30 + cloudOffset1 * 0.2,
                            y: -UIScreen.main.bounds.height / 2 + 40)
            
            createCloudCircle(size: 100, opacity: 0.8,
                            x: -UIScreen.main.bounds.width / 2 + 110 + cloudOffset1 * 0.25,
                            y: -UIScreen.main.bounds.height / 2 + 30)
            
            createCloudCircle(size: 100, opacity: 0.75,
                            x: -UIScreen.main.bounds.width / 2 + 170 + cloudOffset1 * 0.15,
                            y: -UIScreen.main.bounds.height / 2 + 30)
            
            createCloudCircle(size: 100, opacity: 0.8,
                            x: -UIScreen.main.bounds.width / 2 + 210 + cloudOffset1 * 0.35,
                            y: -UIScreen.main.bounds.height / 2 + 60)
            
            createCloudCircle(size: 80, opacity: 0.7,
                            x: -UIScreen.main.bounds.width / 2 + 90 + cloudOffset1 * 0.28,
                            y: -UIScreen.main.bounds.height / 2 + 50)
            
            createCloudCircle(size: 90, opacity: 0.75,
                            x: -UIScreen.main.bounds.width / 2 + 50 + cloudOffset1 * 0.18,
                            y: -UIScreen.main.bounds.height / 2 + 30)
            
            createCloudCircle(size: 110, opacity: 0.8,
                            x: -UIScreen.main.bounds.width / 2 + 150 + cloudOffset1 * 0.22,
                            y: -UIScreen.main.bounds.height / 2 + 80)
        }
    }
    
    private var bottomRightCloudGroup: some View {
        ZStack {
            createCloudCircle(size: 120, opacity: 0.9,
                            x: UIScreen.main.bounds.width / 2 - 60 + cloudOffset2 * 0.2,
                            y: UIScreen.main.bounds.height / 2 - 60)
            
            createCloudCircle(size: 100, opacity: 0.85,
                            x: UIScreen.main.bounds.width / 2 - 30 + cloudOffset2 * 0.15,
                            y: UIScreen.main.bounds.height / 2 - 40)
            
            createCloudCircle(size: 80, opacity: 0.7,
                            x: UIScreen.main.bounds.width / 2 - 90 + cloudOffset2 * 0.3,
                            y: UIScreen.main.bounds.height / 2 - 50)
            
            createCloudCircle(size: 90, opacity: 0.75,
                            x: UIScreen.main.bounds.width / 2 - 50 + cloudOffset2 * 0.25,
                            y: UIScreen.main.bounds.height / 2 - 30)
            
            createCloudCircle(size: 90, opacity: 0.75,
                            x: UIScreen.main.bounds.width / 2 - 30 + cloudOffset2 * 0.18,
                            y: UIScreen.main.bounds.height / 2 - 110)
            
            createCloudCircle(size: 110, opacity: 0.8,
                            x: UIScreen.main.bounds.width / 2 - 155 + cloudOffset2 * 0.28,
                            y: UIScreen.main.bounds.height / 2 - 30)
            
            createCloudCircle(size: 110, opacity: 0.8,
                            x: UIScreen.main.bounds.width / 2 - 150 + cloudOffset2 * 0.22,
                            y: UIScreen.main.bounds.height / 2 - 80)
        }
    }
    
    // Helper function to create cloud circles (from Page3)
    private func createCloudCircle(size: CGFloat, opacity: Double, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(opacity), Color.white.opacity(opacity - 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: size > 100 ? 1 : 0.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: size > 100 ? 8 : 4, x: 0, y: size > 100 ? 4 : 2)
            .offset(x: x, y: y)
    }
    
    // MARK: - Main Content (from Page2)
    private var mainContent: some View {
        // Content is now placed inside the body's ScrollView
        VStack(spacing: 20) {
            titleSection
            separatorSection
            descriptionSection
            buttonSection
        }
        .padding(.horizontal, 40)
        .opacity(textOpacity)
    }
    
    private var titleSection: some View {
        HStack {
            Text("Circl")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Ethics")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(hexCode: "FFD700"))
        }
        .opacity(textOpacity)
        .animation(.easeInOut(duration: 1.0).delay(0.5), value: textOpacity)
    }
    
    private var separatorSection: some View {
        Rectangle()
            .fill(Color.white.opacity(0.8))
            .frame(height: 3)
            .frame(maxWidth: .infinity)
            .cornerRadius(1.5)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .opacity(textOpacity)
            .animation(.easeInOut(duration: 1.0).delay(0.7), value: textOpacity)
            .padding(.horizontal, 40)
    }

    private var descriptionSection: some View {
        Text("""
        We will not allow businesses to be created here that produce, supply, or use: tobacco/nicotine products, unethical health, cannabis, gambling activities, casinos/online casinos, adult entertainment, predatory lending, counterfeit/knockoff products, miracle health products, whatever is deemed unethical/exploitative by Circl.
        """)
        .font(.system(size: 19, weight: .bold, design: .rounded))
        .foregroundColor(.white.opacity(0.9))
        .multilineTextAlignment(.center)
        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 0.5)
        .padding(.horizontal, 40)
        .padding(.top, 25)
        .opacity(textOpacity)
        .animation(.easeInOut(duration: 1.0).delay(0.9), value: textOpacity)
    }
    
    private var buttonSection: some View {
        NavigationLink(destination: Page2_Next()) {
            Text("Next")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(hexCode: "004aad"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
        }
        .opacity(textOpacity)
        .animation(.easeInOut(duration: 1.0).delay(1.1), value: textOpacity)
    }

    // MARK: - Animation Functions (from Page3)
    private func startAnimations() {
        // Start all animations when view appears
        withAnimation(
            Animation.linear(duration: 10.0)
                .repeatForever(autoreverses: true)
        ) {
            gradientOffset = 100
        }
        
        withAnimation(
            Animation.linear(duration: 15.0)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        withAnimation(
            Animation.linear(duration: 20.0)
                .repeatForever(autoreverses: true)
        ) {
            cloudOffset1 = 30
        }
        
        withAnimation(
            Animation.linear(duration: 25.0)
                .repeatForever(autoreverses: true)
        ) {
            cloudOffset2 = -25
        }
        
        // Fade in text content
        withAnimation(
            Animation.easeInOut(duration: 1.5)
        ) {
            textOpacity = 1.0
        }
    }
}

struct Page2_Previews: PreviewProvider {
    static var previews: some View {
        Page2()
    }
}
