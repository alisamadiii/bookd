import SwiftUI
import PhotosUI

struct ClientAccountView: View {
    let onSwitchToPro: () -> Void

    @Environment(AuthManager.self) private var authManager
    @State private var showEditProfile = false
    @State private var showPersonalInfo = false
    @State private var showSignOutAlert = false
    @State private var errorMessage: String?

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
                Task {
                    do {
                        try await authManager.signOut()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You'll need to sign in again to access your account.")
        }
        .errorAlert($errorMessage)
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 14) {
            ProfileAvatarView(
                avatarUrl: authManager.profile?.avatarUrl,
                palette: authManager.profile?.palette ?? [],
                name: authManager.profile?.fullName ?? "",
                size: 64
            )

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
            .contentShape(Rectangle())
            .background(Color.bookdAccentSoft, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // MARK: - Settings

    private var settingsSections: some View {
        VStack(spacing: 18) {
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
                .contentShape(Rectangle())
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
    @State private var errorMessage: String?

    var body: some View {
        Form {
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
                        } else {
                            ProfileAvatarView(
                                avatarUrl: authManager.profile?.avatarUrl,
                                palette: authManager.profile?.palette ?? [],
                                name: fullName,
                                size: 96
                            )
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
                if isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task { await save() }
                    }
                    .fontWeight(.bold)
                    .disabled(fullName.isEmpty)
                }
            }
        }
        .onAppear {
            fullName = authManager.profile?.fullName ?? ""
            handle = authManager.profile?.handle ?? ""
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                do {
                    guard let item else { return }
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        errorMessage = "Could not load the selected image."
                        return
                    }
                    // Convert to JPEG for upload compatibility
                    guard let uiImage = UIImage(data: data),
                          let jpegData = uiImage.jpegData(compressionQuality: 0.85) else {
                        errorMessage = "Could not process the selected image."
                        return
                    }
                    avatarData = jpegData
                    avatarImage = Image(uiImage: uiImage)
                } catch {
                    errorMessage = "Failed to load photo: \(error.localizedDescription)"
                }
            }
        }
        .errorAlert($errorMessage)
    }

    private func save() async {
        guard let uid = authManager.userId else { return }
        isSaving = true

        do {
            // Step 1: Upload avatar if changed
            var newAvatarUrl: String?
            if let data = avatarData {
                do {
                    newAvatarUrl = try await dataService.uploadAvatar(userId: uid, imageData: data)
                } catch {
                    errorMessage = "Avatar upload failed: \(error.localizedDescription)"
                    isSaving = false
                    return
                }
            }

            // Step 2: Build profile update
            var updates: [String: String] = [
                "full_name": fullName,
            ]
            // Only send handle if it's valid (3+ chars, alphanumeric)
            let trimmedHandle = handle.lowercased().trimmingCharacters(in: .whitespaces)
            if trimmedHandle.count >= 3 {
                updates["handle"] = trimmedHandle
            }
            if let url = newAvatarUrl {
                updates["avatar_url"] = url
            }

            // Step 3: Update profile in DB
            try await AppSupabase.client
                .from("profiles")
                .update(updates)
                .eq("id", value: uid.uuidString)
                .execute()

            // Step 4: Refresh local state
            authManager.profile?.fullName = fullName
            if trimmedHandle.count >= 3 {
                authManager.profile?.handle = trimmedHandle
            }
            if let url = newAvatarUrl {
                // Append cache-buster so AsyncImage reloads the new image
                let cacheBusted = url.contains("?") ? "\(url)&v=\(Int(Date().timeIntervalSince1970))" : "\(url)?v=\(Int(Date().timeIntervalSince1970))"
                authManager.profile?.avatarUrl = cacheBusted

                // Also update in DB with cache-busted URL
                try await AppSupabase.client
                    .from("profiles")
                    .update(["avatar_url": cacheBusted])
                    .eq("id", value: uid.uuidString)
                    .execute()
            }

            dismiss()
        } catch {
            errorMessage = "Profile update failed: \(error.localizedDescription)"
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
