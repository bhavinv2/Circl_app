import SwiftUI
import Foundation

struct CirclPopupCard: View {
    @State private var showMediaPicker = false
    @State private var selectedImage: UIImage?

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

                // 🔗 Create Invite Link button
                Button(action: {
                    Task { await createInviteLink(circleId: circle.id) }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "link")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                        Text("Create Invite Link")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // ▶️ Open Circl button
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
    }
}

func createInviteLink(circleId: Int) async {
    guard let userId = UserDefaults.standard.integer(forKey: "user_id") as Int? else { return }

    guard let url = URL(string: "\(baseURL)circles/create_invite_link/\(circleId)/") else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let payload = ["user_id": userId]

    do {
        let body = try JSONSerialization.data(withJSONObject: payload)
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let inviteLink = json["invite_link"] as? String {

            // Extract token correctly
            let token = inviteLink
                .replacingOccurrences(of: "https://circlapp.online/invite/", with: "")
                .replacingOccurrences(of: "/", with: "")

            // ✅ Correct preview URL (missing /circles fixed)
            let previewLink = "https://circlapp.online/invite_preview/\(token)/"
            UIPasteboard.general.string = previewLink



            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Invite Link Created",
                    message: previewLink,

                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first,
                       let root = window.rootViewController {
                        root.present(alert, animated: true)
                    }
                }

            }

        }
    } catch {
        print("Error:", error)
    }
}
