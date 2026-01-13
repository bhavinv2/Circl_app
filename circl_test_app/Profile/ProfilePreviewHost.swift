//
//  ProfilePreviewHost.swift
//  circl_test_app
//
//  Created by Ryan Camp on 1/2/26.
//

import SwiftUI

struct ProfilePreviewHost: ViewModifier {
    @EnvironmentObject var profilePreview: ProfilePreviewCoordinator
    let isInNetwork: (Int) -> Bool

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .navigationDestination(item: $profilePreview.route) { route in
                    Group {
                        if profilePreview.isLoading {
                            VStack(spacing: 14) {
                                ProgressView()
                                Text("Loading profile…")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .navigationTitle("Profile")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Close") { profilePreview.dismiss() }
                                }
                            }
                        } else if let p = profilePreview.profile {
                            DynamicProfilePreview(
                                profileData: p,
                                isInNetwork: isInNetwork(p.user_id)
                            )
                        } else { // TODO: Add preview to make sure this looks good
                            VStack(spacing: 12) {
                                Text("Couldn’t load profile.")
                                Button("Close") { profilePreview.dismiss() }
                            }
                            .padding()
                        }
                    }
                    .onDisappear {
                        if profilePreview.route?.userId == route.userId {
                            profilePreview.dismiss()
                        }
                    }
                }
            
        } else {
            // Fallback on earlier versions
            Text("Wrong version.")
        }
    }
}

extension View {
    func profilePreviewHost(isInNetwork: @escaping (Int) -> Bool) -> some View {
        modifier(ProfilePreviewHost(isInNetwork: isInNetwork))
    }
}

