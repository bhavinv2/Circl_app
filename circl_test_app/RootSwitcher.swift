//
//  RootSwitcher.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 12/1/25.
//

import SwiftUI

struct RootSwitcher: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var network = NetworkDataManager.shared // Centralized access to IDs across
    
    @State var currentTab: RootTab = .home

    var body: some View {
        NavigationStack {
            Group {
                if appState.isLoggedIn {
                    AppLaunchView()
                } else {
                    Page1()
                }
            }
            .profilePreviewHost(isInNetwork: { userId in
                network.userNetworkIds.contains(userId)
            })
        }
        .onAppear {
            // make sure network cache is populated so "isInNetwork" works
            NetworkDataManager.shared.fetchUserNetwork()
        }
    }
}

enum RootTab: Hashable {
    case home
    case network
    case circles
    case growth
    case settings
}
