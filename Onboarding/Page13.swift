import SwiftUI

struct Page13: View {
    @State private var notificationsEnabled: Bool = false // Toggle state

    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "004aad")
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 80), y: -UIScreen.main.bounds.height / 2 + 0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 130), y: -UIScreen.main.bounds.height / 2 + 0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: -UIScreen.main.bounds.height / 2 + 40)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 110), y: -UIScreen.main.bounds.height / 2 + 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 170), y: -UIScreen.main.bounds.height / 2 + 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 210), y: -UIScreen.main.bounds.height / 2 + 60)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 90), y: -UIScreen.main.bounds.height / 2 + 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 50), y: -UIScreen.main.bounds.height / 2 + 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .offset(x: -(UIScreen.main.bounds.width / 2 + 150), y: -UIScreen.main.bounds.height / 2 + 80)
            }

            // Bottom Left Cloud (Flipped from Bottom Right Cloud)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 60), y: UIScreen.main.bounds.height / 2 - 60)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 40)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 90), y: UIScreen.main.bounds.height / 2 - 50)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 50), y: UIScreen.main.bounds.height / 2 - 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 30), y: UIScreen.main.bounds.height / 2 - 110)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: -(UIScreen.main.bounds.width / 2 - 135), y: UIScreen.main.bounds.height / 2 - 30)
            }

            // Middle Right Cloud (Flipped from Middle Left Cloud)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: UIScreen.main.bounds.width / 2 - 60, y: 2 + 150)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: UIScreen.main.bounds.width / 2 - 40, y: 120)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .offset(x: UIScreen.main.bounds.width / 2 - 10, y: 140)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .offset(x: UIScreen.main.bounds.width / 2 - 90, y:90)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .offset(x: UIScreen.main.bounds.width / 2 - 125, y: 130)
            }

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Notifications")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "ffde59"))

                    // Separator Line
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                }

                // Body Text
                Text("Turn on your notifications so we can give you new information, exclusive deals, and more!")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // Toggle
                VStack(spacing: 15) {
                    Text("Mobile App Notifications")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 50) // Push text and toggle down by 50 pixels

                    Toggle(isOn: $notificationsEnabled) {
                        EmptyView()
                    }
                    .onChange(of: notificationsEnabled) { newValue in
                        toggleNotifications(enabled: newValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: notificationsEnabled ? Color(hex: "00bf63") : Color(hex: "ffde59")))
                    .frame(width: 80)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)

                }

                Spacer()

                // Next Button
                NavigationLink(destination: Page18()) {
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
                        .padding(.bottom, 40)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })

                Spacer()
            }
        }
    }
    
    func toggleNotifications(enabled: Bool) {
        if enabled {
            // Turn ON
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        print("✅ Notifications enabled by user toggle")
                    }
                } else {
                    print("❌ Notification permission not granted: \(String(describing: error))")
                }
            }
        } else {
            // Turn OFF
            DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
                print("🔕 Notifications disabled by user toggle")
            }
        }
    }

}

struct Page13View_Previews: PreviewProvider {
    static var previews: some View {
        Page13()
    }
}
