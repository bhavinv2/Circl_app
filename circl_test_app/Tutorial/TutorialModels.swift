import SwiftUI
import Foundation

// MARK: - User Type Detection
enum UserType: String, CaseIterable, Codable {
    case entrepreneur = "entrepreneur"
    case student = "student" 
    case studentEntrepreneur = "studentEntrepreneur"
    case mentor = "mentor"
    case communityBuilder = "communityBuilder"
    case investor = "investor"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .entrepreneur: return "Entrepreneur"
        case .student: return "Student"
        case .studentEntrepreneur: return "Student Entrepreneur"
        case .mentor: return "Mentor"
        case .communityBuilder: return "Community Builder"
        case .investor: return "Investor"
        case .other: return "Other"
        }
    }
    
    // Keywords from onboarding that map to user types
    static func detectUserType(from onboardingData: OnboardingData) -> UserType {
        let interests = onboardingData.usageInterests.lowercased()
        let industry = onboardingData.industryInterests.lowercased()
        
        print("🔍 Detecting user type from interests: '\(interests)' and industry: '\(industry)'")
        print("📋 Available Page3 options: Student, Start Your Business, Scale Your Business, Network with Entrepreneurs, Find Co-Founder/s, Find Mentors, Find Investors, Be Part of the Community, Share Knowledge, Make Investments, Sell a Skill")
        
        // EXACT MAPPING from Page3 "Main Usage Interests":
        
        // Student --> Student Tutorial
        if interests.contains("student") && !interests.contains("entrepreneur") && 
           !interests.contains("start your business") && !interests.contains("scale your business") {
            print("✅ Detected: Student (from 'Student' interest)")
            return .student
        }
        
        // Check for student entrepreneur (student + business interests)
        if interests.contains("student") && (interests.contains("entrepreneur") || 
           interests.contains("start your business") || interests.contains("scale your business")) {
            print("✅ Detected: Student Entrepreneur")
            return .studentEntrepreneur
        }
        
        // Start Your Business --> Entrepreneur Tutorial
        if interests.contains("start your business") {
            print("✅ Detected: Entrepreneur (from 'Start Your Business' interest)")
            return .entrepreneur
        }
        
        // Scale Your Business --> Entrepreneur Tutorial
        if interests.contains("scale your business") {
            print("✅ Detected: Entrepreneur (from 'Scale Your Business' interest)")
            return .entrepreneur
        }
        
        // Network with Entrepreneurs --> Entrepreneur Tutorial
        if interests.contains("network with entrepreneurs") {
            print("✅ Detected: Entrepreneur (from 'Network with Entrepreneurs' interest)")
            return .entrepreneur
        }
        
        // Find Co-Founder/s --> Entrepreneur Tutorial
        if interests.contains("find co-founder") {
            print("✅ Detected: Entrepreneur (from 'Find Co-Founder/s' interest)")
            return .entrepreneur
        }
        
        // Find Mentors --> Entrepreneur Tutorial
        if interests.contains("find mentors") {
            print("✅ Detected: Entrepreneur (from 'Find Mentors' interest)")
            return .entrepreneur
        }
        
        // Find Investors --> Entrepreneur Tutorial
        if interests.contains("find investors") {
            print("✅ Detected: Entrepreneur (from 'Find Investors' interest)")
            return .entrepreneur
        }
        
        // Make Investments --> Investor
        if interests.contains("make investments") {
            print("✅ Detected: Investor (from 'Make Investments' interest)")
            return .investor
        }
        
        // Share Knowledge --> Mentor
        if interests.contains("share knowledge") {
            print("✅ Detected: Mentor (from 'Share Knowledge' interest)")
            return .mentor
        }
        
        // Sell a Skill --> Entrepreneur Tutorial
        if interests.contains("sell a skill") {
            print("✅ Detected: Entrepreneur (from 'Sell a Skill' interest)")
            return .entrepreneur
        }
        
        // Be Part of the Community --> Community Builder
        if interests.contains("be part of the community") {
            print("✅ Detected: Community Builder (from 'Be Part of the Community' interest)")
            return .communityBuilder
        }
        
        // Fallback checks for broader keyword matching
        if interests.contains("entrepreneur") || industry.contains("startups & entrepreneurship") {
            print("✅ Detected: Entrepreneur (from broad keyword matching)")
            return .entrepreneur
        }
        
        if interests.contains("invest") || interests.contains("investor") || interests.contains("funding") {
            print("✅ Detected: Investor (from broad keyword matching)")
            return .investor
        }
        
        if interests.contains("mentor") || interests.contains("teaching") {
            print("✅ Detected: Mentor (from broad keyword matching)")
            return .mentor
        }
        
        if interests.contains("community") || interests.contains("networking") {
            print("✅ Detected: Community Builder (from broad keyword matching)")
            return .communityBuilder
        }
        
        // Default to community builder for general users
        print("✅ Detected: Community Builder (default)")
        return .communityBuilder
    }
}

// MARK: - Onboarding Data Model
struct OnboardingData: Codable {
    let usageInterests: String
    let industryInterests: String
    let location: String
    let userGoals: String?
    
    init(usageInterests: String = "", industryInterests: String = "", location: String = "", userGoals: String? = nil) {
        self.usageInterests = usageInterests
        self.industryInterests = industryInterests
        self.location = location
        self.userGoals = userGoals
    }
}

// MARK: - Tutorial Step Model
struct TutorialStep: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let targetView: String // Identifier for the view/component to highlight
    let message: String // Detailed explanation for this user type
    let navigationDestination: String? // Where to navigate (if needed)
    let highlightRect: CGRect? // Area to highlight (optional)
    let tooltipAlignment: TooltipAlignment
    let duration: TimeInterval?
    let isInteractive: Bool // Whether user needs to interact or just view
    
    enum TooltipAlignment: String, Codable, CaseIterable {
        case top, bottom, leading, trailing, center
    }
}

// MARK: - Tutorial Flow Model
struct TutorialFlow: Identifiable, Codable {
    let id = UUID()
    let userType: UserType
    let title: String
    let description: String
    let steps: [TutorialStep]
    let estimatedDuration: TimeInterval
    let isRequired: Bool // Some tutorials might be optional
    
    var progress: Float {
        return 0.0 // Will be calculated by TutorialManager
    }
}

// MARK: - Tutorial Progress Model
struct TutorialProgress: Codable {
    let userId: Int
    let flowId: UUID
    let completedSteps: Set<UUID>
    let currentStepIndex: Int
    let isCompleted: Bool
    let lastAccessed: Date
    let startedAt: Date
    
    init(userId: Int, flowId: UUID) {
        self.userId = userId
        self.flowId = flowId
        self.completedSteps = []
        self.currentStepIndex = 0
        self.isCompleted = false
        self.lastAccessed = Date()
        self.startedAt = Date()
    }
}

// MARK: - Tutorial State
enum TutorialState {
    case notStarted
    case inProgress(stepIndex: Int)
    case completed
    case skipped
}

// MARK: - Tutorial Manager
class TutorialManager: ObservableObject {
    static let shared = TutorialManager()
    
    @Published var currentFlow: TutorialFlow?
    @Published var currentStepIndex: Int = 0
    @Published var isShowingTutorial: Bool = false
    @Published var tutorialState: TutorialState = .notStarted
    @Published var userType: UserType = .communityBuilder
    
    // Track which tutorial type is currently running (may differ from userType)
    private var currentTutorialType: UserType = .communityBuilder
    
    // Prevent multiple simultaneous tutorial starts
    private var isTutorialStarting: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "tutorial_progress"
    private let userTypeKey = "user_type_detected"
    private let completedFlowsKey = "completed_tutorial_flows"
    
    private init() {
        loadUserType()
        loadTutorialProgress()
    }
    
    // MARK: - User Type Management
    func setUserType(_ type: UserType) {
        userType = type
        userDefaults.set(type.rawValue, forKey: userTypeKey)
    }
    
    func detectAndSetUserType(from onboardingData: OnboardingData) {
        let detectedType = UserType.detectUserType(from: onboardingData)
        setUserType(detectedType)
    }
    
    private func loadUserType() {
        if let typeString = userDefaults.string(forKey: userTypeKey),
           let type = UserType(rawValue: typeString) {
            userType = type
        }
    }
    
    // MARK: - Tutorial Flow Management
    func startTutorial(for userType: UserType? = nil) {
        let targetUserType = userType ?? self.userType
        
        // Don't start if already completed (unless this is a manual restart)
        if hasTutorialBeenCompleted(for: targetUserType) {
            print("Tutorial already completed for user type: \(targetUserType) - use restartTutorial() to replay")
            return
        }
        
        guard let flow = getTutorialFlow(for: targetUserType) else {
            print("No tutorial flow found for user type: \(targetUserType)")
            return
        }
        
        // Reset navigation to starting position (PageForum = tab 0)
        NavigationManager.shared.selectedTab = 0
        
        // Reset tutorial state
        currentFlow = flow
        currentStepIndex = 0
        currentTutorialType = targetUserType // Track which tutorial type is running
        tutorialState = .inProgress(stepIndex: 0)
        isShowingTutorial = true
        
        print("Started tutorial for \(targetUserType.displayName): \(flow.title)")
        print("🧭 Reset navigation to PageForum (tab 0)")
    }
    
    func nextStep() {
        guard let flow = currentFlow,
              currentStepIndex < flow.steps.count - 1 else {
            completeTutorial()
            return
        }
        
        currentStepIndex += 1
        tutorialState = .inProgress(stepIndex: currentStepIndex)
        saveTutorialProgress()
        
        // Handle navigation if the new step requires it
        handleStepNavigation()
    }
    
    private func handleStepNavigation() {
        // Navigation is now handled directly by NavigationLinks in the TutorialOverlay
        // No additional handling needed here
    }
    
    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        tutorialState = .inProgress(stepIndex: currentStepIndex)
        saveTutorialProgress()
    }
    
    func skipTutorial() {
        print("⏭️ Skipping tutorial for \(currentTutorialType.displayName)")
        tutorialState = .skipped
        isShowingTutorial = false
        markTutorialAsCompleted()
        currentFlow = nil
        currentTutorialType = userType // Reset to user's actual type
        
        // Don't reset navigation when skipping - let user stay where they are
        print("📊 Tutorial skipped - navigation preserved")
    }
    
    func completeTutorial() {
        print("🎉 Completing tutorial for \(currentTutorialType.displayName)")
        tutorialState = .completed
        isShowingTutorial = false
        markTutorialAsCompleted()
        
        // Show completion message
        showTutorialCompletionMessage()
        currentFlow = nil
        currentTutorialType = userType // Reset to user's actual type
        
        // Don't reset navigation when completing - let user stay where they ended
        print("📊 Tutorial completed - navigation preserved at final position")
    }
    
    private func showTutorialCompletionMessage() {
        // This could trigger a success notification or celebration animation
        print("🎉 Tutorial completed for \(userType.displayName)!")
    }
    
    // MARK: - Tutorial Content
    private func getTutorialFlow(for userType: UserType) -> TutorialFlow? {
        switch userType {
        case .entrepreneur:
            return createEntrepreneurTutorial()
        case .student:
            return createStudentTutorial()
        case .studentEntrepreneur:
            return createStudentEntrepreneurTutorial()
        case .mentor:
            return createMentorTutorial()
        case .communityBuilder:
            return createCommunityBuilderTutorial()
        case .investor:
            return createInvestorTutorial()
        case .other:
            return createGeneralTutorial()
        }
    }
    
    // MARK: - Progress Persistence
    private func saveTutorialProgress() {
        guard let flow = currentFlow else { return }
        
        let progress = TutorialProgress(
            userId: UserDefaults.standard.integer(forKey: "user_id"),
            flowId: flow.id
        )
        
        if let data = try? JSONEncoder().encode(progress) {
            userDefaults.set(data, forKey: progressKey)
        }
    }
    
    private func loadTutorialProgress() {
        guard let data = userDefaults.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(TutorialProgress.self, from: data) else {
            return
        }
        
        // Restore state if needed
        if !progress.isCompleted {
            currentStepIndex = progress.currentStepIndex
            tutorialState = .inProgress(stepIndex: progress.currentStepIndex)
        }
    }
    
    private func markTutorialAsCompleted() {
        // Mark the currently running tutorial type as completed
        var completedFlows = getCompletedFlows()
        completedFlows.insert(currentTutorialType.rawValue)
        
        if let data = try? JSONEncoder().encode(completedFlows) {
            userDefaults.set(data, forKey: completedFlowsKey)
        }
        
        print("✅ Marked \(currentTutorialType.displayName) tutorial as completed")
    }
    
    private func hasTutorialBeenCompleted(for userType: UserType) -> Bool {
        let completedFlows = getCompletedFlows()
        return completedFlows.contains(userType.rawValue)
    }
    
    private func getCompletedFlows() -> Set<String> {
        guard let data = userDefaults.data(forKey: completedFlowsKey),
              let flows = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            print("📝 No completed tutorial flows found (this is normal for new users)")
            return Set<String>()
        }
        print("📝 Found completed tutorial flows: \(flows)")
        return flows
    }
    
    // MARK: - Debug/Testing Methods
    func clearAllTutorialData() {
        print("🧹 Clearing all tutorial completion data...")
        userDefaults.removeObject(forKey: completedFlowsKey)
        userDefaults.removeObject(forKey: "just_completed_onboarding")
        userDefaults.synchronize()
        print("✅ Tutorial data cleared")
    }
    
    func resetTutorialCompletely() {
        print("🔄 COMPLETE TUTORIAL RESET - Clearing all state...")
        
        // Clear all UserDefaults
        userDefaults.removeObject(forKey: completedFlowsKey)
        userDefaults.removeObject(forKey: progressKey)
        userDefaults.removeObject(forKey: "just_completed_onboarding")
        userDefaults.synchronize()
        
        // Reset all @Published properties
        isShowingTutorial = false
        currentFlow = nil
        currentStepIndex = 0
        tutorialState = .notStarted
        
        // Reset navigation to PageForum
        NavigationManager.shared.selectedTab = 0
        
        print("✅ Complete tutorial reset finished")
        print("📊 State: showing=\(isShowingTutorial), step=\(currentStepIndex), tab=\(NavigationManager.shared.selectedTab)")
    }
    
    // MARK: - Utility Methods
    func shouldShowTutorial() -> Bool {
        // Show tutorial if:
        // 1. User just completed onboarding (PRIORITY - always show)
        // 2. Tutorial hasn't been completed for this user type
        // 3. User manually requested tutorial restart
        
        let hasCompletedOnboarding = userDefaults.bool(forKey: "onboarding_completed")
        let justCompletedOnboarding = userDefaults.bool(forKey: "just_completed_onboarding")
        let hasSeenTutorial = hasTutorialBeenCompleted(for: userType)
        
        print("🔍 shouldShowTutorial() check:")
        print("   • hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("   • justCompletedOnboarding: \(justCompletedOnboarding)")
        print("   • hasSeenTutorial for \(userType.displayName): \(hasSeenTutorial)")
        
        // PRIORITY: If user just completed onboarding, ALWAYS show tutorial
        if justCompletedOnboarding {
            print("   • 🎯 PRIORITY: Just completed onboarding - MUST show tutorial!")
            return true
        }
        
        // Normal case: Show if onboarding done and tutorial not seen
        let shouldShow = hasCompletedOnboarding && !hasSeenTutorial
        print("   • Should show (normal case): \(shouldShow)")
        
        return shouldShow
    }
    
    func restartTutorial() {
        print("🔄 Restarting tutorial for \(userType.displayName)")
        
        // Clear completion status for this user type
        var completedFlows = getCompletedFlows()
        completedFlows.remove(userType.rawValue)
        
        if let data = try? JSONEncoder().encode(completedFlows) {
            userDefaults.set(data, forKey: completedFlowsKey)
        }
        
        // Reset current tutorial state completely
        isShowingTutorial = false
        currentFlow = nil
        currentStepIndex = 0
        tutorialState = .notStarted
        
        // Reset navigation to starting position (PageForum = tab 0)
        NavigationManager.shared.selectedTab = 0
        
        // Start fresh tutorial
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.startTutorial(for: self.userType)
        }
        
        print("✅ Tutorial restart complete - navigation reset to PageForum")
    }
    
    func startTutorialForUserType(_ userType: UserType) {
        // Force start tutorial for any user type (used in settings) - ALWAYS works
        print("🔄 Force starting tutorial for \(userType.displayName) (from settings)")
        
        // Clear completion status for this user type
        var completedFlows = getCompletedFlows()
        completedFlows.remove(userType.rawValue)
        
        if let data = try? JSONEncoder().encode(completedFlows) {
            userDefaults.set(data, forKey: completedFlowsKey)
        }
        
        // Clear any existing tutorial state
        isShowingTutorial = false
        currentFlow = nil
        currentStepIndex = 0
        tutorialState = .notStarted
        
        // Reset navigation to starting position (PageForum = tab 0)
        NavigationManager.shared.selectedTab = 0
        print("🧭 Reset navigation to PageForum (tab 0)")
        
        // Get the tutorial flow
        guard let flow = getTutorialFlow(for: userType) else {
            print("❌ No tutorial flow found for user type: \(userType)")
            return
        }
        
        // Start the tutorial with a small delay to ensure navigation has settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Force start the tutorial (bypassing all checks)
            self.currentFlow = flow
            self.currentStepIndex = 0
            self.currentTutorialType = userType // Track which tutorial type is running
            self.tutorialState = .inProgress(stepIndex: 0)
            self.isShowingTutorial = true
            
            print("✅ Successfully started tutorial for \(userType.displayName): \(flow.title)")
            print("📊 Tutorial state: showing=\(self.isShowingTutorial), step=\(self.currentStepIndex)/\(flow.steps.count)")
            print("🎯 Current tutorial type: \(self.currentTutorialType.displayName)")
        }
    }
    
    var currentStep: TutorialStep? {
        guard let flow = currentFlow,
              currentStepIndex < flow.steps.count else { return nil }
        return flow.steps[currentStepIndex]
    }
    
    var progressPercentage: Float {
        guard let flow = currentFlow else { return 0 }
        return Float(currentStepIndex + 1) / Float(flow.steps.count)
    }
    
    // Enhanced tutorial triggering based on app state
    func checkAndTriggerTutorial() {
        print("🔍 Checking if tutorial should be triggered...")
        
        // Prevent multiple simultaneous starts
        guard !isTutorialStarting else {
            print("⏸️ Tutorial start already in progress - skipping duplicate trigger")
            return
        }
        
        // Don't interrupt an active tutorial
        guard !isShowingTutorial else {
            print("⏸️ Tutorial already active - skipping trigger")
            return
        }
        
        // Debug all the key flags
        let onboardingCompleted = userDefaults.bool(forKey: "onboarding_completed")
        let justCompletedOnboarding = userDefaults.bool(forKey: "just_completed_onboarding")
        let completedFlows = getCompletedFlows()
        
        print("📊 Debug Tutorial Check:")
        print("   • onboarding_completed: \(onboardingCompleted)")
        print("   • just_completed_onboarding: \(justCompletedOnboarding)")
        print("   • current user type: \(userType.displayName)")
        print("   • completed tutorial flows: \(completedFlows)")
        print("   • has tutorial been completed for \(userType.displayName): \(hasTutorialBeenCompleted(for: userType))")
        
        // CRITICAL FIX: Priority check for post-onboarding tutorial
        if justCompletedOnboarding {
            print("🎯 CRITICAL: User just completed onboarding - forcing tutorial start!")
            
            // Set starting flag to prevent duplicates
            isTutorialStarting = true
            
            // Clear the flag immediately
            userDefaults.set(false, forKey: "just_completed_onboarding")
            
            // Ensure we have a valid user type (fallback to communityBuilder if needed)
            if userType == .other || userType.rawValue.isEmpty {
                print("⚠️ Invalid user type detected, falling back to communityBuilder")
                setUserType(.communityBuilder)
            }
            
            // Reset navigation to ensure we're on PageForum
            NavigationManager.shared.selectedTab = 0
            
            print("🚀 Starting post-onboarding tutorial for \(userType.displayName) user...")
            
            // Start tutorial with a longer delay to ensure everything is loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Force start the tutorial bypassing all completion checks
                self.forceStartTutorial()
                self.isTutorialStarting = false // Clear the flag
            }
            
            return // Skip the normal shouldShowTutorial() check
        }
        
        // Normal tutorial check for other scenarios
        guard shouldShowTutorial() else { 
            print("❌ Tutorial should not be shown (already completed or onboarding not done)")
            return 
        }
        
        print("✅ Starting tutorial via normal flow for \(userType.displayName)")
        
        // Set starting flag
        isTutorialStarting = true
        
        // Start tutorial after a brief delay to let the main app load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startTutorial(for: self.userType)
            self.isTutorialStarting = false // Clear the flag
        }
    }
    
    // MARK: - Force Start Tutorial (for post-onboarding)
    private func forceStartTutorial() {
        print("🔥 FORCE STARTING tutorial for post-onboarding user (\(userType.displayName))")
        
        // Clear any existing tutorial state
        isShowingTutorial = false
        currentFlow = nil
        currentStepIndex = 0
        tutorialState = .notStarted
        
        // Get the tutorial flow
        if let flow = getTutorialFlow(for: userType) {
            currentFlow = flow
            currentTutorialType = userType
        } else {
            print("❌ CRITICAL: No tutorial flow found for user type: \(userType)")
            // Fallback to community builder tutorial if no flow exists
            if let fallbackFlow = getTutorialFlow(for: .communityBuilder) {
                currentFlow = fallbackFlow
                currentTutorialType = .communityBuilder
                print("✅ Using fallback communityBuilder tutorial")
            } else {
                print("💥 FATAL: No tutorial flows available at all!")
                return
            }
        }
        
        // Force start the tutorial
        currentStepIndex = 0
        tutorialState = .inProgress(stepIndex: 0)
        isShowingTutorial = true
        
        print("✅ Post-onboarding tutorial started successfully!")
        print("� Tutorial state: showing=\(isShowingTutorial), step=\(currentStepIndex), flow=\(currentFlow?.title ?? "none")")
    }
}