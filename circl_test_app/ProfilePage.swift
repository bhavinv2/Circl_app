import SwiftUI
import Foundation

struct ProfilePage: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showError: Bool = false
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var isMentor: Bool = UserDefaults.standard.bool(forKey: "isMentor")
    @State private var profileData: FullProfile?
    @State private var myNetwork: [InviteProfileData] = []
    
    // Add these for image upload
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false

    // Animation states
    @State private var cardOffset: CGFloat = 50
    @State private var cardOpacity: Double = 0

    @State private var isEditing = false
    @State private var updatedBio = ""
    @State private var updatedPersonalityType = ""
//    @State private var updatedEducationLevel = ""
    @State private var updatedInstitution = ""
//    @State private var updatedCertificates: String = ""
    @State private var updatedExperience = ""
    @State private var updatedLocations = ""
    @State private var updatedSkills = ""
    @State private var updatedClubs = ""
    @State private var updatedHobbies = ""
    @State private var updatedBirthday = ""  // Add this to your @State variables
    @State private var updatedEntrepreneurialHistory: String = ""




    // Animated background for header (DEPRECATED - now using solid color)
    /*
    private var animatedBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.customHex("001a3d"),
                    Color.customHex("004aad"),
                    Color.customHex("0066ff"),
                    Color.customHex("003d7a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Flowing wave-like gradient overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.customHex("0066ff").opacity(0.3),
                    Color.customHex("004aad").opacity(0.2),
                    Color.clear,
                    Color.customHex("002d5a").opacity(0.25),
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: isAnimating ? -0.3 : 1.3,
                    y: 0.0
                ),
                endPoint: UnitPoint(
                    x: isAnimating ? 1.0 : 0.0,
                    y: 1.0
                )
            )
            
            // Subtle radial gradient for depth
            RadialGradient(
                colors: [
                    Color.customHex("0066ff").opacity(isAnimating ? 0.15 : 0.05),
                    Color.clear
                ],
                center: UnitPoint(
                    x: isAnimating ? 0.8 : 0.2,
                    y: isAnimating ? 0.3 : 0.7
                ),
                startRadius: 50,
                endRadius: 300
            )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    */

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // HEADER SECTION
                VStack(spacing: 0) {
                    ZStack {
                        // Center - Circl Logo (positioned in center of entire header)
                        NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                            Text("Circl.")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Left and Right content overlaid on top
                        HStack {
                            // Left side - Back button
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Right side - Edit + Settings aligned horizontally
                            HStack(spacing: 20) {
                                Button(action: {
                                    if isEditing {
                                        saveAllProfileUpdates()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            fetchProfile()
                                        }
                                    }
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isEditing.toggle()
                                    }
                                }) {
                                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .scaleEffect(isEditing ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isEditing)
                                }

                                NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                }
                .padding(.top, 50)
                .background(Color(hex: "004aad"))
                .clipped()

                // MAIN CONTENT
                ScrollView {
                    VStack(spacing: 0) {
                        // Add top spacing after header
                        Spacer().frame(height: 30)
                        
                        // Profile Header Card
                        ProfileHeaderCard(
                            profileData: profileData,
                            myNetwork: myNetwork,
                            selectedImage: $selectedImage,
                            isImagePickerPresented: $isImagePickerPresented,
                            uploadProfileImage: uploadProfileImage
                        )
                        .offset(y: cardOffset)
                        .opacity(cardOpacity)
                        .animation(.easeOut(duration: 0.8).delay(0.1), value: cardOpacity)

                        // Add spacing between profile card and content cards
                        Spacer().frame(height: 40)

                        VStack(spacing: 24) {
                            // Bio Section
                            ModernCard(title: "Bio") {
                                if isEditing {
                                    ZStack(alignment: .topLeading) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.customHex("004aad").opacity(0.3), lineWidth: 1)
                                            )
                                            .frame(height: 120)
                                        
                                        TextEditor(text: $updatedBio)
                                            .padding(12)
                                            .background(Color.clear)
                                            .font(.body)
                                    }
                                } else {
                                    Text(updatedBio.isEmpty ? "Tell others about yourself..." : updatedBio)
                                        .font(.body)
                                        .foregroundColor(updatedBio.isEmpty ? .secondary : .primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(nil)
                                }
                            }
                            .offset(y: cardOffset)
                            .opacity(cardOpacity)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: cardOpacity)

                            // About Section
                            ModernCard(title: "About \(profileData?.first_name ?? "")") {
                                VStack(spacing: 20) {
                                    ProfileField(label: "Age", value: calculateAge(from: updatedBirthday), editValue: $updatedBirthday, isEditing: isEditing, placeholder: "YYYY-MM-DD")
                                    ProfileField(label: "Institution", value: updatedInstitution, editValue: $updatedInstitution, isEditing: isEditing, placeholder: "Institution")
                                    ProfileField(label: "Location(s)", value: updatedLocations, editValue: $updatedLocations, isEditing: isEditing, placeholder: "Location(s)")
                                    if !updatedPersonalityType.isEmpty || isEditing {
                                        ProfileField(label: "Personality Type", value: updatedPersonalityType, editValue: $updatedPersonalityType, isEditing: isEditing, placeholder: "Personality Type")
                                    }
                                }
                            }
                            .offset(y: cardOffset)
                            .opacity(cardOpacity)
                            .animation(.easeOut(duration: 0.8).delay(0.3), value: cardOpacity)

                            // Technical Side Section
                            ModernCard(title: "Technical Side") {
                                VStack(spacing: 20) {
                                    ProfileField(label: "Skills", value: updatedSkills, editValue: $updatedSkills, isEditing: isEditing, placeholder: "Skills (comma-separated)")
                                    ProfileField(label: "Experience", value: "\(updatedExperience) years", editValue: $updatedExperience, isEditing: isEditing, placeholder: "Experience (years)", keyboardType: .numberPad)
                                }
                            }
                            .offset(y: cardOffset)
                            .opacity(cardOpacity)
                            .animation(.easeOut(duration: 0.8).delay(0.4), value: cardOpacity)

                            // Interests Section
                            ModernCard(title: "Interests") {
                                VStack(spacing: 20) {
                                    ProfileField(label: "Clubs", value: updatedClubs, editValue: $updatedClubs, isEditing: isEditing, placeholder: "Clubs (comma-separated)")
                                    ProfileField(label: "Hobbies", value: updatedHobbies, editValue: $updatedHobbies, isEditing: isEditing, placeholder: "Hobbies (comma-separated)")
                                }
                            }
                            .offset(y: cardOffset)
                            .opacity(cardOpacity)
                            .animation(.easeOut(duration: 0.8).delay(0.5), value: cardOpacity)

                            // Entrepreneurial History Section
                            ModernCard(title: "Entrepreneurial History") {
                                if isEditing {
                                    ZStack(alignment: .topLeading) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.customHex("004aad").opacity(0.3), lineWidth: 1)
                                            )
                                            .frame(height: 120)
                                        
                                        TextEditor(text: $updatedEntrepreneurialHistory)
                                            .padding(12)
                                            .background(Color.clear)
                                            .font(.body)
                                    }
                                } else {
                                    Text(updatedEntrepreneurialHistory.isEmpty ? "Share your entrepreneurial journey..." : updatedEntrepreneurialHistory)
                                        .font(.body)
                                        .foregroundColor(updatedEntrepreneurialHistory.isEmpty ? .secondary : .primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(nil)
                                }
                            }
                            .offset(y: cardOffset)
                            .opacity(cardOpacity)
                            .animation(.easeOut(duration: 0.8).delay(0.6), value: cardOpacity)
                        }
                        .padding(.horizontal, 20)
                        
                        // Bottom spacing for navigation
                        Spacer().frame(height: 100)
                    }
                }
                .background(
                    LinearGradient(
                        colors: [Color(.systemGray6).opacity(0.3), Color(.systemGray5).opacity(0.5)], 
                        startPoint: .top, 
                        endPoint: .bottom
                    )
                )
                .dismissKeyboardOnScroll()
            }
            .ignoresSafeArea(edges: .top)
            
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
                    
                    // Circles
                    NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                        VStack(spacing: 4) {
                            Image(systemName: "circle.grid.2x2")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("Circles")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
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
                    
                    // Profile (Current page - highlighted)
                    VStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                        Text("Profile")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 8)
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
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            // Start animations
            withAnimation(.easeOut(duration: 0.8)) {
                cardOffset = 0
                cardOpacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                fetchProfile()
                fetchNetwork()
            }
        }
    }

// MARK: - Modern UI Components

struct ProfileHeaderCard: View {
    let profileData: FullProfile?
    let myNetwork: [InviteProfileData]
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool
    let uploadProfileImage: (UIImage) -> Void
    @State private var profileImageScale: CGFloat = 1.0
    
    var body: some View {
        // Main profile section with solid blue background - single container
        ZStack {
            // Background with solid blue color
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "004aad"))
            
            VStack(spacing: 20) {
                Spacer().frame(height: 25)
                
                // Profile Picture with enhanced styling
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        profileImageScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            profileImageScale = 1.0
                        }
                    }
                    isImagePickerPresented = true
                    }) {
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 140, height: 140)
                                .blur(radius: 4)
                            
                            // White border ring
                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                                .frame(width: 130, height: 130)
                            
                            // Profile image
                            Group {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                } else if let profileURL = URL(string: profileData?.profile_image ?? ""), !profileURL.absoluteString.isEmpty {
                                    AsyncImage(url: profileURL) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.9))
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .foregroundColor(Color.customHex("004aad").opacity(0.7))
                                                .frame(width: 80, height: 80)
                                        }
                                    }
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.9))
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(Color.customHex("004aad").opacity(0.7))
                                            .frame(width: 80, height: 80)
                                    }
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            
                            // Camera overlay for editing hint
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color.customHex("004aad"))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                            }
                            .frame(width: 120, height: 120)
                        }
                        .scaleEffect(profileImageScale)
                    }
                    .sheet(isPresented: $isImagePickerPresented, onDismiss: {
                        if let selectedImage = selectedImage {
                            uploadProfileImage(selectedImage)
                        }
                    }) {
                        ImagePicker(image: $selectedImage)
                    }
                    
                    // Name and Username with improved typography
                    VStack(spacing: 8) {
                        Text(profileData?.full_name ?? "Loading...")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        if let lastName = profileData?.last_name,
                           let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
                            Text("@\(lastName)\(userId)")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer().frame(height: 15)
                    
                    // Enhanced Stats Cards with Premium Design (from DynamicProfilePreview)
                    HStack(spacing: 16) {
                        // Connections Card - Premium Design
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.customHex("1e40af").opacity(0.9),
                                                Color.customHex("3b82f6").opacity(0.8),
                                                Color.customHex("60a5fa").opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .frame(width: 70, height: 70)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(myNetwork.count)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("Connections")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Circles Card - Premium Design
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.customHex("7c3aed").opacity(0.9),
                                                Color.customHex("a855f7").opacity(0.8),
                                                Color.customHex("c084fc").opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .frame(width: 70, height: 70)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "circle.grid.2x2.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("0")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("Circles")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Circs Card - Premium Design
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.customHex("059669").opacity(0.9),
                                                Color.customHex("10b981").opacity(0.8),
                                                Color.customHex("34d399").opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .frame(width: 70, height: 70)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(profileData?.circs ?? 0)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("Circs")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer().frame(height: 25)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var isIntegrated: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isIntegrated ? .white : Color.customHex("004aad"))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isIntegrated ? .white : .primary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isIntegrated ? .white.opacity(0.8) : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

struct ModernCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            
            content
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

struct ProfileField: View {
    let label: String
    let value: String
    @Binding var editValue: String
    let isEditing: Bool
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                if !isEditing && !value.isEmpty && value != "Not set" {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                }
            }
            
            if isEditing {
                TextField(placeholder, text: $editValue)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.customHex("004aad").opacity(0.3), lineWidth: 1)
                            )
                    )
                    .keyboardType(keyboardType)
                    .font(.body)
            } else {
                HStack {
                    Text(value.isEmpty ? "Not set" : value)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

    
    // Image the upload function
    func uploadProfileImage(image: UIImage) {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        let urlString = "https://circlapp.online/api/users/upload_profile_image/"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add authorization token if available
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Append user_id
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(userId)\r\n".data(using: .utf8)!)

        // Append image
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)
        }

        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Upload error:", error.localizedDescription)
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("✅ Upload response:", responseString)
                fetchProfile() // refresh profile after upload
            }
        }.resume()
    }
    
    func fetchNetwork() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id found")
            return
        }

        let urlString = "https://circlapp.online/api/users/get_network/\(userId)/"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            if let data = data {
                if let network = try? JSONDecoder().decode([InviteProfileData].self, from: data) {
                    DispatchQueue.main.async {
                        self.myNetwork = network
                    }
                } else {
                    print("❌ Decoding network failed")
                }
            }
        }.resume()
    }

    func fetchProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("❌ No user_id in UserDefaults")
            return
        }

        let urlString = "https://circlapp.online/api/users/profile/\(userId)/"
        print("🌐 Fetching profile from:", urlString)

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed:", error)
                return
            }

            if let data = data {
                print("📦 Received data:", String(data: data, encoding: .utf8) ?? "No string")

                if let decoded = try? JSONDecoder().decode(FullProfile.self, from: data) {
                    DispatchQueue.main.async {
                        print("✅ Decoded:", decoded.full_name)
                        self.profileData = decoded
                        self.updatedBio = decoded.bio ?? ""
                        self.updatedPersonalityType = decoded.personality_type ?? ""
//                        self.updatedEducationLevel = decoded.education_level ?? ""
                        self.updatedInstitution = decoded.institution_attended ?? ""
//                        self.updatedCertificates = (decoded.certificates ?? []).joined(separator: ", ")
                        self.updatedExperience = decoded.years_of_experience.map { String($0) } ?? ""
                        self.updatedLocations = (decoded.locations ?? []).joined(separator: ", ")
                      
                        self.updatedSkills = (decoded.skillsets ?? []).joined(separator: ", ")
                       
                        self.updatedClubs = (decoded.clubs ?? []).joined(separator: ", ")
                        self.updatedHobbies = (decoded.hobbies ?? []).joined(separator: ", ")
                        self.updatedBirthday = decoded.birthday ?? ""
                        self.updatedEntrepreneurialHistory = decoded.entrepreneurial_history ?? ""



                    }
                } else {
                    print("❌ Failed to decode JSON")
                }
            }
        }.resume()
    }
    
    func saveAllProfileUpdates() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        
        func post(_ urlString: String, _ body: [String: Any]) {
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = UserDefaults.standard.string(forKey: "auth_token") {
                request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            URLSession.shared.dataTask(with: request).resume()
        }
        
        post("https://circlapp.online/api/users/update-user-bio/", [
            "user_id": userId,
            "bio": updatedBio
        ])
        
        post("https://circlapp.online/api/users/update-personal-details/", [
            "user_id": userId,
            "personality_type": updatedPersonalityType,
//            "education_level": updatedEducationLevel,
            "institution_attended": updatedInstitution,
//            "certificates": updatedCertificates.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "years_of_experience": Int(updatedExperience) ?? 0,
            "birthday": updatedBirthday
        ])
        
        post("https://circlapp.online/api/users/update-skills-interests/", [
            "user_id": userId,
            "locations": updatedLocations.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            
            "skillsets": updatedSkills.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            
            "clubs": updatedClubs.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "hobbies": updatedHobbies.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        ])
        
        post("https://circlapp.online/api/users/update-entrepreneurial-history/", [
            "user_id": userId,
            "entrepreneurial_history": updatedEntrepreneurialHistory
        ])
    }


}

func calculateAge(from birthday: String) -> String {
    guard !birthday.isEmpty else { return "N/A" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let birthDate = formatter.date(from: birthday) else { return "N/A" }

    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
    return "\(ageComponents.year ?? 0)"
}



struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
}
