import SwiftUI

struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        ScrollView {
            content
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
    }
}

extension View {
    func dismissKeyboardOnScroll() -> some View {
        self.modifier(KeyboardDismissModifier())
    }
}
