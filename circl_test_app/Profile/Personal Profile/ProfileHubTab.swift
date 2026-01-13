//
//  ProfileHubTab.swift
//  circl_test_app
//
//  Created by Ryan Camp on 1/11/26.
//

import SwiftUI

enum ProfileHubTab: Hashable {
    case profile
    case business
}

struct ProfileHubPage: View {
    @State private var tab: ProfileHubTab

    init(initialTab: ProfileHubTab = .profile) {
        _tab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack {
            Color(hex: "004aad").ignoresSafeArea(edges: .top)
            
            TabView(selection: $tab) {
                ProfilePage(hubTab: $tab)
                    .tag(ProfileHubTab.profile)

                PageBusinessProfile(hubTab: $tab)
                    .tag(ProfileHubTab.business)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

#Preview {
    ProfileHubPage(initialTab: ProfileHubTab.profile)
}
