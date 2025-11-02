import SwiftUI

// MARK: - Tutorial Overlay Modifier
struct TutorialOverlay: ViewModifier {
    @ObservedObject var tutorialManager = TutorialManager.shared
    @State private var highlightFrame: CGRect = .zero
    @State private var targetViewFrame: CGRect = .zero
    
    func body(content: Content) -> some View {
        content
            .overlay(
                tutorialOverlayView
                    .animation(.easeInOut(duration: 0.3), value: tutorialManager.isShowingTutorial)
            )
    }
    
    @ViewBuilder
    private var tutorialOverlayView: some View {
        if tutorialManager.isShowingTutorial,
           let currentStep = tutorialManager.currentStep {
            
            // Check if this is the community welcome step
            if currentStep.targetView == "community_welcome" {
                CommunityWelcomeOverlay(
                    userType: tutorialManager.userType,
                    onJoinCircl: {
                        // Navigate to circles page
                        tutorialManager.completeTutorial()
                        NavigationManager.shared.navigateToCircles()
                    },
                    onInviteFriends: {
                        // Share functionality is handled by ShareLink
                    },
                    onGetStarted: {
                        tutorialManager.completeTutorial()
                    }
                )
                .transition(.scale)
            } else {
                ZStack {
                    // Semi-transparent backdrop
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Allow tap to dismiss or move to next step
                            if !currentStep.isInteractive {
                                tutorialManager.nextStep()
                            }
                        }
                    
                    // Highlighted area cutout
                    if let highlightRect = currentStep.highlightRect {
                        highlightCutout(for: highlightRect)
                    }
                    
                    // Tutorial tooltip
                    TutorialTooltip(
                        step: currentStep,
                        onNext: { tutorialManager.nextStep() },
                        onPrevious: { tutorialManager.previousStep() },
                        onSkip: { tutorialManager.skipTutorial() }
                    )
                }
                .transition(.opacity)
            }
        }
    }
    
    private func highlightCutout(for rect: CGRect) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: rect.width + 16, height: rect.height + 16)
            .position(x: rect.midX, y: rect.midY)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 3)
                    .shadow(color: .white.opacity(0.3), radius: 8)
                    .frame(width: rect.width + 16, height: rect.height + 16)
            )
            .overlay(
                // Pulsing animation for attention
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "ffde59"), lineWidth: 2)
                    .frame(width: rect.width + 20, height: rect.height + 20)
                    .scaleEffect(tutorialManager.isShowingTutorial ? 1.1 : 1.0)
                    .opacity(tutorialManager.isShowingTutorial ? 0.5 : 0.0)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: tutorialManager.isShowingTutorial
                    )
            )
    }
}

// MARK: - Tutorial Tooltip Component
struct TutorialTooltip: View {
    let step: TutorialStep
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onSkip: () -> Void
    
    @ObservedObject var tutorialManager = TutorialManager.shared
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Position tooltip based on alignment
            if step.tooltipAlignment == .top {
                Spacer()
                tooltipContent
                Spacer()
            } else if step.tooltipAlignment == .bottom {
                Spacer()
                tooltipContent
            } else {
                Spacer()
                tooltipContent
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    private var tooltipContent: some View {
        VStack(spacing: 20) {
            // Main content card
            VStack(alignment: .leading, spacing: 16) {
                // Header with step counter
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "004aad"))
                        
                        Text("Step \(tutorialManager.currentStepIndex + 1) of \(tutorialManager.currentFlow?.steps.count ?? 1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    CircularProgressView(
                        progress: tutorialManager.progressPercentage,
                        size: 40
                    )
                }
                
                // Description text
                Text(step.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                // Detailed message
                Text(step.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                // Debug navigation info
                if let destination = step.navigationDestination {
                    Text("🎯 Next: \(destination)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                        .padding(.top, 8)
                        .opacity(0.8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(showContent ? 1.0 : 0.9)
            .opacity(showContent ? 1.0 : 0.0)
            
            // Navigation controls
            tutorialControls
                .scaleEffect(showContent ? 1.0 : 0.9)
                .opacity(showContent ? 1.0 : 0.0)
        }
    }
    
    private var tutorialControls: some View {
        HStack(spacing: 12) {
            // Previous button
            Button(action: onPrevious) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Previous")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(hex: "004aad"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(hex: "004aad"), lineWidth: 2)
                )
            }
            .disabled(tutorialManager.currentStepIndex == 0)
            .opacity(tutorialManager.currentStepIndex == 0 ? 0.5 : 1.0)
            
            Spacer()
            
            // Skip button
            Button(action: onSkip) {
                Text("Skip Tutorial")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .underline()
            }
            
            Spacer()
            
            // Next/Complete button with NavigationLink
            if let destination = step.navigationDestination, !isLastStep {
                // Use NavigationLink for steps that need navigation (like Page13)
                NavigationLink(destination: getDestinationView(for: destination)) {
                    HStack(spacing: 6) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "004aad"),
                                Color(hex: "0066ff")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    // Advance tutorial step when navigating
                    onNext()
                })
            } else {
                // Regular button for steps without navigation or final step
                Button(action: onNext) {
                    HStack(spacing: 6) {
                        Text(isLastStep ? "Complete" : "Next")
                            .font(.system(size: 16, weight: .semibold))
                        
                        if !isLastStep {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "004aad"),
                                Color(hex: "0066ff")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var isLastStep: Bool {
        guard let flow = tutorialManager.currentFlow else { return true }
        return tutorialManager.currentStepIndex == flow.steps.count - 1
    }
    
    // Helper method to get destination view (like Page13 approach)
    @ViewBuilder
    private func getDestinationView(for destination: String) -> some View {
        switch destination {
        case "PageForum":
            PageForum()
        case "PageUnifiedNetworking":
            PageUnifiedNetworking()
        case "PageCircles":
            PageCircles()
        case "PageBusinessProfile":
            PageBusinessProfile()
        case "PageEntrepreneurResources":
            PageEntrepreneurResources()
        case "PageMessages":
            PageMessages()
        case "ProfilePage":
            ProfilePage()
        default:
            PageForum() // Default fallback
        }
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Float
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 3)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "004aad"),
                            Color(hex: "0066ff")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Progress percentage
            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "004aad"))
        }
    }
}

// MARK: - Highlighted View Modifier
struct HighlightedView: ViewModifier {
    let targetId: String
    @ObservedObject var tutorialManager = TutorialManager.shared
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Store the frame of this view for highlighting
                            if let currentStep = tutorialManager.currentStep,
                               currentStep.targetView == targetId {
                                // Update the highlight frame in tutorial manager
                                updateHighlightFrame(geometry.frame(in: .global))
                            }
                        }
                }
            )
            .overlay(
                // Optional glow effect for highlighted elements
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        shouldHighlight ? Color(hex: "ffde59") : Color.clear,
                        lineWidth: 2
                    )
                    .shadow(
                        color: shouldHighlight ? Color(hex: "ffde59").opacity(0.3) : Color.clear,
                        radius: shouldHighlight ? 6 : 0
                    )
                    .animation(.easeInOut(duration: 0.3), value: shouldHighlight)
            )
    }
    
    private var shouldHighlight: Bool {
        guard let currentStep = tutorialManager.currentStep else { return false }
        return tutorialManager.isShowingTutorial && currentStep.targetView == targetId
    }
    
    private func updateHighlightFrame(_ frame: CGRect) {
        // This would ideally update the tutorial manager's highlight frame
        // For now, this is a placeholder for the frame update logic
    }
}

// MARK: - Tutorial Spotlight Effect
struct TutorialSpotlight: View {
    let highlightRect: CGRect
    let cornerRadius: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            // Create a mask that highlights the target area
            Rectangle()
                .fill(Color.black.opacity(0.7))
                .mask(
                    Rectangle()
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .frame(
                                    width: highlightRect.width + 16,
                                    height: highlightRect.height + 16
                                )
                                .position(
                                    x: highlightRect.midX,
                                    y: highlightRect.midY
                                )
                                .blendMode(.destinationOut)
                        )
                )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - View Extensions
extension View {
    func withTutorialOverlay() -> some View {
        self.modifier(TutorialOverlay())
    }
    
    func tutorialHighlight(id: String) -> some View {
        self.modifier(HighlightedView(targetId: id))
    }
}

// MARK: - Community Welcome Overlay
struct CommunityWelcomeOverlay: View {
    let userType: UserType
    let onJoinCircl: () -> Void
    let onInviteFriends: () -> Void
    let onGetStarted: () -> Void
    
    @State private var showContent = false
    @State private var selectedBackgroundImage: String = ""
    
    private func getRandomTutorialEndingImage() -> String {
        let availableImages = ["Tutorial1", "Tutorial2", "Tutorial3", "Tutorial4", "Tutorial5", "Tutorial6", "Tutorial7"]
        return availableImages.randomElement() ?? "Tutorial1"
    }
    
    var body: some View {
        ZStack {
            // Full screen background image - appears instantly for 0.6s impact (like paywall)
            Image(selectedBackgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            
            // Content overlay (appears after 0.6s like paywall)
            if showContent {
                ScrollView {
                    VStack(spacing: 0) {
                        // Main content with white rounded background
                        VStack(spacing: 30) {
                            // Header Section
                            VStack(spacing: 20) {
                                Text("Congratulations on becoming one of us!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                
                                Text("This thriving collaborative ecosystem grows stronger with incredible members like you joining us")
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                            
                            // Community Description
                            VStack(spacing: 15) {
                                Text("Circl brings together employees, students, entrepreneurs, community builders, investors, and mentors into one dynamic ecosystem. The network effect is powerful here. Every connection you make and collaboration you build elevates the future for everyone involved.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                            }
                            
                            // Action Buttons
                            VStack(spacing: 15) {
                                // Join a Circl Button
                                Button(action: onJoinCircl) {
                                    HStack {
                                        Image(systemName: "circle.grid.3x3.fill")
                                        Text("Join a Circl")
                                    }
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(hex: "004aad"))
                                    .cornerRadius(12)
                                }
                                
                                // Invite Friends Button
                                ShareLink(
                                    item: URL(string: "https://apps.apple.com/us/app/circl-the-entrepreneurs-hub/id6741139445")!,
                                    subject: Text("Join Circl with me!"),
                                    message: Text("I want to see you win this year. Join Circl with me and let's grow this ecosystem together!")
                                ) {
                                    HStack {
                                        Image(systemName: "person.2.fill")
                                        Text("Invite Friends")
                                    }
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "004aad"), lineWidth: 1)
                                    )
                                }
                                
                                // Get Started Button
                                Button(action: onGetStarted) {
                                    Text("Get Started")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 12)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 100) // Give space for background to show
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            // Select random background image once when view appears
            selectedBackgroundImage = getRandomTutorialEndingImage()
            
            // Show background for 0.6 seconds, then show content (like paywall)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
        }
    }
}

// MARK: - Tutorial Animation Helpers
struct TutorialAnimations {
    static let bounceIn = Animation.interpolatingSpring(
        mass: 0.8,
        stiffness: 100,
        damping: 10,
        initialVelocity: 0
    )
    
    static let slideIn = Animation.easeOut(duration: 0.4)
    
    static let pulse = Animation.easeInOut(duration: 1.0)
        .repeatForever(autoreverses: true)
    
    static let fadeIn = Animation.easeIn(duration: 0.3)
}