import SwiftUI

struct ProfilePageSettings: View {
    @State private var userTitle: String = UserDefaults.standard.string(forKey: "userTitle") ?? ""
    @Environment(\.presentationMode) var presentationMode  // ✅ For dismissing the settings page

    var body: some View {
        VStack {
        

            // ✅ Logout Button (Newly Added)
            Button(action: logoutUser) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()


            Spacer()
        }
        .padding()
        .navigationBarTitle("Settings", displayMode: .inline)  // ✅ Title
        .navigationBarBackButtonHidden(true)  // ✅ Hide default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                }
            }
        }
    }

    func saveTitle() {
        UserDefaults.standard.set(userTitle, forKey: "userTitle")
        print("✅ Title saved: \(userTitle)")
        
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")

        // ✅ Navigate back to Page1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: Page1())
                window.makeKeyAndVisible()
            }
        }
    }

}

// Preview
struct ProfilePageSettings_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePageSettings()
    }
    
    
}
