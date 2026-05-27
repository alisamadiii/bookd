import SwiftUI

struct ProProfileView: View {
    let onSwitchToClient: () -> Void

    private let pro = SampleData.mePro

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile preview card
                profilePreview

                // Switch to client
                switchCard

                // Business settings
                businessSettings
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: { Image(systemName: "gearshape") }
            }
        }
    }

    // MARK: - Profile Preview

    private var profilePreview: some View {
        VStack(spacing: 0) {
            // Cover
            MeshGradientImage(palette: pro.palette, seed: 3)
                .frame(height: 110)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 12) {
                    AvatarView(palette: pro.palette.reversed(), size: 72, name: pro.name, showRing: true)
                        .offset(y: -20)
                    Spacer()
                    Button { } label: {
                        Label("Preview public", systemImage: "eye")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                HStack(spacing: 6) {
                    Text(pro.name)
                        .font(.system(size: 22, weight: .heavy))
                        .tracking(-0.4)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.bookdAccent)
                }
                .padding(.top, -8)

                Text(pro.role)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                HStack(spacing: 18) {
                    VStack(alignment: .leading) {
                        Text("★ \(String(format: "%.2f", pro.rating))")
                            .font(.system(size: 16, weight: .heavy))
                        Text("Rating")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text(pro.followers)
                            .font(.system(size: 16, weight: .heavy))
                        Text("Followers")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text("1.2k")
                            .font(.system(size: 16, weight: .heavy))
                        Text("Bookings")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 14)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
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
            .background(.quaternary, in: RoundedRectangle(cornerRadius: BookdRadius.lg))
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // MARK: - Business Settings

    private var businessSettings: some View {
        let items: [(icon: String, label: String, detail: String?)] = [
            ("pencil", "Edit profile", "Bio, photos, services"),
            ("calendar", "Working hours", nil),
            ("dollarsign", "Payouts", "Stripe · Daily"),
            ("chart.line.uptrend.xyaxis", "Analytics", nil),
            ("star", "Reviews & ratings", nil),
        ]

        return VStack(alignment: .leading, spacing: 8) {
            Text("BUSINESS")
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
        .padding(.top, 18)
    }
}
