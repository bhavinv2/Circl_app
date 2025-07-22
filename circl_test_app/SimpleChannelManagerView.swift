import SwiftUI
import Foundation

struct SimpleChannelManagerView: View {
    let circleId: Int
    @Binding var channels: [Channel]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text("Channel Overview")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .background(Color(hex: "004aad"))
                .safeAreaInset(edge: .top) {
                    Color(hex: "004aad")
                        .frame(height: 0)
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Status Banner
                        VStack(spacing: 12) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "004aad"))
                            
                            Text("Channel Management")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Backend endpoints needed for full functionality")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "004aad").opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Current Channels
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Channels (\(channels.count))")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if channels.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "number")
                                        .font(.system(size: 28))
                                        .foregroundColor(.secondary)
                                    Text("No channels found")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(channels) { channel in
                                        HStack(spacing: 12) {
                                            Image(systemName: "number")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color(hex: "004aad"))
                                                .frame(width: 24, height: 24)
                                                .background(
                                                    Circle()
                                                        .fill(Color(hex: "004aad").opacity(0.1))
                                                )
                                            
                                            Text(channel.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.green)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Coming Soon Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Coming Soon")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                FeatureRow(
                                    icon: "plus.circle",
                                    title: "Add New Channels",
                                    description: "Create custom channels for your circle"
                                )
                                
                                FeatureRow(
                                    icon: "arrow.up.arrow.down",
                                    title: "Reorder Channels", 
                                    description: "Drag and drop to reorganize"
                                )
                                
                                FeatureRow(
                                    icon: "trash",
                                    title: "Delete Channels",
                                    description: "Remove unused channels"
                                )
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(hex: "004aad").opacity(0.02)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.secondary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "clock")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct SimpleChannelManagerView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleChannelManagerView(
            circleId: 1,
            channels: .constant([
                Channel(id: 1, name: "#general", circleId: 1),
                Channel(id: 2, name: "#announcements", circleId: 1)
            ])
        )
    }
} 