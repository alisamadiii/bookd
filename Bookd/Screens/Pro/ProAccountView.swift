import SwiftUI

struct ProAccountView: View {
    let onSwitchToClient: () -> Void

    @Environment(AuthManager.self) private var authManager
    @State private var showPreview = false
    @State private var showSettings = false

    private var proProfile: DBProProfile? { authManager.proProfile }
    private var profile: DBProfile? { authManager.profile }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profilePreview
                switchCard
                    .padding(.horizontal, 16)
                businessSettings
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showPreview) {
            if let proId = proProfile?.id {
                ProDetailView(proId: proId.uuidString, onBook: { _, _ in }, onMessage: { _ in })
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                ProSettingsView()
            }
        }
    }

    // MARK: - Profile Preview

    private var profilePreview: some View {
        let palette = profile?.palette?.isEmpty == false ? profile!.palette! : ["#6C5CE7", "#FFB259"]
        let displayName = proProfile?.businessName ?? profile?.fullName ?? "User"
        // Pro avatar only — no fallback to client avatar
        let proAvatarUrl = proProfile?.avatarUrl

        return VStack(spacing: 0) {
            // Cover — full width, stretches on overscroll (Twitter-style)
            GeometryReader { geo in
                let minY = geo.frame(in: .scrollView).minY
                let isStretching = minY > 0
                let height: CGFloat = 180 + (isStretching ? minY : 0)

                ZStack(alignment: .topTrailing) {
                    if let coverUrl = proProfile?.coverUrl, !coverUrl.isEmpty, let url = URL(string: coverUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                MeshGradientImage(palette: palette, seed: 3)
                            }
                        }
                    } else {
                        MeshGradientImage(palette: palette, seed: 3)
                    }

                    // Settings gear on cover
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.top, 54)
                    .padding(.trailing, 16)
                }
                .frame(width: geo.size.width, height: height)
                .clipped()
                .offset(y: isStretching ? -minY : 0)
            }
            .frame(height: 180)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 12) {
                    ProfileAvatarView(
                        avatarUrl: proAvatarUrl,
                        palette: palette,
                        name: displayName,
                        size: 72,
                        showRing: true
                    )
                    .offset(y: -20)
                    Spacer()
                    Button { showPreview = true } label: {
                        Label("Preview public", systemImage: "eye")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                HStack(spacing: 6) {
                    Text(displayName)
                        .font(.system(size: 22, weight: .heavy))
                        .tracking(-0.4)
                    if proProfile?.verified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.bookdProAccent)
                    }
                }
                .padding(.top, -8)

                if let roleTitle = proProfile?.roleTitle ?? proProfile?.category {
                    Text(roleTitle.localizedCapitalized)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 18) {
                    statColumn(value: String(format: "%.2f", proProfile?.rating ?? 0), label: "Rating", prefix: "★ ")
                    statColumn(value: formatCount(proProfile?.followersCount ?? 0), label: "Followers")
                    statColumn(value: formatCount(proProfile?.reviewsCount ?? 0), label: "Reviews")
                }
                .padding(.top, 14)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
    }

    private func statColumn(value: String, label: String, prefix: String = "") -> some View {
        VStack(alignment: .leading) {
            Text("\(prefix)\(value)")
                .font(.system(size: 16, weight: .heavy))
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }

    private func formatCount(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.1fk", Double(n) / 1000) }
        return "\(n)"
    }

    // MARK: - Switch

    private var switchCard: some View {
        Button(action: onSwitchToClient) {
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.primary, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Switch to client mode")
                        .font(.system(size: 14, weight: .bold))
                    Text("Discover, book, follow other pros")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .contentShape(Rectangle())
            .background(.quaternary, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // MARK: - Business Settings

    private var businessSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BUSINESS")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                NavigationLink(destination: EditProProfileView()) {
                    businessRow(icon: "pencil", label: "Edit profile", detail: "Bio, photos, services")
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 54)

                NavigationLink(destination: WorkingHoursView()) {
                    businessRow(icon: "calendar", label: "Working hours")
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 54)

                NavigationLink(destination: PayoutsView()) {
                    businessRow(icon: "dollarsign", label: "Payouts", detail: proProfile?.stripeOnboarded == true ? "Stripe · Daily" : "Not connected")
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 54)

                NavigationLink(destination: ProAnalyticsView()) {
                    businessRow(icon: "chart.line.uptrend.xyaxis", label: "Analytics")
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 54)

                NavigationLink(destination: ReviewsListView()) {
                    businessRow(icon: "star", label: "Reviews & ratings", detail: proProfile.map { "\(String(format: "%.1f", $0.rating)) ★" })
                }
                .buttonStyle(.plain)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
        .padding(.top, 18)
    }

    private func businessRow(icon: String, label: String, detail: String? = nil) -> some View {
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
        .contentShape(Rectangle())
    }
}

// MARK: - Pro Settings (gear icon)

struct ProSettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutAlert = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Text("Name")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(authManager.profile?.fullName ?? "—")
                }
                HStack {
                    Text("Email")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(authManager.profile?.email ?? authManager.session?.user.email ?? "—")
                }
            }
            .font(.system(size: 14.5))

            Section {
                Button("Sign out", role: .destructive) {
                    showSignOutAlert = true
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .alert("Sign out?", isPresented: $showSignOutAlert) {
            Button("Sign out", role: .destructive) {
                Task {
                    do { try await authManager.signOut() }
                    catch { errorMessage = error.localizedDescription }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You'll need to sign in again to access your account.")
        }
        .errorAlert($errorMessage)
    }
}
