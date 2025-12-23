import SwiftUI

struct PageCirclesMyCirclesWrapper: View {
    var body: some View {
        PageCirclesWithMyCirclesSelected()
    }
}

struct PageCirclesWithMyCirclesSelected: View {
    var body: some View {
        PageCircles(showMyCircles: true)
    }
}
