import SwiftUI

struct Page10: View {
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var showAlert = false
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            // Background Color
            Color(hexCode: "004aad")
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

            VStack(spacing: 10) {
                Spacer()

                // Title
                Text("One Last Thing")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hexCode: "ffde59"))

                // Separator
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)

                // Main Prompt
                Text("Why should we accept you?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 0)
                    .padding(.bottom, 12)

                // Input Fields Section
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

                // Next Button
                Button(action: {
                    if answer1.isEmpty || answer2.isEmpty {
                        showAlert = true
                    } else {
                        isNavigating = true
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
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.horizontal, 50)
                        .padding(.bottom, 30)
                }
                .background(
                    NavigationLink(
                        destination: Page18(),
                        isActive: $isNavigating,
                        label: { EmptyView() }
                    )
                )
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Incomplete Form"),
                        message: Text("Please fill out all fields before proceeding."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Spacer()
            }
        }
    }
}

struct FreeResponseField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .padding(10)
                .background(Color(hexCode: "d9d9d9"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hexCode: "004aad"), lineWidth: 2)
                )
                .font(.system(size: 16))
                .foregroundColor(.primary)

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
