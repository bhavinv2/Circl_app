import SwiftUI

struct Page1: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isNavigatingToSignup = false // For "Join Circl"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Circl Logo
                    Circle()
                        .foregroundColor(.white)
                        .overlay(
                            Text("Circl.")
                                .font(.system(size: 55, weight: .bold))
                                .foregroundColor(Color(hexCode: "004aad"))
                        )
                        .frame(width: 250, height: 250)
                        .offset(y: -30)

                    Text("Where Ideas Go Around")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(y: -30)

                    Spacer()

                    // Join Circl Button Inside a White Section
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: UIScreen.main.bounds.width, height: 100)
                            .offset(y: -40)

                        Button(action: {
                            isNavigatingToSignup = true
                        }) {
                            Text("Join Circl")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color(hexCode: "ffde59"))
                                .foregroundColor(Color(hexCode: "004aad"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 50)
                        .offset(y: -40)
                    }

                    // Login Fields Below Join Circl
                    VStack(spacing: 15) {
                        // Email Field
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hexCode: "e2e2e2"))
                            .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                            .overlay(
                                TextField("Email", text: $email)
                                    .padding(.horizontal)
                                    .foregroundColor(Color(hexCode: "004aad"))
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                            )

                        // Password Field
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hexCode: "e2e2e2"))
                            .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                            .overlay(
                                SecureField("Password", text: $password)
                                    .padding(.horizontal)
                                    .foregroundColor(Color(hexCode: "004aad"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                            )

                        // Login Button
                        Button(action: loginUser) {
                            Text("Login")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color(hexCode: "ffde59"))
                                .foregroundColor(Color(hexCode: "004aad"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 50)
                    }

                    // Forgot Password Link
                    Button(action: {
                        // Forgot password functionality here
                    }) {
                        Text("Forgot your password?")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding(.top, 10)

                    Spacer()

                    // Show login error message
                    if !loginMessage.isEmpty {
                        Text(loginMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                PageForum() // Navigate to main page on successful login
            }
            .navigationDestination(isPresented: $isNavigatingToSignup) {
                Page3() // Navigate to signup page
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Small delay to ensure consistency
                    let storedLoginState = UserDefaults.standard.bool(forKey: "isLoggedIn")
                    if storedLoginState && !isLoggedIn {
                        isLoggedIn = true
                        
                    }
                }
            }
        }
    }
    
    // 🚀 Function to handle login
    func loginUser() {
        guard let url = URL(string: "http://34.44.204.172:8000/api/login/") else {
            loginMessage = "Invalid login URL"
            return
        }

        let loginData: [String: String] = ["email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else {
            loginMessage = "Failed to encode login data"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    loginMessage = "Error: \(error.localizedDescription)"
                    return
                }

                // Print the raw response data (for debugging)
                if let data = data {
                    let rawResponse = String(data: data, encoding: .utf8) ?? "No data"
                    print("Raw Login Response: \(rawResponse)")
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                print("Parsed Response: \(jsonResponse)")

                                var hasUserID = false
                                var hasToken = false
                                
                                if let userID = jsonResponse["user_id"] as? Int {
                                    UserDefaults.standard.set(userID, forKey: "user_id")
                                    print("✅ user_id stored: \(userID)")
                                    hasUserID = true
                                }

                                if let token = jsonResponse["token"] as? String {
                                    UserDefaults.standard.set(token, forKey: "auth_token")
                                    print("✅ auth_token stored: \(token)")
                                    hasToken = true
                                }
                                
                                if let firstName = jsonResponse["first_name"] as? String,
                                   let lastName = jsonResponse["last_name"] as? String {
                                    let fullName = "\(firstName) \(lastName)"
                                    UserDefaults.standard.set(fullName, forKey: "user_fullname")
                                    print("✅ user_fullname saved:", fullName)
                                }



                                
                                if hasUserID && hasToken {
                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")

                                    // ✅ Ensure `isLoggedIn` is updated correctly before navigating
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                                    }
                                }
                                
                                

                            }
                        } catch {
                            loginMessage = "Error parsing response"
                        }
                    }
                } else {
                    loginMessage = "Invalid credentials"
                }
            }
        }
        task.resume()
    }




}

struct Page1_Previews: PreviewProvider {
    static var previews: some View {
        Page1()
    }
}
