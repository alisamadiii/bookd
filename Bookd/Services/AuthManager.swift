import Foundation
import Observation
import Supabase
import AuthenticationServices

@Observable
@MainActor
final class AuthManager {
    var session: Session?
    var profile: DBProfile?
    var proProfile: DBProProfile?
    var isLoading = true

    var isSignedIn: Bool { session != nil }
    var userId: UUID? { session?.user.id }
    var isPro: Bool { profile?.role == "pro" && proProfile != nil }

    init() {
        Task { await bootstrap() }
    }

    // MARK: - Bootstrap

    private func bootstrap() async {
        do {
            session = try await AppSupabase.client.auth.session
            if let uid = session?.user.id {
                await loadProfile(uid: uid)
            }
        } catch {
            session = nil
        }
        isLoading = false

        // Listen for auth state changes
        Task {
            for await (event, session) in AppSupabase.client.auth.authStateChanges {
                self.session = session
                if let uid = session?.user.id, event == .signedIn {
                    await loadProfile(uid: uid)
                } else if event == .signedOut {
                    profile = nil
                    proProfile = nil
                }
            }
        }
    }

    // MARK: - Sign In with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8)
        else { throw AuthError.missingToken }

        let session = try await AppSupabase.client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: tokenString
            )
        )
        self.session = session

        // Update profile with Apple's name if available
        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !name.isEmpty {
                try await AppSupabase.client
                    .from("profiles")
                    .update(["full_name": name])
                    .eq("id", value: session.user.id.uuidString)
                    .execute()
            }
        }

        await loadProfile(uid: session.user.id)
    }

    // MARK: - Role Selection

    func setRole(_ role: String) async throws {
        guard let uid = userId else { return }

        try await AppSupabase.client
            .from("profiles")
            .update(["role": role])
            .eq("id", value: uid.uuidString)
            .execute()

        if role == "pro" {
            // Create pro_profile if doesn't exist
            let existing: [DBProProfile] = try await AppSupabase.client
                .from("pro_profiles")
                .select()
                .eq("user_id", value: uid.uuidString)
                .execute()
                .value

            if existing.isEmpty {
                try await AppSupabase.client
                    .from("pro_profiles")
                    .insert(["user_id": uid.uuidString, "category": "hair"])
                    .execute()
            }
        }

        await loadProfile(uid: uid)
    }

    // MARK: - Email/Password Auth

    func signUpWithEmail(email: String, password: String, name: String) async throws {
        let session = try await AppSupabase.client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)]
        ).session

        self.session = session

        // Update profile name
        if let uid = session?.user.id, !name.isEmpty {
            try await AppSupabase.client
                .from("profiles")
                .update(["full_name": name])
                .eq("id", value: uid.uuidString)
                .execute()
            await loadProfile(uid: uid)
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        let session = try await AppSupabase.client.auth.signIn(
            email: email,
            password: password
        )
        self.session = session
        await loadProfile(uid: session.user.id)
    }

    // MARK: - Sign Out

    func signOut() async throws {
        try await AppSupabase.client.auth.signOut()
        session = nil
        profile = nil
        proProfile = nil
    }

    // MARK: - Load Profile

    private func loadProfile(uid: UUID) async {
        do {
            let profiles: [DBProfile] = try await AppSupabase.client
                .from("profiles")
                .select()
                .eq("id", value: uid.uuidString)
                .execute()
                .value
            profile = profiles.first

            if profile?.role == "pro" {
                let proProfiles: [DBProProfile] = try await AppSupabase.client
                    .from("pro_profiles")
                    .select()
                    .eq("user_id", value: uid.uuidString)
                    .execute()
                    .value
                proProfile = proProfiles.first
            }
        } catch {
            print("Failed to load profile: \(error)")
        }
    }
}

enum AuthError: Error {
    case missingToken
}
