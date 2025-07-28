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
        NavigationView {
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
                            
                            Spacer()
                            
                            // Right side - Enhanced Messages
                            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                ZStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    
                                    if unreadMessageCount > 0 {
                                        Text(unreadMessageCount > 99 ? "99+" : "\(unreadMessageCount)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(
                                                Circle()
                                                    .fill(Color.red)
                                                    .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                                            )
                                            .offset(x: 12, y: -12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)
                        .padding(.top, 10)
                        
                        // Enhanced Tab Buttons Row with modern styling
                        HStack(spacing: 0) {
                            Spacer()
                            
                            // Explore Tab
                            HStack {
                                VStack(spacing: 6) {
                                    Text("Explore")
                                        .font(.system(size: 16, weight: !showMyCircles ? .bold : .medium))
                                        .foregroundColor(.white)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(!showMyCircles ? Color.white : Color.clear)
                                        .frame(height: 3)
                                        .frame(width: 40)
                                        .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMyCircles)
                                }
                                .frame(width: 80)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showMyCircles = false
                                }
                            }
                            
                            Spacer()
                            
                            // My Circles Tab
                            HStack {
                                VStack(spacing: 6) {
                                    Text("My Circles")
                                        .font(.system(size: 16, weight: showMyCircles ? .bold : .medium))
                                        .foregroundColor(.white)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(showMyCircles ? Color.white : Color.clear)
                                        .frame(height: 3)
                                        .frame(width: 60)
                                        .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMyCircles)
                                }
                                .frame(width: 100)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showMyCircles = true
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 12)
                    }
                    .padding(.top, 50)
                    .background(Color(hex: "004aad"))
                    .ignoresSafeArea(edges: .top)
                    
                    .sheet(isPresented: $showCreateCircleSheet) {
                        VStack(spacing: 16) {
                            Text("Create a Circl")
                                .font(.title2)
                                .bold()

                            TextField("Circle Name", text: $circleName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            TextField("Industry", text: $circleIndustry)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            // ✅ NEW: Optional category field
                            TextField("Category (optional)", text: $circleCategory)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            TextEditor(text: $circleDescription)
                                .frame(height: 80)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            Picker("Join Type", selection: $selectedJoinType) {
                                Text("Join Now").tag(JoinType.joinNow)
                                Text("Apply Now").tag(JoinType.applyNow)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.top)

                            Divider()

                            Text("Select Channels")
                                .font(.headline)

                            ForEach(allChannelOptions, id: \.self) { channel in
                                if channel == "#Welcome" {
                                    Toggle(channel, isOn: .constant(true))
                                        .disabled(true)
                                        .foregroundColor(.gray)
                                } else {
                                    Toggle(channel, isOn: Binding(
                                        get: { selectedChannels.contains(channel) },
                                        set: { isSelected in
                                            if isSelected {
                                                selectedChannels.append(channel)
                                            } else {
                                                selectedChannels.removeAll { $0 == channel }
                                            }
                                        }
                                    ))
                                }
                            }

                            Spacer()

                            Button(action: {
                                createCircle()
                            }) {
                                Text("Create Circl")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }

                    // MARK: Enhanced Search Section
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            TextField("Search for a Circle (keywords or name)...", text: $searchText)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                                )
                                .overlay(
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.secondary)
                                            .padding(.leading, -35)
                                        Spacer()
                                    }
                                )
                                .padding(.leading, 35)
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(hex: "004aad"))
                                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                        // Enhanced suggestions list
                        if !searchText.isEmpty {
                            // 1. Filter once
                            let allCircles = exploreCircles + myCircles
                            let filtered = allCircles.filter {
                                $0.name.lowercased().contains(searchText.lowercased())
                            }
                            
                            // 2. Enhanced results display
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filtered) { circle in
                                        Button {
                                            selectedCircleToOpen = circle
                                            searchText = ""
                                            
                                            let isMember = myCircles.contains(where: { $0.id == circle.id })
                                            if isMember {
                                                triggerOpenGroupChat = true
                                            } else {
                                                showAboutPopup = true
                                            }
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: "circle.grid.2x2")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "004aad"))
                                                    .frame(width: 20)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(circle.name)
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(circle.industry)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                        }
                                        
                                        if circle.id != filtered.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                            )
                            .padding(.horizontal, 4)
                            .zIndex(1)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, -45)
                    .padding(.bottom, 10)
                    // MARK: Enhanced Circle List
                    ScrollView {
                        VStack(spacing: 18) {
                            if showMyCircles {
                                // Enhanced My Circles Header
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("My Circles")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("\(myCircles.count) joined circles")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if !myCircles.isEmpty {
                                        Text("\(myCircles.count)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color(hex: "004aad").opacity(0.1))
                                            )
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                if myCircles.isEmpty {
                                    // Enhanced empty state
                                    VStack(spacing: 16) {
                                        Image(systemName: "circle.grid.2x2")
                                            .font(.system(size: 48))
                                            .foregroundColor(Color(hex: "004aad").opacity(0.4))
                                        
                                        Text("No circles joined yet")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Explore and join circles to see them here")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: "004aad").opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                                            )
                                    )
                                    .padding(.horizontal, 20)
                                } else {
                                    ForEach(myCircles) { circle in
                                        renderMyCircleCard(for: circle)
                                    }
                                }
                            } else {
                                // Enhanced Explore Header
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Explore")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Discover new circles")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showCreateCircleSheet.toggle()
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("Create")
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(Color.green)
                                                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                        )
                                    }
                                    .scaleEffect(showCreateCircleSheet ? 0.95 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCreateCircleSheet)
                                }
                                .padding(.horizontal, 20)
                                
                                if exploreCircles.isEmpty {
                                    // Enhanced empty state
                                    VStack(spacing: 16) {
                                        Image(systemName: "magnifyingglass.circle")
                                            .font(.system(size: 48))
                                            .foregroundColor(Color(hex: "004aad").opacity(0.4))
                                        
                                        Text("No circles to explore")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Create a new circle to get started!")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.green.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.green.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                                    .padding(.horizontal, 20)
                                }
                                
                                ForEach(exploreCircles) { circle in
                                    CircleCardView(
                                        circle: circle,
                                        onJoinPressed: {
                                            joinCircleAndOpen(circle: circle)
                                        },
                                        showButtons: true,
                                        isMember: myCircles.contains(where: { $0.id == circle.id })
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 100) // Space for bottom navigation
                    }
                }
                
                // MARK: - Twitter/X Style Bottom Navigation
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        // Forum / Home
                        NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                Image(systemName: "house")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("Home")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        // Connect and Network
                        NavigationLink(destination: PageMyNetwork().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("Network")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        // Circles (Current page - highlighted)
                        VStack(spacing: 4) {
                            Image(systemName: "circle.grid.2x2.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("Circles")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Business Profile
                        NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 4) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("Business")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        // More / Additional Resources
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMoreMenu.toggle()
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                                Text("More")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 6)
                    .background(
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(UIColor.separator))
                            .padding(.horizontal, 16),
                        alignment: .top
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
                
                // MARK: - More Menu Popup
                if showMoreMenu {
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("More Options")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .foregroundColor(.primary)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 0) {
                        // Professional Services
                        NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                            HStack(spacing: 16) {
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Professional Services")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("Find business services and experts")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // News & Knowledge
                        NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                            HStack(spacing: 16) {
                                Image(systemName: "newspaper.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("News & Knowledge")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("Stay updated with industry insights")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // The Circl Exchange
                        NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                            HStack(spacing: 16) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("The Circl Exchange")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("Buy and sell skills and services")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // Settings
                        NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                            HStack(spacing: 16) {
                                Image(systemName: "gear.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Settings")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("Manage your account and preferences")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                    }
                    
                    // Close button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMoreMenu = false
                        }
                    }) {
                        Text("Close")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(Color(UIColor.systemGray6))
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Leave space for bottom navigation
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(2)
        }

        // Tap-out-to-dismiss layer
        if showMoreMenu {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMoreMenu = false
                    }
                }
                .zIndex(1)
        }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCircles()
            loadUserData()
        }
        .onChange(of: showMyCircles) { newValue in
            print("🔄 showMyCircles changed:", newValue)
            loadCircles()
        }
        }
        
        NavigationLink(
            destination: GroupChatWrapper(circle: selectedCircleToOpen),
            isActive: $triggerOpenGroupChat
        ) {
            EmptyView()
        }
        
        NavigationLink(
            destination: GroupChatWrapper(circle: selectedCircleToOpen),
            isActive: $triggerOpenGroupChat
        ) {
            EmptyView()
        }
        .sheet(isPresented: $showAboutPopup) {
            if let circle = selectedCircleToOpen {
                NavigationView {
                    CirclPopupCard(
                        circle: circle,
                        isMember: myCircles.contains(where: { $0.id == circle.id }),
                        onJoinPressed: {
                            joinCircleAndOpen(circle: circle)
                            showAboutPopup = false
                        },
                        onOpenCircle: {
                            selectedCircleToOpen = circle
                            triggerOpenGroupChat = true
                            showAboutPopup = false
                        }
                    )
                    .navigationBarHidden(true)
                }
            }
        }
    }
    
    // MARK: - Load User Data
    func loadUserData() {
        // Load user profile image
        guard let profileUrl = URL(string: "\(baseURL)users/profile/\(userId)/") else { return }
        
        URLSession.shared.dataTask(with: profileUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load user profile:", error?.localizedDescription ?? "unknown")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let profileImage = json["profile_image"] as? String {
                    DispatchQueue.main.async {
                        self.userProfileImageURL = profileImage
                    }
                }
                
                // Also load first name
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let firstName = json["first_name"] as? String {
                    DispatchQueue.main.async {
                        self.userFirstName = firstName
                    }
                }
            } catch {
                print("❌ Failed to parse user profile:", error)
            }
        }.resume()
        
        // Load unread message count
        guard let messagesUrl = URL(string: "\(baseURL)messages/unread_count/\(userId)/") else { return }
        
        URLSession.shared.dataTask(with: messagesUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load unread messages:", error?.localizedDescription ?? "unknown")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let count = json["unread_count"] as? Int {
                    DispatchQueue.main.async {
                        self.unreadMessageCount = count
                    }
                }
            } catch {
                print("❌ Failed to parse unread messages:", error)
            }
        }.resume()
    }
    
    // MARK: - Helpers
    func imageName(for name: String) -> String {
        switch name {
        case "Lean Startup-ists": return "leanstartups"
        case "Houston Landscaping Network": return "houstonlandscape"
        case "UH Marketing": return "uhmarketing"
        default: return "uhmarketing"
        }
    }
    
    func membersString(for name: String) -> String {
        switch name {
        case "Lean Startup-ists": return "1.2k+"
        case "Houston Landscaping Network": return "200+"
        case "UH Marketing": return "300+"
        default: return "100+"
        }
    }
    func joinCircleAndOpen(circle: CircleData) {
        guard let url = URL(string: "\(baseURL)circles/join_circle/") else { return }
        
        let payload = [
            "user_id": userId,
            "circle_id": circle.id
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Join Circle error:", error.localizedDescription)
                return
            }
            
            print("✅ Joined circle:", circle.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                selectedCircleToOpen = circle
                triggerOpenGroupChat = true
            }
            
            loadCircles() // Refresh list
        }.resume()
    }
    
    func joinCircle(circleId: Int) {
        guard let url = URL(string: "\(baseURL)circles/join_circle/") else { return }
        let payload = [
            "user_id": userId,
            "circle_id": circleId
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Join Circle error:", error.localizedDescription)
                return
            }
            
            print("✅ Joined circle:", circleId)
            print("🧠 PageCircles now sees userId:", userId)
            print("🧠 Loaded userId from UserDefaults:", userId)
            loadCircles() // Refresh both tabs
        }.resume()
    }
    func createCircle() {
        guard let url = URL(string: "\(baseURL)circles/create_with_channels/") else { return }
        
        let payload: [String: Any] = [
            "user_id": userId,
            "name": circleName,
            "industry": circleIndustry,
            
            "description": circleDescription,
            "join_type": selectedJoinType.rawValue.lowercased(),
            "channels": selectedChannels,
            "category": circleCategory
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                // ✅ Reset form fields here
                circleName = ""
                circleIndustry = ""
                
                circleDescription = ""
                selectedJoinType = JoinType.joinNow
                selectedChannels = []
                
                showCreateCircleSheet = false
                loadCircles()
            }
        }.resume()
    }
    
    
    
    func loadCircles() {
        print("🔍 loadCircles() called with userId:", userId)
        
        guard let urlMy = URL(string: "\(baseURL)circles/my_circles/\(userId)/"),
              let urlExplore = URL(string: "\(baseURL)circles/explore_circles/\(userId)/") else { return }
        
        func convert(_ data: [APICircle]) -> [CircleData] {
            data.map {
                CircleData(
                    id: $0.id,
                    name: $0.name,
                    industry: $0.industry,
                    memberCount: $0.member_count ?? 0,
                    imageName: imageName(for: $0.name),
                    pricing: $0.pricing,
                    description: $0.description,
                    joinType: $0.join_type == "apply_now" ? JoinType.applyNow : JoinType.joinNow,
                    channels: $0.channels ?? [],
                    creatorId: $0.creator_id,
                    isModerator: $0.is_moderator ?? false
                )
            }
        }
        
        URLSession.shared.dataTask(with: urlMy) { data, response, error in
            if let error = error {
                print("❌ Error loading MY circles:", error.localizedDescription)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 MyCircles status code:", httpResponse.statusCode)
            }
            
            if let data = data {
                print("📥 MyCircles raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                
                if let decoded = try? JSONDecoder().decode([APICircle].self, from: data) {
                    DispatchQueue.main.async {
                        self.myCircles = convert(decoded)
                        print("✅ Loaded My Circles:", self.myCircles.map { $0.name })
                        
                        for i in self.myCircles.indices {
                            let circleId = self.myCircles[i].id
                            self.fetchMembers(for: circleId) { count in
                                DispatchQueue.main.async {
                                    self.myCircles[i].memberCount = count
                                }
                            }
                        }
                    }
                } else {
                    print("❌ Failed to decode My Circles JSON")
                }
            }
        }.resume()
        
        
        URLSession.shared.dataTask(with: urlExplore) { data, response, error in
            if let error = error {
                print("❌ Error loading EXPLORE circles:", error.localizedDescription)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 ExploreCircles status code:", httpResponse.statusCode)
            }
            
            if let data = data {
                print("📥 ExploreCircles raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                
                do {
                    let decoded = try JSONDecoder().decode([APICircle].self, from: data)
                    DispatchQueue.main.async {
                        self.exploreCircles = convert(decoded)
                        for i in self.exploreCircles.indices {
                            let circleId = self.exploreCircles[i].id
                            self.fetchMembers(for: circleId) { count in
                                DispatchQueue.main.async {
                                    self.exploreCircles[i].memberCount = count
                                }
                            }
                        }
                        
                        print("✅ Loaded Explore Circles:", self.exploreCircles.map { $0.name })
                    }
                } catch {
                    print("❌ Failed to decode Explore Circles:", error.localizedDescription)
                }
            }
        }.resume()
        
    }
    func fetchMembers(for circleId: Int, completion: @escaping (Int) -> Void) {
        
        struct Member: Identifiable, Decodable, Hashable {
            let id: Int
            let full_name: String
            let profile_image: String?
            let user_id: Int
        }
        guard let url = URL(string: "\(baseURL)circles/members/\(circleId)/") else {
            completion(0)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to load members for \(circleId):", error?.localizedDescription ?? "unknown")
                completion(0)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                completion(decoded.count)
            } catch {
                print("❌ Failed to decode members for \(circleId):", error)
                completion(0)
            }
        }.resume()
    }
    
    
    
    
    @ViewBuilder
    func renderMyCircleCard(for circle: CircleData) -> some View {
        CircleCardView(
            onOpenCircle: {
                selectedCircleToOpen = circle
                triggerOpenGroupChat = true
            },
            circle: circle,
            showButtons: false,
            isMember: true
        )
        .padding(.horizontal) // ✅ This makes spacing match Explore
    }
    
    
    
    
    struct GroupChatWrapper: View {
        let circle: CircleData?
        
        var body: some View {
            if let circle = circle {
                PageGroupchats(circle: circle).navigationBarBackButtonHidden(true)
            } else {
                EmptyView()
            }
        }
    }
    
    
    
    
    // MARK: - Enhanced Circle Card View
    struct CircleCardView: View {
        var onOpenCircle: (() -> Void)? = nil
        
        var circle: CircleData
        @State private var showAbout = false
        @State private var selectedCircleToOpen: CircleData? = nil
        @State private var triggerOpenGroupChat = false
        var onJoinPressed: (() -> Void)? = nil
        var showButtons: Bool = true
        var isMember: Bool = false
        
        var body: some View {
            HStack(alignment: .center, spacing: 16) {
                // Enhanced circle image
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color(hex: "004aad").opacity(0.1))
                        .frame(width: 90, height: 90)
                    
                    Image(circle.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "004aad").opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(circle.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                        if !circle.pricing.isEmpty {
                            Text(circle.pricing)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "004aad"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "004aad").opacity(0.1))
                                )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "building.2")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("Industry: \(circle.industry)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "person.2")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "004aad"))
                            Text("\(circle.memberCount) Members")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showAbout = true
                        }) {
                            Text("About")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                                .underline()
                        }
                        
                        Spacer()
                        
                        if showButtons {
                            Button(action: {
                                onJoinPressed?()
                            }) {
                                Text(circle.joinType.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(Color.green)
                                            .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                                    )
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                // Enhanced navigation arrow for members
                if isMember {
                    Button(action: {
                        onOpenCircle?()
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(hex: "004aad"))
                            .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 4)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
                    )
            )
            .frame(maxWidth: .infinity)
            .sheet(isPresented: $showAbout) {
                NavigationView {
                    CirclPopupCard(
                        circle: circle,
                        isMember: isMember,
                        onJoinPressed: onJoinPressed,
                        onOpenCircle: {
                            showAbout = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                onOpenCircle?()
                            }
                        }
                    )
                    .navigationBarHidden(true)
                }
            }
        }
    }
    
    
    // MARK: - Preview
    struct PageCircles_Previews: PreviewProvider {
        static var previews: some View {
            PageCircles()
        }
    }
    
}
