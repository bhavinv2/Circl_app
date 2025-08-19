import SwiftUI
import Foundation

// MARK: - API Model
struct APICircle: Identifiable, Decodable {
    let id: Int
    let name: String
    let industry: String
    let pricing: String
    let description: String
    let join_type: String
    let channels: [String]?
    let creator_id: Int
    let is_moderator: Bool?  // ✅ Add this (optional for safety)
    let member_count: Int?
}



// MARK: - Main View for Circle Discovery
struct PageCircles: View {
    @State private var searchText: String = ""
    @State private var selectedCircleToOpen: CircleData? = nil
    @State private var triggerOpenGroupChat = false
    @State private var showAboutPopup = false
    
    @State private var showCreateCircleSheet = false
    @State private var circleName: String = ""
    @State private var circleIndustry: String = ""
    @State private var circleDescription: String = ""
    @State private var selectedJoinType: JoinType = JoinType.joinNow
    @State private var circleCategory: String = ""
    @State private var showMyCircles = false
    @State private var myCircles: [CircleData] = []
    @State private var exploreCircles: [CircleData] = []
    @AppStorage("user_id") private var userId: Int = 0
    
    @State private var selectedChannels: [String] = []
    let allChannelOptions = ["#Welcome", "#Chats", "#Moderators", "#News"]
    
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var userFirstName: String = ""
    @State private var showMoreMenu = false
    
    init(showMyCircles: Bool = false) {
        self._showMyCircles = State(initialValue: showMyCircles)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if showCreateCircleSheet {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showCreateCircleSheet = false }
                        }
                        .transition(.opacity)
                }
                
                VStack(spacing: 0) {
                    // MARK: Enhanced Header with gradient
                    VStack(spacing: 0) {
                        HStack {
                            // Left side - Enhanced Profile
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                AsyncImage(url: URL(string: userProfileImageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 34, height: 34)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                            )
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    default:
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 34))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Center - Enhanced Logo
                            Text("Circl.")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
