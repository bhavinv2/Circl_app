//
//  AppState.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 12/1/25.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
}
