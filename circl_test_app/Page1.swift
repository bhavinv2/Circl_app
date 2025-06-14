import SwiftUI

struct Page1: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isNavigatingToSignup = false // For "Join Circl"
    @State private var isShowingForgotPasswordPopup = false
    @State private var forgotPasswordEmail: String = ""
    @State private var forgotPasswordConfirmationShown = false
    @State private var showInvalidCredentialsAlert = false


    var body: some View {
        NavigationStack {
            ZStack {
                Color(hexCode: "004aad")
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarBackButtonHidden(true)  // Hide back button
                            .navigationBarHidden(true)  // Hide entire navigation bar if desired
                
                ScrollView {
                    
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
                        .padding(.top, 10) // Optional: adds breathing room below tagline
                        .offset(y: -50)


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

                        Button(action: {
                            isShowingForgotPasswordPopup = true
                        }) {
                            Text("Forgot your password?")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .underline()
                        }
                        .padding(.top, 10)


                        Spacer()
                    }
                    .padding(.top, 50)
                    
                }
                .dismissKeyboardOnScroll()

                
                
            }
            .sheet(isPresented: $isShowingForgotPasswordPopup) {
                VStack(spacing: 20) {
                    Text("Forgot Password")
                        .font(.title)
                        .bold()

                    Text("Enter your email. We will get back to you soon with a new password.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    TextField("Email", text: $forgotPasswordEmail)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    Button("Submit") {
                        submitForgotPasswordRequest()
                    }

                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hexCode: "ffde59"))
                    .foregroundColor(Color(hexCode: "004aad"))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .alert("Password Reset", isPresented: $forgotPasswordConfirmationShown) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("We will get back to you soon with a new password.")
            }
            .alert("Invalid Credentials", isPresented: $showInvalidCredentialsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The email or password you entered is incorrect. Please try again.")
            }

            
            .navigationDestination(isPresented: $isLoggedIn) {
                PageForum()
                    .navigationBarBackButtonHidden(true)
            }

            .navigationDestination(isPresented: $isNavigatingToSignup) {
                Page2() // Navigate to signup page
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
        guard let url = URL(string: "https://circlapp.online/api/login/") else {
            showInvalidCredentialsAlert = true
            return
        }

        let loginData: [String: String] = ["email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else {
            showInvalidCredentialsAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    showInvalidCredentialsAlert = true
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
                                print("🔎 Parsed Login Response: \(jsonResponse)")


                                var hasUserID = false
                                var hasToken = false

                                if let userID = jsonResponse["user_id"] as? Int {
                                    
                                    UserDefaults.standard.set(userID, forKey: "user_id")
                                    print("✅ user_id stored: \(userID)")
                                    hasUserID = true
                                }
                                
                                if let savedToken = UserDefaults.standard.string(forKey: "pending_push_token") {
                                    print("📤 Sending saved push token after login: \(savedToken)")
                                    sendDeviceTokenToBackend(token: savedToken)
                                    UserDefaults.standard.removeObject(forKey: "pending_push_token")
                                }


                                if let token = jsonResponse["token"] as? String {
                                    UserDefaults.standard.set(token, forKey: "auth_token")
                                    print("✅ auth_token stored: \(token)")
                                    hasToken = true
                                }

                                if let email = jsonResponse["email"] as? String {
                                    UserDefaults.standard.set(email, forKey: "user_email")
                                    print("✅ user_email saved:", email)
                                }

                                if let firstName = jsonResponse["first_name"] as? String,
                                   let lastName = jsonResponse["last_name"] as? String {
                                    let fullName = "\(firstName) \(lastName)"
                                    UserDefaults.standard.set(fullName, forKey: "user_fullname")
                                    print("✅ user_fullname saved:", fullName)
                                }

                                if hasUserID && hasToken {
                                    UserDefaults.standard.set(self.email, forKey: "user_email")
                                    print("✅ user_email (fallback from login field) saved manually:", self.email)

                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                                    }
                                }

                            }
                        } catch {
                            showInvalidCredentialsAlert = true
                        }
                    }
                } else {
                    showInvalidCredentialsAlert = true
                }
            }
        }
        task.resume()
    }
    
    func submitForgotPasswordRequest() {
        guard let url = URL(string: "https://circlapp.online/api/forgot-password/") else {
            print("Invalid forgot password URL")
            return
        }

        let requestData = ["email": forgotPasswordEmail]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else {
            print("Failed to encode email")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isShowingForgotPasswordPopup = false
                forgotPasswordConfirmationShown = true
            }
        }.resume()
    }
}

struct Page1_Previews: PreviewProvider {
    static var previews: some View {
        Page1()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
