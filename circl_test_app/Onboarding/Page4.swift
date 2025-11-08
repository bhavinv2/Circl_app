import SwiftUI

struct Page4: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var navigateToPage5 = false
    @State private var isUploading = false
    @State private var uploadSuccess = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "004aad")
                    .edgesIgnoringSafeArea(.all)
                
                // Cloud background matching other pages
                ZStack {
                    // Top Right Cloud Group
                    Group {
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: UIScreen.main.bounds.width / 2 - 80, y: -UIScreen.main.bounds.height / 2 + 0)
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: UIScreen.main.bounds.width / 2 - 130, y: -UIScreen.main.bounds.height / 2 + 0)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 30, y: -UIScreen.main.bounds.height / 2 + 40)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 110, y: -UIScreen.main.bounds.height / 2 + 50)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 + 170, y: -UIScreen.main.bounds.height / 2 + 30)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 + 210, y: -UIScreen.main.bounds.height / 2 + 60)
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: UIScreen.main.bounds.width / 2 + 90, y: -UIScreen.main.bounds.height / 2 + 50)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: UIScreen.main.bounds.width / 2 + 50, y: -UIScreen.main.bounds.height / 2 + 30)
                        Circle().fill(Color.white).frame(width: 110, height: 110)
                            .offset(x: UIScreen.main.bounds.width / 2 + 150, y: -UIScreen.main.bounds.height / 2 + 80)
                    }
                    
                    // Bottom Right Cloud Group
                    Group {
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 60)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 40)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 90, y: UIScreen.main.bounds.height / 2 - 50)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height / 2 - 30)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 110)
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: UIScreen.main.bounds.width / 2 - 135, y: UIScreen.main.bounds.height / 2 - 30)
                    }
                    
                    // Middle Left Cloud Group
                    Group {
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 60, y: 2 + 50)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 40, y: -20)
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 10, y: 40)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 90, y: -30)
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 125, y: 20)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 50)
                        
                        // Title Section
                        VStack(spacing: 8) {
                            Text("Add Profile Picture")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "ffde59"))
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                        }
                        
                        // Subtitle
                        Text("Make your profile stand out! Add a photo so others can get to know you better.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Profile Picture Section
                        VStack(spacing: 20) {
                            // Profile Picture Display
                            Button(action: {
                                isImagePickerPresented = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(.systemGray5))
                                        .frame(width: 150, height: 150)
                                    
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(hex: "004aad"))
                                            
                                            Text("Tap to add photo")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color(hex: "004aad"))
                                        }
                                    }
                                }
                            }
                            
                            // Upload Status (only show during upload process)
                            if isUploading {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Uploading...")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            } else if selectedImage != nil {
                                Text("Photo ready to upload!")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer(minLength: 50)
                        
                        // Skip and Next Buttons
                        VStack(spacing: 15) {
                            // Skip Button
                            Button(action: {
                                navigateToPage5 = true
                            }) {
                                Text("Skip for now")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            
                            // Next Button - uploads photo if selected, then navigates
                            Button(action: {
                                if let _ = selectedImage, !isUploading {
                                    // Upload image first, then navigate on success
                                    uploadProfileImageAndNavigate()
                                } else {
                                    // No image selected or already uploading, just navigate
                                    navigateToPage5 = true
                                }
                            }) {
                                Text(isUploading ? "Uploading..." : "Next")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(maxWidth: 300)
                                    .padding(.vertical, 15)
                                    .background(isUploading ? Color.gray : Color(hex: "ffde59"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .padding(.horizontal, 50)
                            }
                            .disabled(isUploading)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
                .dismissKeyboardOnScroll()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            .background(
                NavigationLink(
                    destination: Page5(),
                    isActive: $navigateToPage5,
                    label: { EmptyView() }
                )
            )
            .alert("Profile Picture", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func uploadProfileImageAndNavigate() {
        guard let image = selectedImage else {
            navigateToPage5 = true
            return
        }
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            alertMessage = "User not found. Please complete registration first."
            showAlert = true
            return
        }
        
        isUploading = true
        
        let urlString = "\(baseURL)users/upload_profile_image/"
        guard let url = URL(string: urlString) else {
            alertMessage = "Invalid upload URL"
            showAlert = true
            isUploading = false
            return
        }
        
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
        
        URLSession.shared.dataTask(with: request) { responseData, response, error in
            DispatchQueue.main.async {
                isUploading = false
                
                if let error = error {
                    print("❌ Upload error:", error.localizedDescription)
                    alertMessage = "Upload failed. Please try again."
                    showAlert = true
                    return
                }
                
                if let responseData = responseData, let responseString = String(data: responseData, encoding: .utf8) {
                    print("📩 Upload response:", responseString)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Upload response status:", httpResponse.statusCode)
                    
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        uploadSuccess = true
                        print("✅ Profile picture uploaded successfully")
                        // Navigate to next page after successful upload
                        navigateToPage5 = true
                    } else {
                        print("❌ Upload failed with status:", httpResponse.statusCode)
                        if let responseData = responseData, let responseString = String(data: responseData, encoding: .utf8) {
                            print("❌ Error response:", responseString)
                        }
                        alertMessage = "Upload failed. Please try again."
                        showAlert = true
                    }
                } else {
                    // If no HTTP response, assume success if we got data and no error
                    if responseData != nil {
                        uploadSuccess = true
                        print("✅ Profile picture uploaded successfully")
                        // Navigate to next page after successful upload
                        navigateToPage5 = true
                    } else {
                        alertMessage = "Upload failed. Please try again."
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
    
}

struct Page4_Previews: PreviewProvider {
    static var previews: some View {
        Page4()
    }
}
