import SwiftUI

struct ProfilePage: View {
    @State private var showError: Bool = false // State variable to show error when bio exceeds 200 characters
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn") // Track login state
    @State private var isMentor: Bool = UserDefaults.standard.bool(forKey: "isMentor") // Retrieve mentor state from UserDefaults

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Section 1: Fixed Top Section
                VStack {
                    HStack {
                        Text("Circl")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.customHex("004aad"))
                            .padding(.top, 25) // Move the logo 10 pixels down
                        
                        Spacer()
                        
                        // Profile and logout button
                        HStack(spacing: 15) { // Added spacing for better UI
                           

                            // Navigation to ProfilePageSettings (Gear Icon)
                            NavigationLink(destination: ProfilePageSettings().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "gearshape") // Gear Icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.customHex("004aad"))
                            }

                           
                        }
                        .padding(.top, 25) // Move them 10 pixels down

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    Spacer() // Adds additional space below the content
                }
                .frame(height: 105) // Increased height (75 + 100 pixels)
                .background(Color.white) // Explicitly set Section 1 background to white
                
                // Section 2: Scrollable Middle Section
                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .frame(height: 300)
                            
                            VStack(spacing: 15) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray)
                                    )
                                
                                HStack(spacing: 40) {
                                    VStack {
                                        Text("Connections:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("123") // Placeholder for backend data
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                    
                                    VStack {
                                        Text("Circles:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("45") // Placeholder for backend data
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                    
                                    VStack {
                                        Text("Circs:")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.customHex("#ffde59"))
                                        Text("980") // Placeholder for backend data
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.white)
                                    }
                                }
                                
                                VStack(spacing: 5) {
                                    Text("Fragne Delgado") // Placeholder for backend data
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("CEO - ")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    + Text("Circl International") // Redirectable link
                                        .font(.system(size: 18, weight: .semibold))
                                        .underline()
                                        .foregroundColor(.white)
                                    
                                    Text("ENFJ - A") // Personality type placeholder
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    // Mentor Toggle with backend update
                                    // ProfilePage.swift
                                    Toggle("Mentor?", isOn: $isMentor)
                                        .toggleStyle(SwitchToggleStyle(tint: Color.customHex("ffde59")))
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                        .onChange(of: isMentor) { newValue in
                                            // Save the updated toggle state in UserDefaults
                                            UserDefaults.standard.set(newValue, forKey: "isMentor")
                                            
                                            // Send the change to the backend (already implemented)
                                            updateMentorStatus(isMentor: newValue)
                                        }
                                    
                                }
                            }
                        }
                        // Personal Secret Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .shadow(radius: 2)
                                .frame(height: 200) // Adjust height as needed
                            
                            VStack(spacing: 10) {
                                // Secret Idea
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Secret Idea")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Creating an app for entrepreneurs") // Placeholder for idea
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.bottom, 10) // Space between sections
                                
                                Divider()
                                    .background(Color.white)
                                
                                // Your Next Steps
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your Next Steps")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Entrepreneur AI coming soon") // Placeholder for next steps
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .padding()
                        }
                        
                        // Profile Section 2: Bio Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .shadow(radius: 2)
                                .frame(height: 150)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Bio")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Entrepreneur with a Harvard Master's")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                            .padding()
                        }
                        
                        // Profile Section 3: About (Name) Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .shadow(radius: 2)
                                .frame(height: 400)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("About Fragne Delgado") // Placeholder for backend data
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Age: 30") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Education Level: Master's Degree") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Institution Attended: Harvard University") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Certifications/Licenses: Certified Project Manager") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Years of Experience: 10") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Location: New York, USA") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Achievements: Led a team of 50 to complete a $10M project under budget") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Profile Section 4: Technical Side
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .shadow(radius: 2)
                                .frame(height: 400) // Adjust height as needed
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Technical Side") // Header
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Skills: Swift, UI/UX Design, Project Management") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Projects/Work Completed: xxx") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Availability: Open to collaboration, Monday - Friday, 9 AM - 5 PM EST") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        // Profile Section 5: Interests
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .shadow(radius: 2)
                                .frame(height: 300) // Adjust height as needed
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Interests") // Header
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Clubs/Organizations: Member of Tau Kappa Epsilon, Volunteer at Habitat for Humanity") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Hobbies/Passions: Reading, Cycling, Digital Art, Traveling") // Placeholder for backend data
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            
                        }
                        // Profile Section 6: Entrepreneurial History
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customHex("004aad"))
                                .shadow(radius: 2)
                                .frame(height: 150) // Adjust height as needed
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Entrepreneurial History")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("xxx") // Placeholder text
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                            .padding()
                        }
                        
                        
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray4))
                
                // Section 3: Fixed Bottom Section with Navigation Links
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
                .background(Color.white) // Explicitly set Section 3 background to white
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Small delay
                let storedLoginState = UserDefaults.standard.bool(forKey: "isLoggedIn")
                if !storedLoginState {
                    isLoggedIn = false
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Update the isMentor state from UserDefaults when the view appears
                isMentor = UserDefaults.standard.bool(forKey: "isMentor")
                isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            }
        }
    }
        




    // Function to update mentor status on the backend
    func updateMentorStatus(isMentor: Bool) {
        let userId = UserDefaults.standard.integer(forKey: "user_id") // Get user_id from UserDefaults
        print("user_id: \(userId), auth_token: \(UserDefaults.standard.string(forKey: "auth_token") ?? "No token")")

        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            return
        }

        let url = URL(string: "http://34.44.204.172:8000/api/users/update-mentor-status/")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization token if available
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "user_id": userId,
            "is_mentor": isMentor
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let data = data {
                // Handle the response
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            }
        }
        task.resume()
    }

}

// Extension to support custom hex colors
extension Color {
    static func customHex(_ hex: String) -> Color {
        let hexValue = Int(hex.dropFirst(), radix: 16) ?? 0
        let red = Double((hexValue >> 16) & 0xFF) / 255.0
        let green = Double((hexValue >> 8) & 0xFF) / 255.0
        let blue = Double(hexValue & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}

// Preview
struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
}
