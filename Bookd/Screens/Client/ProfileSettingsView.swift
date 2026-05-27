import SwiftUI

struct ProfileSettingsView: View {
    let onSwitchToPro: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile card
                profileHeader

                // Switch to Pro
                proModeCard

                // Settings sections
                settingsSections
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("You")
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 14) {
            AvatarView(palette: SampleData.me.avatarPalette, size: 64, name: SampleData.me.name)
            VStack(alignment: .leading, spacing: 2) {
                Text("Jordan Mendez")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.4)
                Text("\(SampleData.me.handle) · 8 bookings")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Button("Edit profile") { }
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
            settingsGroup(title: "ACCOUNT", items: [
                SettingsRow(icon: "person", label: "Personal info"),
                SettingsRow(icon: "creditcard", label: "Payment methods", detail: "Apple Pay, Visa •• 4982"),
                SettingsRow(icon: "bell", label: "Notifications"),
            ])

            settingsGroup(title: "PREFERENCES", items: [
                SettingsRow(icon: "mappin", label: "Location", detail: "Brooklyn, NY"),
                SettingsRow(icon: "calendar", label: "Calendar sync", detail: "iOS Calendar"),
                SettingsRow(icon: "eye", label: "Privacy"),
            ])

            settingsGroup(title: "SUPPORT", items: [
                SettingsRow(icon: "bubble.right", label: "Help center"),
                SettingsRow(icon: "tray", label: "Send feedback"),
            ])

            Text("Bookd 1.0 · Built with care")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
        .padding(.top, 18)
    }

    private func settingsGroup(title: String, items: [SettingsRow]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.label) { idx, item in
                    HStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14))
                            .frame(width: 28, height: 28)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                        Text(item.label)
                            .font(.system(size: 14.5, weight: .medium))
                        Spacer()
                        if let detail = item.detail {
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

                    if idx < items.count - 1 {
                        Divider().padding(.leading, 54)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
    }
}

private struct SettingsRow {
    let icon: String
    let label: String
    var detail: String? = nil
}
