//
//  RootSwitcher.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 12/1/25.
//

import SwiftUI

struct RootSwitcher: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                AppLaunchView()
            } else {
                Page1()
            }
        }
    }
}
