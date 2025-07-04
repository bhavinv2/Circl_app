import SwiftUI

struct CirclPopupCard: View {
    var circle: CircleData
    var isMember: Bool = false
    var onJoinPressed: (() -> Void)? = nil
    var onOpenCircle: (() -> Void)? = nil


    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing)

            Image(circle.imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Image("CirclLogoButton")
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            Text(circle.name)


            Text("Industry: \(circle.industry)")
                .font(.subheadline)

            if !circle.pricing.isEmpty {
                Text("Pricing: \(circle.pricing)")
                    .font(.subheadline)
            }

            Text("\(circle.memberCount) Members")

                .font(.subheadline)

            Divider().padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("About This Circl")
                    .font(.headline)

                Text(circle.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)

            Spacer()

            if isMember {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onOpenCircle?()
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                        Text("Open Circl")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else {
                Button(action: {
                    onJoinPressed?()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Join Now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding()
    }
}
