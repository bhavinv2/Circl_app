import SwiftUI

// MARK: - Success Toast Component
struct SuccessToast: View {
    @Binding var isShowing: Bool
    let message: String
    
    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green,
                        Color.green.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 5)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)

            Spacer()
                .frame(height: 100)
        }
        .zIndex(1000)
    }
}

// MARK: - Preview
struct SuccessToast_Previews: PreviewProvider {
    static var previews: some View {
        SuccessToast(isShowing: .constant(true), message: "Announcement created successfully!")
    }
}
