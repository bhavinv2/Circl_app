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
    
    @State private var isEditing = false
    @State private var updatedBio = ""
    @State private var updatedPersonalityType = ""
    @State private var updatedEducationLevel = ""
    @State private var updatedInstitution = ""
    @State private var updatedCertificates: String = ""
    @State private var updatedExperience = ""
    @State private var updatedLocations = ""
    @State private var updatedAchievements = ""
    @State private var updatedSkills = ""
    @State private var updatedAvailability = ""
    @State private var updatedClubs = ""
    @State private var updatedHobbies = ""
    @State private var updatedBirthday = ""  // Add this to your @State variables
    @State private var updatedEntrepreneurialHistory: String = ""




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
                            Button(action: {
                                if isEditing {
                                    saveAllProfileUpdates()

                                    // ✅ Delay profile refresh slightly after save
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        fetchProfile()
                                    }
                                }

                                isEditing.toggle()
                            }) {
                                Text(isEditing ? "Save" : "Edit")
                                    .foregroundColor(Color.customHex("004aad"))
                                    .fontWeight(.bold)
                            }

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
                                        Text("\(profileData?.circs ?? 0)")
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
                        
//                        // Personal Secret Section
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.customHex("004aad"))
//                                .frame(height: 200)
//                            
//                            VStack(spacing: 10) {
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text("Secret Idea")
//                                        .font(.system(size: 22, weight: .bold))
//                                        .foregroundColor(.white)
//                                    
//                                    Text("Creating an app for entrepreneurs")
//                                        .font(.system(size: 16))
//                                        .foregroundColor(.white)
//                                        .multilineTextAlignment(.leading)
//                                }
//                                .padding(.bottom, 10)
//                                
//                                Divider()
//                                    .background(Color.white)
//                                
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text("Your Next Steps")
//                                        .font(.system(size: 22, weight: .bold))
//                                        .foregroundColor(.white)
//                                    
//                                    Text("Entrepreneur AI coming soon")
//                                        .font(.system(size: 16))
//                                        .foregroundColor(.white)
//                                        .multilineTextAlignment(.leading)
//                                }
//                            }
//                            .padding()
//                        }
                        
          
                        // Bio Section
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Bio")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                VStack(alignment: .leading, spacing: 8) {
                                  

                                    if isEditing {
                                        TextEditor(text: $updatedBio)
                                            .frame(height: 100)
                                            .foregroundColor(.black)
                                            .padding(5)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                        
                                    } else {
                                        Text(updatedBio.isEmpty ? "Bio not set." : updatedBio)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }

                                
                            }
                            .padding()
                        }





                        // About Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("About \(profileData?.first_name ?? "") \(profileData?.last_name ?? "")")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Age")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("YYYY-MM-DD", text: $updatedBirthday)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(calculateAge(from: updatedBirthday))
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Education Level")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Education Level", text: $updatedEducationLevel)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedEducationLevel)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Institution")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Institution", text: $updatedInstitution)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedInstitution)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location(s)")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Location(s)", text: $updatedLocations)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedLocations)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Achievements")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Achievements (comma-separated)", text: $updatedAchievements)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedAchievements)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Personality Type")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                           

                                    if isEditing {
                                        TextField("Personality Type", text: $updatedPersonalityType)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else if !updatedPersonalityType.isEmpty {
                                        Text(updatedPersonalityType)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                           
                                    }
                                }
                            }
                            .padding()
                        }

                        




                        // Technical Side Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Technical Side")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Skills")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Skills (comma-separated)", text: $updatedSkills)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedSkills)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Certificates")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Certificates (comma-separated)", text: $updatedCertificates)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedCertificates)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Experience")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Experience (years)", text: $updatedExperience)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.numberPad)
                                    } else {
                                        Text("\(updatedExperience) years")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Availability")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Availability", text: $updatedAvailability)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedAvailability)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                            }
                            .padding()
                        }


                        // Interests Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Interests")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Clubs")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Clubs (comma-separated)", text: $updatedClubs)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedClubs)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hobbies")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    if isEditing {
                                        TextField("Hobbies (comma-separated)", text: $updatedHobbies)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(updatedHobbies)
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                            }
                            .padding()
                        }

                        
                        // Entrepreneurial History Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))

                            VStack(alignment: .leading, spacing: 15) {
                                Text("Entrepreneurial History")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                VStack(alignment: .leading, spacing: 8) {

                                    if isEditing {
                                        TextEditor(text: $updatedEntrepreneurialHistory)
                                            .frame(height: 100)
                                            .foregroundColor(.black)
                                            .padding(5)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                    } else {
                                        Text(updatedEntrepreneurialHistory.isEmpty ? "Enter work experience..." : updatedEntrepreneurialHistory)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
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
                        self.updatedEducationLevel = decoded.education_level ?? ""
                        self.updatedInstitution = decoded.institution_attended ?? ""
                        self.updatedCertificates = (decoded.certificates ?? []).joined(separator: ", ")
                        self.updatedExperience = decoded.years_of_experience.map { String($0) } ?? ""
                        self.updatedLocations = (decoded.locations ?? []).joined(separator: ", ")
                        self.updatedAchievements = (decoded.achievements ?? []).joined(separator: ", ")
                        self.updatedSkills = (decoded.skillsets ?? []).joined(separator: ", ")
                        self.updatedAvailability = decoded.availability ?? ""
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
            "education_level": updatedEducationLevel,
            "institution_attended": updatedInstitution,
            "certificates": updatedCertificates.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "years_of_experience": Int(updatedExperience) ?? 0,
            "birthday": updatedBirthday
        ])
        
        post("https://circlapp.online/api/users/update-skills-interests/", [
            "user_id": userId,
            "locations": updatedLocations.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "achievements": updatedAchievements.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "skillsets": updatedSkills.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "availability": updatedAvailability,
            "clubs": updatedClubs.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "hobbies": updatedHobbies.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        ])
        
        post("https://circlapp.online/api/users/update-entrepreneurial-history/", [
            "user_id": userId,
            "entrepreneurial_history": updatedEntrepreneurialHistory
        ])
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
