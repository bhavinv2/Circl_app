import SwiftUI
import UIKit

struct ForumPost: View {
    let content: String
    let author: String
    let timestamp: String
    let category: String
    let profileImageName: String
    let position: String
    let company: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(profileImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                
                VStack(alignment: .leading) {
                    Text(author)
                        .font(.headline)
                    
                    HStack {
                        Text(position)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("-")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        NavigationLink(destination: Text("Company Page")) {
                            Text(company)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.fromHex("004aad"))
                        }
                    }
                    
                    Text(timestamp)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(category)
                    .font(.caption)
                    .padding(8)
                    .background(Color.fromHex("ffde59"))
                    .foregroundColor(.black)
                    .cornerRadius(5)
            }

            Text(content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.black)
            
            HStack {
                Button(action: { /* Like Action */ }) {
                    Label("Like", systemImage: "hand.thumbsup")
                        .font(.subheadline)
                }
                Spacer()
                Button(action: { /* Comment Action */ }) {
                    Label("Comment", systemImage: "message")
                        .font(.subheadline)
                }
                Spacer()
                Button(action: { /* Share Action */ }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct PageForum: View {
    @State private var selectedCategory = "Category"
    @State private var selectedPrivacy = "Privacy"
    @State private var postContent = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showMenu = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Circl.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                // Action for Filter
                            }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.white)
                                    Text("Filter")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            VStack {
                                HStack(spacing: 10) {
                                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)
                                            .foregroundColor(.white)
                                    }

                                    NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.white)
                                    }
                                }

                                Text("Hello, Fragne")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad"))
                }
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Write a Post Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Write a Post")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("Ask a question, or share some knowledge", text: $postContent)
                                    .padding()
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                
                                Image(systemName: "rectangle.portrait.and.arrow.forward")
                                    .foregroundColor(Color.fromHex("004aad"))
                            }
                            
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .padding(.top, 10)
                            }
                            
                            HStack(spacing: 10) {
                                // Category Dropdown
                                Menu {
                                    Button("Advice & Tips", action: { selectedCategory = "Advice & Tips" })
                                    Button("Personal Development", action: { selectedCategory = "Personal Development" })
                                    Button("Experience", action: { selectedCategory = "Experience" })
                                    Button("Product Launch", action: { selectedCategory = "Product Launch" })
                                    Button("Funding", action: { selectedCategory = "Funding" })
                                    Button("Investment", action: { selectedCategory = "Investment" })
                                    Button("Networking", action: { selectedCategory = "Networking" })
                                    Button("Collaboration", action: { selectedCategory = "Collaboration" })
                                    Button("News & Trends", action: { selectedCategory = "News & Trends" })
                                    Button("Challenges", action: { selectedCategory = "Challenges" })
                                    Button("Marketing", action: { selectedCategory = "Marketing" })
                                    Button("Growth", action: { selectedCategory = "Growth" })
                                    Button("Sales", action: { selectedCategory = "Sales" })
                                    Button("Technology", action: { selectedCategory = "Technology" })
                                    Button("Legal & Compliance", action: { selectedCategory = "Legal & Compliance" })
                                    Button("Productivity", action: { selectedCategory = "Productivity" })
                                } label: {
                                    HStack {
                                        Text(selectedCategory)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                    .frame(width: 120)
                                }
                                
                                // Add Pictures Dropdown
                                Menu {
                                    Button("Upload from Camera") {
                                        sourceType = .camera
                                        isImagePickerPresented = true
                                    }
                                    Button("Upload from Gallery") {
                                        sourceType = .photoLibrary
                                        isImagePickerPresented = true
                                    }
                                } label: {
                                    HStack {
                                        Text("Pictures")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "plus")
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                    .frame(width: 120)
                                }
                                
                                // Privacy Dropdown
                                Menu {
                                    Button("Public", action: { selectedPrivacy = "Public" })
                                    Button("My Network", action: { selectedPrivacy = "My Network" })
                                } label: {
                                    HStack {
                                        Text(selectedPrivacy)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                                    .frame(width: 120)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                        // Forum Posts List
                        VStack(spacing: 10) {
                            ForEach(0..<10, id: \.self) { index in
                                ForumPost(
                                    content: "This is an example post content.",
                                    author: "John Doe",
                                    timestamp: "2 hours ago",
                                    category: "Advice & Tips",
                                    profileImageName: "profile_image",
                                    position: "Software Engineer",
                                    company: "Apple"
                                )
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray6))
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
            .overlay(
                // Hammer Menu Overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            if showMenu {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Welcome to your resources")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray5))
                                    
                                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "person.2.fill", title: "Connect and Network")
                                    }
                                    
                                    NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "person.crop.square.fill", title: "Your Business Profile")
                                    }
                                    
                                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "text.bubble.fill", title: "The Forum Feed")
                                    }
                                    
                                    NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "briefcase.fill", title: "Professional Services")
                                    }
                                    
                                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "envelope.fill", title: "Messages")
                                    }
                                    
                                    NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "newspaper.fill", title: "News & Knowledge")
                                    }
                                    
                                    NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "dollarsign.circle.fill", title: "The Circl Exchange")
                                    }
                                    
                                    Divider()
                                    
                                    NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                                        MenuItem(icon: "circle.grid.2x2.fill", title: "Circles")
                                    }
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .frame(width: 250)
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    showMenu.toggle()
                                }
                            }) {
                                Image(systemName: "hammer.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .background(Color.fromHex("004aad"))
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .offset(x: -22)
                        }
                        .padding()
                    }
                }
            )
        }
    }
}

struct MenuItem15: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.fromHex("004aad"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

extension Color {
    static func fromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    var body: some View {
        ImagePickerController(selectedImage: $selectedImage, sourceType: sourceType)
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerController
        
        init(parent: ImagePickerController) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct PageForum_Previews: PreviewProvider {
    static var previews: some View {
        PageForum()
    }
}
