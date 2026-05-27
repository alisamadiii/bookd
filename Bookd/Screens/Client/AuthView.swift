import SwiftUI
import AuthenticationServices

enum AuthMode {
    case signIn, signUp
}

struct AuthView: View {
    let onSuccess: () -> Void
    var initialMode: AuthMode = .signUp

    @Environment(AuthManager.self) private var authManager
    @State private var mode: AuthMode = .signUp
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode == .signUp ? "Create your\naccount." : "Welcome\nback.")
                        .font(.system(size: 36, weight: .heavy))
                        .tracking(-1)
                    Text(mode == .signUp ? "Join Bookd to discover and book pros." : "Sign in to continue.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

                // Error
                if let errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundStyle(.red)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: BookdRadius.sm))
                    .padding(.top, 16)
                }

                // Form
                VStack(spacing: 12) {
                    if mode == .signUp {
                        formField(label: "Full name", text: $name, icon: "person", placeholder: "Jordan Mendez")
                    }
                    formField(label: "Email", text: $email, icon: "envelope", placeholder: "you@example.com", keyboard: .emailAddress)
                    formField(label: "Password", text: $password, icon: "lock", placeholder: mode == .signUp ? "Create a password" : "Your password", isSecure: true)
                }
                .padding(.top, 24)

                // Submit button
                Button {
                    Task { await submit() }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(mode == .signUp ? "Create account" : "Sign in")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.bookdAccent)
                .disabled(isLoading || !isFormValid)
                .padding(.top, 20)

                // Divider
                HStack(spacing: 10) {
                    Rectangle().fill(.separator).frame(height: 0.5)
                    Text("OR")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(.tertiary)
                    Rectangle().fill(.separator).frame(height: 0.5)
                }
                .padding(.top, 24)

                // Apple Sign In
                SignInWithAppleButton(
                    mode == .signUp ? .signUp : .signIn
                ) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(Capsule())
                .padding(.top, 16)

                // Toggle mode
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        mode = mode == .signUp ? .signIn : .signUp
                        errorMessage = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(mode == .signUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundStyle(.secondary)
                        Text(mode == .signUp ? "Sign in" : "Sign up")
                            .foregroundStyle(Color.bookdAccent)
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                .padding(.top, 20)

                // Terms
                Text("By continuing you agree to Bookd's Terms · Privacy\nand consent to receive booking texts.")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationTitle(mode == .signUp ? "Sign up" : "Sign in")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { mode = initialMode }
    }

    // MARK: - Form

    private var isFormValid: Bool {
        let hasEmail = email.contains("@") && email.contains(".")
        let hasPassword = password.count >= 6
        if mode == .signUp {
            return !name.isEmpty && hasEmail && hasPassword
        }
        return hasEmail && hasPassword
    }

    private func formField(label: String, text: Binding<String>, icon: String, placeholder: String, keyboard: UIKeyboardType = .default, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(.tertiary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                        .autocorrectionDisabled(keyboard == .emailAddress)
                }
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.sm))
        }
    }

    // MARK: - Submit

    private func submit() async {
        isLoading = true
        errorMessage = nil

        do {
            if mode == .signUp {
                try await authManager.signUpWithEmail(email: email, password: password, name: name)
            } else {
                try await authManager.signInWithEmail(email: email, password: password)
            }
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Apple

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            isLoading = true
            Task {
                do {
                    try await authManager.signInWithApple(credential: credential)
                    onSuccess()
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }
}
