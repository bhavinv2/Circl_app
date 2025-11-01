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
    
    var displayName: String {
        switch self {
        case .entrepreneur: return "Entrepreneur"
        case .student: return "Student"
        case .studentEntrepreneur: return "Student Entrepreneur"
        case .mentor: return "Mentor"
        case .communityBuilder: return "Community Builder"
        case .investor: return "Investor"
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
        
        // Don't start if already completed
        if hasTutorialBeenCompleted(for: targetUserType) {
            print("Tutorial already completed for user type: \(targetUserType)")
            return
        }
        
        guard let flow = getTutorialFlow(for: targetUserType) else {
            print("No tutorial flow found for user type: \(targetUserType)")
            return
        }
        
        currentFlow = flow
        currentStepIndex = 0
        currentTutorialType = targetUserType // Track which tutorial type is running
        tutorialState = .inProgress(stepIndex: 0)
        isShowingTutorial = true
        
        print("Started tutorial for \(targetUserType.displayName): \(flow.title)")
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
        tutorialState = .skipped
        isShowingTutorial = false
        markTutorialAsCompleted()
        currentFlow = nil
        currentTutorialType = userType // Reset to user's actual type
    }
    
    func completeTutorial() {
        tutorialState = .completed
        isShowingTutorial = false
        markTutorialAsCompleted()
        
        // Show completion message
        showTutorialCompletionMessage()
        currentFlow = nil
        currentTutorialType = userType // Reset to user's actual type
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
    
    // MARK: - Utility Methods
    func shouldShowTutorial() -> Bool {
        // Show tutorial if:
        // 1. User just completed onboarding
        // 2. Tutorial hasn't been completed for this user type
        // 3. User manually requested tutorial restart
        
        let hasCompletedOnboarding = userDefaults.bool(forKey: "onboarding_completed")
        let hasSeenTutorial = hasTutorialBeenCompleted(for: userType)
        
        print("🔍 shouldShowTutorial() check:")
        print("   • hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("   • hasSeenTutorial for \(userType.displayName): \(hasSeenTutorial)")
        print("   • Should show: \(hasCompletedOnboarding && !hasSeenTutorial)")
        
        return hasCompletedOnboarding && !hasSeenTutorial
    }
    
    func restartTutorial() {
        // Allow users to replay tutorial from settings
        var completedFlows = getCompletedFlows()
        completedFlows.remove(userType.rawValue)
        
        if let data = try? JSONEncoder().encode(completedFlows) {
            userDefaults.set(data, forKey: completedFlowsKey)
        }
        
        startTutorial(for: userType)
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
        
        // Get the tutorial flow
        guard let flow = getTutorialFlow(for: userType) else {
            print("❌ No tutorial flow found for user type: \(userType)")
            return
        }
        
        // Force start the tutorial (bypassing all checks)
        currentFlow = flow
        currentStepIndex = 0
        currentTutorialType = userType // Track which tutorial type is running
        tutorialState = .inProgress(stepIndex: 0)
        isShowingTutorial = true
        
        print("✅ Successfully started tutorial for \(userType.displayName): \(flow.title)")
        print("📊 Tutorial state: showing=\(isShowingTutorial), step=\(currentStepIndex)/\(flow.steps.count)")
        print("🎯 Current tutorial type: \(currentTutorialType.displayName)")
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
        
        guard shouldShowTutorial() else { 
            print("❌ Tutorial should not be shown (already completed or onboarding not done)")
            return 
        }
        
        print("✅ Just completed onboarding: \(justCompletedOnboarding)")
        print("✅ Current user type: \(userType.displayName)")
        
        if justCompletedOnboarding {
            // Clear the flag
            userDefaults.set(false, forKey: "just_completed_onboarding")
            
            print("🚀 Starting tutorial for \(userType.displayName) user...")
            
            // Start tutorial after a brief delay to let the main app load
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startTutorial(for: self.userType)
            }
        } else {
            print("⚠️ just_completed_onboarding flag is false - tutorial won't start")
        }
    }
}