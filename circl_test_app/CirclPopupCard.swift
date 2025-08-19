import SwiftUI
import Foundation

struct CirclPopupCard: View {
    var circle: CircleData
    var isMember: Bool = false
    var onJoinPressed: (() -> Void)? = nil
    var onOpenCircle: (() -> Void)? = nil

    @AppStorage("user_id") private var userId: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    // Check if current user is the creator/admin of the circle
    private var isUserCreator: Bool {
        let result = userId == circle.creatorId
        print("🔍 Admin check: userId=\(userId), creatorId=\(circle.creatorId), isUserCreator=\(result)")
        return result
    }

    var body: some View {
        VStack(spacing: 16) {
            // Debug admin/moderator status
            let _ = print("🔍 Circle '\(circle.name)': isPrivate=\(circle.isPrivate), isModerator=\(circle.isModerator), isUserCreator=\(isUserCreator), shouldShowAdminOptions=\(circle.isModerator || isUserCreator)")
            
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

            // Show private circle indicator for all users
            if circle.isPrivate {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color(hex: "004aad"))
                        .font(.system(size: 12))
                    Text("Private Circle")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "004aad"))
                }
            }

            Divider().padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("About This Circl")
                    .font(.headline)

                Text(circle.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)

            // MARK: - Circle Settings (for moderators and admins)
            if circle.isModerator || isUserCreator {
                Divider().padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Circle Settings")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        if circle.isPrivate {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color(hex: "004aad"))
                                .font(.system(size: 14))
                            Text("Private Circle")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "globe")
                                .foregroundColor(Color(hex: "004aad"))
                                .font(.system(size: 14))
                            Text("Public Circle")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        // Show admin/moderator badge
                        if isUserCreator {
                            Text("ADMIN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        } else if circle.isModerator {
                            Text("MOD")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    // Only show access code for private circles
                    if circle.isPrivate {
                        if let accessCode = circle.accessCode, !accessCode.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Access PIN:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(accessCode)
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(hex: "004aad"))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: "004aad").opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color(hex: "004aad").opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    
                                    Button(action: {
                                        UIPasteboard.general.string = accessCode
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(Color(hex: "004aad"))
                                            .font(.system(size: 16))
                                    }
                                }
                                
                                Text("Share this PIN with people you want to invite to this private circle.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Access PIN:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text("PIN not available - Backend needs to return 'access_code' field in API response.")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    } else {
                        // For public circles, show general admin options
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Circle Management:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("As an admin/moderator, you have access to manage this circle's settings, members, and content.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal)
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
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding()
    }
}
