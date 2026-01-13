import SwiftUI

// MARK: - Subscription Paywall Testing
extension SubscriptionManager {
    
    // MARK: - Test Methods (Remove in production)
    func testShowPaywallForEntrepreneur() {
        showPaywall(for: .entrepreneur)
    }
    
    func testShowPaywallForStudent() {
        showPaywall(for: .student)
    }
    
    func testShowPaywallForStudentEntrepreneur() {
        showPaywall(for: .studentEntrepreneur)
    }
    
    func testShowPaywallForMentor() {
        showPaywall(for: .mentor)
    }
    
    func testShowPaywallForCommunityBuilder() {
        showPaywall(for: .communityBuilder)
    }
}

// MARK: - Test Button Component
struct PaywallTestButtons: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Paywall Testing")
                .font(.headline)
                .padding(.bottom, 10)
            
            Button("Test Entrepreneur Paywall") {
                subscriptionManager.testShowPaywallForEntrepreneur()
            }
            .buttonStyle(TestButtonStyle())
            
            Button("Test Student Paywall") {
                subscriptionManager.testShowPaywallForStudent()
            }
            .buttonStyle(TestButtonStyle())
            
            Button("Test Student Entrepreneur Paywall") {
                subscriptionManager.testShowPaywallForStudentEntrepreneur()
            }
            .buttonStyle(TestButtonStyle())
            
            Button("Test Mentor Paywall") {
                subscriptionManager.testShowPaywallForMentor()
            }
            .buttonStyle(TestButtonStyle())
            
            Button("Test Community Builder Paywall") {
                subscriptionManager.testShowPaywallForCommunityBuilder()
            }
            .buttonStyle(TestButtonStyle())
            
            Divider()
                .padding(.vertical, 10)
            
            Button("Reset Paywall Status") {
                subscriptionManager.resetPaywallStatus()
            }
            .buttonStyle(TestButtonStyle(color: .red))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TestButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .blue) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}