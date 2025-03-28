import SwiftUI

struct Page10: View {
    @State private var navigateToPage11 = false // ✅ State variable for navigation
    @State private var businessGoals: String = "" // ✅ Added for business goals
    @State private var businessChallenges: String = "" // ✅ Added for business challenges
    @State private var showMissingFieldsAlert = false


    var body: some View {
        NavigationView { // ✅ Wrap the ZStack in a NavigationView
            ZStack {
                // Background Color
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    Text("Your Business Profile")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))

                    // Separator
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)

                    // Subtitle
                    Text("Let Us Understand You")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 4) // Move text down

                    // Instruction
                    Text("Please answer in your own words\nbe as detailed as possible")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, -8) // Reduce spacing between subtitle and instruction

                    // Input Fields
                    VStack(spacing: 20) {
                        // Updated to bind to businessGoals
                        TextEditor(text: $businessGoals)
                            .frame(height: 200)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(hexCode: "d9d9d9"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hexCode: "004aad"), lineWidth: 2)
                            )
                            .overlay(
                                Text("What are your business' goals?")
                                    .foregroundColor(businessGoals.isEmpty ? .gray : .clear)
                                    .padding(.leading, 19)
                                    .padding(.top, 12), alignment: .topLeading
                            )
                            .padding(.top, 8) // Move text down

                        // Updated to bind to businessChallenges
                        TextEditor(text: $businessChallenges)
                            .frame(height: 200)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(hexCode: "d9d9d9"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hexCode: "004aad"), lineWidth: 2)
                            )
                            .overlay(
                                Text("What has stopped/is stopping your company from growing?")
                                    .foregroundColor(businessChallenges.isEmpty ? .gray : .clear)
                                    .padding(.leading, 19)
                                    .padding(.top, 12), alignment: .topLeading
                            )
                            .padding(.top, 8) // Move text down
                    }
                    .padding(.horizontal, 50)
                    .padding(.top, 10)

                    Spacer()

                    Button(action: {
                        if businessGoals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                           businessChallenges.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showMissingFieldsAlert = true
                        } else {
                            submitBusinessDetails()
                        }
                    }) {

                        Text("Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hexCode: "004aad"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hexCode: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2) // White outline
                            )
                            .padding(.horizontal, 50)
                            .padding(.bottom, 20)
                    }

                    // ✅ Navigation to Page 11
                    NavigationLink(destination: Page11(), isActive: $navigateToPage11) {
                        EmptyView()
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true) // ✅ Hide the default navigation bar
            .alert("Missing Fields", isPresented: $showMissingFieldsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill out both fields before continuing.")
            }

        }
    }

    // ✅ Added submitBusinessDetails function
    func submitBusinessDetails() {
        guard let url = URL(string: "http://34.136.164.254:8000/api/users/update-business-details/") else {
            print("❌ Invalid API URL")
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")

        // ✅ Debugging: Print which user_id is being used
        print("📌 Debug: Sending business details for user_id = \(userId)")

        if userId == 0 {
            print("❌ User ID not found. Ensure registration is complete on Page 3.")
            return
        }

        let businessDetails: [String: Any] = [
            "user_id": userId,
            "business_goals": businessGoals,
            "business_challenges": businessChallenges
        ]

        // ✅ Debugging: Print JSON before sending
        if let jsonData = try? JSONSerialization.data(withJSONObject: businessDetails),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🚀 Debug: Sending Business Details JSON: \(jsonString)")
        } else {
            print("❌ Debug: Failed to encode JSON")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: businessDetails) else {
            print("❌ Debug: Failed to encode data")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Debug: Request Error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Debug: Response Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        print("✅ Debug: Business details updated successfully for user_id = \(userId)")
                        
                        // ✅ Navigate to Page 11 after saving data
                        DispatchQueue.main.async {
                            print("🚀 Debug: Navigating to Page 11")
                            navigateToPage11 = true
                        }
                    } else {
                        print("❌ Debug: Failed to update business details. Status code: \(httpResponse.statusCode)")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Debug: Response Body: \(responseString)")
                }
            }
        }.resume()
    }
}

struct FreeResponseField: View {
    var placeholder: String

    var body: some View {
        TextEditor(text: .constant(""))
            .padding(.horizontal, 12) // Reduce internal border
            .padding(.vertical, 10)   // Reduce internal border
            .background(Color(hexCode: "d9d9d9"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hexCode: "004aad"), lineWidth: 2)
            )
            .frame(maxWidth: .infinity)
            .overlay(
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 19) // Move placeholder text further right
                    .padding(.top, 12), alignment: .topLeading // Adjust placeholder position
            )
    }
}

struct Page10View_Previews: PreviewProvider {
    static var previews: some View {
        Page10()
    }
}
