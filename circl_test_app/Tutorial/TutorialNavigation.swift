import SwiftUI
import Foundation

// MARK: - Simplified Tutorial Navigation
// Navigation is now handled directly by NavigationLinks in TutorialOverlay
// No coordinator needed - following Page13's simple NavigationLink pattern

// MARK: - App Launch View Integration
struct AppLaunchView: View {
    @State private var showLoadingScreen = true
    @State private var isUserLoggedIn = false
    @StateObject private var tutorialManager = TutorialManager.shared
    
    var body: some View {
        Group {
            if showLoadingScreen {
                LoadingScreen()
            } else if isUserLoggedIn {
                // User is logged in, show main app with tutorial overlay
                MainAppView()
                    .withTutorialOverlay()
                    .onAppear {
                        tutorialManager.checkAndTriggerTutorial()
                    }
            } else {
                // User not logged in, show login screen
                Page1()
            }
        }
        .onAppear {
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

// MARK: - Main App View (Simplified)
struct MainAppView: View {
    @StateObject private var tutorialManager = TutorialManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Home Tab
                PageForum()
                    .tutorialHighlight(id: "home_tab")
                    .tabItem {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    }
                    .tag(0)
                
                // Network Tab
                PageUnifiedNetworking()
                    .tutorialHighlight(id: "network_tab")
                    .tabItem {
                        VStack {
                            Image(systemName: "person.2.fill")
                            Text("Network")
                        }
                    }
                    .tag(1)
                
                // Circles Tab
                PageCircles()
                    .tutorialHighlight(id: "circles_tab")
                    .tabItem {
                        VStack {
                            Image(systemName: "circle.grid.2x2.fill")
                            Text("Circles")
                        }
                    }
                    .tag(2)
                
                // Business Tab
                PageBusinessProfile()
                    .tutorialHighlight(id: "business_tab")
                    .tabItem {
                        VStack {
                            Image(systemName: "building.2.fill")
                            Text("Business")
                        }
                    }
                    .tag(3)
                
                // Profile Tab
                ProfilePage()
                    .tutorialHighlight(id: "profile_tab")
                    .tabItem {
                        VStack {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    }
                    .tag(4)
            }
        }
        .withTutorialOverlay()
        .onAppear {
            // Check if tutorial should be triggered after app launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                tutorialManager.checkAndTriggerTutorial()
            }
        }
    }
}

// MARK: - Onboarding Integration Guide
/* 
To integrate with Page3, add this method inside the Page3 struct (not as an extension):

func completePage3WithTutorialSetup() {
    // This should be called when Page3 (user details/interests) is completed
    let onboardingData = OnboardingData(
        usageInterests: selectedUsageInterest ?? "",
        industryInterests: selectedIndustryInterest ?? "",
        location: "", // You can add location if captured in Page3
        userGoals: nil // You can add this if captured
    )
    
    // Detect and set user type based on onboarding data
    TutorialManager.shared.detectAndSetUserType(from: onboardingData)
    
    // Mark that onboarding was just completed to trigger tutorial
    UserDefaults.standard.set(true, forKey: "just_completed_onboarding")
}

Then call this method when the user completes Page3 and moves to the next page.
*/

// MARK: - Settings Integration for Tutorial Restart
struct TutorialSettingsView: View {
    @ObservedObject var tutorialManager = TutorialManager.shared
    @State private var selectedUserType: UserType? = nil
    @State private var showingDropdown = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Tutorial Type Dropdown
            Button(action: {
                showingDropdown = true
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tutorial Type")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(selectedUserType?.displayName ?? "Select Tutorial Type")
                            .font(.system(size: 14))
                            .foregroundColor(selectedUserType != nil ? .primary : .secondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showingDropdown ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showingDropdown)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Start Tutorial Button (appears when user type is selected)
            if let selectedType = selectedUserType {
                Button(action: {
                    startTutorialForSelectedType(selectedType)
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Start \(selectedType.displayName) Tutorial")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "004aad"), Color(hex: "0066ff")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.3), value: selectedUserType)
            }
        }
        .actionSheet(isPresented: $showingDropdown) {
            ActionSheet(
                title: Text("Select Tutorial Type"),
                message: Text("Choose which tutorial you'd like to experience"),
                buttons: createUserTypeButtons()
            )
        }
    }
    
    private func createUserTypeButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        
        // Add button for each user type
        for userType in UserType.allCases {
            buttons.append(.default(Text(userType.displayName)) {
                selectedUserType = userType
            })
        }
        
        // Add cancel button
        buttons.append(.cancel())
        
        return buttons
    }
    
    private func startTutorialForSelectedType(_ userType: UserType) {
        // Start tutorial for selected type
        tutorialManager.startTutorialForUserType(userType)
        
        print("🚀 Tutorial started for \(userType.displayName) from settings")
        print("� Tutorial will display overlay with NavigationLinks for navigation")
    }
}

// MARK: - Tutorial Debug View (for development)
struct TutorialDebugView: View {
    @ObservedObject var tutorialManager = TutorialManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tutorial Debug")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Current User Type: \(tutorialManager.userType.displayName)")
            
            Text("Tutorial State: \(String(describing: tutorialManager.tutorialState))")
            
            if let currentStep = tutorialManager.currentStep {
                Text("Current Step: \(currentStep.title)")
                Text("Step \(tutorialManager.currentStepIndex + 1) of \(tutorialManager.currentFlow?.steps.count ?? 0)")
            }
            
            HStack {
                ForEach(UserType.allCases, id: \.self) { userType in
                    Button(userType.displayName) {
                        tutorialManager.setUserType(userType)
                        tutorialManager.startTutorial(for: userType)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            Button("Stop Tutorial") {
                tutorialManager.skipTutorial()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - Tutorial Completion Celebration
struct TutorialCompletionView: View {
    let userType: UserType
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Celebration animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "004aad"),
                                    Color(hex: "0066ff")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(1.2)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
                
                VStack(spacing: 16) {
                    Text("🎉 Tutorial Complete!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You're all set to make the most of Circl as \(userType.displayName.lowercased())")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button(action: onDismiss) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "004aad"))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
            }
        }
    }
}