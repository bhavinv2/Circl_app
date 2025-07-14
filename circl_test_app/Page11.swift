import SwiftUI

struct Page11: View {
    @State private var successDefinition: String = ""
    @State private var businessUniqueness: String = ""
    @State private var showMissingFieldsAlert = false
    

    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color(hex: "004aad")
                    .edgesIgnoringSafeArea(.all)
                
                
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer()

                        // Title
                        Text("Your Business Profile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "ffde59"))

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
                        Text("Please answer below in your own words\nBe as detailed as possible")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, -8) // Reduce spacing between subtitle and instruction

                        // Input Fields
                        VStack(spacing: 20) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $successDefinition)
                                    .frame(height: 200)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.top, 8)
                                
                                if successDefinition.isEmpty {
                                    Text("What makes your business successful?")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                        .padding(.top, 16)
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $businessUniqueness)
                                    .frame(height: 200)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.top, 8)
                                
                                if businessUniqueness.isEmpty {
                                    Text("What makes your business unique?")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                        .padding(.top, 16)
                                }
                            }
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, 10)

                        Spacer()

                        // Next Button
                        Button(action: {
                            saveBusinessDetails()
                        }) {
                            NavigationLink(destination: Page12()) {
                                Text("Next")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color(hex: "ffde59"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 2) // White outline
                                    )
                                    .padding(.horizontal, 50)
                                    .padding(.bottom, 20)
                            }
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            saveBusinessDetails()
                        })

                        Spacer()
                    }
                }
                .dismissKeyboardOnScroll()
            }
        }
    }
    
    // Function to send data to the backend
    func saveBusinessDetails() {
        guard let url = URL(string: "https://circlapp.online/api/users/update-business-details/") else { return }
        
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        print("📌 Debug: Sending business details for user_id = \(user_id)")
        
        let parameters: [String: Any] = [
            "user_id": user_id,
            "business_success_definition": successDefinition,
            "business_uniqueness": businessUniqueness
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to encode parameters: \(error)" )
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }.resume()
    }
}

struct Page11View_Previews: PreviewProvider {
    static var previews: some View {
        Page11()
    }
}
