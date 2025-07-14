import SwiftUI

struct MenuItem: View {
    var icon: String
    var title: String
    var badgeCount: Int? // Optional badge count

    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "004aad"))
                    .frame(width: 30)

                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 12, y: -12) // Adjust position
                }
            }
            Text(title)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding()
    }
}
