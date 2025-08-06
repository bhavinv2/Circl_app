//
//  GroupChatHeader.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 7/28/25.
//

import SwiftUI

// MARK: - Group Chat Header Component
struct GroupChatHeader: View {

       let hasDashboard: Bool
    @Binding var selectedTab: GroupTab
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Top header with back button and logo
            HStack {
                // Left side - Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Center - Logo
                Text("Circl.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Right side - Empty to keep logo centered
                Color.clear
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // Tab navigation
            HStack(spacing: 0) {
                if hasDashboard {
                    Button(action: { selectedTab = .dashboard }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Dashboard")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(selectedTab == .dashboard ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                    
                    Spacer()
                }

                
                // Home Tab
                Button(action: { selectedTab = .home }) {
                    VStack(spacing: 4) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Home")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(selectedTab == .home ? .white : .white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Calendar Tab
                Button(action: { selectedTab = .calendar }) {
                    VStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .medium))
                        Text("Calendar")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(selectedTab == .calendar ? .white : .white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(hex: "004aad"))
        .safeAreaInset(edge: .top) {
            Color(hex: "004aad")
                .frame(height: 0)
        }
    }
}

// MARK: - Preview
struct GroupChatHeader_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatHeader(hasDashboard: true, selectedTab: .constant(.home))
    }
}
