import SwiftUI

// MARK: - Subscription Paywall Overlay
struct SubscriptionPaywallOverlay: ViewModifier {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $subscriptionManager.isShowingPaywall) {
                if let paywallContent = subscriptionManager.currentContent {
                    PaywallFullScreenView(content: paywallContent)
                }
            }
    }
}

// MARK: - Full Screen Paywall View
struct PaywallFullScreenView: View {
    let content: SubscriptionContent
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        ZStack {
            // Always show background image immediately (no animation)
            PaywallBackgroundView(content: content)
            
            // Content overlay appears after delay with animation
            if subscriptionManager.subscriptionState == .showingContent {
                PaywallContentView(content: content)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeOut(duration: 0.4), value: subscriptionManager.subscriptionState)
    }
}

// MARK: - Paywall Background View
struct PaywallBackgroundView: View {
    let content: SubscriptionContent
    
    private func getRandomBackgroundImage() -> String {
        let availableImages: [String]
        
        switch content.backgroundImage {
        case "CommunityBuilderPaywall":
            availableImages = ["CommunityBuilderPaywall", "CommunityBuilderPaywall2"]
        case "EntrepreneurPaywall":
            availableImages = ["EntrepreneurPaywall", "EntrepreneurPaywall2"]
        case "StudentEntrepreneurPaywall":
            availableImages = ["StudentEntrepreneurPaywall", "StudentEntrepreneurPaywall2"]
        case "StudentPaywall":
            availableImages = ["StudentPaywall", "StudentPaywall2", "StudentPaywall3"]
        case "MentorPaywall":
            availableImages = ["MentorPaywall", "MentorPaywall2", "MentorPaywall3"]
        case "InvestorPaywall":
            availableImages = ["InvestorPaywall", "InvestorPaywall2", "InvestorPaywall3"]
        default:
            return content.backgroundImage
        }
        
        return availableImages.randomElement() ?? content.backgroundImage
    }
    
    var body: some View {
        // Full screen background image - appears instantly for 0.6s impact
        Image(getRandomBackgroundImage())
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea()
    }
}

// MARK: - Paywall Content View
struct PaywallContentView: View {
    let content: SubscriptionContent
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Close Button (stays on background image)
                HStack {
                    Spacer()
                    Button(action: {
                        subscriptionManager.dismissPaywall()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer(minLength: 50)
                
                // White Content Container (includes title + content)
                VStack(spacing: 30) {
                    // Title Section (now in white background)
                    VStack(spacing: 12) {
                        Text(content.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(content.subtitle)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    
                    // Subscription Plans (Horizontal Scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(content.plans) { plan in
                                SubscriptionPlanCard(
                                    plan: plan,
                                    isSelected: subscriptionManager.selectedPlan?.id == plan.id,
                                    onSelect: {
                                        subscriptionManager.selectedPlan = plan
                                    }
                                )
                                .frame(width: 280) // Fixed width for consistent card sizes
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15) // Add vertical padding to prevent border clipping
                    }
                    .clipShape(Rectangle()) // Use Rectangle to allow overflow
                    
                    // Subscribe Button
                    Button(action: {
                        subscriptionManager.completeSubscription()
                    }) {
                        HStack {
                            Text("Start Your Journey")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
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
                        .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(subscriptionManager.selectedPlan == nil)
                    .opacity(subscriptionManager.selectedPlan == nil ? 0.6 : 1.0)
                    .padding(.horizontal, 30)
                    
                    // Terms & Privacy
                    HStack(spacing: 20) {
                        Button("Terms of Service") {
                            // Handle terms
                        }
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                        
                        Button("Privacy Policy") {
                            // Handle privacy
                        }
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.92))
                .cornerRadius(30)
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                showContent = true
            }
        }
        .scaleEffect(showContent ? 1.0 : 0.9)
        .opacity(showContent ? 1.0 : 0.0)
    }
}

// MARK: - Subscription Plan Card
struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with pricing
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "004aad"))
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(plan.price)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "004aad"))
                            
                            Text("/\(plan.period)")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "0066ff"))
                        }
                        
                        if let originalPrice = plan.originalPrice,
                           let discount = plan.discount {
                            HStack(spacing: 8) {
                                Text(originalPrice)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .strikethrough()
                                
                                Text(discount)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if plan.isPopular {
                        Text("POPULAR")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                            
                            Text(feature)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "004aad").opacity(0.8))
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "004aad").opacity(0.25),
                    Color(hex: "0066ff").opacity(0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? 
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.yellow.opacity(0.9),
                            Color.orange.opacity(0.8),
                            Color.yellow.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "004aad").opacity(0.3),
                            Color(hex: "0066ff").opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 3 : 1
                )
        )
        .shadow(
            color: isSelected ? Color.yellow.opacity(0.3) : Color(hex: "004aad").opacity(0.1),
            radius: isSelected ? 6 : 4,
            x: 0,
            y: isSelected ? 3 : 2
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - View Extension for Easy Usage
extension View {
    func withSubscriptionPaywall() -> some View {
        self.modifier(SubscriptionPaywallOverlay())
    }
}