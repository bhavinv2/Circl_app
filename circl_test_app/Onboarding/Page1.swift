import SwiftUI
import UIKit

struct Page1: View {
    @EnvironmentObject var appState: AppState

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
//        NavigationStack {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "004aad"),
                        Color(hex: "0056c7"),
                        Color(hex: "004aad")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .onTapGesture {
                    hideKeyboard()
                }
                
                VStack(spacing: 0) {
                    Spacer(minLength: 50)
                    
                    // Logo Section with subtle enhancements
                    VStack(spacing: 20) {
                        Circle()
                            .foregroundColor(.white)
                            .overlay(
                                Text("Circl.")
                                    .font(.system(size: 55, weight: .bold))
                                    .foregroundColor(Color(hex: "004aad"))
                            )
                            .frame(width: 220, height: 220)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("Where Ideas Go Around")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Enhanced card layout
                    VStack(spacing: 25) {
                        // Join Circl Button with subtle styling
                        Button(action: {
                            isNavigatingToSignup = true
                        }) {
                            Text("Join Circl")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(hex: "ffde59"))
                                .foregroundColor(Color(hex: "004aad"))
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                        
                        // Enhanced login card
                        VStack(spacing: 18) {
                            // Email Field with improved styling
                            TextField("Email", text: $email)
                                .padding(18)
                                .background(Color.white.opacity(0.95))
                                .foregroundColor(Color(hex: "004aad"))
                                .cornerRadius(15)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            
                            // Password Field with improved styling
                            SecureField("Password", text: $password)
                                .padding(18)
                                .background(Color.white.opacity(0.95))
                                .foregroundColor(Color(hex: "004aad"))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            
                            // Login Button with enhanced styling
                            Button(action: loginUser) {
                                Text("Login")
                                    .font(.system(size: 22, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color(hex: "ffde59"))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .cornerRadius(15)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        // Enhanced forgot password
                        Button(action: {
                            isShowingForgotPasswordPopup = true
                        }) {
                            Text("Forgot your password?")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .underline()
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 50)
                }
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
                .onTapGesture {
                    hideKeyboard()
                }
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
                Page14() // Navigate to Page14
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Small delay to ensure consistency
                    let storedLoginState = UserDefaults.standard.bool(forKey: "isLoggedIn")
                    if storedLoginState && !isLoggedIn {
                        isLoggedIn = true
                    }
                }
            }
//        }
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
                                    appState.isLoggedIn = true

                                }
                                // 🔥 Handle pending deep link join AFTER login
                                if let pendingId = pendingDeepLinkCircleId {
                                    print("🔥 Processing pending deep link after login:", pendingId)
                                    pendingDeepLinkCircleId = nil
                                    Task { await joinCircleFromDeepLink(pendingId) }
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
