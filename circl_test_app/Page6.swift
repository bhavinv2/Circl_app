import SwiftUI

struct Page6: View {
    @State private var clubs: String = ""
    @State private var locations: String = ""
    @State private var skillsets: String = ""
    @State private var hobbies: String = ""
    @State private var achievements: String = ""
    @State private var availability: String = ""
    @State private var navigateToPage7 = false
    @State private var showMissingFieldsAlert = false


    func submitSkillsInterests(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://34.136.164.254:8000/api/users/update-skills-interests/") else {
            print("❌ Invalid API URL")
            completion(false)
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")

        if userId == 0 {
            print("❌ User ID not found. Ensure registration is complete on Page 3.")
            completion(false)
            return
        }

        let skillsInterestsData: [String: Any] = [
            "user_id": userId,
            "clubs": clubs.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
            "locations": locations.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
            "skillsets": skillsets.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
            "hobbies": hobbies.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
            "achievements": achievements.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
            "availability": availability
        ]

        // ✅ Debugging: Print the JSON payload before sending
        if let jsonData = try? JSONSerialization.data(withJSONObject: skillsInterestsData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🚀 Sending Skills & Interests JSON: \(jsonString)")
        } else {
            print("❌ Failed to encode JSON")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: skillsInterestsData) else {
            print("❌ Failed to encode data")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Request Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        print("✅ Skills & Interests updated successfully.")
                        completion(true)
                    } else {
                        print("❌ Failed to update Skills & Interests. Status code: \(httpResponse.statusCode)")
                        completion(false)
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Response Body: \(responseString)")
                }
            }
        }.resume()
    }

    var body: some View {
        NavigationView { // Wrap the entire view in a NavigationView
            ZStack {
                // Background Color
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    Text("Create Your Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))

                    // Separator
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)

                    // Section Title aligned to text boxes
                    HStack {
                        Text("Personal Information")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 40) // Aligns with text box padding
                    .padding(.top, 20)

                    // Input Fields
                    VStack(spacing: 15) {
                        TextField("Clubs/Organizations", text: $clubs)
                            .textFieldStyle(CustomRoundedTextFieldStyle())
                            .frame(maxWidth: 300) // Matches previous text box width
                        TextField("Location", text: $locations)
                            .textFieldStyle(CustomRoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                        TextField("Skill Sets", text: $skillsets)
                            .textFieldStyle(CustomRoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                        TextField("Hobbies/Passions", text: $hobbies)
                            .textFieldStyle(CustomRoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                        TextField("Achievements", text: $achievements)
                            .textFieldStyle(CustomRoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                        TextField("Availability", text: $availability)
                            .textFieldStyle(CustomRoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)

                    Spacer()

                    // Next Button
                    Button(action: {
                        if clubs.isEmpty ||
                           locations.isEmpty ||
                           skillsets.isEmpty ||
                           hobbies.isEmpty ||
                           achievements.isEmpty ||
                           availability.isEmpty {
                            showMissingFieldsAlert = true
                        } else {
                            submitSkillsInterests { success in
                                if success {
                                    navigateToPage7 = true
                                }
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hexCode: "004aad"))
                            .frame(maxWidth: 300)
                            .padding(.vertical, 15)
                            .background(Color(hexCode: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 50)
                    }


                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar
            .alert("Missing Fields", isPresented: $showMissingFieldsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill out all fields before continuing.")
            }

            .background(
                NavigationLink(
                    destination: Page7(),
                    isActive: $navigateToPage7,
                    label: { EmptyView() }
                )
            )
        }
    }
}

// Custom TextField Style
struct CustomRoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color(hexCode: "d9d9d9")) // Light gray background
            .cornerRadius(10)
            .font(.system(size: 20))
            .foregroundColor(Color(hexCode: "004aad"))
    }
}

struct Page6_Previews: PreviewProvider {
    static var previews: some View {
        Page6()
    }
}
