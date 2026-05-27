import SwiftUI
import PhotosUI

struct ProfileSettingsView: View {
    let onSwitchToPro: () -> Void

    @Environment(AuthManager.self) private var authManager
    @State private var showEditProfile = false
    @State private var showPersonalInfo = false
    @State private var showSignOutAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                proModeCard
                settingsSections
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("You")
        .sheet(isPresented: $showEditProfile) {
            NavigationStack {
                EditProfileView()
            }
        }
        .sheet(isPresented: $showPersonalInfo) {
            NavigationStack {
                PersonalInfoView()
            }
        }
        .alert("Sign out?", isPresented: $showSignOutAlert) {
            Button("Sign out", role: .destructive) {
                Task { try? await authManager.signOut() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You'll need to sign in again to access your account.")
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 14) {
            if let avatarUrl = authManager.profile?.avatarUrl, !avatarUrl.isEmpty {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    AvatarView(palette: authManager.profile?.palette ?? ["#6C5CE7", "#FFB259"], size: 64, name: authManager.profile?.fullName ?? "")
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
            } else {
                AvatarView(palette: authManager.profile?.palette ?? ["#6C5CE7", "#FFB259"], size: 64, name: authManager.profile?.fullName ?? "")
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(authManager.profile?.fullName ?? "User")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.4)

                if let handle = authManager.profile?.handle {
                    Text("@\(handle)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                } else if let email = authManager.profile?.email {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Button("Edit profile") {
                        showEditProfile = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.bookdAccent)

                    Button("Share") { }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
    }

    // MARK: - Pro Mode Card

    private var proModeCard: some View {
        Button {
            onSwitchToPro()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.bookdAccent, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Switch to Pro mode")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.bookdAccent)
                    Text("Manage clients, hours and earnings")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.bookdAccent)
            }
            .padding(14)
            .background(Color.bookdAccentSoft, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // MARK: - Settings

    private var settingsSections: some View {
        VStack(spacing: 18) {
            // Account
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("ACCOUNT")

                VStack(spacing: 0) {
                    settingsButton(icon: "person", label: "Personal info") {
                        showPersonalInfo = true
                    }
                    Divider().padding(.leading, 54)
                    settingsRow(icon: "creditcard", label: "Payment methods", detail: "Not set up")
                    Divider().padding(.leading, 54)
                    settingsRow(icon: "bell", label: "Notifications")
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }

            // Preferences
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("PREFERENCES")

                VStack(spacing: 0) {
                    settingsRow(icon: "mappin", label: "Location")
                    Divider().padding(.leading, 54)
                    settingsRow(icon: "calendar", label: "Calendar sync")
                    Divider().padding(.leading, 54)
                    settingsRow(icon: "eye", label: "Privacy")
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }

            // Support
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("SUPPORT")

                VStack(spacing: 0) {
                    settingsRow(icon: "bubble.right", label: "Help center")
                    Divider().padding(.leading, 54)
                    settingsRow(icon: "tray", label: "Send feedback")
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }

            // Sign Out
            Button {
                showSignOutAlert = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 14))
                        .frame(width: 28, height: 28)
                        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.red)
                    Text("Sign out")
                        .font(.system(size: 14.5, weight: .medium))
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
            }
            .buttonStyle(.plain)

            Text("Bookd 1.0 · Built with care")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
        .padding(.top, 18)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .tracking(1)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 4)
    }

    private func settingsRow(icon: String, label: String, detail: String? = nil) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .frame(width: 28, height: 28)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            Text(label)
                .font(.system(size: 14.5, weight: .medium))
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func settingsButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRow(icon: icon, label: label)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var handle = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var avatarData: Data?
    @State private var isSaving = false

    var body: some View {
        Form {
            // Avatar
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        if let avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                        } else if let avatarUrl = authManager.profile?.avatarUrl, !avatarUrl.isEmpty {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                AvatarView(palette: authManager.profile?.palette ?? ["#6C5CE7"], size: 96, name: fullName)
                            }
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                        } else {
                            AvatarView(palette: authManager.profile?.palette ?? ["#6C5CE7"], size: 96, name: fullName)
                        }

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Change photo")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.bookdAccent)
                        }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

            // Info
            Section("Name") {
                TextField("Full name", text: $fullName)
            }

            Section("Handle") {
                HStack(spacing: 4) {
                    Text("@")
                        .foregroundStyle(.secondary)
                    TextField("username", text: $handle)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .fontWeight(.bold)
                .disabled(isSaving || fullName.isEmpty)
            }
        }
        .onAppear {
            fullName = authManager.profile?.fullName ?? ""
            handle = authManager.profile?.handle ?? ""
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    avatarData = data
                    if let uiImage = UIImage(data: data) {
                        avatarImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }

    private func save() async {
        guard let uid = authManager.userId else { return }
        isSaving = true

        do {
            // Upload avatar if changed
            var avatarUrl = authManager.profile?.avatarUrl
            if let data = avatarData {
                avatarUrl = try await dataService.uploadAvatar(userId: uid, imageData: data)
            }

            // Update profile
            var updates: [String: String] = [
                "full_name": fullName,
            ]
            if !handle.isEmpty {
                updates["handle"] = handle.lowercased()
            }
            if let avatarUrl {
                updates["avatar_url"] = avatarUrl
            }

            try await AppSupabase.client
                .from("profiles")
                .update(updates)
                .eq("id", value: uid.uuidString)
                .execute()

            // Refresh profile in auth manager
            authManager.profile?.fullName = fullName
            authManager.profile?.handle = handle.lowercased()
            if let avatarUrl {
                authManager.profile?.avatarUrl = avatarUrl
            }

            dismiss()
        } catch {
            print("Failed to save profile: \(error)")
        }

        isSaving = false
    }
}

// MARK: - Personal Info View

struct PersonalInfoView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Account") {
                infoRow(label: "Name", value: authManager.profile?.fullName ?? "—")
                infoRow(label: "Email", value: authManager.profile?.email ?? authManager.session?.user.email ?? "—")
                infoRow(label: "Handle", value: authManager.profile?.handle.map { "@\($0)" } ?? "Not set")
                infoRow(label: "Phone", value: authManager.profile?.phone ?? "Not set")
            }

            Section("Membership") {
                infoRow(label: "Role", value: authManager.profile?.role.capitalized ?? "Client")
                if let date = authManager.profile?.createdAt {
                    infoRow(label: "Member since", value: date.formatted(.dateTime.month(.wide).year()))
                }
                infoRow(label: "User ID", value: String(authManager.userId?.uuidString.prefix(8) ?? "—") + "...")
            }
        }
        .navigationTitle("Personal info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.system(size: 14.5))
    }
}
