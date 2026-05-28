import SwiftUI

// MARK: - Reusable Error Alert Modifier
// Usage: .errorAlert($errorMessage)
// Any view that does async work should have @State var errorMessage: String?
// and show errors via this modifier.

struct ErrorAlertModifier: ViewModifier {
    @Binding var errorMessage: String?

    func body(content: Content) -> some View {
        content
            .alert("Something went wrong", isPresented: showAlert) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
    }

    private var showAlert: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }
}

extension View {
    func errorAlert(_ errorMessage: Binding<String?>) -> some View {
        modifier(ErrorAlertModifier(errorMessage: errorMessage))
    }
}
