import SwiftUI
import Foundation

// Add reference to CircleDataModels.swift for data types

struct PageGroupchats: View {
    @State private var showSettingsMenu = false
    @State private var showLeaveConfirmation = false
    @State private var navigateToMembers = false
    @State private var showMoreMenu = false
    @State private var userProfileImageURL: String = ""
    @State private var unreadMessageCount: Int = 0
    @State private var categories: [ChannelCategory] = []
    @State private var selectedTab: GroupTab = .home
    @State private var announcements: [AnnouncementModel] = []
    @State private var showCreateAnnouncementPopup = false
    @State private var isDashboardEnabled: Bool
    @State var circle: CircleData
    @State private var navigateToDues = false


    
    @State private var showDeleteConfirmation = false
    @State private var deleteInputText = ""
    @State private var showManageChannels = false

    @State private var myCircles: [CircleData] = []

    @Environment(\.presentationMode) var presentationMode
    @AppStorage("user_id") private var userId: Int = 0
    @State private var loading = true
    @AppStorage("last_circle_id") private var lastCircleId: Int = 0

    @State private var circles: [CircleData] = []
    @State private var channels: [Channel] = []
    var groupedChannels: [String: [Channel]] {
        Dictionary(grouping: channels) { $0.name.prefix(1).uppercased() }
    }



   
    @State private var selectedGroup: String
   
    @State private var showCircleAboutPopup = false
    init(circle: CircleData) {
        _circle = State(initialValue: circle) // ✅ not just `circle = ...`
        _selectedGroup = State(initialValue: circle.name)
        _isDashboardEnabled = State(initialValue: circle.hasDashboard ?? false)
        lastCircleId = circle.id
    }



    @State private var threads: [ThreadPost] = []
    @State private var showCreateThreadPopup = false
    @State private var newThreadContent: String = ""


    var body: some View {
        ZStack {
            // Enhanced background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(hex: "004aad").opacity(0.02)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                GroupChatHeader(hasDashboard: circle.hasDashboard ?? false, selectedTab: $selectedTab)

                if selectedTab == .dashboard {
                    DashboardView(circle: circle)
                } else if selectedTab == .calendar {
                    CalendarView(circle: circle)
                } else {
                    // 🏠 HOME TAB — all of this goes inside here 👇
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            

                            // Group Selector
                            VStack(alignment: .center, spacing: 12) {
                                HStack(spacing: 16) {
                                    // Enhanced Dropdown menu with gradient and shadow
                                    Menu {
                                        ForEach(myCircles, id: \.id) { circl in
                                            NavigationLink(destination: PageGroupchats(circle: circl).navigationBarBackButtonHidden(true)) {
                                                Text(circl.name)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text(circle.name)
                                                .foregroundColor(.primary)
                                                .font(.system(size: 18, weight: .semibold))

                                            Image(systemName: "chevron.down")
                                                .foregroundColor(Color(hex: "004aad"))
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.72)

                                    // Enhanced Gear icon with modern styling
                                    Button(action: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showSettingsMenu.toggle()
                                        }
                                    }) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 48, height: 48)
                                            .background(
                                                Circle()
                                                    .fill(Color.white)
                                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                                            )
                                    }
                                    .scaleEffect(showSettingsMenu ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showSettingsMenu)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)

                                // Enhanced Moderator label with modern badge styling
                                if circle.isModerator {

                                    HStack(spacing: 6) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(hex: "004aad"))
                                        
                                        Text("Circle Moderator")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color(hex: "004aad"))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "004aad").opacity(0.1))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                                    )
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.bottom, 16)
                            // 📢 Announcements Section
                            AnnouncementsSection(
                                announcements: announcements,
                                showCreateAnnouncementPopup: $showCreateAnnouncementPopup,
                                userId: userId,
                                circle: circle
                            )
                            .padding(.bottom, 8)




        //                    Announcement Banner
        //                    Text("Announcements: Group Call Tonight 8:00 PM")
        //                        .font(.subheadline)
        //                        .foregroundColor(.white)
        //                        .padding(8)
        //                        .frame(maxWidth: .infinity)
        //                       .background(Color.fromHex("004aad"))
        //                        .cornerRadius(10)
        //                        .padding(.horizontal)
        //                        .padding(.vertical, 5)
                        
                        //Enhanced Circle Threads Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Circle Threads")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Share ideas and discussions")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Button(action: {
                                        showCreateThreadPopup = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("New")
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "0066dd")]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 6, x: 0, y: 3)
                                        )
                                    }
                                    .scaleEffect(showCreateThreadPopup ? 0.95 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCreateThreadPopup)
                                }
                                .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(threads) { thread in
                                            ThreadCard(thread: thread)
                                                .frame(width: 300)
                                        }
                                        
                                        // Empty state card when no threads
                                        if threads.isEmpty {
                                            VStack(spacing: 8) {
                                                Image(systemName: "bubble.left.and.bubble.right")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(Color(hex: "004aad").opacity(0.4))
                                                
                                                Text("No threads yet")
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                
                                                Text("Be the first to start a discussion!")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(width: 260, height: 120)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(hex: "004aad").opacity(0.05))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                                                            .foregroundColor(Color(hex: "004aad").opacity(0.1))
                                                    )
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 6)

                            // Enhanced Divider
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color(hex: "004aad").opacity(0.2), Color.clear]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            
                            // Enhanced Channels Section
                        ScrollView {
                            VStack(alignment: .leading, spacing: 18) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Channels")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.primary)
                                        Text("Join conversations by topic")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Text("\(channels.count) channels")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color(hex: "004aad").opacity(0.1)))
                                }
                                .padding(.horizontal, 20)

                                if categories.isEmpty {
                                    Text("No channels created yet.")
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 20)
                                } else {
                                    ForEach(categories) { category in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(category.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 20)

                                            ForEach(category.channels.filter { channel in
                                                !channel.isModeratorOnly! || circle.isModerator
                                            }) { channel in
                                                NavigationLink(destination: PageCircleMessages(channel: channel, circleName: circle.name)) {
                                                    HStack(spacing: 10) {
                                                        Image(systemName: "number")
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(Color(hex: "004aad"))
                                                            .frame(width: 28, height: 28)
                                                            .background(Circle().fill(Color(hex: "004aad").opacity(0.1)))

                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(channel.name)
                                                                .font(.system(size: 15, weight: .medium))
                                                                .foregroundColor(.primary)

                                                            Text("Tap to join conversation")
                                                                .font(.system(size: 12))
                                                                .foregroundColor(.secondary)
                                                        }

                                                        Spacer()

                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 11, weight: .medium))
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 12)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.white)
                                                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
                                                    )
                                                    .padding(.horizontal, 16)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 6)
                            .padding(.bottom, 100)
                        }

                            Spacer()
                        }
                        .sheet(isPresented: $showCreateThreadPopup) {
                            VStack(spacing: 16) {
                                Text("New Thread")
                                    .font(.headline)
                                TextEditor(text: $newThreadContent)
                                    .frame(height: 120)
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

                                Button("Post") {
                                    postNewThread()
                                    showCreateThreadPopup = false
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                Spacer()
                            }
                            .padding()
                        }
                        .sheet(isPresented: $showCircleAboutPopup) {
                            CirclPopupCard(circle: circle, isMember: true)
                        }
                        .sheet(isPresented: $showManageChannels) {
                            ManageChannelsView(circleId: circle.id, channels: $channels)
                                .onDisappear {
                                    // Refresh channels when returning from manage view
                                    fetchCategoriesAndChannels(for: circle.id)

                                }
                        }
                        .sheet(isPresented: $showCreateAnnouncementPopup) {
                            CreateAnnouncementPopup(circleId: circle.id, userId: userId) {
                                fetchAnnouncements(for: circle.id)
                            }
                        }


                        
                        }
                    }
                }
            
            

            NavigationLink(
                                       destination: PageDues(circle: circle).navigationBarBackButtonHidden(true),
                                       isActive: $navigateToDues
                                   ) {
                                       EmptyView()
                                   }


            if showSettingsMenu {
                ZStack {
                    // FULL invisible blocker
                    Color.clear
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                showSettingsMenu = false
                            }
                        }

                    // Dimmed background that can't pass touches
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(false) // 🔐 block interaction passing

                    // Floating menu under gear icon
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: {
                            showCircleAboutPopup = true
                        }) {
                            GroupMenuItem(icon: "info.circle.fill", title: "About This Circle")
                        }
                        .buttonStyle(PlainButtonStyle())

                      
                        Button(action: {
                            navigateToMembers = true
                            showSettingsMenu = false
                        }) {
                            GroupMenuItem(icon: "person.2.fill", title: "Members List")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            navigateToDues = true
                            showSettingsMenu = false
                        }) {
                            GroupMenuItem(icon: "creditcard.fill", title: "Dues")
                        }
                        .buttonStyle(PlainButtonStyle())
                       
                      

                        Divider()

                        Button(action: {
                            showLeaveConfirmation = true
                            showSettingsMenu = false
                        }) {
                            GroupMenuItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Leave Circle", isDestructive: true)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if circle.isModerator {

                            Divider()

                            Text("Moderator Options")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            Toggle(isOn: $isDashboardEnabled) {
                                Label("Enable Dashboard", systemImage: "chart.bar")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "004aad")))
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(8)
                            .onChange(of: isDashboardEnabled) { newValue in
                                updateDashboardEnabled(to: newValue)
                            }
                            
                     


                            Button(action: {
                                showManageChannels = true
                                showSettingsMenu = false
                            }) {
                                GroupMenuItem(icon: "slider.horizontal.3", title: "Manage Channels")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                showDeleteConfirmation = true
                                showSettingsMenu = false
                            }) {
                                GroupMenuItem(icon: "trash.fill", title: "Delete Circle", isDestructive: true)
                            }
                            .buttonStyle(PlainButtonStyle())

                        }

                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(width: 250)
                    .padding(.top, -150)  // 🔁 adjust to move under gear
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, alignment: .topTrailing)

                }
                .zIndex(999)
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
                                NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
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
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "004aad"))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Settings")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("Manage your account settings")
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
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .background(
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMoreMenu = false
                                }
                            }
                    )
                    .zIndex(2)
                }
            }
        
        NavigationLink(
            destination: MemberListPage(circleName: circle.name, circleId: circle.id),
            isActive: $navigateToMembers
        ) {
            EmptyView()
        }
        .alert("Leave Circle?", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                leaveCircle()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this circle?")
        }
        
        .alert("Delete Circle", isPresented: $showDeleteConfirmation) {
            TextField("Type CIRCL to confirm", text: $deleteInputText)

            Button("Delete", role: .destructive) {
                if deleteInputText == "CIRCL" {
                    deleteCircle()
                }
            }

            Button("Cancel", role: .cancel) {
                deleteInputText = ""
            }
        } message: {
            Text("Are you sure? This action will permanently delete the circle and all its data.")
        }

        
    

        .onAppear {
            print("🔄 PageGroupchats appeared - Circle ID: \(circle.id), User ID: \(userId)")
            fetchCategoriesAndChannels(for: circle.id)

            fetchThreads(for: circle.id)
            fetchMyCircles(userId: userId)
            fetchAnnouncements(for: circle.id)
            fetchLatestCircleDetails()
            
            
            

            func fetchMyCircles(userId: Int) {
                URLSession.shared.dataTask(with: URL(string: "http://localhost:8000/api/circles/my_circles/\(userId)/")!) { data, _, _ in
                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.loading = false
                        }
                        return
                    }
                    if let decoded: [CircleData] = try? JSONDecoder().decode([CircleData].self, from: data) {
                        DispatchQueue.main.async {
                            self.myCircles = decoded
                            self.loading = false
                        }
                    } else {
                        print("❌ Failed to decode my_circles")
                        DispatchQueue.main.async {
                            self.loading = false
                        }
                    }
                }.resume()
            }

        }
    }

    func fetchCategoriesAndChannels(for circleId: Int) {
        guard let url = URL(string: "\(baseURL)circles/get_categories/\(circleId)/?user_id=\(userId)") else {
            print("❌ Invalid URL for get_categories")
            return
        }

        print("🌐 Fetching categories + channels for circle: \(circleId)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("❌ No data")
                    return
                }

                if let decoded = try? JSONDecoder().decode([ChannelCategory].self, from: data) {
                    print("✅ Decoded \(decoded.count) categories")
                    self.categories = decoded
                    self.channels = decoded.flatMap { $0.channels } // ← for the count + legacy use
                } else {
                    print("❌ Failed to decode categories")
                    if let str = String(data: data, encoding: .utf8) {
                        print("Raw response:\n\(str)")
                    }
                }
            }
        }.resume()
    }

    func postNewThread() {
        guard let url = URL(string: "\(baseURL)circles/create_thread/") else { return }

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id,
            "content": newThreadContent
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                newThreadContent = ""
                fetchThreads(for: circle.id)
            }
        }
        task.resume()
    }

    func leaveCircle() {
        guard let url = URL(string: "\(baseURL)circles/leave_circle/") else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }
        task.resume()
    }
    
    func deleteCircle() {
        guard let url = URL(string: "\(baseURL)circles/delete_circle/") else { return }

        let payload: [String: Any] = [
            "circle_id": circle.id,
            "user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }
        task.resume()
    }

    func fetchThreads(for circleId: Int) {
        guard let url = URL(string: "http://localhost:8000/api/circles/get_threads/\(circleId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                print("📥 Raw JSON:")
                print(String(data: data, encoding: .utf8) ?? "nil")

                if let decoded = try? JSONDecoder().decode([ThreadPost].self, from: data) {
                    DispatchQueue.main.async {
                        self.threads = decoded
                    }
                } else {
                    print("❌ Failed to decode threads")
                }
            }
        }.resume()
    }
    func fetchAnnouncements(for circleId: Int) {
        // Use your deployed backend instead of localhost
        guard let url = URL(string: "\(baseURL)circles/get_announcements/\(circleId)/") else {
            print("❌ Invalid announcements URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Network error fetching announcements:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data returned for announcements")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([AnnouncementModel].self, from: data)
                DispatchQueue.main.async {
                    self.announcements = decoded
                }
                print("✅ Decoded \(decoded.count) announcements")
            } catch {
                print("❌ Failed to decode announcements:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response:\n\(raw)")
                }
            }
        }.resume()
    }

    func updateDashboardEnabled(to newValue: Bool) {
        guard let url = URL(string: "\(baseURL)circles/toggle_dashboard/") else { return }

        let payload: [String: Any] = [
            "circle_id": circle.id,
            "user_id": userId,
            "has_dashboard": newValue
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to toggle dashboard:", error.localizedDescription)
            } else if let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("✅ Dashboard toggle response:", json)

                DispatchQueue.main.async {
                    self.circle.hasDashboard = newValue
                    self.isDashboardEnabled = newValue

                    // ✅ Tell wrapper to refresh
                    UserDefaults.standard.set(true, forKey: "should_refresh_circles")
                }
            }
        }.resume()
    }

    func fetchLatestCircleDetails() {
        guard let url = URL(string: "\(baseURL)circles/get_circle_details/?circle_id=\(circle.id)&user_id=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching latest circle details")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CircleData.self, from: data)
                DispatchQueue.main.async {
                    self.circle = decoded
                    self.isDashboardEnabled = decoded.hasDashboard ?? false
                }
            } catch {
                print("❌ Failed to decode CircleData:", error)
            }
        }.resume()
    }

    struct CreateAnnouncementPopup: View {
        let circleId: Int
        let userId: Int
        var onPost: () -> Void

        @Environment(\.presentationMode) var presentationMode
        @State private var title = ""
        @State private var content = ""

        var body: some View {
            VStack(spacing: 16) {
                Text("New Announcement")
                    .font(.headline)

                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextEditor(text: $content)
                    .frame(height: 120)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

                Button("Post") {
                    postAnnouncement()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }

        func postAnnouncement() {
            guard let url = URL(string: "http://localhost:8000/api/circles/post_announcement/") else { return }

            let body: [String: Any] = [
                "circle_id": circleId,
                "user_id": userId,
                "title": title,
                "content": content
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { _, _, _ in
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                    onPost()
                }
            }.resume()
        }
    }


    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left side - Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Center - Logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side - Empty to keep logo centered
                Color.clear
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(Color(hex: "004aad"))
        .safeAreaInset(edge: .top) {
            Color(hex: "004aad")
                .frame(height: 0)
        }
    }
}


// MARK: - Thread Post Model
struct ThreadPost: Identifiable, Decodable {
    let id: Int
    let author: String
    let content: String
    let likes: Int
    let comments: Int
}

// MARK: - Enhanced Thread Card View
struct ThreadCard: View {
    let thread: ThreadPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with author and engagement stats
            HStack {
                HStack(spacing: 8) {
                    // Author avatar placeholder
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "0066dd")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(thread.author.prefix(1)).uppercased())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(thread.author)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("2 hours ago") // You can make this dynamic later
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }

            // Thread content
            Text(thread.content)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)

            // Engagement section
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: thread.likes > 0 ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(thread.likes > 0 ? .red : .secondary)
                    Text("\(thread.likes)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(thread.comments)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Share action
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Menu Item Component
struct MenuItem2: View {
    let icon: String
    let title: String

    var body: some View {
        Button(action: {
            // Action for each menu item
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "004aad"))
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct PageGroupchats_Previews: PreviewProvider {
    static var previews: some View {
        // Fixed: CircleData expects channels as [String], not [Channel]
        let sampleChannels = ["#Welcome", "#Founder-Chat", "#Introductions"]

        PageGroupchats(circle: CircleData(
            id: 1,
            name: "Lean Startup-lists",
            industry: "Tech",
            memberCount: 1200,
            imageName: "leanstartups",
            pricing: "Free",
            description: "A community of founders",
            joinType: .joinNow,
            channels: sampleChannels,
            creatorId: 999,
            isModerator: false,
            isPrivate: false,
            hasDashboard: false
        ))
    }
}



// Placeholder views for navigation destinations
struct PageMessages2: View {
    var body: some View {
        Text("Messages View")
    }
}

struct ProfilePage2: View {
    var body: some View {
        Text("Profile View")
    }
}

struct PageCircleMessages2: View {
    var body: some View {
        Text("Channel Messages View")
    }
}




struct PageGroupchatsWrapper: View {
    @State private var myCircles: [CircleData] = []
    @AppStorage("user_id") private var userId: Int = 0
    @State private var loading = true
    @AppStorage("last_circle_id") private var lastCircleId: Int = 0


    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else if myCircles.isEmpty {
                VStack(spacing: 0) {
                    CirclHeader()

                    Spacer()

                    VStack(spacing: 16) {
                        Text("You're not in any Circls yet!")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: PageCircles(showMyCircles: true).navigationBarBackButtonHidden(true)) {
                            Text("Explore Circls")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }

                    Spacer()
                }
            }
 else {
                if let savedCircle = myCircles.first(where: { $0.id == lastCircleId }) {
                    PageGroupchats(circle: savedCircle)
                } else {
                    if let savedCircle = myCircles.first(where: { $0.id == lastCircleId }) {
                        PageGroupchats(circle: savedCircle)
                    } else {
                        PageGroupchats(circle: myCircles[0])
                    }
// fallback
                }
 // default to first circle
            }
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "should_refresh_circles") {
                print("🔁 Refreshing circles from toggle")
                UserDefaults.standard.set(false, forKey: "should_refresh_circles")
                fetchMyCircles()
            } else {
                print("✅ Normal onAppear, no dashboard refresh needed")
            }
        }

        
    }

    func fetchMyCircles() {
        // Local API model for this function
        struct LocalAPICircle: Identifiable, Decodable {
            let id: Int
            let name: String
            let industry: String
            let pricing: String
            let description: String
            let join_type: String
            let channels: [String]?
            let creator_id: Int
            let is_moderator: Bool?
            let member_count: Int?
            let is_private: Bool?    //
            let has_dashboard: Bool? 
        }
        
        guard let url = URL(string: "http://localhost:8000/api/circles/my_circles/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([LocalAPICircle].self, from: data) {
                DispatchQueue.main.async {
                    self.myCircles = decoded.map { apiCircle in
                        print("✅ Refetched circles from server: \(decoded.map { "\($0.name): \($0.has_dashboard ?? false)" })")

                        return CircleData(
                            id: apiCircle.id,
                            name: apiCircle.name,
                            industry: apiCircle.industry,
                            memberCount: apiCircle.member_count ?? 0,
                            imageName: "uhmarketing",
                            pricing: apiCircle.pricing,
                            description: apiCircle.description,
                            joinType: apiCircle.join_type == "apply_now" ? JoinType.applyNow : JoinType.joinNow,
                            channels: apiCircle.channels ?? [],
                            creatorId: apiCircle.creator_id,
                            isModerator: apiCircle.is_moderator ?? false,
                            isPrivate: apiCircle.is_private ?? false,
                            hasDashboard: apiCircle.has_dashboard

                        )
                    }

                    self.loading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.loading = false
                }
            }
        }.resume()
    }
}



struct CirclHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Circl.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 40, height: 30)
                                .foregroundColor(.white)
                        }

                        NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(Color(hex: "004aad"))
        }
    }
}
