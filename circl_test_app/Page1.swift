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
    @State private var alertTitle = "Login Error"
    @State private var alertMessage = "Please check your email and password and try again."
    
    // Animation states for moving gradient
    @State private var gradientOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Moving Gradient Background
                ZStack {
                    // Base gradient layer
                    LinearGradient(
                        colors: [
                            Color(hex: "001a3d"),
                            Color(hex: "004aad"),
                            Color(hex: "0066ff"),
                            Color(hex: "004aad")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Moving overlay gradients for animation
                    RadialGradient(
                        colors: [
                            Color(hex: "0066ff").opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .offset(x: gradientOffset, y: -gradientOffset * 0.5)
                    .rotationEffect(.degrees(rotationAngle))
                    
                    RadialGradient(
                        colors: [
                            Color(hex: "002d5a").opacity(0.8),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 300
                    )
                    .offset(x: -gradientOffset * 0.7, y: gradientOffset * 0.8)
                    .rotationEffect(.degrees(-rotationAngle * 0.5))
                    
                    // Additional flowing gradient layer
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "004aad").opacity(0.3),
                            Color.clear
                        ],
                        startPoint: UnitPoint(x: 0.5 + gradientOffset * 0.002, y: 0),
                        endPoint: UnitPoint(x: 0.5 - gradientOffset * 0.002, y: 1)
                    )
                    
                    // Subtle overlay for depth
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.1),
                            Color.clear,
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .onAppear {
                    // Start the gradient animation
                    withAnimation(
                        Animation.linear(duration: 8.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        gradientOffset = 150
                    }
                    
                    withAnimation(
                        Animation.linear(duration: 12.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                }
                
                ScrollView {
                    
                    VStack(spacing: 20) {
                        Spacer()

                        // Circl Logo
                        Circle()
                            .foregroundColor(.white)
                            .overlay(
                                Text("Circl.")
                                    .font(.system(size: 55, weight: .bold))
                                    .foregroundColor(Color(hex: "004aad"))
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
                                .background(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.95)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(Color(hex: "004aad"))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, 10) // Optional: adds breathing room below tagline
                        .offset(y: -50)


                        // Login Fields Below Join Circl
                        VStack(spacing: 15) {
                            // Email Field
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "e2e2e2"))
                                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                .overlay(
                                    TextField("Email", text: $email)
                                        .padding(.horizontal)
                                        .foregroundColor(Color(hex: "004aad"))
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 3)
                                )

                            // Password Field
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "e2e2e2"))
                                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                .overlay(
                                    SecureField("Password", text: $password)
                                        .padding(.horizontal)
                                        .foregroundColor(Color(hex: "004aad"))
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
                                    .background(
                                        LinearGradient(
                                            colors: [Color.white, Color.white.opacity(0.95)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .foregroundColor(Color(hex: "004aad"))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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

                        // Debug: Test Connection Button (can be removed in production)
                        Button(action: testConnection) {
                            Text("Test Connection")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .opacity(0.7)
                        }
                        .padding(.top, 5)

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
                    .background(Color(hex: "ffde59"))
                    .foregroundColor(Color(hex: "004aad"))
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
            .alert(alertTitle, isPresented: $showInvalidCredentialsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
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
    
    // Helper function to show specific error messages
    func showLoginError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showInvalidCredentialsAlert = true
    }
    
    // Test network connectivity
    func testConnection() {
        guard let url = URL(string: "https://circlapp.online/api/login/") else {
            print("❌ Invalid URL")
            return
        }
        
        print("🧪 Testing connection to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Connection test failed: \(error.localizedDescription)")
                    showLoginError(title: "Connection Test Failed", message: "Cannot reach server: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Connection test successful - Status: \(httpResponse.statusCode)")
                    showLoginError(title: "Connection Test Passed", message: "Server is reachable (Status: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    // 🚀 Function to handle login
    func loginUser() {
        // Input validation and debugging
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🔐 LOGIN ATTEMPT:")
        print("📧 Email: '\(trimmedEmail)' (length: \(trimmedEmail.count))")
        print("🔑 Password: [length: \(trimmedPassword.count)] (hidden for security)")
        
        // Basic validation
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            print("❌ Empty email or password")
            showLoginError(title: "Missing Information", message: "Please enter both email and password.")
            return
        }
        
        // Email format validation
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            print("❌ Invalid email format")
            showLoginError(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        guard let url = URL(string: "https://circlapp.online/api/login/") else {
            print("❌ Invalid login URL")
            showLoginError(title: "Connection Error", message: "Unable to connect to login server.")
            return
        }

        let loginData: [String: String] = ["email": trimmedEmail, "password": trimmedPassword]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else {
            print("❌ Failed to serialize login data")
            showLoginError(title: "Technical Error", message: "Unable to prepare login request. Please try again.")
            return
        }
        
        print("📤 Sending request to: \(url.absoluteString)")
        print("📦 Request payload: \(loginData)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("iOS", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30.0
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Enhanced error handling
                if let error = error {
                    print("❌ Network Error: \(error.localizedDescription)")
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            print("❌ No internet connection")
                            showLoginError(title: "No Internet", message: "Please check your internet connection and try again.")
                        case .timedOut:
                            print("❌ Request timed out")
                            showLoginError(title: "Request Timeout", message: "The login request timed out. Please try again.")
                        case .cannotFindHost, .cannotConnectToHost:
                            print("❌ Cannot connect to server")
                            showLoginError(title: "Server Unavailable", message: "Unable to reach the login server. Please try again later.")
                        case .networkConnectionLost:
                            print("❌ Network connection lost")
                            showLoginError(title: "Connection Lost", message: "Network connection was lost. Please try again.")
                        case .serverCertificateUntrusted:
                            print("❌ Server certificate untrusted")
                            showLoginError(title: "Security Error", message: "Unable to establish a secure connection.")
                        default:
                            print("❌ URL Error code: \(urlError.code.rawValue)")
                            showLoginError(title: "Connection Error", message: "Unable to connect to the server. Please try again.")
                        }
                    } else {
                        showLoginError(title: "Network Error", message: error.localizedDescription)
                    }
                    return
                }

                // Print HTTP response details
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📡 Response Headers: \(httpResponse.allHeaderFields)")
                }

                // Print the raw response data (for debugging)
                if let data = data {
                    let rawResponse = String(data: data, encoding: .utf8) ?? "No data"
                    print("📥 Raw Login Response: \(rawResponse)")
                } else {
                    print("❌ No response data received")
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data {
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    print("✅ Parsed Login Response: \(jsonResponse)")

                                    var hasUserID = false
                                    var hasToken = false

                                    if let userID = jsonResponse["user_id"] as? Int {
                                        UserDefaults.standard.set(userID, forKey: "user_id")
                                        print("✅ user_id stored: \(userID)")
                                        hasUserID = true
                                    } else {
                                        print("⚠️ No user_id found in response")
                                    }
                                    
                                    // Handle saved push token
                                    if let savedToken = UserDefaults.standard.string(forKey: "pending_push_token") {
                                        print("📤 Sending saved push token after login: \(savedToken)")
                                        sendDeviceTokenToBackend(token: savedToken)
                                        UserDefaults.standard.removeObject(forKey: "pending_push_token")
                                    }

                                    if let token = jsonResponse["token"] as? String {
                                        UserDefaults.standard.set(token, forKey: "auth_token")
                                        print("✅ auth_token stored: \(token.prefix(20))...")
                                        hasToken = true
                                    } else {
                                        print("⚠️ No auth token found in response")
                                    }

                                    if let email = jsonResponse["email"] as? String {
                                        UserDefaults.standard.set(email, forKey: "user_email")
                                        print("✅ user_email saved: \(email)")
                                    }

                                    if let firstName = jsonResponse["first_name"] as? String,
                                       let lastName = jsonResponse["last_name"] as? String {
                                        let fullName = "\(firstName) \(lastName)"
                                        UserDefaults.standard.set(fullName, forKey: "user_fullname")
                                        print("✅ user_fullname saved: \(fullName)")
                                    }

                                    if hasUserID && hasToken {
                                        UserDefaults.standard.set(trimmedEmail, forKey: "user_email")
                                        print("✅ user_email (from login field) saved: \(trimmedEmail)")

                                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                        print("✅ Login successful - setting isLoggedIn to true")
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                                            print("✅ Navigation should trigger to PageForum")
                                        }
                                    } else {
                                        print("❌ Missing required login data (userID: \(hasUserID), token: \(hasToken))")
                                        showLoginError(title: "Login Error", message: "Server response is incomplete. Please try again.")
                                    }

                                } else {
                                    print("❌ Failed to parse JSON response as dictionary")
                                    showLoginError(title: "Response Error", message: "Server returned invalid data. Please try again.")
                                }
                            } catch {
                                print("❌ JSON parsing error: \(error.localizedDescription)")
                                showLoginError(title: "Data Error", message: "Unable to process server response. Please try again.")
                            }
                        } else {
                            print("❌ No data in successful response")
                            showLoginError(title: "Empty Response", message: "Server returned empty response. Please try again.")
                        }
                    } else {
                        print("❌ HTTP Status Code: \(httpResponse.statusCode)")
                        
                        // Handle specific HTTP error codes
                        switch httpResponse.statusCode {
                        case 400:
                            print("❌ Bad Request - Check email/password format")
                            showLoginError(title: "Invalid Request", message: "Please check your email and password format.")
                        case 401:
                            print("❌ Unauthorized - Invalid credentials")
                            showLoginError(title: "Invalid Credentials", message: "The email or password you entered is incorrect.")
                        case 403:
                            print("❌ Forbidden - Account may be disabled")
                            showLoginError(title: "Account Restricted", message: "Your account may be disabled. Please contact support.")
                        case 404:
                            print("❌ Not Found - Login endpoint not found")
                            showLoginError(title: "Service Error", message: "Login service is currently unavailable.")
                        case 500:
                            print("❌ Internal Server Error")
                            showLoginError(title: "Server Error", message: "Server is experiencing issues. Please try again later.")
                        case 502, 503:
                            print("❌ Server temporarily unavailable")
                            showLoginError(title: "Service Unavailable", message: "Service is temporarily unavailable. Please try again later.")
                        default:
                            print("❌ Unexpected status code: \(httpResponse.statusCode)")
                            showLoginError(title: "Login Failed", message: "Login failed with status code \(httpResponse.statusCode). Please try again.")
                        }
                    }
                } else {
                    print("❌ No HTTP response received")
                    showLoginError(title: "Connection Error", message: "No response received from server.")
                }
            }
        }
        task.resume()
        print("📤 HTTP request sent, waiting for response...")
    }
    
    func submitForgotPasswordRequest() {
        guard let url = URL(string: "https://circlapp.online/api/forgot-password/") else {
            print("Invalid forgot password URL")
            return
        }

        let requestData = ["email": self.forgotPasswordEmail]
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
                self.isShowingForgotPasswordPopup = false
                self.forgotPasswordConfirmationShown = true
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
