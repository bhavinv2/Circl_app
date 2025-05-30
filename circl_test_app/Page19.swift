import SwiftUI

struct Page19: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.fromHex("004aad"),
                        Color.fromHex("0066cc")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Decorative elements
                ConfettiView()
                    .opacity(0.3)
                
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 30) {
                        // Logo with subtle shadow
                        Circle()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .overlay(
                                Text("Circl.")
                                    .font(.system(size: 55, weight: .bold))
                                    .foregroundColor(Color.fromHex("004aad"))
                            )
                            .frame(width: 180, height: 180)
                            .padding(.top, 40)
                        
                        // Message Section with improved typography
                        VStack(spacing: 20) {
                            Text("Congratulations!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            
                            VStack(spacing: 12) {
                                Text("We can't wait to see you in our community.")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                
                                Text("Your application is being reviewed. You'll receive an email with login credentials once approved.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    Spacer()
                    
                    // Buttons Section with improved styling
                    VStack(spacing: 20) {
                        // Primary Button
                        NavigationLink(destination: Page1().navigationBarBackButtonHidden(true)) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back to Log-in")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.fromHex("ffde59"))
                            .foregroundColor(Color.fromHex("004aad"))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 30)
                        
                        // Secondary Button
                        Link(destination: URL(string: "https://youtu.be/-xEFg7Vodco?si=ZVzh9zmjQhe8E4-Q")!) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("How to Use Our Platform")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(Color.fromHex("004aad"))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Confetti Animation View
struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width/2, y: -50)
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        
        let colors: [UIColor] = [
            .systemYellow, .systemOrange, .white,
            .systemTeal, .systemPurple, .systemPink
        ]
        
        var cells = [CAEmitterCell]()
        for color in colors {
            let cell = CAEmitterCell()
            cell.contents = UIImage(systemName: "circle.fill")?.cgImage
            cell.color = color.cgColor
            cell.birthRate = 2
            cell.lifetime = 15
            cell.velocity = 100
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi/4
            cell.spin = 2
            cell.spinRange = 3
            cell.scale = 0.3
            cell.scaleRange = 0.2
            cell.yAcceleration = 30
            cells.append(cell)
        }
        
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Preview
struct Page19_Previews: PreviewProvider {
    static var previews: some View {
        Page19()
    }
}
