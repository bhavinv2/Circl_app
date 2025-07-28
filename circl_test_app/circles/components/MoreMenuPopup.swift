import SwiftUI

// MARK: - More Menu Popup Component
struct MoreMenuPopup: View {
    @Binding var showMoreMenu: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("More Options")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .foregroundColor(.primary)
                
                Divider()
                    .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    // Professional Services
                    NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 16) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "004aad"))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Professional Services")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Find business services and experts")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // News & Knowledge
                    NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 16) {
                            Image(systemName: "newspaper.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "004aad"))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("News & Knowledge")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Stay updated with industry insights")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // The Circl Exchange
                    NavigationLink(destination: PageSkillSellingMatching().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 16) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "004aad"))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("The Circl Exchange")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Buy and sell skills and services")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Settings
                    NavigationLink(destination: PageSettings().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 16) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "004aad"))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Settings")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Manage your account settings")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMoreMenu = false
                    }
                }
        )
        .zIndex(2)
    }
}

// MARK: - Preview
struct MoreMenuPopup_Previews: PreviewProvider {
    static var previews: some View {
        MoreMenuPopup(showMoreMenu: .constant(true))
    }
}
