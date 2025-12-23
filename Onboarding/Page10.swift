import SwiftUI
import Foundation
import UIKit
struct Page10: View {
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var showAlert = false
    @State private var isNavigating = false

    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "004aad")
                .edgesIgnoringSafeArea(.all)

            // Cloud background (same as before)
            ZStack {
                Circle().fill(Color.white).frame(width: 120, height: 120).offset(x: -(UIScreen.main.bounds.width / 2 - 80), y: -UIScreen.main.bounds.height / 2 + 0)
                Circle().fill(Color.white).frame(width: 120, height: 120).offset(x: -(UIScreen.main.bounds.width / 2 - 130), y: -UIScreen.main.bounds.height / 2 + 0)
                Circle().fill(Color.white).frame(width: 100, height: 100).offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: -UIScreen.main.bounds.height / 2 + 40)
                Circle().fill(Color.white).frame(width: 100, height: 100).offset(x: -(UIScreen.main.bounds.width / 2 - 110), y: -UIScreen.main.bounds.height / 2 + 50)
                Circle().fill(Color.white).frame(width: 100, height: 100).offset(x: -(UIScreen.main.bounds.width / 2 + 170), y: -UIScreen.main.bounds.height / 2 + 30)
                Circle().fill(Color.white).frame(width: 100, height: 100).offset(x: -(UIScreen.main.bounds.width / 2 + 210), y: -UIScreen.main.bounds.height / 2 + 60)
                Circle().fill(Color.white).frame(width: 80, height: 80).offset(x: -(UIScreen.main.bounds.width / 2 + 90), y: -UIScreen.main.bounds.height / 2 + 50)
                Circle().fill(Color.white).frame(width: 90, height: 90).offset(x: -(UIScreen.main.bounds.width / 2 + 50), y: -UIScreen.main.bounds.height / 2 + 30)
                Circle().fill(Color.white).frame(width: 110, height: 110).offset(x: -(UIScreen.main.bounds.width / 2 + 150), y: -UIScreen.main.bounds.height / 2 + 80)
            }

            // Bottom cloud
            ZStack {
                Circle().fill(Color.white).frame(width: 120, height: 120).offset(x: -(UIScreen.main.bounds.width / 2 - 60), y: UIScreen.main.bounds.height / 2 - 60)
                Circle().fill(Color.white).frame(width: 100, height: 100).offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 40)
                Circle().fill(Color.white).frame(width: 100, height: 100).offset(x: -(UIScreen.main.bounds.width / 2 - 90), y: UIScreen.main.bounds.height / 2 - 50)
                Circle().fill(Color.white).frame(width: 90, height: 90).offset(x: -(UIScreen.main.bounds.width / 2 - 50), y: UIScreen.main.bounds.height / 2 - 30)
                Circle().fill(Color.white).frame(width: 90, height: 90).offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 110)
                Circle().fill(Color.white).frame(width: 80, height: 80).offset(x: -(UIScreen.main.bounds.width / 2 - 135), y: UIScreen.main.bounds.height / 2 - 30)
            }

            VStack(spacing: 10) {
                Spacer()

                Text("One Last Thing")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "ffde59"))

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)

                Text("Why should we accept you?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 0)
                    .padding(.bottom, 12)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Describe a business/side hustle you're currently working on or recently completed—what's the biggest challenge you've faced, and how are you handling it?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        FreeResponseField(placeholder: "Type your answer here...", text: $answer1)
                            .frame(height: 160)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("What's one valuable lesson you've learned in business that you'd share with another entrepreneur, and what's one skill you're actively trying to improve right now?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        FreeResponseField(placeholder: "Type your answer here...", text: $answer2)
                            .frame(height: 160)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()

                Button(action: {
                    if answer1.isEmpty || answer2.isEmpty {
                        showAlert = true
                    } else {
                        submitAnswers()
                    }
                }) {
                    Text("Next")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "004aad"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(hex: "ffde59"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.horizontal, 50)
                        .padding(.bottom, 30)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Incomplete Form"),
                        message: Text("Please fill out all fields before proceeding."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                NavigationLink(destination: Page18(), isActive: $isNavigating) {
                    EmptyView()
                }

                Spacer()
            }
        }
        .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
        // Add these modifiers to hide navigation elements
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .statusBarHidden(false) // Change to true if you want to hide the status bar completely
        .onAppear {
            // Additional way to hide navigation bar
            UINavigationBar.appearance().isHidden = true
        }
    }

    // ✅ Backend save functionality
    func submitAnswers() {
        guard let url = URL(string: "\(baseURL)users/update-business-details/") else {
            print("❌ Invalid URL")
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        if userId == 0 {
            print("❌ User ID not found")
            return
        }

        let payload: [String: Any] = [
            "user_id": userId,
            "business_goals": answer1,
            "business_challenges": answer2
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ Failed to encode JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Request failed: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        // ✅ Now trigger navigation
                        isNavigating = true
                    } else {
                        print("❌ Error saving: Status code \(httpResponse.statusCode)")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Response: \(responseString)")
                }
            }
        }.resume()
    }
}

struct FreeResponseField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .padding(10)
                .background(Color(hex: "d9d9d9"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "004aad"), lineWidth: 2)
                )
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 15)
                    .padding(.top, 12)
                    .font(.system(size: 16))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct Page10View_Previews: PreviewProvider {
    static var previews: some View {
        Page10()
    }
}
