//
//  ProfilePreviewCoordinator.swift
//  circl_test_app
//
//  Created by Ryan Camp on 1/2/26.
//

import SwiftUI

@MainActor
final class ProfilePreviewCoordinator: ObservableObject {
    struct Route: Identifiable, Hashable, Equatable {
        let userId: Int
        var id: Int { userId }
    }
    
    @Published var route: Route? = nil
    
//    @Published var isPresented = false
    @Published var isLoading = false
    @Published var profile: FullProfile?

    private let fetcher: ProfileFetching
    

    init(fetcher: ProfileFetching) {
        self.fetcher = fetcher
    }

    func present(userId: Int) {
        print("Presenting w/ userId: \(userId)...")
        
        if route?.userId == userId { return }
        
        isLoading = true
        profile = nil
        route = Route(userId: userId)

        fetcher.fetchProfile(userId: userId) { [weak self] loaded in
            guard let self else { return }
            
            print("Fetching profile...")
            self.isLoading = false
            
            if let loaded {
                print("Loaded: \(loaded.first_name) \(loaded.last_name), userId: \(loaded.user_id)...")
                self.profile = loaded
                print("Profile loaded: \(self.profile?.first_name ?? "nil"), \(self.profile?.last_name ?? "nil"), \(self.profile?.user_id ?? -1)")
            } else {
                print("Failed to load.")
                self.route = nil
            }
        }
    }

    func present(profile: FullProfile) {
        print("Presenting w/ profile: \(profile.first_name) \(profile.last_name), userId: \(profile.user_id)...")
        self.route = Route(userId: profile.user_id)
            
        self.profile = profile
        self.isLoading = false
    }

    func dismiss() {
        route = nil
        isLoading = false
        profile = nil
    }
}
