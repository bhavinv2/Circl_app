import SwiftUI

struct Page19: View {
    @State private var animateConfetti = false
    @State private var confettiOpacity: Double = 0.0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "004aad"),
                        Color(hex: "0066cc")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Top Left Cloud
                ZStack {
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
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 110, height: 110)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 150, y: -UIScreen.main.bounds.height / 2 + 80)
                }

                // Bottom Right Cloud
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 60)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: UIScreen.main.bounds.width / 2 - 5, y: UIScreen.main.bounds.height / 2 - 40)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: UIScreen.main.bounds.width / 2 - 110, y: UIScreen.main.bounds.height / 2 - 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .offset(x: UIScreen.main.bounds.width / 2 - 170, y: UIScreen.main.bounds.height / 2 - 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: UIScreen.main.bounds.width / 2 - 205, y: UIScreen.main.bounds.height / 2 - 70)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .offset(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height / 2 - 50)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                        .offset(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height / 2 - 30)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 110, height: 110)
                        .offset(x: UIScreen.main.bounds.width / 2 - 150, y: UIScreen.main.bounds.height / 2 - 80)
                }
                
                // Confetti Explosion
                if animateConfetti {
                    ConfettiExplosionView()
                        .opacity(confettiOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.5)) {
                                confettiOpacity = 1.0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    confettiOpacity = 0.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    animateConfetti = false
                                }
                            }
                        }
                }
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 110)
                    
                    // Header Section
                    VStack(spacing: 40) {
                        // Logo with subtle shadow
                        Circle()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .overlay(
                                Text("Circl.")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(Color(hex: "004aad"))
                            )
                            .frame(width: 180, height: 180)
                            .padding(.top, 5)
                            .onAppear {
                                withAnimation(.spring()) {
                                    animateConfetti = true
                                }
                            }
                        
                        // Message Section
                        VStack(spacing: 40) {
                            Text("Congratulations!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            
                            Text("Welcome to your future, go dream big and build your way to the top!")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    
                    Spacer()
                    
                    // Buttons Section
                    VStack(spacing: 20) {
                        NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                            Text("Continue to Circl")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "ffde59"))
                            .foregroundColor(Color(hex: "004aad"))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 30)
                        
                        ShareLink(
                            item: URL(string: "https://apps.apple.com/us/app/circl-the-entrepreneurs-hub/id6741139445")!,
                            subject: Text("Join Circl with me!"),
                            message: Text("I want to see you win this year. Join Circl with me.")
                        ) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Invite your Friends")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(Color(hex: "004aad"))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

struct ConfettiExplosionView: View {
    @State private var particles: [Particle] = []
    
    let colors: [Color] = [
        .green, .pink, .purple, .yellow,
        Color(red: 0.4, green: 0.8, blue: 1.0) // Light blue
    ]
    
    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: particles[index].size, height: particles[index].size)
                    .offset(x: particles[index].x, y: particles[index].y)
                    .opacity(particles[index].opacity)
            }
        }
        .onAppear {
            createExplosion()
        }
    }
    
    func createExplosion() {
        particles = []
        
        // Create 150 particles for a rich explosion
        for i in 0..<150 {
            let size = CGFloat.random(in: 6...12)
            let distance = CGFloat.random(in: 50...UIScreen.main.bounds.width/2)
            let angle = Angle(degrees: Double.random(in: 0..<360)).radians
            let duration = Double.random(in: 2.0...4.0)
            
            let x = CGFloat(cos(angle)) * distance
            let y = CGFloat(sin(angle)) * distance
            
            let delay = Double.random(in: 0...0.3)
            let verticalMovement = CGFloat.random(in: -100...100)
            
            particles.append(Particle(
                x: 0, y: 0,
                size: size,
                opacity: 0
            ))
            
            let lastIndex = particles.count - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration * 0.5)) {
                    if lastIndex < particles.count {
                        particles[lastIndex].x = x
                        particles[lastIndex].y = y + verticalMovement
                        particles[lastIndex].opacity = 1
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.5) {
                    withAnimation(.easeIn(duration: duration * 0.5)) {
                        if lastIndex < particles.count {
                            particles[lastIndex].opacity = 0
                        }
                    }
                }
            }
        }
    }
}

struct Particle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

struct Page19_Previews: PreviewProvider {
    static var previews: some View {
        Page19()
    }
}
