import SwiftUI
import AuthenticationServices

struct RoleSelectView: View {
    let onPick: (String) -> Void

    @State private var picked: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("How do you\nplan to use Bookd?")
                    .font(.system(size: 36, weight: .heavy))
                    .tracking(-1)
                    .padding(.top, 4)

                Text("You can always switch later.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                // Role cards
                VStack(spacing: 14) {
                    roleCard(
                        id: "client",
                        title: "I'm a client",
                        subtitle: "Discover pros · Book in seconds",
                        palette: ["#FF7A59", "#FFB259", "#FFE0C4"],
                        rotation: -3
                    )
                    roleCard(
                        id: "pro",
                        title: "I'm a pro",
                        subtitle: "Showcase work · Get bookings",
                        palette: ["#6C5CE7", "#B385FF", "#FFD86B"],
                        rotation: 3
                    )
                }
                .padding(.top, 20)

                // Auth divider
                HStack(spacing: 10) {
                    Rectangle().fill(.separator).frame(height: 0.5)
                    Text("CONTINUE WITH")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(.tertiary)
                    Rectangle().fill(.separator).frame(height: 0.5)
                }
                .padding(.top, 28)

                // Auth buttons
                VStack(spacing: 10) {
                    SignInWithAppleButton(.continue) { _ in } onCompletion: { _ in
                        if picked != nil { onPick(picked!) }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .clipShape(Capsule())

                    Button {
                        if let p = picked { onPick(p) }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope")
                            Text("Email or phone")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Capsule())
                }
                .padding(.top, 14)

                Text("By continuing you agree to Bookd's Terms · Privacy\nand consent to receive booking texts.")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func roleCard(id: String, title: String, subtitle: String, palette: [String], rotation: Double) -> some View {
        let isSelected = picked == id

        Button {
            withAnimation(.spring(duration: 0.3)) {
                picked = id
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                MeshGradientImage(palette: palette, seed: id.count)

                LinearGradient(colors: [.clear, .black.opacity(0.45)],
                               startPoint: .init(x: 0.5, y: 0.4), endPoint: .bottom)

                // Selection indicator
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.bookdAccent : .white.opacity(0.4))
                                .frame(width: 28, height: 28)
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .background(.ultraThinMaterial, in: Circle())
                    }
                    Spacer()
                }
                .padding(16)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 30, weight: .heavy))
                        .tracking(-0.6)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(20)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: BookdRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BookdRadius.lg)
                    .strokeBorder(isSelected ? Color.bookdAccent : .clear, lineWidth: 2.5)
            )
            .shadow(color: isSelected ? .bookdAccent.opacity(0.25) : .black.opacity(0.06),
                    radius: isSelected ? 15 : 12, y: isSelected ? 6 : 4)
            .scaleEffect(isSelected ? 1.01 : 1)
        }
        .buttonStyle(.plain)
    }
}
