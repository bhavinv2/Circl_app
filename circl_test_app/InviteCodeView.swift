import SwiftUI

struct InviteCodeView: View {
    @State private var inviteCode: String? = nil
    @State private var generatedCodes = Set<String>()
    @State private var showCopiedMessage = false
    @State private var tagline: String? = nil
    @State private var inverted = false

    let messages = [
        "Drop a code. Add a co-founder.",
        "Build your board one friend at a time.",
        "Your startup needs vibes. Start here.",
        "Collab > compete. Share it.",
        "They might just be your next investor.",
        "Grow your circle, grow your hustle.",
        "This invite could change your network.",
        "You never know who’s on the other end.",
        "It all starts with a code.",
        "Founders don’t go solo — share it."
    ]

    var body: some View {
        ZStack {
            (inverted ? Color(hex: "#004AAD") : Color.white)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Your Invite Code")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(inverted ? .white : .black)
                    .padding(.top)

                if let code = inviteCode {
                    Text(code)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(inverted ? Color.white : Color.gray)
                        )
                        .foregroundColor(inverted ? .white : .black)
                        .padding(.horizontal)

                    if let tagline = tagline {
                        Text(tagline)
                            .font(.subheadline)
                            .foregroundColor(inverted ? .white.opacity(0.8) : .gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    Text("No code generated yet.")
                        .foregroundColor(inverted ? .white.opacity(0.8) : .gray)
                }

                Button("Generate New Code") {
                    let newCode = generateUniqueCode()
                    inviteCode = newCode
                    generatedCodes.insert(newCode)
                    tagline = messages.randomElement()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                .buttonStyle(.borderedProminent)
                .tint(inverted ? .white : Color(hex: "#004AAD"))
                .foregroundColor(inverted ? Color(hex: "#004AAD") : .white)

                HStack(spacing: 20) {
                    Button("Copy") {
                        if let code = inviteCode {
                            UIPasteboard.general.string = code
                            showCopiedMessage = true
                            inverted = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedMessage = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    inverted = false
                                }
                            }
                        }
                    }
                    .disabled(inviteCode == nil)
                    .foregroundColor(inverted ? Color(hex: "#004AAD") : .white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(inverted ? .white : Color(hex: "#004AAD"))
                    .cornerRadius(8)

                    Button("Share") {
                        print("Share button tapped — functionality coming soon.")
                    }
                    .disabled(inviteCode == nil)
                    .foregroundColor(inverted ? Color(hex: "#004AAD") : .white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(inverted ? .white : Color(hex: "#004AAD"))
                    .cornerRadius(8)
                }

                if showCopiedMessage {
                    Text("Copied to clipboard!")
                        .font(.footnote)
                        .foregroundColor(inverted ? .white : .green)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding()
        }
    }

    func generateUniqueCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var code: String
        repeat {
            code = String((0..<8).map { _ in characters.randomElement()! })
        } while generatedCodes.contains(code)
        return code
    }
}

// MARK: - HEX Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

