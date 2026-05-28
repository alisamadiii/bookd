import SwiftUI
import PhotosUI

struct EditProProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(DataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss

    @State private var businessName = ""
    @State private var roleTitle = ""
    @State private var bio = ""
    @State private var category = "hair"
    @State private var city = ""

    @State private var selectedCoverPhoto: PhotosPickerItem?
    @State private var coverImage: Image?
    @State private var coverData: Data?

    @State private var selectedAvatarPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var avatarData: Data?

    @State private var isSaving = false
    @State private var errorMessage: String?

    private var proProfile: DBProProfile? { authManager.proProfile }
    private var profile: DBProfile? { authManager.profile }

    var body: some View {
        Form {
            coverSection
            avatarSection
            businessInfoSection
            categorySection
            bioSection
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Save") { Task { await save() } }
                        .fontWeight(.bold)
                        .disabled(businessName.isEmpty)
                }
            }
        }
        .onAppear { populateFields() }
        .onChange(of: selectedCoverPhoto) { _, item in
            Task { await loadPhoto(item: item, setImage: { coverImage = $0 }, setData: { coverData = $0 }) }
        }
        .onChange(of: selectedAvatarPhoto) { _, item in
            Task { await loadPhoto(item: item, setImage: { avatarImage = $0 }, setData: { avatarData = $0 }) }
        }
        .errorAlert($errorMessage)
    }

    // MARK: - Sections

    private var coverSection: some View {
        Section {
            VStack(spacing: 12) {
                if let coverImage {
                    coverImage
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: BookdRadius.sm))
                } else if let coverUrl = proProfile?.coverUrl, let url = URL(string: coverUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            MeshGradientImage(palette: profile?.palette ?? ["#6C5CE7", "#FFB259"], seed: 3)
                        }
                    }
                    .frame(height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: BookdRadius.sm))
                } else {
                    MeshGradientImage(palette: profile?.palette ?? ["#6C5CE7", "#FFB259"], seed: 3)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: BookdRadius.sm))
                }

                PhotosPicker(selection: $selectedCoverPhoto, matching: .images) {
                    Text("Change cover")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.bookdProAccent)
                }
            }
        } header: {
            Text("Cover photo")
        }
    }

    private var avatarSection: some View {
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
                            avatarUrl: profile?.avatarUrl,
                            palette: profile?.palette ?? [],
                            name: profile?.fullName ?? "",
                            size: 96
                        )
                    }

                    PhotosPicker(selection: $selectedAvatarPhoto, matching: .images) {
                        Text("Change photo")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.bookdProAccent)
                    }
                }
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
    }

    private var businessInfoSection: some View {
        Section("Business info") {
            TextField("Business name", text: $businessName)
            TextField("Role title (e.g. Hair stylist)", text: $roleTitle)
            TextField("City", text: $city)
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $category) {
                ForEach(ProCategory.all.filter { $0.id != "all" }) { cat in
                    Label(cat.label, systemImage: cat.systemImage)
                        .tag(cat.id)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var bioSection: some View {
        Section("Bio") {
            TextEditor(text: $bio)
                .frame(minHeight: 100)
        }
    }

    // MARK: - Helpers

    private func populateFields() {
        businessName = proProfile?.businessName ?? ""
        roleTitle = proProfile?.roleTitle ?? ""
        bio = proProfile?.bio ?? ""
        category = proProfile?.category ?? "hair"
        city = proProfile?.city ?? ""
    }

    private func loadPhoto(item: PhotosPickerItem?, setImage: @escaping (Image) -> Void, setData: @escaping (Data) -> Void) async {
        do {
            guard let item else { return }
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "Could not load the selected image."
                return
            }
            guard let uiImage = UIImage(data: data),
                  let jpegData = uiImage.jpegData(compressionQuality: 0.85) else {
                errorMessage = "Could not process the selected image."
                return
            }
            setData(jpegData)
            setImage(Image(uiImage: uiImage))
        } catch {
            errorMessage = "Failed to load photo: \(error.localizedDescription)"
        }
    }

    private func save() async {
        guard let proId = proProfile?.id,
              let uid = authManager.userId else { return }
        isSaving = true

        do {
            // Upload cover if changed
            var newCoverUrl: String?
            if let data = coverData {
                newCoverUrl = try await dataService.uploadCover(userId: uid, imageData: data)
            }

            // Upload avatar if changed
            var newAvatarUrl: String?
            if let data = avatarData {
                newAvatarUrl = try await dataService.uploadAvatar(userId: uid, imageData: data)
            }

            // Update pro profile fields
            var fields: [String: String] = [
                "business_name": businessName,
                "category": category,
                "bio": bio,
                "city": city,
            ]
            if !roleTitle.isEmpty { fields["role_title"] = roleTitle }
            if let url = newCoverUrl { fields["cover_url"] = url }

            try await dataService.updateProProfile(proId: proId, fields: fields)

            // Update avatar on user profile if changed
            if let url = newAvatarUrl {
                let cacheBusted = url.contains("?") ? "\(url)&v=\(Int(Date().timeIntervalSince1970))" : "\(url)?v=\(Int(Date().timeIntervalSince1970))"
                try await AppSupabase.client
                    .from("profiles")
                    .update(["avatar_url": cacheBusted])
                    .eq("id", value: uid.uuidString)
                    .execute()
            }

            // Refresh local state
            await authManager.reloadProfile()
            dismiss()
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }

        isSaving = false
    }
}
