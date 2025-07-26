import SwiftUI
import Foundation

struct PageEntrepreneurMatchingRedirect: View {
    var body: some View {
        PageUnifiedNetworking()
            .onAppear {
                // This page now redirects to the unified networking page  
                // The unified page will handle setting the correct tab state to .entrepreneurs
            }
    }
}
