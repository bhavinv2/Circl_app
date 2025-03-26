import SwiftUI
import Foundation

struct ProfilePage: View {
    @State private var showError: Bool = false
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var isMentor: Bool = UserDefaults.standard.bool(forKey: "isMentor")
    @State private var profileData: FullProfile?
    @State private var myNetwork: [InviteProfileData] = []
    
    // Add these for image upload
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header Section
                VStack {
                    HStack {
                        Text("Circl")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.customHex("004aad"))
                            .padding(.top, 25)
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.customHex("004aad"))
                            }
                        }
                        .padding(.top, 25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                .frame(height: 105)
                .background(Color.white)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 300)
                            
                            VStack(spacing: 15) {
                                // Profile picture with upload capability
                                Button(action: {
                                    isImagePickerPresented = true
                                }) {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else if let profileURL = URL(string: profileData?.profile_image ?? ""), !profileURL.absoluteString.isEmpty {
                                        AsyncImage(url: profileURL) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "person.crop.circle")
                                                .resizable()
                                                .foregroundColor(.gray.opacity(0.3))
                                        }
                                    } else {
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .sheet(isPresented: $isImagePickerPresented, onDismiss: {
                                    if let selectedImage = selectedImage {
                                        uploadProfileImage(image: selectedImage)
                                    }
                                }) {
                                    ImagePicker(image: $selectedImage)
                                }
                                
                                
                                HStack(spacing: 40) {
                                    VStack {
                                        Text("Connections:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("\(myNetwork.count)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                    
                                    VStack {
                                        Text("Circles:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("0")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                    
                                    VStack {
                                        Text("Circs:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("0")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                }
                                
                                VStack(spacing: 5) {
                                    Text(profileData?.full_name ?? "Loading...")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)

                                    if let lastName = profileData?.last_name,
                                       let userId = UserDefaults.standard.value(forKey: "user_id") as? Int {
                                        Text("@\(lastName)\(userId)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }

//                                    Text("CEO - ")
//                                        .font(.system(size: 18, weight: .semibold))
//                                        .foregroundColor(.white)
//                                    + Text("Circl International")
//                                        .font(.system(size: 18, weight: .semibold))
//                                        .underline()
//                                        .foregroundColor(.white)

                                }

                            }
                        }
                        
                        // Personal Secret Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 200)
                            
                            VStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Secret Idea")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Creating an app for entrepreneurs")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.bottom, 10)
                                
                                Divider()
                                    .background(Color.white)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your Next Steps")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Entrepreneur AI coming soon")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .padding()
                        }
                        
                        // Bio Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 150)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Bio")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let usage = profileData?.main_usage,
                                   let industry = profileData?.industry_interest {
                                    Text("I want to \(usage) in the \(industry) industry.")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal)
                                } else {
                                    Text("Bio not set.")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal)
                                }


                                if let type = profileData?.personality_type, !type.isEmpty {
                                    Text("Personality Type: \(type)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                }

                            }
                            .padding()
                        }
                        
                        // About Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 400)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("About \(profileData?.first_name ?? "") \(profileData?.last_name ?? "")")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Age: \(calculateAge(from: profileData?.birthday ?? ""))")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Education Level: \(profileData?.education_level ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Institution: \(profileData?.institution_attended ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                        
                            
                                
                                Text("Location: \(profileData?.locations?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Achievements: \(profileData?.achievements?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Technical Side Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 400)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Technical Side")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Skills: \(profileData?.skillsets?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Certificates: \(profileData?.certificates?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Experience: \(profileData?.years_of_experience.map { "\($0) years" } ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
//                                Text("Projects/Work Completed: xxx")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundColor(.white)
                                
                                Text("Availability: \(profileData?.availability ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Interests Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 300)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Interests")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Clubs: \(profileData?.clubs?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Hobbies: \(profileData?.hobbies?.joined(separator: ", ") ?? "N/A")")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Entrepreneurial History Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 150)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Entrepreneurial History")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
//                                Text("nba player")
//                                    .font(.system(size: 16))
//                                    .foregroundColor(.white)
//                                    .multilineTextAlignment(.leading)
//                                    .padding(.horizontal)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray4))
                
                // Footer Navigation
                HStack(spacing: 15) {
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
                    }

                    NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "briefcase.fill")
                    }

                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "captions.bubble.fill")
                    }

                    NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "building.columns.fill")
                    }

                    NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "newspaper")
                    }
                }
                .padding(.vertical, 10)
                .background(Color.white)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                fetchProfile()
                fetchNetwork()
            }
        }
    }
    
    // Image upload function
    func uploadProfileImage(image: UIImage) {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else { return }
        let urlString = "http://34.136.164.254:8000/api/users/upload_profile_image/"

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

        let urlString = "http://34.136.164.254:8000/api/users/get_network/\(userId)/"
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

        let urlString = "http://34.136.164.254:8000/api/users/profile/\(userId)/"
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
                    }
                } else {
                    print("❌ Failed to decode JSON")
                }
            }
        }.resume()
    }
}

extension Color {
    static func customHex(_ hex: String) -> Color {
        let hexValue = Int(hex.dropFirst(), radix: 16) ?? 0
        let red = Double((hexValue >> 16) & 0xFF) / 255.0
        let green = Double((hexValue >> 8) & 0xFF) / 255.0
        let blue = Double(hexValue & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
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

struct InviteProfileData: Identifiable, Codable {
    let id = UUID()
    let user_id: Int
    let name: String
    let username: String
    let email: String
    let title: String
    let company: String
    let proficiency: String
    let tags: [String]
    let profileImage: String?
}

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
}
