//
//  Page19.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 3/5/25.
//

import SwiftUI

struct Page19: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Thank You for Signing Up!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            Text("Your account is now awaiting approval. Once approved, you will receive an email with your login credentials.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Text("You can close the app now.")
                .font(.headline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct Page19_Previews: PreviewProvider {
    static var previews: some View {
        Page19()
    }
}
