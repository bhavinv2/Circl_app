import SwiftUI

struct Page2_Next: View {
    // Animation states
    @State private var gradientOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0
    @State private var textOpacity: Double = 0.0
    @State private var isAccepted: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced Animated Background
                animatedBackground
                
                // Enhanced Top Left Cloud with animations
                topLeftCloudGroup
                
                // Enhanced Bottom Right Cloud with animations
                bottomRightCloudGroup
                
                // Main content
                ScrollView {
                    VStack(spacing: 15) {
                        titleSection
                            .padding(.top, 60)
                        
                        separatorSection
                        
                        termsSection
                        
                        acceptanceSection
                        
                        buttonSection
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .onAppear {
                startAnimations()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Background Component
    private var animatedBackground: some View {
        ZStack {
            // Base gradient layer with multiple blues
            LinearGradient(
                colors: [
                    Color(hex: "001a3d"),
                    Color(hex: "004aad"),
                    Color(hex: "0066ff")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .offset(x: gradientOffset)
            
            // Moving secondary gradient layer
            LinearGradient(
                colors: [
                    Color(hex: "004aad").opacity(0.6),
                    Color(hex: "0066ff").opacity(0.8),
                    Color(hex: "001a3d").opacity(0.4)
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .offset(x: -gradientOffset)
            .blendMode(.overlay)
            
            // Radial gradient overlay
            RadialGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .rotationEffect(.degrees(rotationAngle))
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Cloud Components
    private var topLeftCloudGroup: some View {
        VStack {
            HStack {
                ZStack {
                    // Main cloud shapes
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .offset(x: cloudOffset1, y: 0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 60, height: 60)
                        .offset(x: cloudOffset1 + 40, y: 0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 100, height: 100)
                        .offset(x: cloudOffset1 + 20, y: -10)
                }
                .blur(radius: 1)
                
                Spacer()
            }
            Spacer()
        }
        .padding(.top, 100)
        .padding(.leading, -50)
    }
    
    private var bottomRightCloudGroup: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    // Main cloud shapes
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 90, height: 90)
                        .offset(x: cloudOffset2, y: 0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 70, height: 70)
                        .offset(x: cloudOffset2 - 35, y: 0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 110, height: 110)
                        .offset(x: cloudOffset2 - 15, y: 10)
                }
                .blur(radius: 1)
            }
        }
        .padding(.bottom, 150)
        .padding(.trailing, -50)
    }
    
    // MARK: - Content Sections
    private var titleSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    // Handle back navigation
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(.bottom, 10)
            
            HStack {
                Text("Circl")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Terms")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "FFD700"))
            }
            .opacity(textOpacity)
            .animation(.easeInOut(duration: 1.0).delay(0.5), value: textOpacity)
        }
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
    }
    
    private var termsSection: some View {
        VStack(spacing: 20) {
            Text("Terms of Service")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(textOpacity)
                .animation(.easeInOut(duration: 1.0).delay(0.9), value: textOpacity)
            
            VStack(alignment: .leading, spacing: 15) {
                termItem(number: "1", text: "You must be 18 years or older to use Circl services")
                termItem(number: "2", text: "All business activities must comply with local and international laws")
                termItem(number: "3", text: "Users are responsible for the accuracy of their profile information")
                termItem(number: "4", text: "Respectful communication is required in all interactions")
                termItem(number: "5", text: "Intellectual property rights must be respected")
                termItem(number: "6", text: "Account suspension may occur for violations of community guidelines")
            }
            .opacity(textOpacity)
            .animation(.easeInOut(duration: 1.0).delay(1.1), value: textOpacity)
        }
        .padding(.horizontal, 30)
        .padding(.top, 15)
    }
    
    private func termItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "FFD700"))
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
        }
    }
    
    private var acceptanceSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isAccepted.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isAccepted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "FFD700"))
                        }
                    }
                    
                    Text("I agree to the Terms of Service and Community Guidelines")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.top, 20)
        .opacity(textOpacity)
        .animation(.easeInOut(duration: 1.0).delay(1.3), value: textOpacity)
    }
    
    private var buttonSection: some View {
        NavigationLink(destination: Page3()) {
            Text("Continue")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(isAccepted ? Color(hex: "004aad") : Color.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: isAccepted ?
                            [Color.white, Color.white.opacity(0.95)] :
                            [Color.white.opacity(0.5), Color.white.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(isAccepted ? 0.15 : 0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
        }
        .disabled(!isAccepted)
        .opacity(textOpacity)
        .animation(.easeInOut(duration: 1.0).delay(1.5), value: textOpacity)
    }
    
    // MARK: - Animations
    private func startAnimations() {
        // Gradient movement
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
            gradientOffset = 100
        }
        
        // Rotation effect
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Cloud movements
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            cloudOffset1 = 30
        }
        
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            cloudOffset2 = -25
        }
        
        // Text opacity animation
        withAnimation(.easeInOut(duration: 0.8)) {
            textOpacity = 1.0
        }
    }
}

#Preview {
    Page2_Next()
}
