//
//  ProfileService.swift
//  circl_test_app
//
//  Created by Ryan Camp on 1/2/26.
//

import Foundation

protocol ProfileFetching {
    func fetchProfile(userId: Int, completion: @escaping (FullProfile?) -> Void)
}

final class ProfileService: ProfileFetching {
    func fetchProfile(userId: Int, completion: @escaping (FullProfile?) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/profile/\(userId)/") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let decodedProfile = try? JSONDecoder().decode(FullProfile.self, from: data)
            DispatchQueue.main.async {
                completion(decodedProfile)
            }
        }.resume()
    }
}
