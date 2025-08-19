import SwiftUI
import Foundation

struct TestPageCircles: View {
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            Text("Test")
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
