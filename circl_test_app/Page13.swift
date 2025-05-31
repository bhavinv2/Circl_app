import SwiftUI

struct Page13: View {
    @State private var notificationsEnabled: Bool = false // Toggle state

    var body: some View {
        ZStack {
            // Background Color
            Color(hexCode: "004aad")
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Notifications")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hexCode: "ffde59"))

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
                        EmptyView() // Empty view for label-less toggle
                    }
                    .toggleStyle(SwitchToggleStyle(tint: notificationsEnabled ? Color(hexCode: "00bf63") : Color(hexCode: "ffde59")))
                    .frame(width: 80) // Expanded width by 80 pixels
                    .padding(.horizontal, 40)
                    .padding(.top, 10) // Align toggle properly
                }

                Spacer()

                // Next Button
                NavigationLink(destination: Page10()) {
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
                        .padding(.bottom, 40)
                }

                Spacer()
            }
        }
    }
}

struct Page13View_Previews: PreviewProvider {
    static var previews: some View {
        Page13()
    }
}
