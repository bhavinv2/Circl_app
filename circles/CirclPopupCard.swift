import SwiftUI
import Foundation

struct CirclPopupCard: View {
    @State private var showMediaPicker = false
    @State private var selectedImage: UIImage?
    @State private var showInviteCopiedToast = false

    @State var circle: CircleData

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

            if let url = circle.profileImageURL, let imgURL = URL(string: url) {
                AsyncImage(url: imgURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)

                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .opacity(0.5)

                    @unknown default:
                        EmptyView()
                    }
                }


            } else {
                Image(systemName: "photo") // fallback if no profile image_url
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }



            // ✅ Moderator-only upload button
            if circle.isModerator {
                Button("Upload Circl Photo") {
                    showMediaPicker = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.top, 4)
                .sheet(isPresented: $showMediaPicker) {
                    MediaPicker(image: $selectedImage, videoURL: .constant(nil))
                }
                .onChange(of: showMediaPicker) { isShowing in
                    if !isShowing, let img = selectedImage {
                        uploadCircleImage(circleId: circle.id, image: img)

                    }
                }


            }
            
            


            Text(circle.name)
                .font(.title)
                .fontWeight(.bold)

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
            
            if circle.isModerator, let accessCode = circle.accessCode, !accessCode.trimmingCharacters(in: .whitespaces).isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Access Code")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(accessCode)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
            }



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
        .onReceive(NotificationCenter.default.publisher(for: .circleUpdated)) { notification in
            if let updatedCircle = notification.object as? CircleData,
               updatedCircle.id == circle.id {
                circle = updatedCircle   // ✅ refresh local state
            }
        }

        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding()
        // Toast overlay for invite copy confirmation
        .overlay(
            Group {
                if showInviteCopiedToast {
                    VStack {
                        Spacer()
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Invite Link Copied to Your Clipboard!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("Paste it into your Messages to invite your network!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            },
            alignment: .bottom
        )
    }
}
